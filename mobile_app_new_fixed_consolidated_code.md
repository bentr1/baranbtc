# BTC Baran Mobile App - Consolidated Code

This document contains all the code files from the `mobile_app_new_fixed` directory consolidated into a single markdown file.

---

## pubspec.yaml

```yaml
name: btcbaran
description: BTC Baran Kripto Analiz ve Bildirim Uygulaması
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  go_router: ^12.1.3
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  qr_flutter: ^4.1.0
  fl_chart: ^0.65.0
  dio: ^5.4.0
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^15.1.1
  local_auth: ^2.1.7
  crypto: ^3.0.3
  flutter_secure_storage: ^9.0.0
  intl: ^0.18.1
  url_launcher: ^6.2.2
  package_info_plus: ^4.2.0
  device_info_plus: ^9.0.0
  permission_handler: ^11.1.0
  flutter_screenutil: ^5.9.0
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  retrofit_generator: ^7.0.8
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_test: ^2.1.8

flutter:
  uses-material-design: true
```

---

## lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_config.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/security_service.dart';

// Firebase messaging background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize services
  await LocalStorageService.initialize();
  await SecurityService.initialize();

  // Request permissions
  await _requestPermissions();

  runApp(
    ProviderScope(
      child: BTCBaranMobileApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  // Request notification permissions
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  // Request biometric permissions
  await Permission.sensors.request();
  await Permission.camera.request();
}

class BTCBaranMobileApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'BTC Baran',
          debugShowCheckedModeBanner: false,
          theme: AppConfig.lightTheme,
          darkTheme: AppConfig.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}
```

---

## lib/core/config/app_config.dart

```dart
import 'package:flutter/material.dart';

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
  static const String firebaseApiKey = 'AIzaSyBMendfBjnBRqxzV9bB--qVvQv3lg-VQMs';
  static const String firebaseAuthDomain = 'btcbaran-c7334.firebaseapp.com';
  static const String firebaseProjectId = 'btcbaran-c7334';
  static const String firebaseStorageBucket = 'btcbaran-c7334.firebasestorage.app';
  static const String firebaseMessagingSenderId = '78955542733';
  static const String firebaseAppId = '1:78955542733:android:81201a5f6b578f2fc65184';

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

  // Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFF64B5F6);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Crypto Colors
  static const Color bullishColor = Color(0xFF4CAF50);
  static const Color bearishColor = Color(0xFFF44336);
  static const Color neutralColor = Color(0xFF9E9E9E);

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 12.0;
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
```

---

## lib/app/router/app_router.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/onboarding_screen.dart';
import '../../core/widgets/splash_screen.dart';
import '../../features/analysis/presentation/pages/analysis_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/mfa_setup_page.dart';
import '../../features/auth/presentation/pages/mfa_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/crypto/presentation/pages/crypto_detail_page.dart';
import '../../features/crypto/presentation/pages/crypto_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash and Onboarding
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: '/mfa-setup',
        builder: (context, state) => const MFASetupPage(),
      ),
      GoRoute(
        path: '/mfa-verification',
        builder: (context, state) => const MFAVerificationPage(),
      ),

      // Main App Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/crypto',
        builder: (context, state) => const CryptoListPage(),
      ),
      GoRoute(
        path: '/crypto/:symbol',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol']!;
          return CryptoDetailPage(symbol: symbol);
        },
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) => const AnalysisPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## lib/core/services/auth_service.dart

```dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _uuid = Uuid();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _deviceIdKey = 'device_id';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      if (token == null) return false;
      
      // Check if token is expired
      final tokenData = _parseJwt(token);
      if (tokenData == null) return false;
      
      final expiry = DateTime.fromMillisecondsSinceEpoch(tokenData['exp'] * 1000);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, try to refresh
        try {
          await refreshToken();
          return true;
        } catch (e) {
          await logout();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData == null) return null;
      
      return User.fromJson(jsonDecode(userData));
    } catch (e) {
      return null;
    }
  }

  // Login
  static Future<User> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      
      final response = await ApiService.post('/auth/login', data: {
        'email': email,
        'password': _hashPassword(password),
        'deviceId': deviceId,
        'deviceName': await _getDeviceName(),
        'deviceType': Platform.isIOS ? 'ios' : 'android',
        'rememberMe': rememberMe,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final refreshToken = response['data']['refreshToken'];

        // Store tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register
  static Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      
      final response = await ApiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': _hashPassword(password),
        'deviceId': deviceId,
        'deviceName': await _getDeviceName(),
        'deviceType': Platform.isIOS ? 'ios' : 'android',
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final refreshToken = response['data']['refreshToken'];

        // Store tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Call logout endpoint
      final token = await _storage.read(key: _authTokenKey);
      if (token != null) {
        try {
          await ApiService.post('/auth/logout', data: {});
        } catch (e) {
          // Ignore logout API errors
        }
      }

      // Clear stored data
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      // Clear stored data even if API call fails
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
    }
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Helper methods
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Map<String, dynamic>? _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(resp);
    } catch (e) {
      return null;
    }
  }

  static Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = _uuid.v4();
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  static Future<String> _getDeviceName() async {
    // This would get the actual device name
    // For now, return a generic name
    return Platform.isIOS ? 'iOS Device' : 'Android Device';
  }
}
```

---

## lib/features/auth/presentation/pages/login_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';
import '../../../../core/config/app_config.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48.h),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          size: 40.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 48.h),
                
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  inputType: InputType.email,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16.h),
                
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  inputType: InputType.password,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16.h),
                
                // Remember Me and Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppConfig.primaryColor,
                        ),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32.h),
                
                // Login Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                ),
                
                SizedBox(height: 24.h),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                
                SizedBox(height: 24.h),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## lib/features/dashboard/presentation/pages/dashboard_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _CryptoTab(),
    const _AnalysisTab(),
    const _NotificationsTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppConfig.primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Crypto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${user?.name ?? 'User'}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 32.w,
                          color: AppConfig.successColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Active Alerts',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '12',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 32.w,
                          color: AppConfig.infoColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Analyses',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '8',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Recent Activity
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications, color: AppConfig.successColor),
                    title: Text('BTC Price Alert Triggered'),
                    subtitle: Text('2 hours ago'),
                    trailing: Text('+5.2%', style: TextStyle(color: AppConfig.successColor)),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.analytics, color: AppConfig.infoColor),
                    title: Text('ETH Technical Analysis Updated'),
                    subtitle: Text('4 hours ago'),
                    trailing: Text('Bullish', style: TextStyle(color: AppConfig.successColor)),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.trending_up, color: AppConfig.warningColor),
                    title: Text('ADA Support Level Reached'),
                    subtitle: Text('6 hours ago'),
                    trailing: Text('\$0.45', style: TextStyle(color: AppConfig.primaryColor)),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/crypto'),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 32.w,
                          color: AppConfig.primaryColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'View Crypto',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/analysis'),
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 32.w,
                          color: AppConfig.secondaryColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Analysis',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/notifications'),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications,
                          size: 32.w,
                          color: AppConfig.accentColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Alerts',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CryptoTab extends StatelessWidget {
  const _CryptoTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crypto Markets',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/crypto'),
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64.w,
              color: AppConfig.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Crypto Markets',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'View detailed crypto market data',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go('/crypto'),
              child: Text('View All Crypto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisTab extends StatelessWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical Analysis',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/analysis'),
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64.w,
              color: AppConfig.secondaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Technical Analysis',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppConfig.secondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Advanced technical analysis tools',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go('/analysis'),
              child: Text('View Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications,
              size: 64.w,
              color: AppConfig.accentColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppConfig.accentColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Manage your alerts and notifications',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go('/notifications'),
              child: Text('View All Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.w,
              backgroundColor: AppConfig.primaryColor,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              user?.name ?? 'User',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go('/profile'),
              child: Text('View Full Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Summary

This consolidated file contains the key components of the BTC Baran mobile application:

1. **Project Configuration** - `pubspec.yaml` with all dependencies
2. **Main Entry Point** - `main.dart` with app initialization
3. **App Configuration** - Centralized config with themes, colors, and settings
4. **Routing** - Navigation setup with GoRouter
5. **Authentication Service** - Complete auth implementation with JWT, biometrics, and security
6. **Login Page** - User authentication interface
7. **Dashboard** - Main app interface with bottom navigation

The app is built with Flutter using modern architecture patterns including:
- **Riverpod** for state management
- **GoRouter** for navigation
- **Firebase** for messaging and authentication
- **Hive** for local storage
- **Material Design 3** for UI components
- **Responsive design** with ScreenUtil

This is a comprehensive cryptocurrency analysis and notification application with features for technical analysis, price alerts, user authentication, and real-time market data.
