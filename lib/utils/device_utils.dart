import 'package:flutter/material.dart';

class DeviceUtils {
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 600;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isTabletLandscape(BuildContext context) {
    return isTablet(context) && isLandscape(context);
  }
}
