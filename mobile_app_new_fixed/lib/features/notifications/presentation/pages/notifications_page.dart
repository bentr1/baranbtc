import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_utils.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Alerts', 'Analysis', 'News'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: Icon(Icons.done_all),
          ),
          IconButton(
            onPressed: _showNotificationSettings,
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          // Notification List
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewAlert,
        backgroundColor: AppConfig.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppConfig.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationList() {
    final notifications = _getFilteredNotifications();

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You\'ll see your alerts and updates here',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    final title = notification['title'] as String;
    final message = notification['message'] as String;
    final time = notification['time'] as String;
    final isRead = notification['isRead'] as bool;
    final priority = notification['priority'] as String;

    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case 'alert':
        typeColor = AppConfig.warningColor;
        typeIcon = Icons.notifications_active;
        break;
      case 'analysis':
        typeColor = AppConfig.infoColor;
        typeIcon = Icons.analytics;
        break;
      case 'news':
        typeColor = AppConfig.primaryColor;
        typeIcon = Icons.article;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.notifications;
    }

    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => _handleNotificationTap(notification),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Notification Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: typeColor.withOpacityDouble(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                typeIcon,
                size: 24.w,
                color: typeColor,
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
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isRead
                                ? Colors.grey[600]
                                : AppConfig.primaryColor,
                          ),
                        ),
                      ),
                      if (priority == 'high')
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: AppConfig.errorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacityDouble(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Button
            IconButton(
              onPressed: () => _showNotificationActions(notification),
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    // Mock data - replace with actual data
    final allNotifications = [
      {
        'type': 'alert',
        'title': 'BTCUSDT Price Alert',
        'message': 'Bitcoin reached your target price of \$43,000',
        'time': '2 minutes ago',
        'isRead': false,
        'priority': 'high',
      },
      {
        'type': 'analysis',
        'title': 'Technical Analysis Update',
        'message': 'RSI indicates overbought conditions for ETHUSDT',
        'time': '15 minutes ago',
        'isRead': false,
        'priority': 'medium',
      },
      {
        'type': 'news',
        'title': 'Market News',
        'message': 'Bitcoin ETF approval expected this week',
        'time': '1 hour ago',
        'isRead': true,
        'priority': 'low',
      },
      {
        'type': 'alert',
        'title': 'ADAUSDT Volume Alert',
        'message': 'Unusual volume spike detected in Cardano',
        'time': '2 hours ago',
        'isRead': true,
        'priority': 'medium',
      },
      {
        'type': 'analysis',
        'title': 'Market Sentiment',
        'message': 'Fear & Greed Index shows extreme greed',
        'time': '3 hours ago',
        'isRead': true,
        'priority': 'low',
      },
    ];

    if (_selectedTab == 0) return allNotifications;

    final selectedType = _tabs[_selectedTab].toLowerCase();
    return allNotifications.where((notification) {
      return notification['type'] == selectedType;
    }).toList();
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    setState(() {
      notification['isRead'] = true;
    });

    // Handle navigation based on notification type
    final type = notification['type'];
    switch (type) {
      case 'alert':
        // Navigate to crypto detail page
        final title = notification['title'] as String;
        if (title.contains('BTCUSDT')) {
          context.go('/crypto/BTCUSDT');
        } else if (title.contains('ETHUSDT')) {
          context.go('/crypto/ETHUSDT');
        } else if (title.contains('ADAUSDT')) {
          context.go('/crypto/ADAUSDT');
        }
        break;
      case 'analysis':
        context.go('/analysis');
        break;
      case 'news':
        // Show news details
        _showNewsDetails(notification);
        break;
    }
  }

  void _showNotificationActions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.mark_as_unread),
              title: Text('Mark as unread'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  notification['isRead'] = false;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                // Implement delete functionality
              },
            ),
            if (notification['type'] == 'alert')
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Alert'),
                onTap: () {
                  Navigator.pop(context);
                  _editAlert(notification);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showNewsDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editAlert(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Target Price (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert updated successfully'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      // Mark all notifications as read
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSettingItem('Price Alerts', true),
            _buildSettingItem('Technical Analysis', true),
            _buildSettingItem('Market News', false),
            _buildSettingItem('Push Notifications', true),
            _buildSettingItem('Email Notifications', false),
            SizedBox(height: 20.h),
            CustomButton(
              text: 'Save Settings',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Settings saved'),
                    backgroundColor: AppConfig.successColor,
                  ),
                );
              },
              isFullWidth: true,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppConfig.primaryColor,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Update setting
            },
            activeColor: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  void _createNewAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Crypto Symbol (e.g., BTCUSDT)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Target Price (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Alert Type',
                border: OutlineInputBorder(),
              ),
              items: [
                'Price Above',
                'Price Below',
                'Volume Spike',
                'RSI Signal'
              ]
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert created successfully'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}
