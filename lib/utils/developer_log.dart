// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Logger {
  final String className;
  const Logger({required this.className});

  void debug([String? functionName, dynamic message]) {
    print('[DEBUG] [$className] [$functionName]');
    print(_parseJson(message));
  }

  void info([String? functionName, dynamic message]) {
    print('[INFO] [$className] [$functionName]');
    print(_parseJson(message));
  }

  void warning([String? functionName, dynamic message]) {
    print('[WARNING] [$className] [$functionName]');
    print(_parseJson(message));
  }

  void error([String? functionName, dynamic message]) {
    print('[ERROR] [$className] [$functionName]');
    print(_parseJson(message));
  }

  String _parseJson(dynamic message) {
    if (message is FlutterError) {
      final FlutterError flutterError = message;
      return flutterError.message;
    } else if (message is String) {
      return message;
    }
    try {
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(message);
    } catch (_) {
      return 'Undefined type of message';
    }
  }
}

class AppLogger {
  const AppLogger({required this.appName});

  final String appName;

  Logger get logger => Logger(className: appName);

  void debug(dynamic message, {String? functionName}) {
    logger.debug(functionName, message);
  }

  void d(dynamic message, {String? functionName}) =>
      debug(message, functionName: functionName);

  void info(dynamic message, {String? functionName}) {
    logger.info(functionName, message);
  }

  void i(dynamic message, {String? functionName}) =>
      info(message, functionName: functionName);

  void warning(dynamic message, {String? functionName}) {
    logger.warning(functionName, message);
  }

  void w(dynamic message, {String? functionName}) =>
      warning(message, functionName: functionName);

  void error(dynamic message, {String? functionName}) {
    logger.error(functionName, message);
  }

  void e(dynamic message, {String? functionName}) =>
      error(message, functionName: functionName);
}
