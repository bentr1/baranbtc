import 'package:flutter/foundation.dart';

/// Environment configuration service
class Environment {
  Environment._();

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://btc.nazlihw.com',
  );
  
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: '/api/v1',
  );
  
  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  // Development API URLs
  static const String devApiBaseUrl = String.fromEnvironment(
    'DEV_API_BASE_URL',
    defaultValue: 'http://185.8.129.67:3000',
  );
  
  static const String localApiBaseUrl = String.fromEnvironment(
    'LOCAL_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Firebase Configuration (Web)
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBZrt1-KgGBYpzNrvHRd0RlOtJVqgSgrig',
  );
  
  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'btcbaran-c7334.firebaseapp.com',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'btcbaran-c7334',
  );
  
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'btcbaran-c7334.firebasestorage.app',
  );
  
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '78955542733',
  );
  
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:78955542733:web:fc21e905ef086992c65184',
  );
  
  static const String firebaseMeasurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-VVR58KX1BQ',
  );

  // Security Configuration
  static const int maxLoginAttempts = int.fromEnvironment(
    'MAX_LOGIN_ATTEMPTS',
    defaultValue: 5,
  );
  
  static const int lockoutDurationMinutes = int.fromEnvironment(
    'LOCKOUT_DURATION_MINUTES',
    defaultValue: 15,
  );
  
  static const int sessionTimeoutHours = int.fromEnvironment(
    'SESSION_TIMEOUT_HOURS',
    defaultValue: 24,
  );
  
  static const int tokenRefreshThresholdMinutes = int.fromEnvironment(
    'TOKEN_REFRESH_THRESHOLD_MINUTES',
    defaultValue: 5,
  );

  // App Configuration
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'BTC Baran',
  );
  
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  
  static const String defaultLanguage = String.fromEnvironment(
    'DEFAULT_LANGUAGE',
    defaultValue: 'tr',
  );
  
  static const List<String> supportedLanguages = [
    'tr', 'en', 'fr', 'de'
  ];

  // Performance Configuration
  static const int cacheDurationMinutes = int.fromEnvironment(
    'CACHE_DURATION_MINUTES',
    defaultValue: 5,
  );
  
  static const int requestRetryCount = int.fromEnvironment(
    'REQUEST_RETRY_COUNT',
    defaultValue: 3,
  );
  
  static const int debounceDelayMs = int.fromEnvironment(
    'DEBOUNCE_DELAY_MS',
    defaultValue: 300,
  );

  // Feature Flags
  static const bool enableBiometricAuth = bool.fromEnvironment(
    'ENABLE_BIOMETRIC_AUTH',
    defaultValue: true,
  );
  
  static const bool enableMfa = bool.fromEnvironment(
    'ENABLE_MFA',
    defaultValue: true,
  );
  
  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH_NOTIFICATIONS',
    defaultValue: true,
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );

  // Debug Configuration
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: kDebugMode,
  );
  
  static const bool verboseLogging = bool.fromEnvironment(
    'VERBOSE_LOGGING',
    defaultValue: kDebugMode,
  );
  
  static const bool showDebugInfo = bool.fromEnvironment(
    'SHOW_DEBUG_INFO',
    defaultValue: kDebugMode,
  );

  /// Get current environment name
  static String get environmentName {
    if (kDebugMode) {
      return 'development';
    } else if (kProfileMode) {
      return 'staging';
    } else {
      return 'production';
    }
  }

  /// Check if running in production
  static bool get isProduction => kReleaseMode;

  /// Check if running in development
  static bool get isDevelopment => kDebugMode;

  /// Check if running in profile mode
  static bool get isProfile => kProfileMode;

  /// Get appropriate API base URL based on environment
  static String get currentApiBaseUrl {
    if (isDevelopment) {
      return localApiBaseUrl;
    } else if (isProfile) {
      return devApiBaseUrl;
    } else {
      return apiBaseUrl;
    }
  }

  /// Get full API URL
  static String get fullApiUrl => '$currentApiBaseUrl$apiVersion';

  /// Print environment info (debug only)
  static void printEnvironmentInfo() {
    if (kDebugMode) {
      debugPrint('=== Environment Info ===');
      debugPrint('Environment: $environmentName');
      debugPrint('API Base URL: $currentApiBaseUrl');
      debugPrint('Full API URL: $fullApiUrl');
      debugPrint('Firebase Project: $firebaseProjectId');
      debugPrint('App Version: $appVersion');
      debugPrint('Debug Mode: $debugMode');
      debugPrint('========================');
    }
  }
}
