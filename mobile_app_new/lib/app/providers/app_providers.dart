import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth/auth_provider.dart';

// App-wide providers
final appProviders = [
  authProvider,
  authStateProvider,
  isAuthenticatedProvider,
  currentUserProvider,
  isEmailVerifiedProvider,
  isMFASetupProvider,
  biometricAvailableProvider,
];
