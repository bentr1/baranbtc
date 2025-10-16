import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Tümü', 'Fiyat Uyarıları', 'Analiz Sinyalleri', 'Sistem'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // Mark all as read
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Notification settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Selector
          _buildTabSelector(),
          
          // Notifications List
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == index;
            
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppConfig.primaryColor 
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: isSelected 
                          ? AppConfig.primaryColor 
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = _getNotificationsForTab(_selectedTab);
    
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding.w),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Henüz bildirim yok',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Yeni bildirimler burada görünecek',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          // Notification Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: notification['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 20.w,
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (notification['isUnread'])
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
                SizedBox(height: 4.h),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  notification['time'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          if (notification['action'] != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: notification['action'],
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getNotificationsForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Tümü
        return [
          {
            'title': 'BTC/USDT Fiyat Uyarısı',
            'message': 'Bitcoin fiyatı \$43,500 seviyesine ulaştı',
            'time': '5 dakika önce',
            'icon': Icons.trending_up,
            'color': AppConfig.bullishColor,
            'isUnread': true,
            'action': () => context.go('/crypto/BTCUSDT'),
          },
          {
            'title': 'Pivot Traditional Sinyali',
            'message': 'R5 seviyesi %50 üzeri kontrolü aktif',
            'time': '15 dakika önce',
            'icon': Icons.analytics,
            'color': AppConfig.primaryColor,
            'isUnread': true,
            'action': () => context.go('/analysis/BTCUSDT'),
          },
          {
            'title': 'Sistem Güncellemesi',
            'message': 'Uygulama v1.0.1 güncellemesi mevcut',
            'time': '1 saat önce',
            'icon': Icons.system_update,
            'color': AppConfig.infoColor,
            'isUnread': false,
            'action': null,
          },
          {
            'title': 'ETH/USDT Analiz',
            'message': 'Ethereum için yeni teknik analiz hazır',
            'time': '2 saat önce',
            'icon': Icons.analytics,
            'color': AppConfig.secondaryColor,
            'isUnread': false,
            'action': () => context.go('/analysis/ETHUSDT'),
          },
        ];
      case 1: // Fiyat Uyarıları
        return [
          {
            'title': 'BTC/USDT Fiyat Uyarısı',
            'message': 'Bitcoin fiyatı \$43,500 seviyesine ulaştı',
            'time': '5 dakika önce',
            'icon': Icons.trending_up,
            'color': AppConfig.bullishColor,
            'isUnread': true,
            'action': () => context.go('/crypto/BTCUSDT'),
          },
        ];
      case 2: // Analiz Sinyalleri
        return [
          {
            'title': 'Pivot Traditional Sinyali',
            'message': 'R5 seviyesi %50 üzeri kontrolü aktif',
            'time': '15 dakika önce',
            'icon': Icons.analytics,
            'color': AppConfig.primaryColor,
            'isUnread': true,
            'action': () => context.go('/analysis/BTCUSDT'),
          },
          {
            'title': 'ETH/USDT Analiz',
            'message': 'Ethereum için yeni teknik analiz hazır',
            'time': '2 saat önce',
            'icon': Icons.analytics,
            'color': AppConfig.secondaryColor,
            'isUnread': false,
            'action': () => context.go('/analysis/ETHUSDT'),
          },
        ];
      case 3: // Sistem
        return [
          {
            'title': 'Sistem Güncellemesi',
            'message': 'Uygulama v1.0.1 güncellemesi mevcut',
            'time': '1 saat önce',
            'icon': Icons.system_update,
            'color': AppConfig.infoColor,
            'isUnread': false,
            'action': null,
          },
        ];
      default:
        return [];
    }
  }
}
