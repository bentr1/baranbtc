import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import '../config/app_config.dart';
import 'local_storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static bool _isInitialized = false;
  static String? _fcmToken;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
      
      // Request permissions
      await _requestPermissions();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      // Initialize settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Initialize plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Create notification channels for Android
      await _createNotificationChannels();
      
    } catch (e) {
      print('Failed to initialize local notifications: $e');
    }
  }

  // Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    try {
      // Price alerts channel
      const priceAlertsChannel = AndroidNotificationChannel(
        AppConfig.priceAlertsChannel,
        'Price Alerts',
        description: 'Notifications for price alerts and market movements',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Analysis signals channel
      const analysisSignalsChannel = AndroidNotificationChannel(
        AppConfig.analysisSignalsChannel,
        'Analysis Signals',
        description: 'Notifications for technical analysis signals',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Market updates channel
      const marketUpdatesChannel = AndroidNotificationChannel(
        AppConfig.marketUpdatesChannel,
        'Market Updates',
        description: 'General market updates and news',
        importance: Importance.medium,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );

      // Security alerts channel
      const securityAlertsChannel = AndroidNotificationChannel(
        AppConfig.securityAlertsChannel,
        'Security Alerts',
        description: 'Important security notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Create channels
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(priceAlertsChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(analysisSignalsChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(marketUpdatesChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(securityAlertsChannel);

    } catch (e) {
      print('Failed to create notification channels: $e');
    }
  }

  // Initialize Firebase messaging
  static Future<void> _initializeFirebaseMessaging() async {
    try {
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _onTokenRefresh(token);
      });

      // Set up foreground message handling
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      
      // Set up background message handling
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Set up message opened handling
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
      
      // Check for initial message
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpenedApp(initialMessage);
      }

    } catch (e) {
      print('Failed to initialize Firebase messaging: $e');
    }
  }

  // Request permissions
  static Future<void> _requestPermissions() async {
    try {
      // Request local notification permissions
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestPermission();
        if (granted) {
          print('Local notification permission granted');
        }
      }

      // Request Firebase messaging permissions
      final messagingSettings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (messagingSettings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Firebase messaging permission granted');
      } else if (messagingSettings.authorizationStatus == AuthorizationStatus.provisional) {
        print('Firebase messaging provisional permission granted');
      } else {
        print('Firebase messaging permission denied');
      }

    } catch (e) {
      print('Failed to request permissions: $e');
    }
  }

  // Set up message handlers
  static void _setupMessageHandlers() {
    // Handle notification taps
    _localNotifications.initialize(
      const InitializationSettings(),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleNotificationTap(data);
      }
    } catch (e) {
      print('Failed to handle notification tap: $e');
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final symbol = data['symbol'] as String?;
      
      // Navigate based on notification type
      switch (type) {
        case 'price_alert':
          if (symbol != null) {
            // Navigate to crypto detail page
            print('Navigate to crypto detail: $symbol');
          }
          break;
        case 'analysis_signal':
          if (symbol != null) {
            // Navigate to analysis page
            print('Navigate to analysis: $symbol');
          }
          break;
        case 'security_alert':
          // Navigate to security page
          print('Navigate to security page');
          break;
        default:
          // Navigate to notifications page
          print('Navigate to notifications page');
          break;
      }
    } catch (e) {
      print('Failed to handle notification tap: $e');
    }
  }

  // Handle foreground message
  static void _onForegroundMessage(RemoteMessage message) {
    try {
      print('Received foreground message: ${message.messageId}');
      
      // Show local notification
      _showLocalNotification(message);
      
      // Log analytics
      LocalStorageService.addAnalyticsEvent('notification_received', {
        'type': 'foreground',
        'message_id': message.messageId,
        'data': message.data,
      });
      
    } catch (e) {
      print('Failed to handle foreground message: $e');
    }
  }

  // Handle message opened from background
  static void _onMessageOpenedApp(RemoteMessage message) {
    try {
      print('Message opened from background: ${message.messageId}');
      
      // Handle navigation
      _handleNotificationTap(message.data);
      
      // Log analytics
      LocalStorageService.addAnalyticsEvent('notification_opened', {
        'type': 'background',
        'message_id': message.messageId,
        'data': message.data,
      });
      
    } catch (e) {
      print('Failed to handle background message: $e');
    }
  }

  // Handle token refresh
  static void _onTokenRefresh(String token) {
    try {
      print('FCM token refreshed: $token');
      _fcmToken = token;
      
      // Send new token to server
      _sendTokenToServer(token);
      
    } catch (e) {
      print('Failed to handle token refresh: $e');
    }
  }

  // Send token to server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      // TODO: Implement API call to update FCM token
      print('Sending FCM token to server: $token');
    } catch (e) {
      print('Failed to send token to server: $e');
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final data = message.data;
      final notification = message.notification;
      
      if (notification == null) return;
      
      final androidDetails = AndroidNotificationDetails(
        _getChannelId(data['type']),
        _getChannelName(data['type']),
        channelDescription: _getChannelDescription(data['type']),
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: _getNotificationColor(data['type']),
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
        _generateNotificationId(),
        notification.title ?? 'BTC Baran',
        notification.body ?? '',
        details,
        payload: jsonEncode(data),
      );

    } catch (e) {
      print('Failed to show local notification: $e');
    }
  }

  // Get channel ID based on notification type
  static String _getChannelId(String? type) {
    switch (type) {
      case 'price_alert':
        return AppConfig.priceAlertsChannel;
      case 'analysis_signal':
        return AppConfig.analysisSignalsChannel;
      case 'market_update':
        return AppConfig.marketUpdatesChannel;
      case 'security_alert':
        return AppConfig.securityAlertsChannel;
      default:
        return AppConfig.marketUpdatesChannel;
    }
  }

  // Get channel name based on notification type
  static String _getChannelName(String? type) {
    switch (type) {
      case 'price_alert':
        return 'Price Alerts';
      case 'analysis_signal':
        return 'Analysis Signals';
      case 'market_update':
        return 'Market Updates';
      case 'security_alert':
        return 'Security Alerts';
      default:
        return 'Market Updates';
    }
  }

  // Get channel description based on notification type
  static String _getChannelDescription(String? type) {
    switch (type) {
      case 'price_alert':
        return 'Notifications for price alerts and market movements';
      case 'analysis_signal':
        return 'Notifications for technical analysis signals';
      case 'market_update':
        return 'General market updates and news';
      case 'security_alert':
        return 'Important security notifications';
      default:
        return 'General notifications';
    }
  }

  // Get notification color based on type
  static int _getNotificationColor(String? type) {
    switch (type) {
      case 'price_alert':
        return 0xFF4CAF50; // Green
      case 'analysis_signal':
        return 0xFF2196F3; // Blue
      case 'market_update':
        return 0xFFFF9800; // Orange
      case 'security_alert':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Generate unique notification ID
  static int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  // Public methods
  static Future<String?> getFCMToken() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _fcmToken;
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = AppConfig.marketUpdatesChannel,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
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
        _generateNotificationId(),
        title,
        body,
        details,
        payload: payload,
      );

    } catch (e) {
      print('Failed to show local notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      print('Failed to cancel notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      print('Failed to cancel all notifications: $e');
    }
  }

  static Future<void> clearNotificationChannels() async {
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.deleteNotificationChannel(AppConfig.priceAlertsChannel);
        await androidPlugin.deleteNotificationChannel(AppConfig.analysisSignalsChannel);
        await androidPlugin.deleteNotificationChannel(AppConfig.marketUpdatesChannel);
        await androidPlugin.deleteNotificationChannel(AppConfig.securityAlertsChannel);
      }
    } catch (e) {
      print('Failed to clear notification channels: $e');
    }
  }

  static Future<bool> isInitialized() async {
    return _isInitialized;
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print('Handling background message: ${message.messageId}');
    
    // Log analytics
    await LocalStorageService.addAnalyticsEvent('notification_received', {
      'type': 'background',
      'message_id': message.messageId,
      'data': message.data,
    });
    
  } catch (e) {
    print('Failed to handle background message: $e');
  }
}
