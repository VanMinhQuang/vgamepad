import 'package:app_controller/data/models/button_dto.dart';
import 'package:app_controller/domain/models/gamepad_layout.dart';

class GamepadDto {
  final String? name;
  final int? id;

  const GamepadDto({this.id, this.name});

  factory GamepadDto.fromGamepadLayout(GamepadLayout layout) {
    return GamepadDto(id: layout.id, name: layout.name);
  }

  GamepadDto copyWith({int? id, String? name}) {
    return GamepadDto(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name};
  }

  factory GamepadDto.fromMap(Map<String, Object?> map) {
    return GamepadDto(id: map['id'] as int, name: map['name'] as String);
  }

  GamepadLayout toGamepadLayout({required List<ButtonDto> buttons}) =>
      GamepadLayout(
        id: id ?? 0,
        name: name ?? '',
        buttons: buttons.map((button) => button.toButtonLayout()).toList(),
      );
}
