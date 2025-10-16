import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import 'custom_button.dart';

class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;
  final String? message;
  final bool showMessage;
  final LoadingType type;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2.0,
    this.message,
    this.showMessage = false,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? AppConfig.primaryColor;
    final indicatorSize = size ?? 24.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicator(indicatorColor, indicatorSize),
        if (showMessage && message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildIndicator(Color color, double size) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: size * 2,
          child: LinearProgressIndicator(
            backgroundColor: color.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      case LoadingType.dots:
        return _buildDotsIndicator(color, size);
      case LoadingType.pulse:
        return _buildPulseIndicator(color, size);
    }
  }

  Widget _buildDotsIndicator(Color color, double size) {
    return SizedBox(
      width: size * 3,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 600),
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPulseIndicator(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? backgroundColor;
  final Color? loadingColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.backgroundColor,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: LoadingIndicator(
                  message: loadingMessage,
                  showMessage: loadingMessage != null,
                  color: loadingColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final ButtonType type;
  final ButtonSize size;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(context),
        child: _buildButtonContent(context),
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getButtonColors(theme);
    final dimensions = _getButtonDimensions();

    return ElevatedButton.styleFrom(
      backgroundColor: colors.backgroundColor,
      foregroundColor: colors.textColor,
      elevation: type == ButtonType.primary ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        side: type == ButtonType.outline
            ? BorderSide(color: colors.borderColor ?? colors.backgroundColor!)
            : BorderSide.none,
      ),
      padding: dimensions.padding,
      minimumSize: Size(0, dimensions.height),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? _getButtonColors(Theme.of(context)).textColor!,
              ),
            ),
          ),
          if (loadingText != null) ...[
            SizedBox(width: 8.w),
            Text(loadingText!),
          ],
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getButtonDimensions().iconSize),
          SizedBox(width: 8.w),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonColors _getButtonColors(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return ButtonColors(
          backgroundColor: backgroundColor ?? AppConfig.primaryColor,
          textColor: textColor ?? Colors.white,
          borderColor: backgroundColor ?? AppConfig.primaryColor,
        );
      case ButtonType.secondary:
        return ButtonColors(
          backgroundColor: backgroundColor ?? AppConfig.secondaryColor,
          textColor: textColor ?? Colors.white,
          borderColor: backgroundColor ?? AppConfig.secondaryColor,
        );
      case ButtonType.outline:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: textColor ?? AppConfig.primaryColor,
          borderColor: backgroundColor ?? AppConfig.primaryColor,
        );
      case ButtonType.text:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: textColor ?? AppConfig.primaryColor,
          borderColor: Colors.transparent,
        );
      case ButtonType.danger:
        return ButtonColors(
          backgroundColor: backgroundColor ?? AppConfig.errorColor,
          textColor: textColor ?? Colors.white,
          borderColor: backgroundColor ?? AppConfig.errorColor,
        );
    }
  }

  ButtonDimensions _getButtonDimensions() {
    switch (size) {
      case ButtonSize.small:
        return ButtonDimensions(
          height: 32.h,
          fontSize: 12.sp,
          iconSize: 16.sp,
          borderRadius: 8.r,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        );
      case ButtonSize.medium:
        return ButtonDimensions(
          height: 44.h,
          fontSize: 14.sp,
          iconSize: 20.sp,
          borderRadius: 12.r,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        );
      case ButtonSize.large:
        return ButtonDimensions(
          height: 56.h,
          fontSize: 16.sp,
          iconSize: 24.sp,
          borderRadius: 16.r,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        );
    }
  }
}

// Enums
enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}
