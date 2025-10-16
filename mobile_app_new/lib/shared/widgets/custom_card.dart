import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/config/app_config.dart';

enum CardType { elevated, outlined, filled }

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final CardType type;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BoxShadow? shadow;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.type = CardType.elevated,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(borderRadius ?? AppConfig.defaultRadius.r),
        border: _getBorder(theme),
        boxShadow: _getBoxShadow(theme),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.w),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConfig.defaultRadius.r),
        child: card,
      );
    }

    return card;
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case CardType.elevated:
        return theme.cardColor;
      case CardType.outlined:
        return theme.cardColor;
      case CardType.filled:
        return theme.colorScheme.surfaceVariant;
    }
  }

  Border? _getBorder(ThemeData theme) {
    if (type == CardType.outlined) {
      return Border.all(
        color: borderColor ?? theme.dividerColor,
        width: 1,
      );
    }
    return null;
  }

  List<BoxShadow>? _getBoxShadow(ThemeData theme) {
    if (shadow != null) return [shadow!];

    switch (type) {
      case CardType.elevated:
        return [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case CardType.outlined:
      case CardType.filled:
        return null;
    }
  }
}

class CryptoCard extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double changePercent24h;
  final VoidCallback? onTap;
  final bool isSelected;

  const CryptoCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = changePercent24h > 0;
    final isNegative = changePercent24h < 0;

    return CustomCard(
      onTap: onTap,
      type: isSelected ? CardType.filled : CardType.elevated,
      backgroundColor: isSelected 
          ? theme.colorScheme.primary.withOpacity(0.1)
          : null,
      borderColor: isSelected 
          ? theme.colorScheme.primary
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Symbol and Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Change Indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppConfig.bullishColor.withOpacity(0.1)
                      : isNegative
                          ? AppConfig.bearishColor.withOpacity(0.1)
                          : AppConfig.neutralColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${changePercent24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive
                        ? AppConfig.bullishColor
                        : isNegative
                            ? AppConfig.bearishColor
                            : AppConfig.neutralColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Price
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 4.h),

          // Change
          Text(
            '${isPositive ? '+' : ''}\$${change24h.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPositive
                  ? AppConfig.bullishColor
                  : isNegative
                      ? AppConfig.bearishColor
                      : AppConfig.neutralColor,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisCard extends StatelessWidget {
  final String title;
  final String description;
  final String signal;
  final double confidence;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const AnalysisCard({
    super.key,
    required this.title,
    required this.description,
    required this.signal,
    required this.confidence,
    required this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBullish = signal == 'BUY';
    final isBearish = signal == 'SELL';
    final isNeutral = signal == 'HOLD';

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isBullish
                      ? AppConfig.bullishColor.withOpacity(0.1)
                      : isBearish
                          ? AppConfig.bearishColor.withOpacity(0.1)
                          : AppConfig.neutralColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  signal,
                  style: TextStyle(
                    color: isBullish
                        ? AppConfig.bullishColor
                        : isBearish
                            ? AppConfig.bearishColor
                            : AppConfig.neutralColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Description
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          SizedBox(height: 12.h),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Confidence
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16.sp,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Güven: ${(confidence * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              // Timestamp
              Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}sa önce';
    } else {
      return '${difference.inDays}g önce';
    }
  }
}
