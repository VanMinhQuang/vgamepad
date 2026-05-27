import 'package:app_controller/app/route.dart';
import 'package:app_controller/app/theme/theme_notifier.dart';
import 'package:app_controller/di/injection.dart';
import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  setUpDI();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual);
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
