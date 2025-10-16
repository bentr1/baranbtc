import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _uuid = Uuid();

  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _deviceIdKey = 'device_id';

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      if (token == null) return false;

      // Check if token is expired
      final tokenData = _parseJwt(token);
      if (tokenData == null) return false;

      final expiry =
          DateTime.fromMillisecondsSinceEpoch(tokenData['exp'] * 1000);
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
    bool rememberMe = false,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();

      final response = await ApiService.post('/auth/login', data: {
        'email': email,
        'password': _hashPassword(password),
        'deviceId': deviceId,
        'deviceName': await _getDeviceName(),
        'deviceType': Platform.isIOS ? 'ios' : 'android',
        'rememberMe': rememberMe,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final refreshToken = response['data']['refreshToken'];

        // Store tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(
            key: _userDataKey, value: jsonEncode(user.toJson()));

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
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();

      final response = await ApiService.post('/auth/register', data: {
        'name': name,
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
        await _storage.write(
            key: _userDataKey, value: jsonEncode(user.toJson()));

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
          await ApiService.post('/auth/logout', data: {});
        } catch (e) {
          // Ignore logout API errors
        }
      }

      // Clear stored data
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      // Clear stored data even if API call fails
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

      final response = await ApiService.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final newRefreshToken = response['data']['refreshToken'];

        // Update stored tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        await _storage.write(
            key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      await logout();
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Verify email
  static Future<void> verifyEmail(String code) async {
    try {
      final response = await ApiService.post('/auth/verify-email', data: {
        'code': code,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  // Resend verification code
  static Future<void> resendVerificationCode() async {
    try {
      final response =
          await ApiService.post('/auth/resend-verification', data: {});

      if (!response['success']) {
        throw Exception(
            response['message'] ?? 'Failed to resend verification code');
      }
    } catch (e) {
      throw Exception('Failed to resend verification code: ${e.toString()}');
    }
  }

  // Forgot password
  static Future<void> forgotPassword(String email) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', data: {
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
      final response = await ApiService.post('/auth/reset-password', data: {
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

  // Generate MFA secret
  static Future<Map<String, String>> generateMFASecret() async {
    try {
      final response = await ApiService.post('/auth/mfa/setup', data: {});

      if (response['success']) {
        return {
          'secret': response['data']['secret'],
          'qrCode': response['data']['qrCode'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to generate MFA secret');
      }
    } catch (e) {
      throw Exception('Failed to generate MFA secret: ${e.toString()}');
    }
  }

  // Verify MFA setup
  static Future<void> verifyMFASetup(String code) async {
    try {
      final response = await ApiService.post('/auth/mfa/verify-setup', data: {
        'code': code,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'MFA setup verification failed');
      }
    } catch (e) {
      throw Exception('MFA setup verification failed: ${e.toString()}');
    }
  }

  // Verify MFA
  static Future<void> verifyMFA(String code) async {
    try {
      final response = await ApiService.post('/auth/mfa/verify', data: {
        'code': code,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'MFA verification failed');
      }
    } catch (e) {
      throw Exception('MFA verification failed: ${e.toString()}');
    }
  }

  // Biometric login
  static Future<User> biometricLogin() async {
    try {
      final deviceId = await _getOrCreateDeviceId();

      final response = await ApiService.post('/auth/biometric-login', data: {
        'deviceId': deviceId,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);
        final token = response['data']['token'];
        final refreshToken = response['data']['refreshToken'];

        // Store tokens and user data
        await _storage.write(key: _authTokenKey, value: token);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(
            key: _userDataKey, value: jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception(response['message'] ?? 'Biometric login failed');
      }
    } catch (e) {
      throw Exception('Biometric login failed: ${e.toString()}');
    }
  }

  // Update profile
  static Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await ApiService.put('/users/profile', data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
      });

      if (response['success']) {
        final user = User.fromJson(response['data']['user']);

        // Update stored user data
        await _storage.write(
            key: _userDataKey, value: jsonEncode(user.toJson()));

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
      final response = await ApiService.put('/users/change-password', data: {
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

      // Clear stored data
      await logout();
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
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
    // This would get the actual device name
    // For now, return a generic name
    return Platform.isIOS ? 'iOS Device' : 'Android Device';
  }
}
