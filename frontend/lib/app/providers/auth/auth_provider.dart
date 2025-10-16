import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final isAuthenticated = await AuthService.isAuthenticated();
      if (isAuthenticated) {
        final user = await AuthService.getCurrentUser();
        if (user != null) {
          state = AsyncValue.data(AuthState.authenticated(user));
        } else {
          state = AsyncValue.data(AuthState.unauthenticated());
        }
      } else {
        state = AsyncValue.data(AuthState.unauthenticated());
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await AuthService.login(
        email: email, 
        password: password,
        rememberMe: rememberMe,
      );
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
      state = AsyncValue.data(AuthState.unauthenticated());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshToken() async {
    try {
      final user = await AuthService.refreshToken();
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> verifyEmail(String code) async {
    try {
      await AuthService.verifyEmail(code);
      // Refresh user data after email verification
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(AuthState.authenticated(user));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resendVerificationCode() async {
    try {
      await AuthService.resendVerificationCode();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await AuthService.forgotPassword(email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await AuthService.resetPassword(token: token, newPassword: newPassword);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Map<String, String>> generateMFASecret() async {
    try {
      return await AuthService.generateMFASecret();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> verifyMFASetup(String code) async {
    try {
      await AuthService.verifyMFASetup(code);
      // Return to authenticated state
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(AuthState.authenticated(user));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> verifyMFA(String code) async {
    try {
      await AuthService.verifyMFA(code);
      // Return to authenticated state
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(AuthState.authenticated(user));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> biometricLogin() async {
    try {
      final user = await AuthService.biometricLogin();
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final updatedUser = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      state = AsyncValue.data(AuthState.authenticated(updatedUser));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await AuthService.deleteAccount();
      state = AsyncValue.data(AuthState.unauthenticated());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Auth State
abstract class AuthState {
  const AuthState();
  
  static AuthState authenticated(User user) => AuthenticatedState(user);
  static AuthState unauthenticated() => const UnauthenticatedState();
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthenticatedState extends AuthState {
  final User user;
  final bool biometricAvailable;
  
  const AuthenticatedState(this.user, {this.biometricAvailable = false});
}

class MFASetupState extends AuthState {
  final User user;
  final String mfaSecret;
  
  const MFASetupState(this.user, this.mfaSecret);
}

class EmailVerificationState extends AuthState {
  final User user;
  
  const EmailVerificationState(this.user);
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) => AuthNotifier(),
);

final authStateProvider = Provider<AuthState?>((ref) {
  final authAsync = ref.watch(authProvider);
  return authAsync.when(
    data: (state) => state,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState is AuthenticatedState;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthenticatedState) {
    return authState.user;
  }
  return null;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isEmailVerified ?? false;
});

final isMFASetupProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isMFASetup ?? false;
});

final biometricAvailableProvider = Provider<bool>((ref) {
  // This would check if biometric authentication is available
  // For now, return true for demo purposes
  return true;
});
