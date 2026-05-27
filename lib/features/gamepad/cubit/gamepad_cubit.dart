import 'package:app_controller/domain/models/button_layout.dart';
import 'package:app_controller/domain/models/gamepad_layout.dart';
import 'package:app_controller/domain/repository/gamepad_config_repo.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'gamepad_state.dart';

class GamepadCubit extends Cubit<GamepadState> {
  GamepadCubit(this._gamepadConfigRepo)
    : super(GamepadState(layout: GamepadLayout.defaultLayout));
  final GamepadConfigRepo _gamepadConfigRepo;

  void init() async {
    emit(state.copyWith(status: GamepadStateStatus.loading));
    final result = await _gamepadConfigRepo.getLayout();
    emit(
      state.copyWith(
        layout: _withDefaultButtons(result ?? GamepadLayout.defaultLayout),
        status: GamepadStateStatus.success,
      ),
    );
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
}
