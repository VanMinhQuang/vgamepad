import 'package:app_controller/app/route.dart';
import 'package:app_controller/app/theme/theme_notifier.dart';
import 'package:app_controller/features/connect/view/connect_screen.dart';
import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation) {
        return ValueListenableBuilder<AppThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildTheme(mode),
              onGenerateRoute: AppRoute.onGenerateRoute,
              initialRoute: Routes.CONNECT,
            );
          },
        );
      },
    );
  }
}
