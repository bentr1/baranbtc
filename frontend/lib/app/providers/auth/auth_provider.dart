import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    // Check if user is already authenticated
    final isAuthenticated = await AuthService.isAuthenticated();
    if (isAuthenticated) {
      final user = await AuthService.getCurrentUser();
      return AuthState.authenticated(user);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await AuthService.login(email: email, password: password);
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String tcId,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await AuthService.register(
        email: email,
        password: password,
        tcId: tcId,
        firstName: firstName,
        lastName: lastName,
      );
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
      state = const AsyncValue.data(AuthState.unauthenticated());
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

  Future<void> verifyEmail(String token) async {
    try {
      await AuthService.verifyEmail(token);
      // Refresh user data after email verification
      final user = await AuthService.getCurrentUser();
      state = AsyncValue.data(AuthState.authenticated(user));
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

  Future<void> setupMFA() async {
    try {
      final mfaSecret = await AuthService.setupMFA();
      // Update state to show MFA setup
      final currentState = state.value;
      if (currentState is AuthenticatedState) {
        state = AsyncValue.data(AuthState.mfaSetup(currentState.user, mfaSecret));
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
      state = const AsyncValue.data(AuthState.unauthenticated());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Auth State
abstract class AuthState {
  const AuthState();
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthenticatedState extends AuthState {
  final User user;
  
  const AuthenticatedState(this.user);
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
