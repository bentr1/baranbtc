import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/loading_indicator.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  final String symbol;
  
  const AnalysisPage({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  int _selectedAnalysis = 0;
  final List<String> _analysisTypes = ['Pivot Traditional', 'S1/R1 Temas', 'Hareketli Ortalama'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('${widget.symbol} Analizi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh analysis
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Analysis settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Analysis Type Selector
            _buildAnalysisSelector(),
            
            // Chart Section
            _buildChartSection(),
            
            // Analysis Results
            _buildAnalysisResults(),
            
            // Historical Data
            _buildHistoricalData(),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSelector() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analiz Türü',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _analysisTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final analysisType = entry.value;
                final isSelected = _selectedAnalysis == index;
                
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAnalysis = index;
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
                        analysisType,
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
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding.w),
      height: 400.h,
      child: CustomCard(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_analysisTypes[_selectedAnalysis]} Grafiği',
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
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // Download chart
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
                        Icons.analytics,
                        size: 64.w,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Analiz Grafiği',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
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

  Widget _buildAnalysisResults() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analiz Sonuçları',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            _buildAnalysisResult(
              'Mevcut Durum',
              'R5 seviyesi %50 üzeri kontrolü aktif',
              AppConfig.successColor,
              Icons.check_circle,
            ),
            
            _buildAnalysisResult(
              'Sinyal Gücü',
              'Güçlü (85%)',
              AppConfig.warningColor,
              Icons.trending_up,
            ),
            
            _buildAnalysisResult(
              'Son Güncelleme',
              '2 dakika önce',
              AppConfig.infoColor,
              Icons.access_time,
            ),
            
            _buildAnalysisResult(
              'Sonraki Kontrol',
              '5 dakika sonra',
              AppConfig.primaryColor,
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalData() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geçmiş Veriler',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Historical data table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                _buildTableHeader(),
                _buildTableRow('2024-01-15', 'Aktif', '+2.5%', 'Güçlü'),
                _buildTableRow('2024-01-14', 'Pasif', '-1.2%', 'Zayıf'),
                _buildTableRow('2024-01-13', 'Aktif', '+3.1%', 'Güçlü'),
                _buildTableRow('2024-01-12', 'Aktif', '+1.8%', 'Orta'),
                _buildTableRow('2024-01-11', 'Pasif', '-0.5%', 'Zayıf'),
              ],
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
              text: 'Uyarı Kur',
              onPressed: () {
                // Set alert
              },
              backgroundColor: AppConfig.primaryColor,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomButton(
              text: 'Rapor İndir',
              onPressed: () {
                // Download report
              },
              backgroundColor: AppConfig.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(String title, String value, Color color, IconData icon) {
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
          Icon(
            icon,
            color: color,
            size: 20.w,
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
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.r),
      ),
      children: [
        _buildTableCell('Tarih', true),
        _buildTableCell('Durum', true),
        _buildTableCell('Değişim', true),
        _buildTableCell('Güç', true),
      ],
    );
  }

  TableRow _buildTableRow(String date, String status, String change, String strength) {
    return TableRow(
      children: [
        _buildTableCell(date, false),
        _buildTableCell(status, false),
        _buildTableCell(change, false),
        _buildTableCell(strength, false),
      ],
    );
  }

  Widget _buildTableCell(String text, bool isHeader) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader 
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
