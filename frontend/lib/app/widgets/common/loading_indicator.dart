import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';

enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}

enum LoadingSize {
  small,
  medium,
  large,
}

class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final Color? color;
  final String? message;
  final bool showMessage;
  final EdgeInsetsGeometry? padding;

  const LoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
    this.showMessage = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? Theme.of(context).colorScheme.primary;
    final loadingSize = _getLoadingSize();

    Widget indicator;
    switch (type) {
      case LoadingType.circular:
        indicator = SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(
            strokeWidth: _getStrokeWidth(),
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        );
        break;
      case LoadingType.linear:
        indicator = SizedBox(
          width: loadingSize,
          child: LinearProgressIndicator(
            backgroundColor: loadingColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        );
        break;
      case LoadingType.dots:
        indicator = _buildDotsIndicator(loadingColor, loadingSize);
        break;
      case LoadingType.pulse:
        indicator = _buildPulseIndicator(loadingColor, loadingSize);
        break;
    }

    if (showMessage && message != null) {
      return Padding(
        padding: padding ?? EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                textAlign: TextAlign.center,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.all(AppConfig.defaultPadding),
      child: indicator,
    );
  }

  double _getLoadingSize() {
    switch (size) {
      case LoadingSize.small:
        return 24.w;
      case LoadingSize.medium:
        return 40.w;
      case LoadingSize.large:
        return 60.w;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  Widget _buildDotsIndicator(Color color, double size) {
    return SizedBox(
      width: size,
      height: size / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Container(
                  width: size / 6,
                  height: size / 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            child: Container(
              width: size / 6,
              height: size / 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPulseIndicator(Color color, double size) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.4),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(1 - value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final double? opacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? Colors.black).withOpacity(opacity ?? 0.5),
            child: Center(
              child: LoadingIndicator(
                type: LoadingType.circular,
                size: LoadingSize.large,
                message: message,
                showMessage: true,
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
  final Widget? icon;
  final ButtonStyle? style;
  final bool isFullWidth;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.style,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: _buildButtonContent(),
    );

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          const Text('Yükleniyor...'),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8.w),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
