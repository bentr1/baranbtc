import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import 'custom_button.dart';

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
