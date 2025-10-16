import 'package:flutter/foundation.dart';

/// Application logger utility
class AppLogger {
  AppLogger._();

  /// Log debug message
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
      if (stackTrace != null) {
        debugPrint('[STACK] $stackTrace');
      }
    }
  }

  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  /// Log warning message
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
    }
  }

  /// Log error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) {
        debugPrint('[ERROR DETAIL] $error');
      }
      if (stackTrace != null) {
        debugPrint('[STACK TRACE] $stackTrace');
      }
    }
  }

  /// Log success message
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('[SUCCESS] $message');
    }
  }

  /// Log API request
  static void apiRequest(String method, String url, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      debugPrint('[API REQUEST] $method $url');
      if (data != null) {
        debugPrint('[API DATA] $data');
      }
    }
  }

  /// Log API response
  static void apiResponse(String method, String url, int statusCode, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[API RESPONSE] $method $url - $statusCode');
      if (data != null) {
        debugPrint('[API RESPONSE DATA] $data');
      }
    }
  }

  /// Log navigation
  static void navigation(String from, String to) {
    if (kDebugMode) {
      debugPrint('[NAVIGATION] $from -> $to');
    }
  }

  /// Log authentication events
  static void auth(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[AUTH] $event');
      if (data != null) {
        debugPrint('[AUTH DATA] $data');
      }
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      debugPrint('[PERFORMANCE] $operation took ${duration.inMilliseconds}ms');
    }
  }

  /// Log security events
  static void security(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[SECURITY] $event');
      if (data != null) {
        debugPrint('[SECURITY DATA] $data');
      }
    }
  }

  /// Log user actions
  static void userAction(String action, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[USER ACTION] $action');
      if (data != null) {
        debugPrint('[USER ACTION DATA] $data');
      }
    }
  }

  /// Log database operations
  static void database(String operation, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[DATABASE] $operation');
      if (data != null) {
        debugPrint('[DATABASE DATA] $data');
      }
    }
  }

  /// Log network operations
  static void network(String operation, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[NETWORK] $operation');
      if (data != null) {
        debugPrint('[NETWORK DATA] $data');
      }
    }
  }

  /// Log cache operations
  static void cache(String operation, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[CACHE] $operation');
      if (data != null) {
        debugPrint('[CACHE DATA] $data');
      }
    }
  }

  /// Log notification events
  static void notification(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[NOTIFICATION] $event');
      if (data != null) {
        debugPrint('[NOTIFICATION DATA] $data');
      }
    }
  }

  /// Log biometric events
  static void biometric(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[BIOMETRIC] $event');
      if (data != null) {
        debugPrint('[BIOMETRIC DATA] $data');
      }
    }
  }

  /// Log MFA events
  static void mfa(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[MFA] $event');
      if (data != null) {
        debugPrint('[MFA DATA] $data');
      }
    }
  }

  /// Log crypto analysis events
  static void cryptoAnalysis(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[CRYPTO ANALYSIS] $event');
      if (data != null) {
        debugPrint('[CRYPTO ANALYSIS DATA] $data');
      }
    }
  }

  /// Log technical analysis events
  static void technicalAnalysis(String event, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[TECHNICAL ANALYSIS] $event');
      if (data != null) {
        debugPrint('[TECHNICAL ANALYSIS DATA] $data');
      }
    }
  }
}
