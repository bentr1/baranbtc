import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  final String symbol;

  const AnalysisPage({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalysisData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysisData() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _analysisData = {
          'symbol': widget.symbol,
          'pivotTraditional': {
            'signal': 'BUY',
            'confidence': 0.85,
            'description': 'Fiyat pivot noktalarına yaklaşıyor. Güçlü destek seviyesi.',
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          },
          's1r1Touch': {
            'signal': 'HOLD',
            'confidence': 0.65,
            'description': 'Fiyat S1 destek seviyesinde. Dikkatli olun.',
            'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
          },
          'movingAverageTouch': {
            'signal': 'BUY',
            'confidence': 0.78,
            'description': 'Fiyat 50 günlük ortalamaya dokundu. Yükseliş sinyali.',
            'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
          },
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingIndicator(
            message: 'Teknik analiz yükleniyor...',
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.symbol} Analiz'),
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
                'Analiz yüklenirken hata oluştu',
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
                onPressed: _loadAnalysisData,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} Analiz'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysisData,
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
                Tab(text: 'Pivot Traditional'),
                Tab(text: 'S1/R1 Touch'),
                Tab(text: 'Moving Average'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPivotTraditionalTab(),
                _buildS1R1TouchTab(),
                _buildMovingAverageTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPivotTraditionalTab() {
    if (_analysisData == null) return const SizedBox.shrink();

    final data = _analysisData!['pivotTraditional'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis Card
          AnalysisCard(
            title: 'Pivot Traditional Analizi',
            description: data['description'],
            signal: data['signal'],
            confidence: data['confidence'],
            timestamp: data['timestamp'],
            onTap: () {
              // Show detailed analysis
            },
          ),

          SizedBox(height: 24.h),

          // Chart Placeholder
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48.sp,
                    color: AppConfig.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Pivot Traditional Grafiği',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Analysis Details
          Text(
            'Analiz Detayları',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildDetailCard([
            _buildDetailRow('Sinyal', data['signal']),
            _buildDetailRow('Güven Seviyesi', '${(data['confidence'] * 100).toStringAsFixed(0)}%'),
            _buildDetailRow('Son Güncelleme', _formatTimestamp(data['timestamp'])),
            _buildDetailRow('Durum', 'Aktif'),
          ]),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Fiyat Uyarısı',
                  icon: Icons.notifications,
                  type: ButtonType.outline,
                  onPressed: _setPriceAlert,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: 'Paylaş',
                  icon: Icons.share,
                  type: ButtonType.outline,
                  onPressed: _shareAnalysis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildS1R1TouchTab() {
    if (_analysisData == null) return const SizedBox.shrink();

    final data = _analysisData!['s1r1Touch'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis Card
          AnalysisCard(
            title: 'S1/R1 Touch Analizi',
            description: data['description'],
            signal: data['signal'],
            confidence: data['confidence'],
            timestamp: data['timestamp'],
            onTap: () {
              // Show detailed analysis
            },
          ),

          SizedBox(height: 24.h),

          // Chart Placeholder
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48.sp,
                    color: AppConfig.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'S1/R1 Touch Grafiği',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Analysis Details
          Text(
            'Analiz Detayları',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildDetailCard([
            _buildDetailRow('Sinyal', data['signal']),
            _buildDetailRow('Güven Seviyesi', '${(data['confidence'] * 100).toStringAsFixed(0)}%'),
            _buildDetailRow('Son Güncelleme', _formatTimestamp(data['timestamp'])),
            _buildDetailRow('Durum', 'Aktif'),
          ]),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Fiyat Uyarısı',
                  icon: Icons.notifications,
                  type: ButtonType.outline,
                  onPressed: _setPriceAlert,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: 'Paylaş',
                  icon: Icons.share,
                  type: ButtonType.outline,
                  onPressed: _shareAnalysis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovingAverageTab() {
    if (_analysisData == null) return const SizedBox.shrink();

    final data = _analysisData!['movingAverageTouch'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis Card
          AnalysisCard(
            title: 'Moving Average Touch Analizi',
            description: data['description'],
            signal: data['signal'],
            confidence: data['confidence'],
            timestamp: data['timestamp'],
            onTap: () {
              // Show detailed analysis
            },
          ),

          SizedBox(height: 24.h),

          // Chart Placeholder
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48.sp,
                    color: AppConfig.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Moving Average Grafiği',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Analysis Details
          Text(
            'Analiz Detayları',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildDetailCard([
            _buildDetailRow('Sinyal', data['signal']),
            _buildDetailRow('Güven Seviyesi', '${(data['confidence'] * 100).toStringAsFixed(0)}%'),
            _buildDetailRow('Son Güncelleme', _formatTimestamp(data['timestamp'])),
            _buildDetailRow('Durum', 'Aktif'),
          ]),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Fiyat Uyarısı',
                  icon: Icons.notifications,
                  type: ButtonType.outline,
                  onPressed: _setPriceAlert,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: 'Paylaş',
                  icon: Icons.share,
                  type: ButtonType.outline,
                  onPressed: _shareAnalysis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return CustomCard(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
    } else {
      return '${difference.inDays}g önce';
    }
  }

  void _setPriceAlert() {
    // TODO: Implement price alert functionality
  }

  void _shareAnalysis() {
    // TODO: Implement share functionality
  }
}
