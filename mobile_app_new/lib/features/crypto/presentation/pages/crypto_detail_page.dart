import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';

class CryptoDetailPage extends ConsumerStatefulWidget {
  final String symbol;

  const CryptoDetailPage({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends ConsumerState<CryptoDetailPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.symbol,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Price Overview
          _buildPriceOverview(),
          
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

  Widget _buildPriceOverview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Current Price
          Text(
            '\$43,250.50',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          
          // Price Change
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                color: AppConfig.successColor,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '+2.98% (+$1,250.30)',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppConfig.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Market Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('24h High', '\$44,500.00'),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard('24h Low', '\$42,100.00'),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard('24h Volume', '\$28.5B'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
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
            child: _buildTabButton('Chart', 0),
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
        return _buildChartTab();
      case 1:
        return _buildAnalysisTab();
      case 2:
        return _buildNewsTab();
      default:
        return _buildChartTab();
    }
  }

  Widget _buildChartTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Chart Placeholder
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 64.w,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Price Chart',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Interactive price chart will be displayed here',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Timeframe Selector
          Row(
            children: [
              Expanded(
                child: _buildTimeframeButton('1H', true),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTimeframeButton('4H', false),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTimeframeButton('1D', false),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTimeframeButton('1W', false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeButton(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppConfig.primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Analysis',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Analysis Cards
          _buildAnalysisCard(
            'RSI',
            '65.4',
            'Neutral',
            AppConfig.infoColor,
          ),
          SizedBox(height: 12.h),
          _buildAnalysisCard(
            'MACD',
            'Bullish',
            'Positive momentum',
            AppConfig.successColor,
          ),
          SizedBox(height: 12.h),
          _buildAnalysisCard(
            'Bollinger Bands',
            'Upper',
            'Near resistance',
            AppConfig.warningColor,
          ),
          SizedBox(height: 12.h),
          _buildAnalysisCard(
            'Support Level',
            '\$42,100',
            'Strong support',
            AppConfig.successColor,
          ),
          SizedBox(height: 12.h),
          _buildAnalysisCard(
            'Resistance Level',
            '\$44,500',
            'Key resistance',
            AppConfig.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String indicator, String value, String description, Color color) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indicator,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest News',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          
          // News Items
          _buildNewsItem(
            'Bitcoin Reaches New All-Time High',
            'Bitcoin has reached a new all-time high of $44,500, driven by institutional adoption...',
            '2 hours ago',
          ),
          SizedBox(height: 12.h),
          _buildNewsItem(
            'Major Bank Announces Bitcoin Support',
            'A major bank has announced plans to offer Bitcoin trading services to its clients...',
            '4 hours ago',
          ),
          SizedBox(height: 12.h),
          _buildNewsItem(
            'Regulatory Update: New Guidelines Released',
            'Financial regulators have released new guidelines for cryptocurrency trading...',
            '6 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String title, String description, String time) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                // Add to favorites logic
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Set Price Alert'),
              onTap: () {
                Navigator.pop(context);
                // Set price alert logic
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Share logic
              },
            ),
          ],
        ),
      ),
    );
  }
}