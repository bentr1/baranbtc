import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class LocalStorageService {
  static const String _settingsBox = 'settings';
  static const String _cryptoDataBox = 'crypto_data';
  static const String _userPreferencesBox = 'user_preferences';
  static const String _cacheBox = 'cache';
  static const String _analyticsBox = 'analytics';

  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Open boxes
      await Hive.openBox(_settingsBox);
      await Hive.openBox(_cryptoDataBox);
      await Hive.openBox(_userPreferencesBox);
      await Hive.openBox(_cacheBox);
      await Hive.openBox(_analyticsBox);

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize LocalStorageService: $e');
      rethrow;
    }
  }

  // Settings methods
  static Future<void> setSetting(String key, dynamic value) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_settingsBox);
      await box.put(key, value);
    } catch (e) {
      print('Failed to set setting $key: $e');
    }
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_settingsBox);
      final value = box.get(key, defaultValue: defaultValue);
      return value as T?;
    } catch (e) {
      print('Failed to get setting $key: $e');
      return defaultValue;
    }
  }

  static Future<void> removeSetting(String key) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_settingsBox);
      await box.delete(key);
    } catch (e) {
      print('Failed to remove setting $key: $e');
    }
  }

  // Crypto data methods
  static Future<void> setCryptoData(String key, Map<String, dynamic> data) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cryptoDataBox);
      await box.put(key, jsonEncode(data));
    } catch (e) {
      print('Failed to set crypto data $key: $e');
    }
  }

  static Map<String, dynamic>? getCryptoData(String key) {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cryptoDataBox);
      final data = box.get(key);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Failed to get crypto data $key: $e');
      return null;
    }
  }

  static Future<void> removeCryptoData(String key) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cryptoDataBox);
      await box.delete(key);
    } catch (e) {
      print('Failed to remove crypto data $key: $e');
    }
  }

  // User preferences methods
  static Future<void> setUserPreference(String key, dynamic value) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_userPreferencesBox);
      await box.put(key, value);
    } catch (e) {
      print('Failed to set user preference $key: $e');
    }
  }

  static T? getUserPreference<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_userPreferencesBox);
      final value = box.get(key, defaultValue: defaultValue);
      return value as T?;
    } catch (e) {
      print('Failed to get user preference $key: $e');
      return defaultValue;
    }
  }

  static Future<void> removeUserPreference(String key) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_userPreferencesBox);
      await box.delete(key);
    } catch (e) {
      print('Failed to remove user preference $key: $e');
    }
  }

  // Cache methods
  static Future<void> setCache(String key, dynamic data, {Duration? ttl}) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cacheBox);
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };
      await box.put(key, jsonEncode(cacheData));
    } catch (e) {
      print('Failed to set cache $key: $e');
    }
  }

  static T? getCache<T>(String key) {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cacheBox);
      final cacheData = box.get(key);
      if (cacheData != null) {
        final decoded = jsonDecode(cacheData) as Map<String, dynamic>;
        final timestamp = decoded['timestamp'] as int;
        final ttl = decoded['ttl'] as int?;
        
        // Check if cache is expired
        if (ttl != null) {
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp + ttl);
          if (DateTime.now().isAfter(expiryTime)) {
            // Cache expired, remove it
            box.delete(key);
            return null;
          }
        }
        
        return decoded['data'] as T?;
      }
      return null;
    } catch (e) {
      print('Failed to get cache $key: $e');
      return null;
    }
  }

  static Future<void> removeCache(String key) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cacheBox);
      await box.delete(key);
    } catch (e) {
      print('Failed to remove cache $key: $e');
    }
  }

  static Future<void> clearExpiredCache() async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_cacheBox);
      final keys = box.keys.toList();
      
      for (final key in keys) {
        final cacheData = box.get(key);
        if (cacheData != null) {
          try {
            final decoded = jsonDecode(cacheData) as Map<String, dynamic>;
            final timestamp = decoded['timestamp'] as int;
            final ttl = decoded['ttl'] as int?;
            
            if (ttl != null) {
              final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp + ttl);
              if (DateTime.now().isAfter(expiryTime)) {
                await box.delete(key);
              }
            }
          } catch (e) {
            // Invalid cache data, remove it
            await box.delete(key);
          }
        }
      }
    } catch (e) {
      print('Failed to clear expired cache: $e');
    }
  }

  // Analytics methods
  static Future<void> addAnalyticsEvent(String event, Map<String, dynamic> data) async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_analyticsBox);
      final events = box.get('events', defaultValue: <String>[]) as List<String>;
      
      final eventData = {
        'event': event,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      events.add(jsonEncode(eventData));
      
      // Keep only last 1000 events
      if (events.length > 1000) {
        events.removeRange(0, events.length - 1000);
      }
      
      await box.put('events', events);
    } catch (e) {
      print('Failed to add analytics event: $e');
    }
  }

  static List<Map<String, dynamic>> getAnalyticsEvents() {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_analyticsBox);
      final events = box.get('events', defaultValue: <String>[]) as List<String>;
      
      return events.map((event) {
        try {
          return jsonDecode(event) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{};
        }
      }).toList();
    } catch (e) {
      print('Failed to get analytics events: $e');
      return [];
    }
  }

  static Future<void> clearAnalyticsEvents() async {
    _ensureInitialized();
    
    try {
      final box = Hive.box(_analyticsBox);
      await box.put('events', <String>[]);
    } catch (e) {
      print('Failed to clear analytics events: $e');
    }
  }

  // SharedPreferences methods (for simple key-value storage)
  static Future<void> setSharedPreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    } catch (e) {
      print('Failed to set shared preference $key: $e');
    }
  }

  static T? getSharedPreference<T>(String key, {T? defaultValue}) {
    try {
      // Note: This is a simplified version. In practice, you'd need to know the type
      // and use the appropriate getter method
      return defaultValue;
    } catch (e) {
      print('Failed to get shared preference $key: $e');
      return defaultValue;
    }
  }

  static Future<void> removeSharedPreference(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Failed to remove shared preference $key: $e');
    }
  }

  // Utility methods
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('LocalStorageService not initialized. Call initialize() first.');
    }
  }

  static Future<void> clear() async {
    _ensureInitialized();
    
    try {
      await Hive.box(_settingsBox).clear();
      await Hive.box(_cryptoDataBox).clear();
      await Hive.box(_userPreferencesBox).clear();
      await Hive.box(_cacheBox).clear();
      await Hive.box(_analyticsBox).clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Failed to clear storage: $e');
    }
  }

  static Future<void> close() async {
    if (_isInitialized) {
      try {
        await Hive.close();
        _isInitialized = false;
      } catch (e) {
        print('Failed to close storage: $e');
      }
    }
  }

  // Get storage statistics
  static Map<String, int> getStorageStats() {
    _ensureInitialized();
    
    try {
      return {
        'settings': Hive.box(_settingsBox).length,
        'crypto_data': Hive.box(_cryptoDataBox).length,
        'user_preferences': Hive.box(_userPreferencesBox).length,
        'cache': Hive.box(_cacheBox).length,
        'analytics': Hive.box(_analyticsBox).length,
      };
    } catch (e) {
      print('Failed to get storage stats: $e');
      return {};
    }
  }
}
