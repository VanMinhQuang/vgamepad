import 'package:app_controller/domain/enum/button_enum.dart';
import 'package:app_controller/domain/models/button_layout.dart';

class GamepadLayout {
  final int id;
  final String name;
  final List<ButtonLayout> buttons;

  GamepadLayout({required this.id, required this.name, required this.buttons});

  GamepadLayout copyWith({int? id, String? name, List<ButtonLayout>? buttons}) {
    return GamepadLayout(
      id: id ?? this.id,
      name: name ?? this.name,
      buttons: buttons ?? this.buttons,
    );
  }

  static final defaultLayout = GamepadLayout(
    id: 1,
    name: 'Default',
    buttons: [
      // Shoulder buttons ─ left
      ButtonLayout(
        id: ButtonEnum.lb.name,
        label: 'LB',
        x: 0.01,
        y: 0.02,
        width: 110,
        height: 50,
      ),
      ButtonLayout(
        id: ButtonEnum.lt.name,
        label: 'LT',
        x: 0.01,
        y: 0.16,
        width: 110,
        height: 50,
      ),
      // Shoulder buttons ─ right
      ButtonLayout(
        id: ButtonEnum.rb.name,
        label: 'RB',
        x: 0.78,
        y: 0.02,
        width: 110,
        height: 50,
      ),
      ButtonLayout(
        id: ButtonEnum.rt.name,
        label: 'RT',
        x: 0.78,
        y: 0.16,
        width: 110,
        height: 50,
      ),
      // D-Pad (group anchor; individual arrows are drawn by _DPad)
      ButtonLayout(
        id: ButtonEnum.dpad.name,
        label: 'D-Pad',
        x: 0.055,
        y: 0.30,
        width: 174,
        height: 174,
      ),
      // ABXY
      ButtonLayout(
        id: ButtonEnum.abxy.name,
        label: 'ABXY',
        x: 0.60,
        y: 0.28,
        width: 178,
        height: 178,
      ),
      // Joysticks
      ButtonLayout(
        id: ButtonEnum.jLeft.name,
        label: 'L-Stick',
        x: 0.02,
        y: 0.55,
        width: 132,
        height: 132,
      ),
      ButtonLayout(
        id: ButtonEnum.l3.name,
        label: 'L3',
        x: 0.18,
        y: 0.70,
        width: 64,
        height: 42,
      ),
      ButtonLayout(
        id: ButtonEnum.jRight.name,
        label: 'R-Stick',
        x: 0.72,
        y: 0.55,
        width: 132,
        height: 132,
      ),
      ButtonLayout(
        id: ButtonEnum.r3.name,
        label: 'R3',
        x: 0.62,
        y: 0.70,
        width: 64,
        height: 42,
      ),
      // Menu buttons
      ButtonLayout(
        id: ButtonEnum.select.name,
        label: 'SELECT',
        x: 0.36,
        y: 0.38,
        width: 108,
        height: 42,
      ),
      ButtonLayout(
        id: ButtonEnum.start.name,
        label: 'START',
        x: 0.52,
        y: 0.38,
        width: 108,
        height: 42,
      ),
    ],
  );
}
