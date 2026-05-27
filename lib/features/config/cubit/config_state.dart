part of 'config_cubit.dart';

enum ConfigStatus { initial, loading, ready, saving, saved, error }

sealed class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object> get props => [];
}

final class ConfigInitial extends ConfigState {
  const ConfigInitial();
}

final class ConfigLayoutState extends ConfigState {
  final ConfigStatus status;
  final GamepadLayout layout;
  final String errorMessage;

  const ConfigLayoutState({
    required this.status,
    required this.layout,
    this.errorMessage = '',
  });

  ConfigLayoutState copyWith({
    ConfigStatus? status,
    GamepadLayout? layout,
    String? errorMessage,
  }) {
    return ConfigLayoutState(
      status: status ?? this.status,
      layout: layout ?? this.layout,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, layout, errorMessage];
}
