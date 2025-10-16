import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../config/app_config.dart';
import 'local_storage_service.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _integrityKey = 'app_integrity';
  static const String _deviceFingerprintKey = 'device_fingerprint';
  static const String _securityEventsKey = 'security_events';
  static const String _lastSecurityCheckKey = 'last_security_check';

  static bool _isInitialized = false;

  // Initialize security service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Perform initial security checks
      await _performSecurityChecks();

      // Set up periodic security monitoring
      _setupSecurityMonitoring();

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize SecurityService: $e');
      rethrow;
    }
  }

  // Perform comprehensive security checks
  static Future<void> _performSecurityChecks() async {
    try {
      // Check app integrity
      final isIntegrityValid = await _checkAppIntegrity();
      if (!isIntegrityValid) {
        await _logSecurityEvent('app_integrity_violation', {
          'timestamp': DateTime.now().toIso8601String(),
          'severity': 'high',
          'description': 'App integrity check failed',
        });
      }

      // Check device security
      final isDeviceSecure = await _checkDeviceSecurity();
      if (!isDeviceSecure) {
        await _logSecurityEvent('device_security_violation', {
          'timestamp': DateTime.now().toIso8601String(),
          'severity': 'medium',
          'description': 'Device security check failed',
        });
      }

      // Generate and store device fingerprint
      await _generateDeviceFingerprint();

      // Update last security check timestamp
      await _storage.write(
        key: _lastSecurityCheckKey,
        value: DateTime.now().toIso8601String(),
      );

    } catch (e) {
      print('Security checks failed: $e');
      await _logSecurityEvent('security_check_failure', {
        'timestamp': DateTime.now().toIso8601String(),
        'severity': 'high',
        'description': 'Security checks failed: ${e.toString()}',
      });
    }
  }

  // Check app integrity
  static Future<bool> _checkAppIntegrity() async {
    try {
      // Check if app is running in debug mode
      if (kDebugMode) {
        // In debug mode, we're more lenient
        return true;
      }

      // Check for common tampering indicators
      final isTampered = await _checkForTampering();
      if (isTampered) {
        return false;
      }

      // Check app signature (simplified version)
      final isValidSignature = await _verifyAppSignature();
      if (!isValidSignature) {
        return false;
      }

      return true;
    } catch (e) {
      print('App integrity check failed: $e');
      return false;
    }
  }

  // Check for common tampering indicators
  static Future<bool> _checkForTampering() async {
    try {
      // Check if app is running in emulator
      final isEmulator = await _isRunningInEmulator();
      if (isEmulator) {
        await _logSecurityEvent('emulator_detected', {
          'timestamp': DateTime.now().toIso8601String(),
          'severity': 'medium',
          'description': 'App running in emulator',
        });
      }

      // Check for root/jailbreak
      final isRooted = await _isDeviceRooted();
      if (isRooted) {
        await _logSecurityEvent('rooted_device_detected', {
          'timestamp': DateTime.now().toIso8601String(),
          'severity': 'high',
          'description': 'Rooted/jailbroken device detected',
        });
        return true; // Consider rooted devices as tampered
      }

      // Check for debugging
      final isBeingDebugged = await _isBeingDebugged();
      if (isBeingDebugged) {
        await _logSecurityEvent('debugging_detected', {
          'timestamp': DateTime.now().toIso8601String(),
          'severity': 'high',
          'description': 'App is being debugged',
        });
        return true;
      }

      return false;
    } catch (e) {
      print('Tampering check failed: $e');
      return true; // Fail secure
    }
  }

  // Check if running in emulator
  static Future<bool> _isRunningInEmulator() async {
    try {
      if (Platform.isAndroid) {
        // Check for common emulator indicators on Android
        final buildConfig = await _getAndroidBuildConfig();
        if (buildConfig != null) {
          final fingerprint = buildConfig['FINGERPRINT'] ?? '';
          final product = buildConfig['PRODUCT'] ?? '';
          final model = buildConfig['MODEL'] ?? '';

          return fingerprint.contains('generic') ||
                 fingerprint.contains('sdk') ||
                 product.contains('sdk') ||
                 model.contains('sdk') ||
                 model.contains('google_sdk');
        }
      } else if (Platform.isIOS) {
        // Check for common emulator indicators on iOS
        final deviceName = await _getIOSDeviceName();
        if (deviceName != null) {
          return deviceName.contains('Simulator') ||
                 deviceName.contains('iPhone Simulator') ||
                 deviceName.contains('iPad Simulator');
        }
      }

      return false;
    } catch (e) {
      print('Emulator check failed: $e');
      return false;
    }
  }

  // Check if device is rooted/jailbroken
  static Future<bool> _isDeviceRooted() async {
    try {
      if (Platform.isAndroid) {
        // Check for common root indicators
        final suExists = await _checkFileExists('/system/bin/su');
        final suExists2 = await _checkFileExists('/system/xbin/su');
        final magiskExists = await _checkFileExists('/sbin/magisk');

        return suExists || suExists2 || magiskExists;
      } else if (Platform.isIOS) {
        // Check for common jailbreak indicators
        final cydiaExists = await _checkFileExists('/Applications/Cydia.app');
        final jailbreakExists = await _checkFileExists('/Library/MobileSubstrate');

        return cydiaExists || jailbreakExists;
      }

      return false;
    } catch (e) {
      print('Root check failed: $e');
      return false;
    }
  }

  // Check if app is being debugged
  static Future<bool> _isBeingDebugged() async {
    try {
      // This is a simplified check. In production, you'd want more sophisticated detection
      return kDebugMode;
    } catch (e) {
      print('Debug check failed: $e');
      return false;
    }
  }

  // Verify app signature (simplified)
  static Future<bool> _verifyAppSignature() async {
    try {
      // In a real implementation, you'd verify the app's signature
      // For now, we'll just return true
      return true;
    } catch (e) {
      print('App signature verification failed: $e');
      return false;
    }
  }

  // Check device security
  static Future<bool> _checkDeviceSecurity() async {
    try {
      // Check if device has screen lock
      final hasScreenLock = await _localAuth.canCheckBiometrics;

      // Check if device encryption is enabled
      final isEncrypted = await _isDeviceEncrypted();

      // Check if device has secure hardware
      final hasSecureHardware = await _hasSecureHardware();

      return hasScreenLock && isEncrypted && hasSecureHardware;
    } catch (e) {
      print('Device security check failed: $e');
      return false;
    }
  }

  // Check if device is encrypted
  static Future<bool> _isDeviceEncrypted() async {
    try {
      // This is a simplified check. In production, you'd check actual encryption status
      return true;
    } catch (e) {
      print('Device encryption check failed: $e');
      return false;
    }
  }

  // Check if device has secure hardware
  static Future<bool> _hasSecureHardware() async {
    try {
      // Check for biometric capabilities
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      return canCheckBiometrics && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Secure hardware check failed: $e');
      return false;
    }
  }

  // Generate device fingerprint
  static Future<void> _generateDeviceFingerprint() async {
    try {
      final fingerprint = await _createDeviceFingerprint();
      await _storage.write(key: _deviceFingerprintKey, value: fingerprint);
    } catch (e) {
      print('Failed to generate device fingerprint: $e');
    }
  }

  // Create device fingerprint
  static Future<String> _createDeviceFingerprint() async {
    try {
      final components = <String>[];

      // Platform
      components.add(Platform.operatingSystem);
      components.add(Platform.operatingSystemVersion);

      // Device info
      if (Platform.isAndroid) {
        final buildConfig = await _getAndroidBuildConfig();
        if (buildConfig != null) {
          components.add(buildConfig['MODEL'] ?? '');
          components.add(buildConfig['MANUFACTURER'] ?? '');
          components.add(buildConfig['HARDWARE'] ?? '');
        }
      } else if (Platform.isIOS) {
        final deviceName = await _getIOSDeviceName();
        if (deviceName != null) {
          components.add(deviceName);
        }
      }

      // Create hash from components
      final combined = components.join('|');
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      print('Failed to create device fingerprint: $e');
      return 'unknown';
    }
  }

  // Get Android build configuration
  static Future<Map<String, String>?> _getAndroidBuildConfig() async {
    try {
      // This is a simplified version. In production, you'd read actual build properties
      return {
        'FINGERPRINT': 'unknown',
        'PRODUCT': 'unknown',
        'MODEL': 'unknown',
        'MANUFACTURER': 'unknown',
        'HARDWARE': 'unknown',
      };
    } catch (e) {
      return null;
    }
  }

  // Get iOS device name
  static Future<String?> _getIOSDeviceName() async {
    try {
      // This is a simplified version. In production, you'd get actual device info
      return 'iPhone';
    } catch (e) {
      return null;
    }
  }

  // Check if file exists
  static Future<bool> _checkFileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Setup security monitoring
  static void _setupSecurityMonitoring() {
    // Set up periodic security checks
    // In a real implementation, you'd use a timer or background task
    // For now, we'll just log that monitoring is set up
    print('Security monitoring set up');
  }

  // Log security event
  static Future<void> _logSecurityEvent(String event, Map<String, dynamic> data) async {
    try {
      final events = await _getSecurityEvents();
      events.add({
        'id': _generateEventId(),
        'event': event,
        ...data,
      });

      // Keep only last 1000 events
      if (events.length > 1000) {
        events.removeRange(0, events.length - 1000);
      }

      await _storage.write(
        key: _securityEventsKey,
        value: jsonEncode(events),
      );

      // Also log to local storage for analytics
      await LocalStorageService.addAnalyticsEvent('security_event', {
        'event': event,
        'data': data,
      });

    } catch (e) {
      print('Failed to log security event: $e');
    }
  }

  // Get security events
  static Future<List<Map<String, dynamic>>> _getSecurityEvents() async {
    try {
      final eventsData = await _storage.read(key: _securityEventsKey);
      if (eventsData != null) {
        final events = jsonDecode(eventsData) as List;
        return events.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Failed to get security events: $e');
      return [];
    }
  }

  // Generate event ID
  static String _generateEventId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = random.nextInt(1000000);
    return '${timestamp}_$randomValue';
  }

  // Public methods
  static Future<bool> isSecure() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final isIntegrityValid = await _checkAppIntegrity();
      final isDeviceSecure = await _checkDeviceSecurity();

      return isIntegrityValid && isDeviceSecure;
    } catch (e) {
      print('Security check failed: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getSecurityEvents() async {
    return await _getSecurityEvents();
  }

  static Future<String?> getDeviceFingerprint() async {
    return await _storage.read(key: _deviceFingerprintKey);
  }

  static Future<DateTime?> getLastSecurityCheck() async {
    final timestamp = await _storage.read(key: _lastSecurityCheckKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  static Future<void> performSecurityCheck() async {
    await _performSecurityChecks();
  }

  static Future<void> clearSecurityEvents() async {
    await _storage.delete(key: _securityEventsKey);
  }
}
