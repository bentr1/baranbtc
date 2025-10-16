import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/router/app_router.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_config.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/security_service.dart';
import 'core/services/api_service.dart';
import 'core/utils/logger.dart';
import 'core/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase messaging background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  Logger.info('Handling a background message: ${message.messageId}',
      'FirebaseMessaging');
  Logger.info('Message data: ${message.data}', 'FirebaseMessaging');
  Logger.info('Message notification: ${message.notification?.title}',
      'FirebaseMessaging');

  // Handle background notification
  if (message.notification != null) {
    // You can add custom logic here for background notifications
    // For example, updating local storage or triggering specific actions
    Logger.info(
        'Background notification received: ${message.notification!.title}',
        'FirebaseMessaging');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    Logger.info('Initializing Firebase...', 'App');
    await FirebaseConfig.initialize();
    Logger.info('Firebase initialized successfully', 'App');

    // Set up Firebase messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Hive
    Logger.info('Initializing Hive...', 'App');
    await Hive.initFlutter();
    Logger.info('Hive initialized successfully', 'App');

    // Initialize services
    Logger.info('Initializing LocalStorageService...', 'App');
    await LocalStorageService.initialize();
    Logger.info('LocalStorageService initialized successfully', 'App');

    Logger.info('Initializing SecurityService...', 'App');
    await SecurityService.initialize();
    Logger.info('SecurityService initialized successfully', 'App');

    Logger.info('Initializing ApiService...', 'App');
    ApiService.initialize();
    Logger.info('ApiService initialized successfully', 'App');

    // Request permissions
    Logger.info('Requesting permissions...', 'App');
    await _requestPermissions();
    Logger.info('Permissions requested successfully', 'App');

    Logger.info('Starting app...', 'App');
    runApp(
      ProviderScope(
        child: BTCBaranMobileApp(),
      ),
    );
  } catch (e, stackTrace) {
    Logger.error('Error during initialization: $e', 'App', e, stackTrace);

    // Fallback: run app without full initialization
    Logger.warning('Running app with minimal initialization...', 'App');
    runApp(
      ProviderScope(
        child: BTCBaranMobileAppMinimal(),
      ),
    );
  }
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
    Logger.info('User granted permission', 'Permissions');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    Logger.info('User granted provisional permission', 'Permissions');
  } else {
    Logger.warning(
        'User declined or has not accepted permission', 'Permissions');
  }

  // Request biometric permissions
  await Permission.sensors.request();
  await Permission.camera.request();
}

class BTCBaranMobileApp extends ConsumerWidget {
  const BTCBaranMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

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
          locale: locale,
          supportedLocales: AppConfig.supportedLanguages
              .map((code) => Locale(code))
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}

class BTCBaranMobileAppMinimal extends ConsumerWidget {
  const BTCBaranMobileAppMinimal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BTC Baran',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BTC Baran'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 64,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Uygulama başlatılırken bir hata oluştu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Lütfen uygulamayı yeniden başlatmayı deneyin',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
