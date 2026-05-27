import 'package:app_controller/domain/models/button_layout.dart';

class ButtonDto {
  final String? id;
  final String? label;
  final num? x;
  final num? y;
  final num? width;
  final num? height;

  const ButtonDto({
    this.id,
    this.label,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  factory ButtonDto.fromButtonLayout(ButtonLayout layout) {
    return ButtonDto(
      id: layout.id,
      label: layout.label,
      x: layout.x,
      y: layout.y,
      width: layout.width,
      height: layout.height,
    );
  }

  ButtonDto copyWith({
    String? id,
    String? label,
    num? x,
    num? y,
    num? width,
    num? height,
  }) {
    return ButtonDto(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, Object?> toMap({required int layoutId}) {
    return {
      'layout_id': layoutId,
      'id': id,
      'label': label,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  factory ButtonDto.fromMap(Map<String, Object?> map) {
    return ButtonDto(
      id: map['id'] as String,
      label: map['label'] as String,
      x: map['x'] as num,
      y: map['y'] as num,
      width: map['width'] as num,
      height: map['height'] as num,
    );
  }

  ButtonLayout toButtonLayout() => ButtonLayout(
    id: id ?? '',
    label: label ?? '',
    x: x ?? 0,
    y: y ?? 0,
    width: width ?? 0,
    height: height ?? 0,
  );
}
