import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../core/config/app_config.dart';

enum EmptyStateType { noData, noResults, noConnection, noNotifications, noFavorites }

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final EmptyStateType type;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customIcon;
  final Color? iconColor;
  final bool showAction;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.type = EmptyStateType.noData,
    this.onAction,
    this.actionText,
    this.customIcon,
    this.iconColor,
    this.showAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyStateInfo = _getEmptyStateInfo();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Animation
            if (customIcon != null)
              customIcon!
            else
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppConfig.neutralColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emptyStateInfo.icon,
                  size: 60.sp,
                  color: iconColor ?? AppConfig.neutralColor,
                ),
              ),

            SizedBox(height: 24.h),

            // Title
            Text(
              title ?? emptyStateInfo.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Message
            Text(
              message ?? emptyStateInfo.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (showAction && onAction != null) ...[
              SizedBox(height: 32.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(emptyStateInfo.actionIcon),
                  label: Text(actionText ?? emptyStateInfo.actionText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  EmptyStateInfo _getEmptyStateInfo() {
    switch (type) {
      case EmptyStateType.noData:
        return const EmptyStateInfo(
          icon: Icons.inbox_outlined,
          title: 'Veri Bulunamadı',
          message: 'Henüz hiç veri bulunmuyor.',
          actionIcon: Icons.refresh,
          actionText: 'Yenile',
        );

      case EmptyStateType.noResults:
        return const EmptyStateInfo(
          icon: Icons.search_off,
          title: 'Sonuç Bulunamadı',
          message: 'Arama kriterlerinize uygun sonuç bulunamadı.',
          actionIcon: Icons.clear,
          actionText: 'Filtreleri Temizle',
        );

      case EmptyStateType.noConnection:
        return const EmptyStateInfo(
          icon: Icons.wifi_off,
          title: 'Bağlantı Yok',
          message: 'İnternet bağlantınızı kontrol edin.',
          actionIcon: Icons.refresh,
          actionText: 'Tekrar Dene',
        );

      case EmptyStateType.noNotifications:
        return const EmptyStateInfo(
          icon: Icons.notifications_none,
          title: 'Bildirim Yok',
          message: 'Henüz hiç bildiriminiz bulunmuyor.',
          actionIcon: Icons.settings,
          actionText: 'Ayarları Aç',
        );

      case EmptyStateType.noFavorites:
        return const EmptyStateInfo(
          icon: Icons.favorite_border,
          title: 'Favori Yok',
          message: 'Henüz hiç favoriniz bulunmuyor.',
          actionIcon: Icons.add,
          actionText: 'Favori Ekle',
        );
    }
  }
}

class EmptyStateInfo {
  final IconData icon;
  final String title;
  final String message;
  final IconData actionIcon;
  final String actionText;

  const EmptyStateInfo({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionIcon,
    required this.actionText,
  });
}

class EmptyStatePage extends StatelessWidget {
  final String? title;
  final String? message;
  final EmptyStateType type;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customIcon;
  final bool showAppBar;

  const EmptyStatePage({
    super.key,
    this.title,
    this.message,
    this.type = EmptyStateType.noData,
    this.onAction,
    this.actionText,
    this.customIcon,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Boş'),
              centerTitle: true,
            )
          : null,
      body: EmptyStateWidget(
        title: title,
        message: message,
        type: type,
        onAction: onAction,
        actionText: actionText,
        customIcon: customIcon,
      ),
    );
  }
}

class NoDataWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const NoDataWidget({
    super.key,
    this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noData,
      message: message,
      onAction: onRefresh,
      actionText: 'Yenile',
    );
  }
}

class NoResultsWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onClearFilters;

  const NoResultsWidget({
    super.key,
    this.message,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noResults,
      message: message,
      onAction: onClearFilters,
      actionText: 'Filtreleri Temizle',
    );
  }
}

class NoConnectionWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noConnection,
      onAction: onRetry,
      actionText: 'Tekrar Dene',
    );
  }
}

class NoNotificationsWidget extends StatelessWidget {
  final VoidCallback? onOpenSettings;

  const NoNotificationsWidget({
    super.key,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noNotifications,
      onAction: onOpenSettings,
      actionText: 'Ayarları Aç',
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  final VoidCallback? onAddFavorite;

  const NoFavoritesWidget({
    super.key,
    this.onAddFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noFavorites,
      onAction: onAddFavorite,
      actionText: 'Favori Ekle',
    );
  }
}

class LottieEmptyState extends StatelessWidget {
  final String lottiePath;
  final String? title;
  final String? message;
  final VoidCallback? onAction;
  final String? actionText;
  final double? width;
  final double? height;

  const LottieEmptyState({
    super.key,
    required this.lottiePath,
    this.title,
    this.message,
    this.onAction,
    this.actionText,
    this.width,
    this.height,
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
            // Lottie Animation
            SizedBox(
              width: width ?? 200.w,
              height: height ?? 200.w,
              child: Lottie.asset(
                lottiePath,
                fit: BoxFit.contain,
              ),
            ),

            if (title != null) ...[
              SizedBox(height: 24.h),
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (onAction != null) ...[
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionText ?? 'Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
