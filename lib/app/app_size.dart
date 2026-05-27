// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const num kDesignWidth = 375;
const num kDesignHeight = 812;

// -------------------------
// Design-time font baseline
// -------------------------
const num kDesignFontBase = 375;

class SizeConfig {
  SizeConfig._();

  static late double width;
  static late double height;
  static late Orientation orientation;
  static late bool isTablet;

  static void init(BoxConstraints constraints, Orientation o) {
    orientation = o;
    width = constraints.maxWidth;
    height = constraints.maxHeight;
    isTablet = width >= 600;
  }

  static double get scaleX {
    final baseScale = width / kDesignWidth;
    return isTablet ? baseScale.clamp(0.85, 1.3) : baseScale;
  }

  static double get scaleY {
    final baseScale = height / kDesignHeight;
    return isTablet ? baseScale.clamp(0.85, 1.3) : baseScale;
  }

  static double get tabletFactor => isTablet ? 0.88 : 1.0;

  // -------------------------
  // Font scale — uses scaleX
  // but clamped more tightly
  // so text never gets huge
  // -------------------------
  static double get scaleFont {
    final base = width / kDesignFontBase;
    return isTablet ? base.clamp(0.9, 1.2) : base.clamp(0.85, 1.15);
  }

  // -------------------------
  // Adaptive value helpers
  // -------------------------

  /// Returns [phone] or [tablet] value based on current device
  static T adaptive<T>(T phone, T tablet) => isTablet ? tablet : phone;

  /// Returns a value that scales between [min] and [max]
  /// based on current screen width
  static double fluid(double min, double max) {
    final t = ((width - kDesignWidth) / (1024 - kDesignWidth)).clamp(0.0, 1.0);
    return min + (max - min) * t;
  }
}

typedef ResponsiveBuilder =
    Widget Function(BuildContext context, Orientation orientation);

class Sizer extends StatelessWidget {
  const Sizer({super.key, required this.builder});

  final ResponsiveBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig.init(constraints, orientation);
            return builder(context, orientation);
          },
        );
      },
    );
  }
}

class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  final Widget mobile;
  final Widget tablet;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return isTablet ? tablet : mobile;
  }
}

extension SizeExtension on num {
  /// Horizontal scaling
  double get w => this * SizeConfig.scaleX * SizeConfig.tabletFactor;

  /// Vertical scaling
  double get h => this * SizeConfig.scaleY * SizeConfig.tabletFactor;

  /// Font scaling — use for all fontSize values
  double get sp => this * SizeConfig.scaleFont;

  /// Uniform scaling — average of x/y, good for icons & squares
  double get r =>
      this *
      ((SizeConfig.scaleX + SizeConfig.scaleY) / 2) *
      SizeConfig.tabletFactor;

  /// Padding/margin shorthand — same as w but semantically clearer
  double get dp => this * SizeConfig.scaleX * SizeConfig.tabletFactor;
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(toStringAsFixed(fractionDigits));
  }

  double isNonZero({num defaultValue = 0.0}) {
    return this > 0 ? this : defaultValue.toDouble();
  }
}

class Responsive {
  Responsive._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < 600;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Returns different values for phone vs tablet inline
  static T when<T>(
    BuildContext context, {
    required T phone,
    required T tablet,
  }) => isTablet(context) ? tablet : phone;
}
