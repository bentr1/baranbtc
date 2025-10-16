import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';
import 'local_storage_service.dart';

class NotificationService {
  // static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLocalNotifications();
      // await _initializeFirebaseMessaging();
      await _requestPermissions();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('🔔 Notification service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Notification service initialization error: $e');
      }
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Handle background messages
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
    // Handle foreground messages
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps when app is in background
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle notification taps when app is terminated
    // final initialMessage = await _firebaseMessaging.getInitialMessage();
    // if (initialMessage != null) {
    //   _handleNotificationTap(initialMessage);
    // }
  }

  static Future<void> _requestPermissions() async {
    try {
      // Request Firebase messaging permissions (disabled for web)
      // final messagingSettings = await _firebaseMessaging.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: false,
      //   provisional: false,
      //   sound: true,
      // );

      // Request local notification permissions
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Permission request error: $e');
      }
    }
  }

  // Local notification tap handler
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('🔔 Local notification tapped: ${response.id}');
    }
    
    // Handle local notification tap
    _processLocalNotificationTap(response);
  }

  // Process local notification tap
  static void _processLocalNotificationTap(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        final type = data['type'];
        
        switch (type) {
          case 'price_alert':
            // Navigate to crypto detail page
            final symbol = data['symbol'];
            if (symbol != null) {
              if (kDebugMode) {
                print('🔔 Navigate to crypto: $symbol');
              }
            }
            break;
          case 'analysis_alert':
            // Navigate to analysis page
            if (kDebugMode) {
              print('🔔 Navigate to analysis');
            }
            break;
          case 'news_alert':
            // Navigate to news page
            if (kDebugMode) {
              print('🔔 Navigate to news');
            }
            break;
          default:
            // Navigate to dashboard
            if (kDebugMode) {
              print('🔔 Navigate to dashboard');
            }
            break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Local notification tap processing error: $e');
      }
    }
  }

  // Store notification locally
  static Future<void> _storeNotification(Map<String, dynamic> notification) async {
    try {
      final notifications = LocalStorageService.getList('notifications') ?? [];
      notifications.insert(0, notification);
      
      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }
      
      await LocalStorageService.setList('notifications', notifications);
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Store notification error: $e');
      }
    }
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'btcbaran_channel',
        'BTC Baran Notifications',
        channelDescription: 'Notifications for BTC Baran app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Show local notification error: $e');
      }
    }
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Cancel notification error: $e');
      }
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Cancel all notifications error: $e');
      }
    }
  }

  // Get stored notifications
  static List<Map<String, dynamic>> getStoredNotifications() {
    try {
      return (LocalStorageService.getList('notifications') ?? [])
          .cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Get stored notifications error: $e');
      }
      return [];
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notifications = getStoredNotifications();
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      
      if (index != -1) {
        notifications[index]['read'] = true;
        await LocalStorageService.setList('notifications', notifications);
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Mark notification as read error: $e');
      }
    }
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      await LocalStorageService.remove('notifications');
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Clear all notifications error: $e');
      }
    }
  }

  // Dispose
  static Future<void> dispose() async {
    try {
      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Dispose error: $e');
      }
    }
  }
}