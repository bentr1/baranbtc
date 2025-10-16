import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool isFullScreen;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: (size ?? 40).w,
          height: (size ?? 40).w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppConfig.primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: indicator,
        ),
      );
    }

    return Center(
      child: indicator,
    );
  }
}