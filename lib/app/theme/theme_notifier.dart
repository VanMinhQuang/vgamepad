// theme/theme_notifier.dart

import 'package:flutter/material.dart';

enum AppThemeMode { dark, light }

class ThemeNotifier extends ValueNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.dark);

  bool get isDark => value == AppThemeMode.dark;

  void toggleTheme() {
    value = isDark ? AppThemeMode.light : AppThemeMode.dark;
  }

  void setTheme(AppThemeMode mode) {
    value = mode;
  }
}

// global instance
final themeNotifier = ThemeNotifier();
