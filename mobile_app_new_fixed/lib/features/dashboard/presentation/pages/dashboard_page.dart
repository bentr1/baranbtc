import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppConfig.errorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),

            SizedBox(height: 24.h),

            // Quick Stats
            _buildQuickStats(),

            SizedBox(height: 24.h),

            // Quick Actions
            _buildQuickActions(),

            SizedBox(height: 24.h),

            // Watchlist
            _buildWatchlist(),

            SizedBox(height: 24.h),

            // Market Overview
            _buildMarketOverview(),

            SizedBox(height: 24.h),

            // Recent Alerts
            _buildRecentAlerts(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.person,
                size: 30.w,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Ready to analyze the markets?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Portfolio Value',
            '\$12,450.50',
            '+2.45%',
            AppConfig.successColor,
            Icons.trending_up,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            'Active Alerts',
            '8',
            '3 new',
            AppConfig.warningColor,
            Icons.notifications,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, String change, Color color, IconData icon) {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.w,
                    color: color,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: Colors.grey[400],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              change,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Market Analysis',
                Icons.analytics,
                AppConfig.primaryColor,
                () => context.go('/analysis'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                'Crypto Markets',
                Icons.trending_up,
                AppConfig.successColor,
                () => context.go('/crypto'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Set Alert',
                Icons.notifications_active,
                AppConfig.warningColor,
                () => _showAlertDialog(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                'Portfolio',
                Icons.pie_chart,
                AppConfig.accentColor,
                () => context.go('/portfolio'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 24.w,
                color: color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Watchlist',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/crypto'),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        CustomCard(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildWatchlistItem('BTCUSDT', 'Bitcoin', 43250.50, 2.45),
                SizedBox(height: 12.h),
                _buildWatchlistItem('ETHUSDT', 'Ethereum', 2650.30, -1.23),
                SizedBox(height: 12.h),
                _buildWatchlistItem('ADAUSDT', 'Cardano', 0.485, 5.67),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistItem(
      String symbol, String name, double price, double change) {
    final isPositive = change >= 0;
    final changeColor =
        isPositive ? AppConfig.successColor : AppConfig.errorColor;

    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppConfig.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.currency_bitcoin,
            size: 20.w,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: changeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Overview',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        CustomCard(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildMarketOverviewItem('Fear & Greed Index', '65', 'Greed',
                    AppConfig.successColor),
                SizedBox(height: 12.h),
                _buildMarketOverviewItem('Total Market Cap', '\$1.85T', '+2.1%',
                    AppConfig.successColor),
                SizedBox(height: 12.h),
                _buildMarketOverviewItem('Bitcoin Dominance', '52.3%', '-0.5%',
                    AppConfig.warningColor),
                SizedBox(height: 12.h),
                _buildMarketOverviewItem(
                    '24h Volume', '\$89.2B', '+12.3%', AppConfig.infoColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketOverviewItem(
      String label, String value, String change, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                change,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/notifications'),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        CustomCard(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildAlertItem(
                  'BTCUSDT',
                  'Price reached \$43,000',
                  '2 minutes ago',
                  AppConfig.successColor,
                ),
                SizedBox(height: 12.h),
                _buildAlertItem(
                  'ETHUSDT',
                  'RSI overbought signal',
                  '15 minutes ago',
                  AppConfig.warningColor,
                ),
                SizedBox(height: 12.h),
                _buildAlertItem(
                  'ADAUSDT',
                  'Volume spike detected',
                  '1 hour ago',
                  AppConfig.infoColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(
      String symbol, String message, String time, Color color) {
    return Row(
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$symbol: $message',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppConfig.primaryColor,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Price Alert'),
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
                  content: Text('Price alert set successfully'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: Text('Set Alert'),
          ),
        ],
      ),
    );
  }
}
