import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'DEBUG',
        level: 500, // Debug level
      );
    }
  }

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'INFO',
      level: 800, // Info level
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'WARNING',
      level: 900, // Warning level
    );
  }

  static void error(String message,
      [String? tag, Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: tag ?? 'ERROR',
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void print(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'PRINT',
        level: 500,
      );
    }
  }
}
