import 'dart:io';

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class SecurityService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<void> initialize() async {
    // Initialize security services
    await _checkBiometricAvailability();
  }

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics({
    String? reason,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication is not available');
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to continue',
        authMessages: _getAuthMessages(),
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return result;
    } catch (e) {
      return false;
    }
  }

  // Authenticate with biometrics and get user
  static Future<bool> authenticateWithBiometricsForUser({
    String? reason,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication is not available');
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to access your account',
        authMessages: _getAuthMessages(),
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return result;
    } catch (e) {
      return false;
    }
  }

  // Check if device is secure
  static Future<bool> isDeviceSecure() async {
    try {
      if (Platform.isAndroid) {
        // Check if device has screen lock
        return await _localAuth.isDeviceSupported();
      } else if (Platform.isIOS) {
        // iOS devices are generally secure
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get device security level
  static Future<DeviceSecurityLevel> getDeviceSecurityLevel() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (isAvailable) {
        final biometrics = await getAvailableBiometrics();
        if (biometrics.contains(BiometricType.face)) {
          return DeviceSecurityLevel.faceId;
        } else if (biometrics.contains(BiometricType.fingerprint)) {
          return DeviceSecurityLevel.fingerprint;
        } else if (biometrics.contains(BiometricType.iris)) {
          return DeviceSecurityLevel.iris;
        }
      }
      
      final isSecure = await isDeviceSecure();
      if (isSecure) {
        return DeviceSecurityLevel.pin;
      }
      
      return DeviceSecurityLevel.none;
    } catch (e) {
      return DeviceSecurityLevel.none;
    }
  }

  // Check if app is running in secure environment
  static Future<bool> isSecureEnvironment() async {
    try {
      // Check for common security threats
      if (Platform.isAndroid) {
        // Check for root detection
        if (await _isRooted()) {
          return false;
        }
        
        // Check for debug mode
        if (await _isDebugMode()) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get security recommendations
  static Future<List<SecurityRecommendation>> getSecurityRecommendations() async {
    final recommendations = <SecurityRecommendation>[];
    
    try {
      final securityLevel = await getDeviceSecurityLevel();
      if (securityLevel == DeviceSecurityLevel.none) {
        recommendations.add(SecurityRecommendation.enableScreenLock);
      }
      
      final isAvailable = await isBiometricAvailable();
      if (isAvailable && !await _isBiometricEnabled()) {
        recommendations.add(SecurityRecommendation.enableBiometric);
      }
      
      final isSecure = await isSecureEnvironment();
      if (!isSecure) {
        recommendations.add(SecurityRecommendation.secureDevice);
      }
      
    } catch (e) {
      recommendations.add(SecurityRecommendation.secureDevice);
    }
    
    return recommendations;
  }

  // Private helper methods
  static Future<void> _checkBiometricAvailability() async {
    try {
      await isBiometricAvailable();
    } catch (e) {
      // Handle error silently
    }
  }

  static List<AuthMessages> _getAuthMessages() {
    if (Platform.isAndroid) {
      return [
        AndroidAuthMessages(
          signInTitle: 'Biometric Authentication',
          cancelButton: 'Cancel',
          deviceCredentialsRequiredTitle: 'Device Credentials Required',
          deviceCredentialsSetupDescription: 'Please set up device credentials to use biometric authentication',
          goToSettingsButton: 'Go to Settings',
          goToSettingsDescription: 'Please set up device credentials',
        ),
      ];
    } else if (Platform.isIOS) {
      return [
        IOSAuthMessages(
          cancelButton: 'Cancel',
          goToSettingsButton: 'Go to Settings',
          goToSettingsDescription: 'Please set up Touch ID or Face ID',
          lockOut: 'Biometric authentication is locked. Please use device passcode.',
        ),
      ];
    }
    
    return [];
  }

  static Future<bool> _isRooted() async {
    // This would implement root detection
    // For now, return false
    return false;
  }

  static Future<bool> _isDebugMode() async {
    // This would implement debug mode detection
    // For now, return false
    return false;
  }

  static Future<bool> _isBiometricEnabled() async {
    // This would check if biometric authentication is enabled in app settings
    // For now, return false
    return false;
  }
}

// Enums
enum DeviceSecurityLevel {
  none,
  pin,
  fingerprint,
  faceId,
  iris,
}

enum SecurityRecommendation {
  enableScreenLock,
  enableBiometric,
  secureDevice,
  updateApp,
  enableTwoFactor,
}