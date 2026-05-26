// theme/colors.dart

import 'package:app_controller/app/app_size.dart';
import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  ColorScheme get _cs => Theme.of(this).colorScheme;
  TextTheme get _tt => Theme.of(this).textTheme;

  // -------------------------
  // Brand
  // -------------------------
  Color get primary => _cs.primary;
  Color get onPrimary => _cs.onPrimary;

  // -------------------------
  // Surface / Background
  // -------------------------
  Color get background => _cs.background;
  Color get surface => _cs.surface;
  Color get card => _cs.surfaceContainer;
  Color get onSurface => _cs.onSurface;
  Color get onBackground => _cs.onBackground;

  // -------------------------
  // Semantic
  // -------------------------
  Color get error => _cs.error;
  Color get onError => _cs.onError;
  Color get outline => _cs.outline;

  // -------------------------
  // Text shades
  // -------------------------
  Color get textPrimary => _cs.onSurface;
  Color get textSecondary => _cs.onSurface.withOpacity(0.7);
  Color get textMuted => _cs.onSurface.withOpacity(0.5);
  Color get textHint => _cs.onSurface.withOpacity(0.35);

  // -------------------------
  // Display
  // -------------------------
  TextStyle get displayLarge => _tt.displayLarge!.copyWith(fontSize: 32.sp);

  TextStyle get displayMedium => _tt.displayMedium!.copyWith(fontSize: 26.sp);

  // -------------------------
  // Headline
  // -------------------------
  TextStyle get headlineMedium => _tt.headlineMedium!.copyWith(fontSize: 22.sp);

  // -------------------------
  // Title
  // -------------------------
  TextStyle get titleLarge => _tt.titleLarge!.copyWith(fontSize: 18.sp);

  TextStyle get titleMedium => _tt.titleMedium!.copyWith(fontSize: 16.sp);

  // -------------------------
  // Body
  // -------------------------
  TextStyle get bodyLarge => _tt.bodyLarge!.copyWith(fontSize: 16.sp);

  TextStyle get bodyMedium => _tt.bodyMedium!.copyWith(fontSize: 14.sp);

  TextStyle get bodySmall => _tt.bodySmall!.copyWith(fontSize: 12.sp);

  // -------------------------
  // Label
  // -------------------------
  TextStyle get labelLarge => _tt.labelLarge!.copyWith(fontSize: 16.sp);

  TextStyle get labelSmall => _tt.labelSmall!.copyWith(fontSize: 11.sp);

  // -------------------------
  // Semantic shortcuts
  // -------------------------

  TextStyle get screenTitle => _tt.displayMedium!.copyWith(fontSize: 26.sp);

  TextStyle get cardTitle => _tt.headlineMedium!.copyWith(fontSize: 22.sp);

  TextStyle get sectionHeader => _tt.titleLarge!.copyWith(fontSize: 18.sp);

  TextStyle get body => _tt.bodyLarge!.copyWith(fontSize: 16.sp);

  TextStyle get muted =>
      _tt.bodyMedium!.copyWith(fontSize: 14.sp, color: textMuted);

  TextStyle get hint =>
      _tt.bodySmall!.copyWith(fontSize: 12.sp, color: textHint);

  TextStyle get buttonText => _tt.labelLarge!.copyWith(fontSize: 16.sp);

  TextStyle get errorText =>
      _tt.bodyMedium!.copyWith(fontSize: 13.sp, color: error);

  TextStyle get badge => _tt.labelSmall!.copyWith(fontSize: 11.sp);
}
