import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';

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
    appId: '1:78955542733:web:fc21e905ef086992c65184',
    messagingSenderId: '78955542733',
    projectId: 'btcbaran-c7334',
    storageBucket: 'btcbaran-c7334.firebasestorage.app',
    iosBundleId: 'com.bozkilinc.btcbaran',
  );

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: androidOptions, // Default to Android, can be changed based on platform
      );
      
      // Configure Firebase Messaging
      await _configureFirebaseMessaging();
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
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

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Get FCM token
      final token = await messaging.getToken();
      if (kDebugMode && token != null) {
        print('FCM Token: $token');
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Messaging configuration error: $e');
      }
    }
  }

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print('Handling a background message: ${message.messageId}');
    }
    
    // Handle background message here
    // You can save to local storage, show notification, etc.
  }
}
