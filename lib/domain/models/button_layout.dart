class ButtonLayout {
  final String id;
  final String label;
  final num x;
  final num y;
  final num width;
  final num height;
  const ButtonLayout({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  ButtonLayout copyWith({
    String? id,
    String? label,
    num? x,
    num? y,
    num? width,
    num? height,
  }) {
    return ButtonLayout(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }


}
