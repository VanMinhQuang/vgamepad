import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/route.dart';
import 'package:app_controller/app/styles.dart';
import 'package:app_controller/di/injection.dart';
import 'package:app_controller/domain/models/button_layout.dart';
import 'package:app_controller/domain/repository/gamepad_config_repo.dart';
import 'package:app_controller/features/config/cubit/config_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfigCubit(sl<GamepadConfigRepo>())..load(),
      child: const ConfigView(),
    );
  }
}

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final Map<String, ButtonLayout> _gestureStarts = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfigCubit, ConfigState>(
      listener: (context, state) {
        if (state is! ConfigLayoutState) return;

        if (state.status == ConfigStatus.saved) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Layout saved')));
        } else if (state.status == ConfigStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      child: Scaffold(
        backgroundColor: context.background,
        extendBody: true,
        extendBodyBehindAppBar: true,

        body: SafeArea(
          top: false,
          left: false,
          right: false,
          child: Column(
            children: [
              _Toolbar(),
              Expanded(
                child: BlocBuilder<ConfigCubit, ConfigState>(
                  builder: (context, state) {
                    if (state is! ConfigLayoutState ||
                        state.status == ConfigStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(16.dp, 0, 16.dp, 16.dp),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boardSize = Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );

                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.surface.withOpacity(0.72),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: context.outline.withOpacity(0.44),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _GridPainter(
                                        color: context.outline.withOpacity(
                                          0.16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (final button in state.layout.buttons)
                                    _EditableButton(
                                      key: ValueKey(button.id),
                                      button: button,
                                      boardSize: boardSize,
                                      onScaleStart: () {
                                        _gestureStarts[button.id] = button;
                                      },
                                      onScaleUpdate: (details) {
                                        final start =
                                            _gestureStarts[button.id] ?? button;
                                        context
                                            .read<ConfigCubit>()
                                            .transformButton(
                                              id: button.id,
                                              boardSize: boardSize,
                                              gestureStart: start,
                                              moveDelta:
                                                  details.focalPointDelta,
                                              scale: details.scale,
                                            );
                                      },
                                      onScaleEnd: () {
                                        _gestureStarts.remove(button.id);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.dp, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => context.pop(true),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Gamepad Layout',
              style: context.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: () => context.read<ConfigCubit>().reset(),
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          SizedBox(width: 6.w),
          BlocBuilder<ConfigCubit, ConfigState>(
            builder: (context, state) {
              final saving =
                  state is ConfigLayoutState &&
                  state.status == ConfigStatus.saving;

              return FilledButton.icon(
                onPressed: saving
                    ? null
                    : () => context.read<ConfigCubit>().save(),
                icon: saving
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EditableButton extends StatelessWidget {
  final ButtonLayout button;
  final Size boardSize;
  final VoidCallback onScaleStart;
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;
  final VoidCallback onScaleEnd;

  const _EditableButton({
    super.key,
    required this.button,
    required this.boardSize,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
  });

  @override
  Widget build(BuildContext context) {
    final width = button.width.toDouble().clamp(44.0, boardSize.width);
    final height = button.height.toDouble().clamp(36.0, boardSize.height);
    final left = (button.x.toDouble() * boardSize.width).clamp(
      0.0,
      boardSize.width - width,
    );
    final top = (button.y.toDouble() * boardSize.height).clamp(
      0.0,
      boardSize.height - height,
    );

    return Positioned(
      left: left.toDouble(),
      top: top.toDouble(),
      width: width.toDouble(),
      height: height.toDouble(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (_) => onScaleStart(),
        onScaleUpdate: onScaleUpdate,
        onScaleEnd: (_) => onScaleEnd(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.card.withOpacity(0.94),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: context.primary.withOpacity(0.64)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  button.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.labelSmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                right: 5.r,
                bottom: 5.r,
                child: Icon(
                  Icons.open_in_full_rounded,
                  color: context.textMuted,
                  size: 12.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 48.0;

    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
