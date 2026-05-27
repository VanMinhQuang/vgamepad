import 'package:app_controller/data/datasources/gamepad_config_local_data_source.dart';
import 'package:app_controller/data/models/button_dto.dart';
import 'package:app_controller/data/models/gamepad_dto.dart';
import 'package:app_controller/domain/models/gamepad_layout.dart';
import 'package:app_controller/domain/repository/gamepad_config_repo.dart';

class GamepadConfigImpl implements GamepadConfigRepo {
  final GamepadConfigLocalDataSource _localDataSource;

  const GamepadConfigImpl(this._localDataSource);

  @override
  Future<void> saveLayout(GamepadLayout layout) => _localDataSource.saveLayout(
    layout: GamepadDto.fromGamepadLayout(layout),
    buttons: layout.buttons.map(ButtonDto.fromButtonLayout).toList(),
  );

  @override
  Future<GamepadLayout?> getLayout() async {
    final result = await _localDataSource.getLayout();
    return result?.layout.toGamepadLayout(buttons: result.buttons);
  }

  @override
  Future<void> updateLayout(GamepadLayout layout) => saveLayout(layout);
}
