import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
// Firebase imports disabled for web compatibility
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/router/app_router.dart';
import 'core/config/app_config.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/security_service.dart';
import 'core/utils/logger.dart';

// Firebase messaging background handler (disabled for web)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (!kIsWeb) {
//     await Firebase.initializeApp();
//     print('Handling a background message: ${message.messageId}');
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (disabled for web)
  // await FirebaseConfig.initialize();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize services
  AppLogger.info('Initializing services...');
  await LocalStorageService.initialize();
  await SecurityService.initialize();
  AppLogger.success('Services initialized successfully');
  
  // Request permissions
  await _requestPermissions();
  
  AppLogger.info('Starting BTC Baran application...');
  runApp(
    const ProviderScope(
      child: BTCBaranApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  // Request notification permissions (disabled for web)
  // final messaging = FirebaseMessaging.instance;
  // final settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );
  // 
  // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //   AppLogger.success('User granted notification permission');
  // } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  //   AppLogger.info('User granted provisional notification permission');
  // } else {
  //   AppLogger.warning('User declined or has not accepted notification permission');
  // }
  
  // Request biometric permissions
  await Permission.sensors.request();
  await Permission.camera.request();
}

class BTCBaranApp extends ConsumerWidget {
  const BTCBaranApp({super.key});

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
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
