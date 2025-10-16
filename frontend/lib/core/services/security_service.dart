import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../config/app_config.dart';
import 'local_storage_service.dart';

class SecurityService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize security features
    await _initializeBiometricAuth();
    await _initializeSecurityChecks();
      
      _isInitialized = true;
  }

  static Future<void> _initializeBiometricAuth() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (kDebugMode) {
        print('🔐 Biometric Auth Available: $isAvailable');
        print('🔐 Device Supported: $isDeviceSupported');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔐 Biometric Auth Error: $e');
      }
    }
  }

  static Future<void> _initializeSecurityChecks() async {
    // Perform security checks
    await _checkRootDetection();
    await _checkDebugMode();
    await _checkEmulatorDetection();
  }

  // Biometric Authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticateWithBiometrics({
    String? reason,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Authenticate to access BTC Baran',
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔐 Biometric Authentication Error: $e');
      }
      return false;
    }
  }

  // Security Checks
  static Future<bool> _checkRootDetection() async {
    try {
      if (Platform.isAndroid) {
        // Check for common root indicators
        final rootIndicators = [
          '/system/app/Superuser.apk',
          '/sbin/su',
          '/system/bin/su',
          '/system/xbin/su',
          '/data/local/xbin/su',
          '/data/local/bin/su',
          '/system/sd/xbin/su',
          '/system/bin/failsafe/su',
          '/data/local/su',
        ];

        for (final indicator in rootIndicators) {
          if (await File(indicator).exists()) {
            if (kDebugMode) {
              print('🔐 Root detected: $indicator');
            }
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkDebugMode() async {
    try {
      if (kDebugMode) {
        if (kDebugMode) {
          print('🔐 Debug mode detected');
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkEmulatorDetection() async {
    try {
      if (Platform.isAndroid) {
        // Check for emulator indicators
        final emulatorIndicators = [
          'goldfish',
          'ranchu',
          'vbox86',
          'generic',
          'sdk_gphone',
        ];

        final model = Platform.environment['MODEL'] ?? '';
        final manufacturer = Platform.environment['MANUFACTURER'] ?? '';
        final brand = Platform.environment['BRAND'] ?? '';

        for (final indicator in emulatorIndicators) {
          if (model.toLowerCase().contains(indicator) ||
              manufacturer.toLowerCase().contains(indicator) ||
              brand.toLowerCase().contains(indicator)) {
            if (kDebugMode) {
              print('🔐 Emulator detected: $indicator');
            }
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Data Encryption
  static String encryptData(String data, String key) {
    try {
      final bytes = utf8.encode(data);
      final keyBytes = utf8.encode(key);
      final hmac = Hmac(sha256, keyBytes);
      final digest = hmac.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  static String decryptData(String encryptedData, String key) {
    // Note: This is a simple hash-based encryption for demo purposes
    // In production, use proper encryption libraries like encrypt package
    return encryptedData;
  }

  // Secure Random Generation
  static String generateSecureRandom({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  static String generateSecureToken() {
    return generateSecureRandom(length: 64);
  }

  // Device Fingerprinting
  static Future<String> getDeviceFingerprint() async {
    try {
      final deviceInfo = {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
        'numberOfProcessors': Platform.numberOfProcessors,
        'pathSeparator': Platform.pathSeparator,
      };

      final fingerprint = jsonEncode(deviceInfo);
      return encryptData(fingerprint, 'device_fingerprint_key');
    } catch (e) {
      return generateSecureToken();
    }
  }

  // Security Validation
  static Future<bool> validateSecurityIntegrity() async {
    try {
      // Check if app is running in a secure environment
      final isRooted = await _checkRootDetection();
      final isEmulator = await _checkEmulatorDetection();
      final isDebugMode = await _checkDebugMode();

      // Log security status
      if (kDebugMode) {
        print('🔐 Security Status:');
        print('  - Rooted: $isRooted');
        print('  - Emulator: $isEmulator');
        print('  - Debug Mode: $isDebugMode');
      }

      // Return true if no security issues detected
      return !isRooted && !isEmulator && !isDebugMode;
    } catch (e) {
      if (kDebugMode) {
        print('🔐 Security validation error: $e');
      }
      return false;
    }
  }

  // Secure Storage
  static Future<void> setSecureData(String key, String value) async {
    try {
      final encryptedValue = encryptData(value, 'secure_storage_key');
      await LocalStorageService.setString('secure_$key', encryptedValue);
    } catch (e) {
      throw Exception('Failed to store secure data: $e');
    }
  }

  static String? getSecureData(String key) {
    try {
      final encryptedValue = LocalStorageService.getString('secure_$key');
      if (encryptedValue == null) return null;
      return decryptData(encryptedValue, 'secure_storage_key');
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeSecureData(String key) async {
    await LocalStorageService.remove('secure_$key');
  }

  // Session Security
  static Future<void> startSecureSession() async {
    try {
      final sessionId = generateSecureToken();
      final deviceFingerprint = await getDeviceFingerprint();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await setSecureData('session_id', sessionId);
      await setSecureData('device_fingerprint', deviceFingerprint);
      await setSecureData('session_start', timestamp.toString());

      if (kDebugMode) {
        print('🔐 Secure session started: $sessionId');
      }
    } catch (e) {
      throw Exception('Failed to start secure session: $e');
    }
  }

  static Future<void> endSecureSession() async {
    try {
      await removeSecureData('session_id');
      await removeSecureData('device_fingerprint');
      await removeSecureData('session_start');

      if (kDebugMode) {
        print('🔐 Secure session ended');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔐 Error ending secure session: $e');
      }
    }
  }

  static Future<bool> validateSession() async {
    try {
      final sessionId = getSecureData('session_id');
      final deviceFingerprint = getSecureData('device_fingerprint');
      final sessionStart = getSecureData('session_start');

      if (sessionId == null || deviceFingerprint == null || sessionStart == null) {
        return false;
      }

      // Check session expiry (24 hours)
      final startTime = DateTime.fromMillisecondsSinceEpoch(int.parse(sessionStart));
      final now = DateTime.now();
      final sessionDuration = now.difference(startTime);

      if (sessionDuration.inHours > 24) {
        await endSecureSession();
        return false;
      }

      // Validate device fingerprint
      final currentFingerprint = await getDeviceFingerprint();
      if (deviceFingerprint != currentFingerprint) {
        await endSecureSession();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Cleanup
  static Future<void> dispose() async {
    await endSecureSession();
    _isInitialized = false;
  }
}