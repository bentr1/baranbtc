import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _uuid = Uuid();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _deviceIdKey = 'device_id';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      if (token == null) return false;
      
      // Check if token is expired
      final tokenData = _parseJwt(token);
      if (tokenData == null) return false;
      
      final expiry = DateTime.fromMillisecondsSinceEpoch(tokenData['exp'] * 1000);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, try to refresh
        try {
          await refreshToken();
          return true;
        } catch (e) {
          await logout();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData == null) return null;
      
      return User.fromJson(jsonDecode(userData));
    } catch (e) {
      return null;
    }
  }

  // Login
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': _hashPassword(password),
        'deviceId': deviceId,
        'deviceName': await _getDeviceName(),
        'deviceType': Platform.isIOS ? 'ios' : 'android',
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final refreshToken = response['data']['refreshToken'];

        // Store tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register
  static Future<User> register({
    required String email,
    required String password,
    required String tcId,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      
      final response = await ApiService.post('/auth/register', {
        'email': email,
        'password': _hashPassword(password),
        'tcId': tcId,
        'firstName': firstName,
        'lastName': lastName,
        'deviceId': deviceId,
        'deviceName': await _getDeviceName(),
        'deviceType': Platform.isIOS ? 'ios' : 'android',
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final refreshToken = response['data']['refreshToken'];

        // Store tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Call logout endpoint
      final token = await _storage.read(key: _authTokenKey);
      if (token != null) {
        try {
          await ApiService.post('/auth/logout', {});
        } catch (e) {
          // Ignore logout API errors
        }
      }

      // Clear stored data
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
      
      // Clear local storage
      await LocalStorageService.clear();
    } catch (e) {
      // Ensure data is cleared even if there's an error
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
    }
  }

  // Refresh token
  static Future<User> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await ApiService.post('/auth/refresh', {
        'refreshToken': refreshToken,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final newToken = response['data']['token'];
        final newRefreshToken = response['data']['refreshToken'];

        // Update stored tokens and user data
        await _storage.write(key: _authTokenKey, value: newToken);
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      await logout();
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Verify email
  static Future<void> verifyEmail(String token) async {
    try {
      final response = await ApiService.post('/auth/verify-email', {
        'token': token,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  // Forgot password
  static Future<void> forgotPassword(String email) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': email,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Password reset request failed');
      }
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post('/auth/reset-password', {
        'token': token,
        'newPassword': _hashPassword(newPassword),
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Setup MFA
  static Future<String> setupMFA() async {
    try {
      final response = await ApiService.post('/auth/mfa/setup', {});

      if (response['success']) {
        return response['data']['secret'];
      } else {
        throw Exception(response['message'] ?? 'MFA setup failed');
      }
    } catch (e) {
      throw Exception('MFA setup failed: ${e.toString()}');
    }
  }

  // Verify MFA
  static Future<void> verifyMFA(String code) async {
    try {
      final response = await ApiService.post('/auth/mfa/verify', {
        'code': code,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'MFA verification failed');
      }
    } catch (e) {
      throw Exception('MFA verification failed: ${e.toString()}');
    }
  }

  // Update profile
  static Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await ApiService.put('/users/profile', {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        
        // Update stored user data
        await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
        
        return user;
      } else {
        throw Exception(response['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.put('/users/change-password', {
        'currentPassword': _hashPassword(currentPassword),
        'newPassword': _hashPassword(newPassword),
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Password change failed');
      }
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      final response = await ApiService.delete('/users/account');

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Account deletion failed');
      }

      await logout();
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // Biometric authentication
  static Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  // Enable/disable biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  // Get stored auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Get stored refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Helper methods
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Map<String, dynamic>? _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(resp);
    } catch (e) {
      return null;
    }
  }

  static Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = _uuid.v4();
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  static Future<String> _getDeviceName() async {
    try {
      if (Platform.isIOS) {
        return 'iOS Device';
      } else if (Platform.isAndroid) {
        return 'Android Device';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }
}
