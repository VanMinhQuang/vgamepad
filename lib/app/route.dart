import 'package:app_controller/features/connect/view/connect_screen.dart';
import 'package:app_controller/features/config/view/config_screen.dart';
import 'package:app_controller/features/gamepad/data/gamepad_connection.dart';
import 'package:app_controller/features/gamepad/view/gamepad_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String CONNECT = '/connect_screen';
  static const String CONFIG = '/config_screen';
  static const String GAMEPAD = '/gamepad_screen';
}

class AppRoute {
  static PageRouteBuilder transitionAnimation({
    required Widget child,
    required String routeName,
  }) {
    return PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween<Offset>(begin: begin, end: end);
        var offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curve)),
        );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static final Map<String, Widget Function(RouteSettings)> _appRoutes = {
    Routes.CONNECT: (_) => const ConnectScreen(),
    Routes.CONFIG: (_) => const ConfigScreen(),
    Routes.GAMEPAD: (settings) {
      final connection = settings.arguments as GamepadConnection;
      return GamepadScreen(connection: connection);
    },
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    if (_appRoutes.containsKey(settings.name)) {
      page = _appRoutes[settings.name]!(settings);
    } else {
      page = const ConnectScreen();
    }
    return CupertinoPageRoute(builder: (context) => page, settings: settings);
  }
}

extension Navigation on BuildContext {
  Future<dynamic> push(Widget newScreen) {
    return Navigator.push(
      this,
      AppRoute.transitionAnimation(child: newScreen, routeName: ''),
    );
  }

  Future<dynamic> backToScreen(Widget newScreen) {
    return Navigator.pushAndRemoveUntil(
      this,
      AppRoute.transitionAnimation(child: newScreen, routeName: ''),
      (Route<dynamic> route) => false,
    );
  }

  Future<dynamic> pushReplacement(Widget newScreen) {
    return Navigator.pushReplacement(
      this,
      AppRoute.transitionAnimation(child: newScreen, routeName: ''),
    );
  }

  void pushReplacementNamed({required String routeName, Object? arguments}) {
    Navigator.pushReplacementNamed(this, routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementUntil(Widget newScreen) {
    return Navigator.pushAndRemoveUntil(
      this,
      AppRoute.transitionAnimation(child: newScreen, routeName: ''),
      (route) => false,
    );
  }

  Future<dynamic> pushNamed({required String routeName, Object? arguments}) {
    return Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }

  void popUntil({required String routeName}) {
    Navigator.popUntil(this, ModalRoute.withName(routeName));
  }

  void popUntilWithResult<T extends Object?>({required String routeName}) {
    Navigator.popUntilWithResult(this, ModalRoute.withName(routeName), T);
  }

  void pushNamedAndRemoveUntil({
    required String newRouteName,
    required String utilRouteName,
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      this,
      newRouteName,
      ModalRoute.withName(utilRouteName),
      arguments: arguments,
    );
  }
}
