import 'package:flutter/material.dart';
import '../../../core/utils/color_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData? icon;
  final Color? iconColor;
  final bool showIcon;
  final EmptyStateType type;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.onAction,
    this.actionText,
    this.icon,
    this.iconColor,
    this.showIcon = true,
    this.type = EmptyStateType.general,
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
            if (onAction != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onAction,
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
                  actionText ?? 'Get Started',
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
      case EmptyStateType.noData:
        return Icons.inbox;
      case EmptyStateType.noSearchResults:
        return Icons.search_off;
      case EmptyStateType.noNetwork:
        return Icons.wifi_off;
      case EmptyStateType.noFavorites:
        return Icons.favorite_border;
      case EmptyStateType.noHistory:
        return Icons.history;
      default:
        return Icons.inbox;
    }
  }

  Color _getDefaultIconColor(ThemeData theme) {
    switch (type) {
      case EmptyStateType.noData:
        return AppConfig.infoColor;
      case EmptyStateType.noSearchResults:
        return AppConfig.warningColor;
      case EmptyStateType.noNetwork:
        return AppConfig.errorColor;
      case EmptyStateType.noFavorites:
        return AppConfig.primaryColor;
      case EmptyStateType.noHistory:
        return AppConfig.secondaryColor;
      default:
        return AppConfig.infoColor;
    }
  }
}

enum EmptyStateType {
  general,
  noData,
  noSearchResults,
  noNetwork,
  noFavorites,
  noHistory,
}
