import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import 'local_storage_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  static String? _fcmToken;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();
    
    // Initialize Local Notifications
    await _initializeLocalNotifications();
    
    // Request permissions
    await _requestPermissions();
    
    // Get FCM token
    await _getFCMToken();
    
    _isInitialized = true;
  }

  // Initialize Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // Initialize Local Notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Request permissions
  static Future<void> _requestPermissions() async {
    // Request notification permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined notification permission');
    }

    // Request local notification permission
    await Permission.notification.request();
  }

  // Get FCM token
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');
      
      // Store token for API calls
      if (_fcmToken != null) {
        await LocalStorageService.setString('fcm_token', _fcmToken!);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Get current FCM token
  static String? getFCMToken() {
    return _fcmToken;
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _getChannelId(type),
        _getChannelName(type),
        channelDescription: _getChannelDescription(type),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: _getNotificationColor(type),
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
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
      print('Error showing local notification: $e');
    }
  }

  // Show scheduled notification
  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _getChannelId(type),
        _getChannelName(type),
        channelDescription: _getChannelDescription(type),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: _getNotificationColor(type),
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error showing scheduled notification: $e');
    }
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    
    // Show local notification for foreground messages
    showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'BTC Baran',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
      type: _getNotificationTypeFromData(message.data),
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('route')) {
      // Navigate to specific route
      _navigateToRoute(data['route']);
    }
  }

  // Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.id}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        if (data.containsKey('route')) {
          _navigateToRoute(data['route']);
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Navigate to route
  static void _navigateToRoute(String route) {
    // This would implement navigation logic
    // For now, just print the route
    print('Navigate to route: $route');
  }

  // Get notification type from data
  static NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'price_alert':
        return NotificationType.priceAlert;
      case 'analysis_signal':
        return NotificationType.analysisSignal;
      case 'market_update':
        return NotificationType.marketUpdate;
      case 'security_alert':
        return NotificationType.securityAlert;
      default:
        return NotificationType.general;
    }
  }

  // Get channel ID for notification type
  static String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.priceAlert:
        return AppConfig.priceAlertsChannel;
      case NotificationType.analysisSignal:
        return AppConfig.analysisSignalsChannel;
      case NotificationType.marketUpdate:
        return AppConfig.marketUpdatesChannel;
      case NotificationType.securityAlert:
        return AppConfig.securityAlertsChannel;
      default:
        return 'general';
    }
  }

  // Get channel name for notification type
  static String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.priceAlert:
        return 'Price Alerts';
      case NotificationType.analysisSignal:
        return 'Analysis Signals';
      case NotificationType.marketUpdate:
        return 'Market Updates';
      case NotificationType.securityAlert:
        return 'Security Alerts';
      default:
        return 'General';
    }
  }

  // Get channel description for notification type
  static String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.priceAlert:
        return 'Notifications for price alerts and targets';
      case NotificationType.analysisSignal:
        return 'Notifications for technical analysis signals';
      case NotificationType.marketUpdate:
        return 'Notifications for market updates and news';
      case NotificationType.securityAlert:
        return 'Notifications for security alerts and warnings';
      default:
        return 'General notifications';
    }
  }

  // Get notification color for type
  static Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.priceAlert:
        return AppConfig.warningColor;
      case NotificationType.analysisSignal:
        return AppConfig.infoColor;
      case NotificationType.marketUpdate:
        return AppConfig.primaryColor;
      case NotificationType.securityAlert:
        return AppConfig.errorColor;
      default:
        return AppConfig.primaryColor;
    }
  }

  // Cleanup
  static Future<void> dispose() async {
    // Cleanup resources if needed
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

// Notification types
enum NotificationType {
  general,
  priceAlert,
  analysisSignal,
  marketUpdate,
  securityAlert,
}