// theme/app_theme.dart

import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------------------
// Dark palette
// -------------------------
const _darkPrimary = Color(0xFF4A90D9);
const _darkSurface = Color(0xFF16213E);
const _darkBackground = Color(0xFF1A1A2E);
const _darkCard = Color(0xFF0F3460);
const _darkBorder = Color(0xFF2A4A7F);
const _darkError = Color(0xFFE57373);

// -------------------------
// Light palette
// -------------------------
const _lightPrimary = Color(0xFF1A6BBF);
const _lightSurface = Color(0xFFFFFFFF);
const _lightBackground = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFE8EEF7);
const _lightBorder = Color(0xFFBFCFE8);
const _lightError = Color(0xFFD32F2F);

TextTheme _buildTextTheme(Brightness brightness) {
  return GoogleFonts.beVietnamProTextTheme(
    brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme,
  ).copyWith(
    displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16.sp),
    bodyMedium: TextStyle(fontSize: 14.sp),
    bodySmall: TextStyle(fontSize: 12.sp, color: Colors.grey),
    labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11.sp, color: Colors.grey),
  );
}

ElevatedButtonThemeData _buildButtonTheme(Color primary) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

InputDecorationTheme _buildInputTheme(Color primary, Color border) {
  return InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primary),
    ),
    labelStyle: const TextStyle(color: Colors.grey),
    prefixIconColor: Colors.grey,
  );
}

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: _darkPrimary,
    surface: _darkSurface,
    surfaceContainer: _darkCard,
    background: _darkBackground,
    error: _darkError,
    onPrimary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    outline: _darkBorder,
  ),
  scaffoldBackgroundColor: _darkBackground,
  elevatedButtonTheme: _buildButtonTheme(_darkPrimary),
  inputDecorationTheme: _buildInputTheme(_darkPrimary, _darkBorder),
  iconTheme: const IconThemeData(color: _darkPrimary),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: _lightPrimary,
    surface: _lightSurface,
    surfaceContainer: _lightCard,
    background: _lightBackground,
    error: _lightError,
    onPrimary: Colors.white,
    onSurface: Color(0xFF1A1A2E),
    onBackground: Color(0xFF1A1A2E),
    outline: _lightBorder,
  ),
  scaffoldBackgroundColor: _lightBackground,
  elevatedButtonTheme: _buildButtonTheme(_lightPrimary),
  inputDecorationTheme: _buildInputTheme(_lightPrimary, _lightBorder),
  iconTheme: const IconThemeData(color: _lightPrimary),
);

// called inside Sizer where .sp is available
ThemeData buildTheme(AppThemeMode mode) {
  final isDark = mode == AppThemeMode.dark;
  final base = isDark ? darkTheme : lightTheme;
  final brightness = isDark ? Brightness.dark : Brightness.light;
  return base.copyWith(textTheme: _buildTextTheme(brightness));
}
