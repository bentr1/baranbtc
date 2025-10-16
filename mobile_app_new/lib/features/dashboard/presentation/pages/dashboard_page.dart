import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
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
            message: 'Dashboard yükleniyor...',
          ),
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
                title: const Text(
                  'BTC Baran',
                  style: TextStyle(
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
                      Icon(
                        Icons.trending_up,
                        size: 60.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Kripto Piyasalarını Takip Edin',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.go('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.go('/settings'),
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
                tabs: const [
                  Tab(text: 'Genel Bakış'),
                  Tab(text: 'Kripto Paralar'),
                  Tab(text: 'Analizler'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildCryptoTab(),
                  _buildAnalysisTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConfig.primaryColor,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin_outlined),
            activeIcon: Icon(Icons.currency_bitcoin),
            label: 'Kripto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Bildirimler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              context.go('/crypto');
              break;
            case 2:
              context.go('/analysis/BTCUSDT');
              break;
            case 3:
              context.go('/notifications');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Summary
          Text(
            'Piyasa Özeti',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Market Cards
          Row(
            children: [
              Expanded(
                child: _buildMarketCard(
                  'Toplam Piyasa Değeri',
                  '\$2.1T',
                  '+2.5%',
                  true,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMarketCard(
                  '24s Hacim',
                  '\$45.2B',
                  '+1.8%',
                  true,
                  Icons.bar_chart,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Top Cryptos
          Text(
            'Popüler Kripto Paralar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Crypto List
          _buildCryptoList(),

          SizedBox(height: 24.h),

          // Quick Actions
          Text(
            'Hızlı İşlemler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildCryptoTab() {
    return const Center(
      child: Text('Kripto Paralar sayfası'),
    );
  }

  Widget _buildAnalysisTab() {
    return const Center(
      child: Text('Analizler sayfası'),
    );
  }

  Widget _buildMarketCard(String title, String value, String change, bool isPositive, IconData icon) {
    final theme = Theme.of(context);
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: AppConfig.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            change,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPositive ? AppConfig.bullishColor : AppConfig.bearishColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList() {
    final cryptos = [
      {'symbol': 'BTC', 'name': 'Bitcoin', 'price': 43250.50, 'change': 2.5},
      {'symbol': 'ETH', 'name': 'Ethereum', 'price': 2650.30, 'change': 1.8},
      {'symbol': 'BNB', 'name': 'Binance Coin', 'price': 315.20, 'change': -0.5},
      {'symbol': 'ADA', 'name': 'Cardano', 'price': 0.45, 'change': 3.2},
    ];

    return Column(
      children: cryptos.map((crypto) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: CryptoCard(
            symbol: crypto['symbol'] as String,
            name: crypto['name'] as String,
            price: crypto['price'] as double,
            change24h: (crypto['price'] as double) * (crypto['change'] as double) / 100,
            changePercent24h: crypto['change'] as double,
            onTap: () => context.go('/crypto/${crypto['symbol']}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Fiyat Uyarısı',
            icon: Icons.notifications,
            type: ButtonType.outline,
            onPressed: () => context.go('/notifications'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomButton(
            text: 'Teknik Analiz',
            icon: Icons.analytics,
            type: ButtonType.outline,
            onPressed: () => context.go('/analysis/BTCUSDT'),
          ),
        ),
      ],
    );
  }
}
