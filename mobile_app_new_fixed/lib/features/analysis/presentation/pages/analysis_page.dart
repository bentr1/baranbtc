import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_utils.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  int _selectedTab = 0;
  String _selectedCrypto = 'BTCUSDT';
  String _selectedTimeframe = '1D';

  final List<String> _cryptos = ['BTCUSDT', 'ETHUSDT', 'ADAUSDT', 'SOLUSDT'];
  final List<String> _timeframes = ['1H', '4H', '1D', '1W'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical Analysis',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Crypto and Timeframe Selector
          _buildSelectorBar(),

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

  Widget _buildSelectorBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Crypto Selector
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCrypto,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedCrypto = value!;
                    });
                  },
                  items: _cryptos.map((crypto) {
                    return DropdownMenuItem(
                      value: crypto,
                      child: Text(crypto),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Timeframe Selector
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeframe,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeframe = value!;
                    });
                  },
                  items: _timeframes.map((timeframe) {
                    return DropdownMenuItem(
                      value: timeframe,
                      child: Text(timeframe),
                    );
                  }).toList(),
                ),
              ),
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
            child: _buildTabButton('Overview', 0),
          ),
          Expanded(
            child: _buildTabButton('Indicators', 1),
          ),
          Expanded(
            child: _buildTabButton('Signals', 2),
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
        return _buildOverviewTab();
      case 1:
        return _buildIndicatorsTab();
      case 2:
        return _buildSignalsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Summary
          Text(
            'Market Summary',
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
                child: _buildSummaryCard(
                  'Trend',
                  'Bullish',
                  AppConfig.successColor,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSummaryCard(
                  'Momentum',
                  'Strong',
                  AppConfig.infoColor,
                  Icons.speed,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Volume',
                  'High',
                  AppConfig.warningColor,
                  Icons.bar_chart,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSummaryCard(
                  'Volatility',
                  'Medium',
                  AppConfig.accentColor,
                  Icons.show_chart,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Price Levels
          Text(
            'Key Price Levels',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          _buildPriceLevelCard(
            'Support Level 1',
            '\$42,100',
            'Strong support zone',
            AppConfig.successColor,
          ),
          SizedBox(height: 12.h),
          _buildPriceLevelCard(
            'Support Level 2',
            '\$40,500',
            'Secondary support',
            AppConfig.successColor,
          ),
          SizedBox(height: 12.h),
          _buildPriceLevelCard(
            'Resistance Level 1',
            '\$44,500',
            'Key resistance',
            AppConfig.errorColor,
          ),
          SizedBox(height: 12.h),
          _buildPriceLevelCard(
            'Resistance Level 2',
            '\$46,000',
            'Strong resistance',
            AppConfig.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            icon,
            size: 32.w,
            color: color,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
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
        ],
      ),
    );
  }

  Widget _buildPriceLevelCard(
      String title, String price, String description, Color color) {
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
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  price,
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

  Widget _buildIndicatorsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Indicators',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          // RSI
          _buildIndicatorCard(
            'RSI (14)',
            '65.4',
            'Neutral',
            AppConfig.infoColor,
            'Relative Strength Index indicates neutral momentum',
          ),
          SizedBox(height: 12.h),

          // MACD
          _buildIndicatorCard(
            'MACD',
            'Bullish',
            'Positive',
            AppConfig.successColor,
            'Moving Average Convergence Divergence shows bullish signal',
          ),
          SizedBox(height: 12.h),

          // Bollinger Bands
          _buildIndicatorCard(
            'Bollinger Bands',
            'Upper',
            'Near resistance',
            AppConfig.warningColor,
            'Price is near upper Bollinger Band resistance',
          ),
          SizedBox(height: 12.h),

          // SMA
          _buildIndicatorCard(
            'SMA (20)',
            '\$42,800',
            'Support',
            AppConfig.successColor,
            '20-period Simple Moving Average provides support',
          ),
          SizedBox(height: 12.h),

          // EMA
          _buildIndicatorCard(
            'EMA (50)',
            '\$41,500',
            'Trend',
            AppConfig.infoColor,
            '50-period Exponential Moving Average shows trend direction',
          ),
          SizedBox(height: 12.h),

          // Stochastic
          _buildIndicatorCard(
            'Stochastic',
            '78.2',
            'Overbought',
            AppConfig.warningColor,
            'Stochastic oscillator indicates overbought conditions',
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(String name, String value, String signal,
      Color color, String description) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacityDouble(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  signal,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
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
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Signals',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          // Buy Signals
          _buildSignalSection(
            'Buy Signals',
            AppConfig.successColor,
            [
              'MACD bullish crossover',
              'RSI above 50',
              'Price above SMA(20)',
              'Volume increasing',
            ],
          ),

          SizedBox(height: 24.h),

          // Sell Signals
          _buildSignalSection(
            'Sell Signals',
            AppConfig.errorColor,
            [
              'Stochastic overbought',
              'Price near resistance',
              'Volume decreasing',
            ],
          ),

          SizedBox(height: 24.h),

          // Neutral Signals
          _buildSignalSection(
            'Neutral Signals',
            AppConfig.infoColor,
            [
              'RSI in neutral zone',
              'Price consolidating',
              'Mixed volume signals',
            ],
          ),

          SizedBox(height: 24.h),

          // Overall Signal
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppConfig.successColor.withOpacityDouble(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppConfig.successColor.withOpacityDouble(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppConfig.successColor,
                  size: 32.w,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Signal',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppConfig.successColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Bullish',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.successColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Strong buy signals with good risk/reward ratio',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalSection(String title, Color color, List<String> signals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 12.h),
        ...signals.map((signal) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      signal,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
