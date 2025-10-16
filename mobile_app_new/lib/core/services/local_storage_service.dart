import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class LocalStorageService {
  static late Box _box;
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _box = await Hive.openBox('btcbaran_storage');
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic storage methods
  static Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  static String? getString(String key) {
    return _box.get(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  static int? getInt(String key) {
    return _box.get(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  static bool? getBool(String key) {
    return _box.get(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _box.put(key, value);
  }

  static double? getDouble(String key) {
    return _box.get(key);
  }

  static Future<void> setList(String key, List<dynamic> value) async {
    await _box.put(key, value);
  }

  static List<dynamic>? getList(String key) {
    return _box.get(key);
  }

  static Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  static Map<String, dynamic>? getMap(String key) {
    return _box.get(key);
  }

  static Future<void> remove(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  // App-specific storage methods
  static Future<void> setLanguage(String language) async {
    await _prefs.setString(AppConfig.languageKey, language);
  }

  static String getLanguage() {
    return _prefs.getString(AppConfig.languageKey) ?? AppConfig.defaultLanguage;
  }

  static Future<void> setTheme(String theme) async {
    await _prefs.setString(AppConfig.themeKey, theme);
  }

  static String getTheme() {
    return _prefs.getString(AppConfig.themeKey) ?? 'system';
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(AppConfig.notificationsEnabledKey, enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs.getBool(AppConfig.notificationsEnabledKey) ?? true;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(AppConfig.biometricEnabledKey, enabled);
  }

  static bool getBiometricEnabled() {
    return _prefs.getBool(AppConfig.biometricEnabledKey) ?? false;
  }

  // User preferences
  static Future<void> setUserPreference(String key, dynamic value) async {
    final prefs = getMap('user_preferences') ?? {};
    prefs[key] = value;
    await setMap('user_preferences', prefs);
  }

  static T? getUserPreference<T>(String key) {
    final prefs = getMap('user_preferences');
    return prefs?[key] as T?;
  }

  // Cache methods
  static Future<void> setCache(String key, dynamic value, {Duration? expiry}) async {
    final cacheData = {
      'value': value,
      'expiry': expiry != null ? DateTime.now().add(expiry).millisecondsSinceEpoch : null,
    };
    await setMap('cache_$key', cacheData);
  }

  static T? getCache<T>(String key) {
    final cacheData = getMap('cache_$key');
    if (cacheData == null) return null;

    final expiry = cacheData['expiry'] as int?;
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      remove('cache_$key');
      return null;
    }

    return cacheData['value'] as T?;
  }

  static Future<void> clearCache() async {
    final keys = _box.keys.where((key) => key.toString().startsWith('cache_'));
    for (final key in keys) {
      await _box.delete(key);
    }
  }

  // Analytics and tracking
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    await _prefs.setBool('analytics_enabled', enabled);
  }

  static bool getAnalyticsEnabled() {
    return _prefs.getBool('analytics_enabled') ?? true;
  }

  static Future<void> setCrashReportingEnabled(bool enabled) async {
    await _prefs.setBool('crash_reporting_enabled', enabled);
  }

  static bool getCrashReportingEnabled() {
    return _prefs.getBool('crash_reporting_enabled') ?? true;
  }

  // App state
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _prefs.setBool('first_launch', isFirstLaunch);
  }

  static bool getFirstLaunch() {
    return _prefs.getBool('first_launch') ?? true;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool('onboarding_completed', completed);
  }

  static bool getOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  // Cleanup
  static Future<void> dispose() async {
    await _box.close();
  }
}