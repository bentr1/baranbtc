import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class CryptoListPage extends ConsumerStatefulWidget {
  const CryptoListPage({super.key});

  @override
  ConsumerState<CryptoListPage> createState() => _CryptoListPageState();
}

class _CryptoListPageState extends ConsumerState<CryptoListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedTimeframe = '1d';
  String _sortBy = 'market_cap';

  final List<String> _timeframes = ['1m', '5m', '15m', '1h', '4h', '1d', '1w'];
  final List<String> _sortOptions = ['market_cap', 'price', 'change', 'volume'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCryptoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptoData() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(
            message: 'Kripto paralar yükleniyor...',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kripto Paralar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Search Bar
                SearchTextField(
                  hint: 'Kripto para ara...',
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                SizedBox(height: 16.h),

                // Timeframe and Sort
                Row(
                  children: [
                    // Timeframe Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedTimeframe,
                        decoration: InputDecoration(
                          labelText: 'Zaman Dilimi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: _timeframes.map((timeframe) {
                          return DropdownMenuItem(
                            value: timeframe,
                            child: Text(timeframe.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeframe = value!;
                          });
                        },
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Sort Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sırala',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: _sortOptions.map((option) {
                          String label;
                          switch (option) {
                            case 'market_cap':
                              label = 'Piyasa Değeri';
                              break;
                            case 'price':
                              label = 'Fiyat';
                              break;
                            case 'change':
                              label = 'Değişim';
                              break;
                            case 'volume':
                              label = 'Hacim';
                              break;
                            default:
                              label = option;
                          }
                          return DropdownMenuItem(
                            value: option,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppConfig.primaryColor,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: AppConfig.primaryColor,
              tabs: const [
                Tab(text: 'Tümü'),
                Tab(text: 'Favoriler'),
                Tab(text: 'Trend'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllCryptosTab(),
                _buildFavoritesTab(),
                _buildTrendingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCryptosTab() {
    final cryptos = _getFilteredCryptos();

    if (cryptos.isEmpty) {
      return EmptyStateWidget(
        type: EmptyStateType.noResults,
        message: 'Arama kriterlerinize uygun kripto para bulunamadı.',
        onAction: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
        },
        actionText: 'Filtreleri Temizle',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: cryptos.length,
      itemBuilder: (context, index) {
        final crypto = cryptos[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: CryptoCard(
            symbol: crypto['symbol'] as String,
            name: crypto['name'] as String,
            price: crypto['price'] as double,
            change24h: crypto['change24h'] as double,
            changePercent24h: crypto['changePercent24h'] as double,
            onTap: () => context.go('/crypto/${crypto['symbol']}'),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return EmptyStateWidget(
      type: EmptyStateType.noFavorites,
      message: 'Henüz favori kripto paranız yok.',
      onAction: () {
        // Navigate to all cryptos tab
        _tabController.animateTo(0);
      },
      actionText: 'Kripto Paraları Görüntüle',
    );
  }

  Widget _buildTrendingTab() {
    final trendingCryptos = _getTrendingCryptos();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: trendingCryptos.length,
      itemBuilder: (context, index) {
        final crypto = trendingCryptos[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: CryptoCard(
            symbol: crypto['symbol'] as String,
            name: crypto['name'] as String,
            price: crypto['price'] as double,
            change24h: crypto['change24h'] as double,
            changePercent24h: crypto['changePercent24h'] as double,
            onTap: () => context.go('/crypto/${crypto['symbol']}'),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredCryptos() {
    final allCryptos = _getAllCryptos();
    
    if (_searchQuery.isEmpty) {
      return allCryptos;
    }

    return allCryptos.where((crypto) {
      final symbol = crypto['symbol'] as String;
      final name = crypto['name'] as String;
      return symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getAllCryptos() {
    return [
      {
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'price': 43250.50,
        'change24h': 1081.25,
        'changePercent24h': 2.56,
      },
      {
        'symbol': 'ETH',
        'name': 'Ethereum',
        'price': 2650.30,
        'change24h': 47.70,
        'changePercent24h': 1.83,
      },
      {
        'symbol': 'BNB',
        'name': 'Binance Coin',
        'price': 315.20,
        'change24h': -1.58,
        'changePercent24h': -0.50,
      },
      {
        'symbol': 'ADA',
        'name': 'Cardano',
        'price': 0.45,
        'change24h': 0.014,
        'changePercent24h': 3.21,
      },
      {
        'symbol': 'SOL',
        'name': 'Solana',
        'price': 98.75,
        'change24h': 2.95,
        'changePercent24h': 3.08,
      },
      {
        'symbol': 'XRP',
        'name': 'XRP',
        'price': 0.52,
        'change24h': 0.01,
        'changePercent24h': 1.96,
      },
      {
        'symbol': 'DOT',
        'name': 'Polkadot',
        'price': 6.85,
        'change24h': 0.21,
        'changePercent24h': 3.16,
      },
      {
        'symbol': 'MATIC',
        'name': 'Polygon',
        'price': 0.89,
        'change24h': 0.02,
        'changePercent24h': 2.30,
      },
    ];
  }

  List<Map<String, dynamic>> _getTrendingCryptos() {
    return _getAllCryptos()
        .where((crypto) => (crypto['changePercent24h'] as double) > 0)
        .toList()
        ..sort((a, b) => (b['changePercent24h'] as double).compareTo(a['changePercent24h'] as double));
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Price Range
            Text(
              'Fiyat Aralığı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Market Cap Range
            Text(
              'Piyasa Değeri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Volume Range
            Text(
              'Hacim',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 32.h),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Filtreleri Uygula',
                onPressed: () {
                  Navigator.pop(context);
                },
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
