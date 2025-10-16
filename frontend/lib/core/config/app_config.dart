import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppConfig {
  // App Information
  static const String appName = 'BTC Baran';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Comprehensive Crypto Analysis and Notification Application';
  
  // API Configuration
  static const String baseUrl = 'https://btc.nazlihw.com';
  static const String apiVersion = '/api/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Development API Configuration (for local testing)
  static const String devBaseUrl = 'http://185.8.129.67:3000';
  static const String localBaseUrl = 'http://localhost:3000';
  
  // Firebase Configuration
  static const String firebaseApiKey = 'AIzaSyBZrt1-KgGBYpzNrvHRd0RlOtJVqgSgrig';
  static const String firebaseAuthDomain = 'btcbaran-c7334.firebaseapp.com';
  static const String firebaseProjectId = 'btcbaran-c7334';
  static const String firebaseStorageBucket = 'btcbaran-c7334.firebasestorage.app';
  static const String firebaseMessagingSenderId = '78955542733';
  static const String firebaseAppId = '1:78955542733:web:fc21e905ef086992c65184';
  static const String firebaseMeasurementId = 'G-VVR58KX1BQ';
  
  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // Supported Languages
  static const List<String> supportedLanguages = ['tr', 'en', 'fr', 'de'];
  static const String defaultLanguage = 'tr';
  
  // Theme Configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.light,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
  
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
  
  // Colors - using AppColors constants
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color accentColor = AppColors.accent;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color errorColor = AppColors.error;
  static const Color infoColor = AppColors.info;
  
  // Crypto Colors
  static const Color bullishColor = AppColors.bullish;
  static const Color bearishColor = AppColors.bearish;
  static const Color neutralColor = AppColors.neutral;
  
  // Dimensions - using AppSizes constants
  static const double defaultPadding = AppSizes.spacingM;
  static const double defaultMargin = AppSizes.spacingM;
  static const double defaultRadius = AppSizes.radiusM;
  static const double defaultIconSize = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Notification Channels
  static const String priceAlertsChannel = 'price_alerts';
  static const String analysisSignalsChannel = 'analysis_signals';
  static const String marketUpdatesChannel = 'market_updates';
  static const String securityAlertsChannel = 'security_alerts';
  
  // Crypto Analysis Settings
  static const int defaultCandlesCount = 200;
  static const List<String> supportedTimeframes = ['1m', '5m', '15m', '1h', '4h', '1d', '1w'];
  static const String defaultTimeframe = '1d';
  
}
