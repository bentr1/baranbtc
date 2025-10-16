import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/router/app_router.dart';
import 'core/config/app_config.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Minimal initialization for debugging
  Logger.debug(
      'Debug mode: Starting app with minimal initialization', 'DebugApp');

  runApp(
    ProviderScope(
      child: const BTCBaranMobileAppDebug(),
    ),
  );
}

class BTCBaranMobileAppDebug extends ConsumerWidget {
  const BTCBaranMobileAppDebug({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'BTC Baran Debug',
          debugShowCheckedModeBanner: true,
          theme: AppConfig.lightTheme,
          darkTheme: AppConfig.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
