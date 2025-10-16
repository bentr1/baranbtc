import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class CryptoDetailPage extends ConsumerStatefulWidget {
  final String symbol;

  const CryptoDetailPage({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends ConsumerState<CryptoDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _errorMessage;
  Map<String, dynamic>? _cryptoData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCryptoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptoData() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _cryptoData = {
          'symbol': widget.symbol,
          'name': _getCryptoName(widget.symbol),
          'price': 43250.50,
          'change24h': 1081.25,
          'changePercent24h': 2.56,
          'marketCap': 850000000000,
          'volume24h': 25000000000,
          'circulatingSupply': 19650000,
          'totalSupply': 21000000,
          'maxSupply': 21000000,
          'high24h': 44500.00,
          'low24h': 42000.00,
        };
      });
    }
  }

  String _getCryptoName(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum';
      case 'BNB':
        return 'Binance Coin';
      case 'ADA':
        return 'Cardano';
      case 'SOL':
        return 'Solana';
      case 'XRP':
        return 'XRP';
      case 'DOT':
        return 'Polkadot';
      case 'MATIC':
        return 'Polygon';
      default:
        return symbol;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(
            message: 'Kripto para bilgileri yükleniyor...',
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.symbol),
          centerTitle: true,
        ),
        body: CustomErrorWidget(
          message: _errorMessage,
          onRetry: _loadCryptoData,
        ),
      );
    }

    if (_cryptoData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.symbol),
          centerTitle: true,
        ),
        body: const EmptyStateWidget(
          type: EmptyStateType.notFound,
          message: 'Kripto para bulunamadı.',
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.h,
              floating: false,
              pinned: true,
              backgroundColor: AppConfig.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConfig.primaryColor,
                        AppConfig.secondaryColor,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      Text(
                        _cryptoData!['name'],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '\$${_cryptoData!['price'].toStringAsFixed(2)}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${_cryptoData!['changePercent24h'] > 0 ? '+' : ''}${_cryptoData!['changePercent24h'].toStringAsFixed(2)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _cryptoData!['changePercent24h'] > 0 
                              ? AppConfig.bullishColor 
                              : AppConfig.bearishColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareCrypto,
                ),
              ],
            ),
          ];
        },
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
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Grafik'),
                  Tab(text: 'Detaylar'),
                  Tab(text: 'Analiz'),
                  Tab(text: 'Haberler'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChartTab(),
                  _buildDetailsTab(),
                  _buildAnalysisTab(),
                  _buildNewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
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
                text: 'Teknik Analiz',
                icon: Icons.analytics,
                onPressed: () => context.go('/analysis/${widget.symbol}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
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
                    'Grafik Yükleniyor...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('24s Yüksek', '\$${_cryptoData!['high24h'].toStringAsFixed(2)}'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard('24s Düşük', '\$${_cryptoData!['low24h'].toStringAsFixed(2)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Data
          Text(
            'Piyasa Verileri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildDetailCard([
            _buildDetailRow('Piyasa Değeri', '\$${(_cryptoData!['marketCap'] / 1000000000).toStringAsFixed(2)}B'),
            _buildDetailRow('24s Hacim', '\$${(_cryptoData!['volume24h'] / 1000000000).toStringAsFixed(2)}B'),
            _buildDetailRow('Dolaşımdaki Arz', '${(_cryptoData!['circulatingSupply'] / 1000000).toStringAsFixed(2)}M'),
            _buildDetailRow('Toplam Arz', '${(_cryptoData!['totalSupply'] / 1000000).toStringAsFixed(2)}M'),
            _buildDetailRow('Maksimum Arz', '${(_cryptoData!['maxSupply'] / 1000000).toStringAsFixed(2)}M'),
          ]),

          SizedBox(height: 24.h),

          // Price Data
          Text(
            'Fiyat Verileri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildDetailCard([
            _buildDetailRow('Mevcut Fiyat', '\$${_cryptoData!['price'].toStringAsFixed(2)}'),
            _buildDetailRow('24s Değişim', '${_cryptoData!['change24h'] > 0 ? '+' : ''}\$${_cryptoData!['change24h'].toStringAsFixed(2)}'),
            _buildDetailRow('24s Değişim %', '${_cryptoData!['changePercent24h'] > 0 ? '+' : ''}${_cryptoData!['changePercent24h'].toStringAsFixed(2)}%'),
            _buildDetailRow('24s Yüksek', '\$${_cryptoData!['high24h'].toStringAsFixed(2)}'),
            _buildDetailRow('24s Düşük', '\$${_cryptoData!['low24h'].toStringAsFixed(2)}'),
          ]),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technical Analysis
          Text(
            'Teknik Analiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Analysis Cards
          AnalysisCard(
            title: 'Pivot Traditional',
            description: 'Fiyat pivot noktalarına yaklaşıyor. Güçlü destek seviyesi.',
            signal: 'BUY',
            confidence: 0.85,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            onTap: () => context.go('/analysis/${widget.symbol}'),
          ),

          SizedBox(height: 12.h),

          AnalysisCard(
            title: 'Moving Average Touch',
            description: 'Fiyat 50 günlük ortalamaya dokundu. Yükseliş sinyali.',
            signal: 'BUY',
            confidence: 0.78,
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            onTap: () => context.go('/analysis/${widget.symbol}'),
          ),

          SizedBox(height: 12.h),

          AnalysisCard(
            title: 'S1/R1 Touch',
            description: 'Fiyat S1 destek seviyesinde. Dikkatli olun.',
            signal: 'HOLD',
            confidence: 0.65,
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            onTap: () => context.go('/analysis/${widget.symbol}'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return const Center(
      child: Text('Haberler sayfası'),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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

  void _shareCrypto() {
    // TODO: Implement share functionality
  }

  void _setPriceAlert() {
    // TODO: Implement price alert functionality
  }
}
