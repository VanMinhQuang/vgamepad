import 'package:app_controller/domain/models/gamepad_layout.dart';

abstract class GamepadConfigRepo {
  Future<void> saveLayout(GamepadLayout layout);
  Future<GamepadLayout?> getLayout();
  Future<void> updateLayout(GamepadLayout layout);
}
