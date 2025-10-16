import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

class FirebaseConfig {
  static FirebaseOptions get androidOptions => const FirebaseOptions(
        apiKey: 'AIzaSyBMendfBjnBRqxzV9bB--qVvQv3lg-VQMs',
        appId: '1:78955542733:android:81201a5f6b578f2fc65184',
        messagingSenderId: '78955542733',
        projectId: 'btcbaran-c7334',
        storageBucket: 'btcbaran-c7334.firebasestorage.app',
      );

  static FirebaseOptions get iosOptions => const FirebaseOptions(
        apiKey: 'AIzaSyBZrt1-KgGBYpzNrvHRd0RlOtJVqgSgrig',
        appId: '1:78955542733:ios:81201a5f6b578f2fc65184',
        messagingSenderId: '78955542733',
        projectId: 'btcbaran-c7334',
        storageBucket: 'btcbaran-c7334.firebasestorage.app',
        iosBundleId: 'com.bozkilinc.btcbaran',
      );

  static FirebaseOptions get webOptions => const FirebaseOptions(
        apiKey: 'AIzaSyBZrt1-KgGBYpzNrvHRd0RlOtJVqgSgrig',
        appId: '1:78955542733:web:fc21e905ef086992c65184',
        messagingSenderId: '78955542733',
        projectId: 'btcbaran-c7334',
        storageBucket: 'btcbaran-c7334.firebasestorage.app',
      );

  static Future<void> initialize() async {
    try {
      // Platform-specific initialization
      final options =
          kIsWeb ? webOptions : (Platform.isIOS ? iosOptions : androidOptions);

      await Firebase.initializeApp(options: options);

      // Configure Firebase Messaging
      await _configureFirebaseMessaging();

      Logger.info('Firebase initialized successfully', 'FirebaseConfig');
    } catch (e) {
      Logger.error('Firebase initialization error: $e', 'FirebaseConfig', e);
      rethrow;
    }
  }

  static Future<void> _configureFirebaseMessaging() async {
    try {
      // Request permission for notifications
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

      Logger.info('User granted permission: ${settings.authorizationStatus}',
          'FirebaseMessaging');

      // Get FCM token
      final token = await messaging.getToken();
      if (token != null) {
        Logger.info('FCM Token: $token', 'FirebaseMessaging');
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } catch (e) {
      Logger.error(
          'Firebase Messaging configuration error: $e', 'FirebaseMessaging', e);
    }
  }

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    Logger.info('Handling a background message: ${message.messageId}',
        'FirebaseMessaging');

    // Handle background message here
    // You can save to local storage, show notification, etc.
  }
}
