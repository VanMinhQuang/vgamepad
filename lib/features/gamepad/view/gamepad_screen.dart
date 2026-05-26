import 'dart:async';
import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/route.dart';
import 'package:app_controller/app/styles.dart';
import 'package:app_controller/features/gamepad/data/gamepad_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vibration/vibration.dart';

class GamepadScreen extends StatefulWidget {
  final GamepadConnection connection;

  const GamepadScreen({super.key, required this.connection});

  @override
  State<GamepadScreen> createState() => _GamepadScreenState();
}

class _GamepadScreenState extends State<GamepadScreen> {
  bool? _canVibrate;

  void _send(Map<String, dynamic> data) {
    widget.connection.send(data);
  }

  void _sendButton(String action, bool pressed) {
    if (pressed) {
      unawaited(_vibratePress());
    }

    _send({'action': action, 'value': pressed ? 1 : 0});
  }

  void _sendJoystick(String side, double x, double y) {
    _send({'action': 'joystick_$side', 'x': x, 'y': y});
  }

  Future<void> _vibratePress() async {
    try {
      final canVibrate = _canVibrate ??= await Vibration.hasVibrator();
      if (!canVibrate) return;

      await Vibration.vibrate(duration: 18, amplitude: 96);
    } catch (_) {
      // Vibration support differs by device/API; controller input should never fail because of haptics.
    }
  }

  @override
  void dispose() {
    widget.connection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.25,
              colors: [context.primary.withOpacity(0.22), context.background],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.outline.withOpacity(0.16),
                        width: 1.5.r,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18.dp,
                bottom: 24.dp,
                child: Joystick(
                  mode: JoystickMode.all,
                  base: _joystickBase(context),
                  stick: _joystickStick(context),
                  listener: (d) => _sendJoystick('left', d.x, d.y),
                ),
              ),
              Positioned(
                right: 18.dp,
                bottom: 24.dp,
                child: Joystick(
                  mode: JoystickMode.all,
                  base: _joystickBase(context),
                  stick: _joystickStick(context),
                  listener: (d) => _sendJoystick('right', d.x, d.y),
                ),
              ),
              Positioned(
                left: 50.dp,
                top: 100.dp,
                child: _DPad(onPress: _sendButton),
              ),
              Positioned(
                right: 50.dp,
                top: 100.dp,
                child: _ABXYButtons(onPress: _sendButton),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: _ShoulderButtons(side: 'left', onPress: _sendButton),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: _ShoulderButtons(side: 'right', onPress: _sendButton),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.dp,
                    vertical: 12.dp,
                  ),
                  decoration: BoxDecoration(
                    color: context.surface.withOpacity(0.68),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: context.outline.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24.r,
                        offset: Offset(0, 12.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Controller Pad',
                        style: context.labelSmall.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _menuButton(context, 'SELECT', 'button_select'),
                          SizedBox(width: 18.r),
                          _menuButton(context, 'START', 'button_start'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4.dp,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.textMuted,
                      size: 14.r,
                    ),
                    label: Text(
                      'Disconnect',
                      style: context.labelSmall.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _joystickBase(BuildContext context) => Container(
    width: 132.r,
    height: 132.r,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.card.withOpacity(0.92),
      border: Border.all(color: context.primary.withOpacity(0.45), width: 2.r),
      boxShadow: [
        BoxShadow(
          color: context.primary.withOpacity(0.18),
          blurRadius: 18.r,
          spreadRadius: 2.r,
        ),
      ],
    ),
  );

  Widget _joystickStick(BuildContext context) => Container(
    width: 54.r,
    height: 54.r,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.primary,
      border: Border.all(color: context.onPrimary.withOpacity(0.55)),
      boxShadow: [
        BoxShadow(
          color: context.primary.withOpacity(0.38),
          blurRadius: 14.r,
          spreadRadius: 1.r,
        ),
      ],
    ),
  );

  Widget _menuButton(BuildContext context, String label, String action) {
    return Material(
      color: context.card,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTapDown: (_) => _sendButton(action, true),
        onTapUp: (_) => _sendButton(action, false),
        onTapCancel: () => _sendButton(action, false),
        child: Container(
          width: 108.r,
          height: 42.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: context.primary.withOpacity(0.34)),
          ),
          child: Text(
            label,
            style: context.labelSmall.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  final void Function(String, bool) onPress;

  const _DPad({required this.onPress});

  Widget _btn(BuildContext context, IconData icon, String action) {
    return Material(
      color: context.card.withOpacity(0.95),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTapDown: (_) => onPress(action, true),
        onTapUp: (_) => onPress(action, false),
        onTapCancel: () => onPress(action, false),
        child: Container(
          width: 58.r,
          height: 58.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: context.primary.withOpacity(0.34)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: context.textSecondary, size: 32.r),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(context, Icons.keyboard_arrow_up_rounded, 'dpad_up'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn(context, Icons.keyboard_arrow_left_rounded, 'dpad_left'),
            SizedBox(width: 52.r, height: 52.r),
            _btn(context, Icons.keyboard_arrow_right_rounded, 'dpad_right'),
          ],
        ),
        _btn(context, Icons.keyboard_arrow_down_rounded, 'dpad_down'),
      ],
    );
  }
}

class _ABXYButtons extends StatelessWidget {
  final void Function(String, bool) onPress;

  const _ABXYButtons({required this.onPress});

  Widget _btn(BuildContext context, String label, String action, Color color) {
    return Material(
      color: color.withOpacity(0.88),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTapDown: (_) => onPress(action, true),
        onTapUp: (_) => onPress(action, false),
        onTapCancel: () => onPress(action, false),
        child: Container(
          width: 66.r,
          height: 66.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.24)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.38),
                blurRadius: 12.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: context.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178.r,
      height: 178.r,
      child: Stack(
        children: [
          Positioned(
            left: 56.r,
            top: 0,
            child: _btn(context, 'Y', 'button_y', const Color(0xFFEAB308)),
          ),
          Positioned(
            left: 0,
            top: 56.r,
            child: _btn(context, 'X', 'button_x', const Color(0xFF2563EB)),
          ),
          Positioned(
            left: 112.r,
            top: 56.r,
            child: _btn(context, 'B', 'button_b', const Color(0xFFEF4444)),
          ),
          Positioned(
            left: 56.r,
            top: 112.r,
            child: _btn(context, 'A', 'button_a', const Color(0xFF22C55E)),
          ),
        ],
      ),
    );
  }
}

class _ShoulderButtons extends StatelessWidget {
  final String side;
  final void Function(String, bool) onPress;

  const _ShoulderButtons({required this.side, required this.onPress});

  Widget _btn(BuildContext context, String label, String action) {
    return Padding(
      padding: EdgeInsets.all(4.dp),
      child: Material(
        color: context.card.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTapDown: (_) => onPress(action, true),
          onTapUp: (_) => onPress(action, false),
          onTapCancel: () => onPress(action, false),
          child: Container(
            width: 110.r,
            height: 50.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.primary.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Text(
              label,
              style: context.labelSmall.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = side == 'left';
    return Column(
      children: [
        _btn(context, isLeft ? 'LB' : 'RB', isLeft ? 'button_lb' : 'button_rb'),
        _btn(context, isLeft ? 'LT' : 'RT', isLeft ? 'button_lt' : 'button_rt'),
      ],
    );
  }
}
