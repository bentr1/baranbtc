import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/onboarding_screen.dart';
import '../../core/widgets/splash_screen.dart';
import '../../features/analysis/presentation/pages/analysis_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/mfa_setup_page.dart';
import '../../features/auth/presentation/pages/mfa_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/crypto/presentation/pages/crypto_detail_page.dart';
import '../../features/crypto/presentation/pages/crypto_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash and Onboarding
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: '/mfa-setup',
        builder: (context, state) => const MFASetupPage(),
      ),
      GoRoute(
        path: '/mfa-verification',
        builder: (context, state) => const MFAVerificationPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/crypto',
        builder: (context, state) => const CryptoListPage(),
      ),
      GoRoute(
        path: '/crypto/:symbol',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol']!;
          return CryptoDetailPage(symbol: symbol);
        },
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) => const AnalysisPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}