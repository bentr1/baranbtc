import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/loading_indicator.dart';

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
  int _selectedTimeframe = 0;
  final List<String> _timeframes = ['1m', '5m', '15m', '1h', '4h', '1d', '1w'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Add to favorites
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share crypto info
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Price Overview
            _buildPriceOverview(),
            
            // Timeframe Selector
            _buildTimeframeSelector(),
            
            // Chart Placeholder
            _buildChart(),
            
            // Market Data
            _buildMarketData(),
            
            // Analysis Section
            _buildAnalysisSection(),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOverview() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.symbol,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Bitcoin',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$43,250.00',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16.w,
                          color: AppConfig.bullishColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '+2.5%',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppConfig.bullishColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 24h Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('24h Yüksek', '\$44,200.00'),
                ),
                Expanded(
                  child: _buildStatItem('24h Düşük', '\$42,100.00'),
                ),
                Expanded(
                  child: _buildStatItem('24h Hacim', '2.5B'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _timeframes.asMap().entries.map((entry) {
            final index = entry.key;
            final timeframe = entry.value;
            final isSelected = _selectedTimeframe == index;
            
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeframe = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppConfig.primaryColor 
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected 
                          ? AppConfig.primaryColor 
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    timeframe,
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

  Widget _buildChart() {
    return Container(
      margin: EdgeInsets.all(AppConfig.defaultPadding.w),
      height: 300.h,
      child: CustomCard(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fiyat Grafiği',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () {
                          // Open fullscreen chart
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          // Chart settings
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48.w,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Grafik Yükleniyor...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'TradingView widget entegrasyonu yapılacak',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketData() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Piyasa Verileri',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            _buildMarketDataRow('Piyasa Değeri', '\$850.2B'),
            _buildMarketDataRow('Dolaşımdaki Arz', '19.6M BTC'),
            _buildMarketDataRow('Toplam Arz', '21M BTC'),
            _buildMarketDataRow('24s Hacim', '\$2.5B'),
            _buildMarketDataRow('Değişim (7g)', '+5.2%'),
            _buildMarketDataRow('Değişim (30g)', '+12.8%'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teknik Analiz',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            _buildAnalysisItem(
              'Pivot Traditional',
              'R5 seviyesi %50 üzeri kontrolü',
              'Aktif',
              AppConfig.primaryColor,
            ),
            
            _buildAnalysisItem(
              'S1/R1 Temas',
              '270 gün sayaç sistemi',
              'İzleniyor',
              AppConfig.secondaryColor,
            ),
            
            _buildAnalysisItem(
              'Hareketli Ortalama',
              '25 MA ve 100 MA analizi',
              'Hazır',
              AppConfig.infoColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Teknik Analiz',
              onPressed: () => context.go('/analysis/${widget.symbol}'),
              backgroundColor: AppConfig.primaryColor,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomButton(
              text: 'Uyarı Kur',
              onPressed: () {
                // Set price alert
              },
              backgroundColor: AppConfig.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String description, String status, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
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
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
