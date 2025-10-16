import 'package:flutter/material.dart';
import '../../../core/utils/color_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final Color? iconColor;
  final bool showIcon;
  final ErrorType type;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText,
    this.icon,
    this.iconColor,
    this.showIcon = true,
    this.type = ErrorType.general,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              _buildIcon(theme),
              SizedBox(height: 24.h),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            ],
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacityDouble(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  retryText ?? 'Try Again',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    final iconData = icon ?? _getDefaultIcon();
    final color = iconColor ?? _getDefaultIconColor(theme);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacityDouble(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 48.w,
        color: color,
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.timeout:
        return Icons.timer_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getDefaultIconColor(ThemeData theme) {
    switch (type) {
      case ErrorType.network:
        return AppConfig.warningColor;
      case ErrorType.server:
        return AppConfig.errorColor;
      case ErrorType.notFound:
        return AppConfig.infoColor;
      case ErrorType.permission:
        return AppConfig.warningColor;
      case ErrorType.validation:
        return AppConfig.errorColor;
      case ErrorType.timeout:
        return AppConfig.warningColor;
      default:
        return AppConfig.errorColor;
    }
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  final ErrorType type;
  final bool isDismissible;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
    this.type = ErrorType.general,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getBackgroundColor(theme);
    final textColor = _getTextColor(theme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: backgroundColor.withOpacityDouble(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: textColor,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (isDismissible && onDismiss != null) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor,
                size: 18.w,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 24.w,
                minHeight: 24.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.timeout:
        return Icons.timer_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (type) {
      case ErrorType.network:
        return AppConfig.warningColor.withOpacityDouble(0.1);
      case ErrorType.server:
        return AppConfig.errorColor.withOpacityDouble(0.1);
      case ErrorType.notFound:
        return AppConfig.infoColor.withOpacityDouble(0.1);
      case ErrorType.permission:
        return AppConfig.warningColor.withOpacityDouble(0.1);
      case ErrorType.validation:
        return AppConfig.errorColor.withOpacityDouble(0.1);
      case ErrorType.timeout:
        return AppConfig.warningColor.withOpacityDouble(0.1);
      default:
        return AppConfig.errorColor.withOpacityDouble(0.1);
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (type) {
      case ErrorType.network:
        return AppConfig.warningColor;
      case ErrorType.server:
        return AppConfig.errorColor;
      case ErrorType.notFound:
        return AppConfig.infoColor;
      case ErrorType.permission:
        return AppConfig.warningColor;
      case ErrorType.validation:
        return AppConfig.errorColor;
      case ErrorType.timeout:
        return AppConfig.warningColor;
      default:
        return AppConfig.errorColor;
    }
  }
}

class ErrorSnackBar extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final ErrorType type;

  const ErrorSnackBar({
    super.key,
    required this.message,
    this.onRetry,
    this.type = ErrorType.general,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getBackgroundColor(theme);
    final textColor = _getTextColor(theme);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: textColor,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.timeout:
        return Icons.timer_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (type) {
      case ErrorType.network:
        return AppConfig.warningColor;
      case ErrorType.server:
        return AppConfig.errorColor;
      case ErrorType.notFound:
        return AppConfig.infoColor;
      case ErrorType.permission:
        return AppConfig.warningColor;
      case ErrorType.validation:
        return AppConfig.errorColor;
      case ErrorType.timeout:
        return AppConfig.warningColor;
      default:
        return AppConfig.errorColor;
    }
  }

  Color _getTextColor(ThemeData theme) {
    return Colors.white;
  }
}

// Error types
enum ErrorType {
  general,
  network,
  server,
  notFound,
  permission,
  validation,
  timeout,
}
