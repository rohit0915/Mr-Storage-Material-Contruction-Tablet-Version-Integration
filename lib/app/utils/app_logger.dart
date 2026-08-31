import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static final List<String> _recentLogs = [];
  static const int _maxLogs = 200;

  static List<String> get recentLogs => List.unmodifiable(_recentLogs);

  static void i(String message, {String tag = 'INFO'}) {
    _log('[$tag] $message');
  }

  static void d(String message, {String tag = 'DEBUG'}) {
    _log('[$tag] $message');
  }

  static void w(String message, {String tag = 'WARN'}) {
    _log('[$tag] $message');
  }

  static void e(String message, {Object? error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    final errStr = error != null ? ' | Error: $error' : '';
    _log('[$tag] $message$errStr');
    if (stackTrace != null) {
      _log('[$tag] StackTrace: $stackTrace');
    }
  }

  static void _log(String line) {
    final timestamp = DateTime.now().toIso8601String().split('T').last;
    final formattedLog = '[$timestamp] $line';

    _recentLogs.add(formattedLog);
    if (_recentLogs.length > _maxLogs) {
      _recentLogs.removeAt(0);
    }

    // debugPrint ensures log output is emitted to logcat / stdout in release & debug mode
    debugPrint(formattedLog);
    if (kDebugMode) {
      developer.log(formattedLog);
    }
  }

  static void clearLogs() {
    _recentLogs.clear();
  }
}
