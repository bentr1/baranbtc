import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  int _selectedTab = 0;

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
            onPressed: () => _showSettings(),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Alerts', 0),
          ),
          Expanded(
            child: _buildTabButton('Analysis', 1),
          ),
          Expanded(
            child: _buildTabButton('News', 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppConfig.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildAlertsTab();
      case 1:
        return _buildAnalysisTab();
      case 2:
        return _buildNewsTab();
      default:
        return _buildAlertsTab();
    }
  }

  Widget _buildAlertsTab() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Active Alerts
        Text(
          'Active Alerts',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        
        _buildAlertCard(
          'BTCUSDT',
          'Price Alert',
          'Above \$45,000',
          'Current: \$43,250',
          AppConfig.warningColor,
          Icons.trending_up,
        ),
        SizedBox(height: 12.h),
        
        _buildAlertCard(
          'ETHUSDT',
          'Price Alert',
          'Below \$2,500',
          'Current: \$2,650',
          AppConfig.infoColor,
          Icons.trending_down,
        ),
        SizedBox(height: 12.h),
        
        _buildAlertCard(
          'ADAUSDT',
          'Volume Alert',
          'Volume > 1.5B',
          'Current: 1.2B',
          AppConfig.successColor,
          Icons.bar_chart,
        ),
        
        SizedBox(height: 24.h),
        
        // Recent Alerts
        Text(
          'Recent Alerts',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        
        _buildRecentAlertCard(
          'BTCUSDT',
          'Price Alert Triggered',
          'Price reached \$44,500',
          '2 hours ago',
          AppConfig.successColor,
        ),
        SizedBox(height: 12.h),
        
        _buildRecentAlertCard(
          'ETHUSDT',
          'Support Level Reached',
          'Price touched \$2,600',
          '4 hours ago',
          AppConfig.infoColor,
        ),
        SizedBox(height: 12.h),
        
        _buildRecentAlertCard(
          'ADAUSDT',
          'Resistance Broken',
          'Price broke \$0.50',
          '6 hours ago',
          AppConfig.warningColor,
        ),
      ],
    );
  }

  Widget _buildAlertCard(String symbol, String type, String condition, String current, Color color, IconData icon) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$symbol - $type',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  condition,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  current,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editAlert(symbol),
            icon: Icon(Icons.edit),
            color: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlertCard(String symbol, String title, String description, String time, Color color) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$symbol - $title',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Analysis Notifications',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        
        _buildAnalysisNotificationCard(
          'BTCUSDT',
          'Technical Analysis Updated',
          'New bullish signals detected',
          '2 hours ago',
          AppConfig.successColor,
        ),
        SizedBox(height: 12.h),
        
        _buildAnalysisNotificationCard(
          'ETHUSDT',
          'Support Level Tested',
          'Price testing key support at \$2,600',
          '4 hours ago',
          AppConfig.warningColor,
        ),
        SizedBox(height: 12.h),
        
        _buildAnalysisNotificationCard(
          'ADAUSDT',
          'Breakout Confirmed',
          'Price confirmed breakout above \$0.50',
          '6 hours ago',
          AppConfig.infoColor,
        ),
      ],
    );
  }

  Widget _buildAnalysisNotificationCard(String symbol, String title, String description, String time, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
              Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Market News',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        
        _buildNewsCard(
          'Bitcoin Reaches New High',
          'Bitcoin has reached a new all-time high of \$44,500...',
          '2 hours ago',
          AppConfig.successColor,
        ),
        SizedBox(height: 12.h),
        
        _buildNewsCard(
          'Major Bank Adopts Bitcoin',
          'A major bank has announced plans to offer Bitcoin...',
          '4 hours ago',
          AppConfig.infoColor,
        ),
        SizedBox(height: 12.h),
        
        _buildNewsCard(
          'Regulatory Update',
          'Financial regulators have released new guidelines...',
          '6 hours ago',
          AppConfig.warningColor,
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String description, String time, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add_alert),
              title: Text('Create New Alert'),
              onTap: () {
                Navigator.pop(context);
                // Create new alert logic
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Notification Settings'),
              onTap: () {
                Navigator.pop(context);
                // Notification settings logic
              },
            ),
            ListTile(
              leading: Icon(Icons.clear_all),
              title: Text('Clear All Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Clear all notifications logic
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editAlert(String symbol) {
    // Edit alert logic
  }
}