import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_button.dart';
import 'package:lottie/lottie.dart';

import '../../core/config/app_config.dart';

enum LoadingType { circular, linear, dots, pulse, shimmer }

class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double? size;
  final double? strokeWidth;
  final bool showMessage;

  const LoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.size,
    this.strokeWidth,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? AppConfig.primaryColor;
    final loadingSize = size ?? 24.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicator(loadingColor, loadingSize),
        if (showMessage && message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth ?? 3,
          ),
        );

      case LoadingType.linear:
        return SizedBox(
          width: size * 2,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(0.2),
          ),
        );

      case LoadingType.dots:
        return _buildDotsIndicator(color, size);

      case LoadingType.pulse:
        return _buildPulseIndicator(color, size);

      case LoadingType.shimmer:
        return _buildShimmerIndicator(color, size);
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
            duration: Duration(milliseconds: 600 + (index * 200)),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(1 - value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildShimmerIndicator(Color color, double size) {
    return Container(
      width: size * 2,
      height: size * 0.5,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -1.0, end: 1.0),
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(value - 0.3, 0.0),
                end: Alignment(value + 0.3, 0.0),
                colors: [
                  color.withOpacity(0.0),
                  color.withOpacity(0.8),
                  color.withOpacity(0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.25),
            ),
          );
        },
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final LoadingType loadingType;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.loadingType = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: LoadingIndicator(
                type: loadingType,
                message: message,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final ButtonType type;
  final ButtonSize size;
  final bool isFullWidth;
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
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: widget.isLoading ? (widget.loadingText ?? 'Yükleniyor...') : widget.text,
      onPressed: widget.isLoading ? null : widget.onPressed,
      type: widget.type,
      size: widget.size,
      isFullWidth: widget.isFullWidth,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      isLoading: widget.isLoading,
    );
  }
}

class LoadingPage extends StatelessWidget {
  final String? message;
  final LoadingType loadingType;
  final Color? backgroundColor;

  const LoadingPage({
    super.key,
    this.message,
    this.loadingType = LoadingType.circular,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: Center(
        child: LoadingIndicator(
          type: loadingType,
          message: message,
          color: AppConfig.primaryColor,
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceContainerHighest;
    final highlightColor = widget.highlightColor ?? theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
