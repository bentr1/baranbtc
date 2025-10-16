import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;
  final bool showRetryButton;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
    this.iconColor,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(
              icon ?? Icons.error_outline,
              size: 80.w,
              color: iconColor ?? AppConfig.errorColor,
            ),
            
            SizedBox(height: 24.h),
            
            // Error Title
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  textAlign: TextAlign.center,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
            ],
            
            // Error Message
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
            ],
            
            // Retry Button
            if (showRetryButton && onRetry != null)
              CustomButton(
                text: buttonText ?? 'Tekrar Dene',
                onPressed: onRetry,
                type: ButtonType.primary,
                size: ButtonSize.medium,
                icon: Icons.refresh,
              ),
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Bağlantı Hatası',
      message: customMessage ?? 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
      buttonText: 'Tekrar Dene',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      iconColor: AppConfig.warningColor,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Sunucu Hatası',
      message: customMessage ?? 'Sunucuda bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
      buttonText: 'Tekrar Dene',
      onRetry: onRetry,
      icon: Icons.cloud_off,
      iconColor: AppConfig.errorColor,
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onGoBack;

  const NotFoundErrorWidget({
    super.key,
    this.customMessage,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Bulunamadı',
      message: customMessage ?? 'Aradığınız içerik bulunamadı.',
      buttonText: 'Geri Dön',
      onRetry: onGoBack,
      icon: Icons.search_off,
      iconColor: AppConfig.infoColor,
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onRequestPermission;
  final String? customMessage;

  const PermissionErrorWidget({
    super.key,
    this.onRequestPermission,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'İzin Gerekli',
      message: customMessage ?? 'Bu özelliği kullanmak için gerekli izinleri vermeniz gerekiyor.',
      buttonText: 'İzin Ver',
      onRetry: onRequestPermission,
      icon: Icons.lock_outline,
      iconColor: AppConfig.warningColor,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final String? actionText;
  final VoidCallback? onAction;
  final bool showActionButton;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.actionText,
    this.onAction,
    this.showActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80.w,
              color: iconColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            
            SizedBox(height: 24.h),
            
            // Empty State Title
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  textAlign: TextAlign.center,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
            ],
            
            // Empty State Message
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  textAlign: TextAlign.center,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
            ],
            
            // Action Button
            if (showActionButton && actionText != null && onAction != null)
              CustomButton(
                text: actionText!,
                onPressed: onAction,
                type: ButtonType.outline,
                size: ButtonSize.medium,
              ),
          ],
        ),
      ),
    );
  }
}
