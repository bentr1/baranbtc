import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: _getButtonStyle(theme),
        child: _buildButtonContent(theme),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final colors = _getButtonColors(theme);
    final dimensions = _getButtonDimensions();

    return ElevatedButton.styleFrom(
      backgroundColor: colors.backgroundColor,
      foregroundColor: colors.textColor,
      elevation: type == ButtonType.primary ? 2 : 0,
      shadowColor: colors.backgroundColor?.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(borderRadius ?? dimensions.borderRadius),
        side: type == ButtonType.outline
            ? BorderSide(color: colors.borderColor ?? colors.backgroundColor!)
            : BorderSide.none,
      ),
      padding: padding ?? dimensions.padding,
      minimumSize: Size(0, dimensions.height),
      maximumSize: Size(double.infinity, dimensions.height),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getButtonDimensions().iconSize,
        width: _getButtonDimensions().iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? _getButtonColors(theme).textColor!,
          ),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getButtonDimensions().iconSize,
            color: textColor ?? _getButtonColors(theme).textColor,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: _getTextStyle(theme),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(theme),
    );
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final dimensions = _getButtonDimensions();
    final baseStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: dimensions.fontSize,
      fontWeight: FontWeight.w600,
      color: textColor ?? _getButtonColors(theme).textColor,
    );

    return baseStyle ??
        TextStyle(
          fontSize: dimensions.fontSize,
          fontWeight: FontWeight.w600,
          color: textColor ?? _getButtonColors(theme).textColor,
        );
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

// Button types
enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

// Helper classes
class ButtonColors {
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  ButtonColors({
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });
}

class ButtonDimensions {
  final double height;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final EdgeInsets padding;

  ButtonDimensions({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.padding,
  });
}
