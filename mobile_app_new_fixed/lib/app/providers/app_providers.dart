import '../providers/auth/auth_provider.dart';
import '../providers/crypto/crypto_provider.dart';

// App-wide providers
final appProviders = [
  authProvider,
  authStateProvider,
  isAuthenticatedProvider,
  currentUserProvider,
  isEmailVerifiedProvider,
  isMFASetupProvider,
  biometricAvailableProvider,
  cryptoNotifierProvider,
  priceAlertNotifierProvider,
];
