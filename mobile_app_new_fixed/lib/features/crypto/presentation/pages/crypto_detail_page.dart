import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_utils.dart';

class CryptoDetailPage extends ConsumerStatefulWidget {
  final String symbol;

  const CryptoDetailPage({super.key, required this.symbol});

  @override
  ConsumerState<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends ConsumerState<CryptoDetailPage> {
  int _selectedTimeframe = 0;
  final List<String> _timeframes = ['1H', '4H', '1D', '1W', '1M'];

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Section
            _buildPriceSection(),

            SizedBox(height: 24.h),

            // Chart Section
            _buildChartSection(),

            SizedBox(height: 24.h),

            // Market Data
            _buildMarketDataSection(),

            SizedBox(height: 24.h),

            // Technical Analysis
            _buildTechnicalAnalysisSection(),

            SizedBox(height: 24.h),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    // Mock data - replace with actual API data
    final currentPrice = 43250.50;
    final change24h = 2.45;
    final changePercent = 0.057;
    final isPositive = change24h >= 0;

    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withOpacityDouble(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.currency_bitcoin,
                    size: 24.w,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bitcoin',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      Text(
                        widget.symbol,
                        style: TextStyle(
                          fontSize: 14.sp,
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
                      '\$${currentPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppConfig.successColor.withOpacityDouble(0.1)
                            : AppConfig.errorColor.withOpacityDouble(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14.w,
                            color: isPositive
                                ? AppConfig.successColor
                                : AppConfig.errorColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${isPositive ? '+' : ''}\$${change24h.toStringAsFixed(2)} (${(changePercent * 100).toStringAsFixed(2)}%)',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isPositive
                                  ? AppConfig.successColor
                                  : AppConfig.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeframe Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Chart',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                Row(
                  children: _timeframes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final timeframe = entry.value;
                    final isSelected = _selectedTimeframe == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeframe = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 4.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppConfig.primaryColor
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          timeframe,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Chart Placeholder
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Chart Coming Soon',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDataSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Data',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildMarketDataRow(
                '24h High', '\$44,250.00', AppConfig.successColor),
            _buildMarketDataRow('24h Low', '\$42,100.00', AppConfig.errorColor),
            _buildMarketDataRow('24h Volume', '\$12.34B', AppConfig.infoColor),
            _buildMarketDataRow(
                'Market Cap', '\$850.2B', AppConfig.accentColor),
            _buildMarketDataRow(
                'Circulating Supply', '19.67M BTC', AppConfig.warningColor),
            _buildMarketDataRow(
                'Max Supply', '21.00M BTC', AppConfig.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDataRow(String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalAnalysisSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Technical Analysis',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/analysis'),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildTechnicalIndicator(
                      'RSI', '65.4', 'Neutral', AppConfig.infoColor),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTechnicalIndicator(
                      'MACD', 'Bullish', 'Positive', AppConfig.successColor),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildTechnicalIndicator(
                      'SMA(20)', '\$42,800', 'Support', AppConfig.successColor),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTechnicalIndicator(
                      'EMA(50)', '\$41,500', 'Trend', AppConfig.infoColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalIndicator(
      String name, String value, String signal, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacityDouble(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacityDouble(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
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
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            signal,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Set Alert',
            onPressed: () => _showAlertDialog(),
            type: ButtonType.outline,
            size: ButtonSize.large,
            icon: Icons.notifications_outlined,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomButton(
            text: 'Add to Watchlist',
            onPressed: () => _addToWatchlist(),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: Icons.star_outline,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark_add),
              title: Text('Add to Watchlist'),
              onTap: () {
                Navigator.pop(context);
                _addToWatchlist();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Set Price Alert'),
              onTap: () {
                Navigator.pop(context);
                _showAlertDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Technical Analysis'),
              onTap: () {
                Navigator.pop(context);
                context.go('/analysis');
              },
            ),
          ],
        ),
      ),
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
            Text(
                'Set an alert when ${widget.symbol} reaches a specific price.'),
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

  void _addToWatchlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.symbol} added to watchlist'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }
}
