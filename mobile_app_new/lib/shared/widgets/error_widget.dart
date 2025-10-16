import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../core/config/app_config.dart';

enum ErrorType { network, server, notFound, unauthorized, forbidden, unknown }

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? customIcon;
  final Color? iconColor;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
    this.retryText,
    this.customIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            if (customIcon != null)
              customIcon!
            else
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppConfig.errorColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorInfo.icon,
                  size: 60.sp,
                  color: iconColor ?? AppConfig.errorColor,
                ),
              ),

            SizedBox(height: 24.h),

            // Title
            Text(
              title ?? errorInfo.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Message
            Text(
              message ?? errorInfo.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRetry != null) ...[
              SizedBox(height: 32.h),

              // Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryText ?? 'Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ErrorInfo _getErrorInfo() {
    switch (type) {
      case ErrorType.network:
        return const ErrorInfo(
          icon: Icons.wifi_off,
          title: 'Bağlantı Hatası',
          message: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
        );

      case ErrorType.server:
        return const ErrorInfo(
          icon: Icons.dns,
          title: 'Sunucu Hatası',
          message: 'Sunucu ile bağlantı kurulamadı. Lütfen daha sonra tekrar deneyin.',
        );

      case ErrorType.notFound:
        return const ErrorInfo(
          icon: Icons.search_off,
          title: 'Bulunamadı',
          message: 'Aradığınız içerik bulunamadı.',
        );

      case ErrorType.unauthorized:
        return const ErrorInfo(
          icon: Icons.lock,
          title: 'Yetkisiz Erişim',
          message: 'Bu işlemi gerçekleştirmek için giriş yapmanız gerekiyor.',
        );

      case ErrorType.forbidden:
        return const ErrorInfo(
          icon: Icons.block,
          title: 'Erişim Engellendi',
          message: 'Bu içeriğe erişim yetkiniz bulunmuyor.',
        );

      case ErrorType.unknown:
      default:
        return const ErrorInfo(
          icon: Icons.error_outline,
          title: 'Bir Hata Oluştu',
          message: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
        );
    }
  }
}

class ErrorInfo {
  final IconData icon;
  final String title;
  final String message;

  const ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
  });
}

class ErrorPage extends StatelessWidget {
  final String? title;
  final String? message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? customIcon;

  const ErrorPage({
    super.key,
    this.title,
    this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
    this.retryText,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hata'),
        centerTitle: true,
      ),
      body: CustomErrorWidget(
        title: title,
        message: message,
        type: type,
        onRetry: onRetry,
        retryText: retryText,
        customIcon: customIcon,
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.network,
      message: message,
      onRetry: onRetry,
      retryText: 'Yeniden Bağlan',
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.server,
      message: message,
      onRetry: onRetry,
      retryText: 'Tekrar Dene',
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NotFoundErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.notFound,
      message: message,
      onRetry: onRetry,
      retryText: 'Geri Dön',
    );
  }
}

class UnauthorizedErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const UnauthorizedErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.unauthorized,
      message: message,
      onRetry: onRetry,
      retryText: 'Giriş Yap',
    );
  }
}

class ErrorSnackBar extends StatelessWidget {
  final String message;
  final ErrorType type;
  final VoidCallback? onAction;
  final String? actionText;

  const ErrorSnackBar({
    super.key,
    required this.message,
    this.type = ErrorType.unknown,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppConfig.errorColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            errorInfo.icon,
            color: Colors.white,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText ?? 'Düzelt',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ErrorInfo _getErrorInfo() {
    switch (type) {
      case ErrorType.network:
        return const ErrorInfo(
          icon: Icons.wifi_off,
          title: 'Bağlantı Hatası',
          message: 'İnternet bağlantınızı kontrol edin.',
        );

      case ErrorType.server:
        return const ErrorInfo(
          icon: Icons.dns,
          title: 'Sunucu Hatası',
          message: 'Sunucu ile bağlantı kurulamadı.',
        );

      case ErrorType.notFound:
        return const ErrorInfo(
          icon: Icons.search_off,
          title: 'Bulunamadı',
          message: 'İçerik bulunamadı.',
        );

      case ErrorType.unauthorized:
        return const ErrorInfo(
          icon: Icons.lock,
          title: 'Yetkisiz Erişim',
          message: 'Giriş yapmanız gerekiyor.',
        );

      case ErrorType.forbidden:
        return const ErrorInfo(
          icon: Icons.block,
          title: 'Erişim Engellendi',
          message: 'Bu içeriğe erişim yetkiniz yok.',
        );

      case ErrorType.unknown:
      default:
        return const ErrorInfo(
          icon: Icons.error_outline,
          title: 'Hata',
          message: 'Bir hata oluştu.',
        );
    }
  }
}

void showErrorSnackBar(
  BuildContext context, {
  required String message,
  ErrorType type = ErrorType.unknown,
  VoidCallback? onAction,
  String? actionText,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: ErrorSnackBar(
        message: message,
        type: type,
        onAction: onAction,
        actionText: actionText,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16.w),
    ),
  );
}
