part of 'gamepad_cubit.dart';

enum GamepadStateStatus { init, loading, success, fail }

class GamepadState extends Equatable {
  final GamepadStateStatus status;
  final GamepadLayout layout;

  const GamepadState({
    this.status = GamepadStateStatus.init,
    required this.layout,
  });

  @override
  List<Object> get props => [status, layout];

  GamepadState copyWith({GamepadStateStatus? status, GamepadLayout? layout}) {
    return GamepadState(
      status: status ?? this.status,
      layout: layout ?? this.layout,
    );
  }
}
