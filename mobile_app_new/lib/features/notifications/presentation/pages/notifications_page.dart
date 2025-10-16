import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _notifications = [
          {
            'id': '1',
            'type': 'price_alert',
            'title': 'BTC Fiyat Uyarısı',
            'message': 'Bitcoin fiyatı \$43,000 seviyesine ulaştı',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
            'isRead': false,
            'priority': 'high',
          },
          {
            'id': '2',
            'type': 'analysis_signal',
            'title': 'Teknik Analiz Sinyali',
            'message': 'ETH için yeni analiz sinyali: BUY',
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
            'isRead': false,
            'priority': 'medium',
          },
          {
            'id': '3',
            'type': 'market_update',
            'title': 'Piyasa Güncellemesi',
            'message': 'Kripto piyasalarında yükseliş devam ediyor',
            'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
            'isRead': true,
            'priority': 'low',
          },
          {
            'id': '4',
            'type': 'security_alert',
            'title': 'Güvenlik Uyarısı',
            'message': 'Hesabınızda yeni bir giriş tespit edildi',
            'timestamp': DateTime.now().subtract(const Duration(days: 1)),
            'isRead': true,
            'priority': 'high',
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(
            message: 'Bildirimler yükleniyor...',
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bildirimler'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppConfig.errorColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'Bildirimler yüklenirken hata oluştu',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppConfig.errorColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'Tekrar Dene',
                onPressed: _loadNotifications,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openNotificationSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppConfig.primaryColor,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: AppConfig.primaryColor,
              tabs: const [
                Tab(text: 'Tümü'),
                Tab(text: 'Okunmamış'),
                Tab(text: 'Önemli'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllNotificationsTab(),
                _buildUnreadNotificationsTab(),
                _buildImportantNotificationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    if (_notifications.isEmpty) {
      return EmptyStateWidget(
        type: EmptyStateType.noNotifications,
        message: 'Henüz hiç bildiriminiz bulunmuyor.',
        onAction: _openNotificationSettings,
        actionText: 'Bildirim Ayarları',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildUnreadNotificationsTab() {
    final unreadNotifications = _notifications.where((n) => !n['isRead']).toList();

    if (unreadNotifications.isEmpty) {
      return const EmptyStateWidget(
        type: EmptyStateType.noNotifications,
        message: 'Okunmamış bildiriminiz bulunmuyor.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: unreadNotifications.length,
      itemBuilder: (context, index) {
        final notification = unreadNotifications[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildImportantNotificationsTab() {
    final importantNotifications = _notifications.where((n) => n['priority'] == 'high').toList();

    if (importantNotifications.isEmpty) {
      return const EmptyStateWidget(
        type: EmptyStateType.noNotifications,
        message: 'Önemli bildiriminiz bulunmuyor.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: importantNotifications.length,
      itemBuilder: (context, index) {
        final notification = importantNotifications[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final isRead = notification['isRead'] as bool;
    final priority = notification['priority'] as String;
    final type = notification['type'] as String;

    return CustomCard(
      onTap: () => _onNotificationTap(notification),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _getNotificationColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Icon(
              _getNotificationIcon(type),
              color: _getNotificationColor(type),
              size: 24.sp,
            ),
          ),

          SizedBox(width: 16.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (priority == 'high')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppConfig.errorColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'ÖNEMLİ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Message
                Text(
                  notification['message'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // Timestamp
                Text(
                  _formatTimestamp(notification['timestamp'] as DateTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Read indicator
          if (!isRead)
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'price_alert':
        return AppConfig.bullishColor;
      case 'analysis_signal':
        return AppConfig.infoColor;
      case 'market_update':
        return AppConfig.warningColor;
      case 'security_alert':
        return AppConfig.errorColor;
      default:
        return AppConfig.neutralColor;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'price_alert':
        return Icons.trending_up;
      case 'analysis_signal':
        return Icons.analytics;
      case 'market_update':
        return Icons.bar_chart;
      case 'security_alert':
        return Icons.security;
      default:
        return Icons.notifications;
    }
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    setState(() {
      notification['isRead'] = true;
    });

    // Handle navigation based on type
    final type = notification['type'] as String;
    switch (type) {
      case 'price_alert':
      case 'analysis_signal':
        // Navigate to crypto detail or analysis
        break;
      case 'security_alert':
        // Navigate to security settings
        break;
      default:
        // Do nothing
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _openNotificationSettings() {
    // TODO: Navigate to notification settings
  }
}
