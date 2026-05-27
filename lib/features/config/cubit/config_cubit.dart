import 'dart:math' as math;
import 'dart:ui';

import 'package:app_controller/domain/models/button_layout.dart';
import 'package:app_controller/domain/models/gamepad_layout.dart';
import 'package:app_controller/domain/repository/gamepad_config_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'config_state.dart';

class ConfigCubit extends Cubit<ConfigState> {
  final GamepadConfigRepo _repo;

  ConfigCubit(this._repo) : super(const ConfigInitial());

  Future<void> load() async {
    emit(
      ConfigLayoutState(
        status: ConfigStatus.loading,
        layout: GamepadLayout.defaultLayout,
      ),
    );

    try {
      final layout = _withDefaultButtons(
        await _repo.getLayout() ?? GamepadLayout.defaultLayout,
      );
      emit(ConfigLayoutState(status: ConfigStatus.ready, layout: layout));
    } catch (error) {
      emit(
        ConfigLayoutState(
          status: ConfigStatus.error,
          layout: GamepadLayout.defaultLayout,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  GamepadLayout _withDefaultButtons(GamepadLayout layout) {
    final byId = <String, ButtonLayout>{
      for (final button in layout.buttons) button.id: button,
    };

    return layout.copyWith(
      buttons: [
        for (final button in GamepadLayout.defaultLayout.buttons)
          byId[button.id] ?? button,
      ],
    );
  }

  void reset() {
    emit(
      ConfigLayoutState(
        status: ConfigStatus.ready,
        layout: GamepadLayout.defaultLayout,
      ),
    );
  }

  void transformButton({
    required String id,
    required Size boardSize,
    required ButtonLayout gestureStart,
    required Offset moveDelta,
    required double scale,
  }) {
    final currentState = state;
    if (currentState is! ConfigLayoutState) return;

    final buttons = currentState.layout.buttons;
    final index = buttons.indexWhere((button) => button.id == id);
    if (index == -1) return;

    final current = buttons[index];
    final maxWidth = math.max(48.0, boardSize.width);
    final maxHeight = math.max(36.0, boardSize.height);
    final nextWidth = (gestureStart.width.toDouble() * scale).clamp(
      48.0,
      maxWidth,
    );
    final nextHeight = (gestureStart.height.toDouble() * scale).clamp(
      36.0,
      maxHeight,
    );
    final maxX = math.max(0.0, 1 - nextWidth / boardSize.width);
    final maxY = math.max(0.0, 1 - nextHeight / boardSize.height);
    final nextX = (current.x.toDouble() + moveDelta.dx / boardSize.width)
        .clamp(0.0, maxX);
    final nextY = (current.y.toDouble() + moveDelta.dy / boardSize.height)
        .clamp(0.0, maxY);

    final updated = List<ButtonLayout>.of(buttons);
    updated[index] = current.copyWith(
      x: nextX,
      y: nextY,
      width: nextWidth,
      height: nextHeight,
    );

    emit(
      currentState.copyWith(
        status: ConfigStatus.ready,
        layout: currentState.layout.copyWith(buttons: updated),
        errorMessage: '',
      ),
    );
  }

  Future<void> save() async {
    final currentState = state;
    if (currentState is! ConfigLayoutState) return;

    emit(currentState.copyWith(status: ConfigStatus.saving));
    try {
      await _repo.updateLayout(currentState.layout);
      emit(currentState.copyWith(status: ConfigStatus.saved));
    } catch (error) {
      emit(
        currentState.copyWith(
          status: ConfigStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
