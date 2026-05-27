import 'dart:async';
import 'dart:math' as math;
import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/route.dart';
import 'package:app_controller/app/styles.dart';
import 'package:app_controller/di/injection.dart';
import 'package:app_controller/domain/enum/button_enum.dart';
import 'package:app_controller/domain/models/button_layout.dart';
import 'package:app_controller/domain/models/gamepad_layout.dart';
import 'package:app_controller/domain/repository/gamepad_config_repo.dart';
import 'package:app_controller/features/gamepad/cubit/gamepad_cubit.dart';
import 'package:app_controller/features/gamepad/data/gamepad_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vibration/vibration.dart';

class GamepadScreen extends StatelessWidget {
  final GamepadConnection connection;
  const GamepadScreen({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GamepadCubit(sl.get<GamepadConfigRepo>())..init(),
      child: GamepadView(connection: connection),
    );
  }
}

class GamepadView extends StatefulWidget {
  final GamepadConnection connection;

  const GamepadView({super.key, required this.connection});

  @override
  State<GamepadView> createState() => _GamepadViewState();
}

class _GamepadViewState extends State<GamepadView> {
  bool? _canVibrate;

  @override
  void initState() {
    super.initState();
  }

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
    final bloc = context.read<GamepadCubit>();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: context.background,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: BlocBuilder<GamepadCubit, GamepadState>(
          builder: (context, state) {
            final layout = state.layout;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.25,
                  colors: [
                    context.primary.withOpacity(0.22),
                    context.background,
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttons = {
                    for (final button in layout.buttons) button.id: button,
                  };
                  ButtonLayout button(ButtonEnum id) =>
                      buttons[id.name] ??
                      GamepadLayout.defaultLayout.buttons.firstWhere(
                        (button) => button.id == id.name,
                      );

                  return Stack(
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
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.jLeft),
                        Joystick(
                          mode: JoystickMode.all,
                          base: _joystickBase(
                            context,
                            button(ButtonEnum.jLeft).width.toDouble(),
                          ),
                          stick: _joystickStick(
                            context,
                            button(ButtonEnum.jLeft).width.toDouble(),
                          ),
                          listener: (d) => _sendJoystick('left', d.x, d.y),
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.jRight),
                        Joystick(
                          mode: JoystickMode.all,
                          base: _joystickBase(
                            context,
                            button(ButtonEnum.jRight).width.toDouble(),
                          ),
                          stick: _joystickStick(
                            context,
                            button(ButtonEnum.jRight).width.toDouble(),
                          ),
                          listener: (d) => _sendJoystick('right', d.x, d.y),
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.dpad),
                        _DPad(
                          width: button(ButtonEnum.dpad).width.toDouble(),
                          height: button(ButtonEnum.dpad).height.toDouble(),
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.abxy),
                        _ABXYButtons(
                          width: button(ButtonEnum.abxy).width.toDouble(),
                          height: button(ButtonEnum.abxy).height.toDouble(),
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.lb),
                        _ShoulderButton(
                          label: 'LB',
                          action: 'button_lb',
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.lt),
                        _ShoulderButton(
                          label: 'LT',
                          action: 'button_lt',
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.l3),
                        _ShoulderButton(
                          label: 'L3',
                          action: 'button_l3',
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.r3),
                        _ShoulderButton(
                          label: 'R3',
                          action: 'button_r3',
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.rb),
                        _ShoulderButton(
                          label: 'RB',
                          action: 'button_rb',
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.rt),
                        _ShoulderButton(
                          label: 'RT',
                          action: 'button_rt',
                          onPress: _sendButton,
                        ),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.select),
                        _menuButton(context, 'SELECT', 'button_select'),
                      ),
                      _positionedControl(
                        constraints,
                        button(ButtonEnum.start),
                        _menuButton(context, 'START', 'button_start'),
                      ),
                      Positioned(
                        top: 4.dp,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Row(
                            spacing: 4.w,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
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
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await context.pushNamed(
                                    routeName: Routes.CONFIG,
                                  );

                                  if (result != null) {
                                    bloc.init();
                                  }
                                },
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: context.textMuted,
                                  size: 14.r,
                                ),
                                label: Text(
                                  'Edit',
                                  style: context.labelSmall.copyWith(
                                    color: context.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _positionedControl(
    BoxConstraints constraints,
    ButtonLayout button,
    Widget child,
  ) {
    final width = button.width.toDouble().clamp(36.0, constraints.maxWidth);
    final height = button.height.toDouble().clamp(32.0, constraints.maxHeight);
    final left = (button.x.toDouble() * constraints.maxWidth).clamp(
      0.0,
      constraints.maxWidth - width,
    );
    final top = (button.y.toDouble() * constraints.maxHeight).clamp(
      0.0,
      constraints.maxHeight - height,
    );

    return Positioned(
      left: left.toDouble(),
      top: top.toDouble(),
      width: width.toDouble(),
      height: height.toDouble(),
      child: child,
    );
  }

  Widget _joystickBase(BuildContext context, double size) => Container(
    width: size,
    height: size,
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

  Widget _joystickStick(BuildContext context, double size) => Container(
    width: size * 0.41,
    height: size * 0.41,
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
          width: double.infinity,
          height: double.infinity,
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
  final double width;
  final double height;
  final void Function(String, bool) onPress;

  const _DPad({
    required this.width,
    required this.height,
    required this.onPress,
  });

  Widget _btn(BuildContext context, IconData icon, String action, double size) {
    return Material(
      color: context.card.withOpacity(0.95),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTapDown: (_) => onPress(action, true),
        onTapUp: (_) => onPress(action, false),
        onTapCancel: () => onPress(action, false),
        child: Container(
          width: size,
          height: size,
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
            child: Icon(icon, color: context.textSecondary, size: size * 0.55),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = math.min(width, height) / 3;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: (width - size) / 2,
            top: 0,
            child: _btn(
              context,
              Icons.keyboard_arrow_up_rounded,
              'dpad_up',
              size,
            ),
          ),
          Positioned(
            left: 0,
            top: (height - size) / 2,
            child: _btn(
              context,
              Icons.keyboard_arrow_left_rounded,
              'dpad_left',
              size,
            ),
          ),
          Positioned(
            right: 0,
            top: (height - size) / 2,
            child: _btn(
              context,
              Icons.keyboard_arrow_right_rounded,
              'dpad_right',
              size,
            ),
          ),
          Positioned(
            left: (width - size) / 2,
            bottom: 0,
            child: _btn(
              context,
              Icons.keyboard_arrow_down_rounded,
              'dpad_down',
              size,
            ),
          ),
        ],
      ),
    );
  }
}

class _ABXYButtons extends StatelessWidget {
  final double width;
  final double height;
  final void Function(String, bool) onPress;

  const _ABXYButtons({
    required this.width,
    required this.height,
    required this.onPress,
  });

  Widget _btn(
    BuildContext context,
    String label,
    String action,
    Color color,
    double size,
  ) {
    return Material(
      color: color.withOpacity(0.88),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTapDown: (_) => onPress(action, true),
        onTapUp: (_) => onPress(action, false),
        onTapCancel: () => onPress(action, false),
        child: Container(
          width: size,
          height: size,
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
    final buttonSize = math.min(width, height) * 0.37;
    final midX = (width - buttonSize) / 2;
    final midY = (height - buttonSize) / 2;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: midX,
            top: 0,
            child: _btn(
              context,
              'Y',
              'button_y',
              const Color(0xFFEAB308),
              buttonSize,
            ),
          ),
          Positioned(
            left: 0,
            top: midY,
            child: _btn(
              context,
              'X',
              'button_x',
              const Color(0xFF2563EB),
              buttonSize,
            ),
          ),
          Positioned(
            right: 0,
            top: midY,
            child: _btn(
              context,
              'B',
              'button_b',
              const Color(0xFFEF4444),
              buttonSize,
            ),
          ),
          Positioned(
            left: midX,
            bottom: 0,
            child: _btn(
              context,
              'A',
              'button_a',
              const Color(0xFF22C55E),
              buttonSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoulderButton extends StatelessWidget {
  final String label;
  final String action;
  final void Function(String, bool) onPress;

  const _ShoulderButton({
    required this.label,
    required this.action,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card.withOpacity(0.95),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTapDown: (_) => onPress(action, true),
        onTapUp: (_) => onPress(action, false),
        onTapCancel: () => onPress(action, false),
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
    );
  }
}
