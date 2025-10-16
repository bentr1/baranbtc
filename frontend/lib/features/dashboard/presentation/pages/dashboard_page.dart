import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/loading_indicator.dart';
import '../../../../app/widgets/common/error_widget.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('BTC Baran'),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildCryptoTab(),
          _buildAnalysisTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
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
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppConfig.primaryColor,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş geldiniz!',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Bugün nasıl gidiyor?',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Kripto para piyasalarını takip edin ve teknik analizlerle yatırım kararlarınızı destekleyin.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Quick Actions
          Text(
            'Hızlı İşlemler',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.currency_bitcoin,
                  title: 'Kripto Listesi',
                  subtitle: 'Tüm kripto paralar',
                  color: AppConfig.primaryColor,
                  onTap: () => context.go('/crypto'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.analytics,
                  title: 'Teknik Analiz',
                  subtitle: 'BTC/USDT analizi',
                  color: AppConfig.secondaryColor,
                  onTap: () => context.go('/analysis/BTCUSDT'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.notifications,
                  title: 'Bildirimler',
                  subtitle: 'Uyarılar ve güncellemeler',
                  color: AppConfig.warningColor,
                  onTap: () => context.go('/notifications'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.settings,
                  title: 'Ayarlar',
                  subtitle: 'Uygulama ayarları',
                  color: AppConfig.infoColor,
                  onTap: () => context.go('/settings'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 32.h),
          
          // Market Overview
          Text(
            'Piyasa Özeti',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          CustomCard(
            child: Column(
              children: [
                _buildMarketItem('BTC/USDT', '\$43,250.00', '+2.5%', true),
                Divider(height: 24.h),
                _buildMarketItem('ETH/USDT', '\$2,650.00', '-1.2%', false),
                Divider(height: 24.h),
                _buildMarketItem('BNB/USDT', '\$310.00', '+0.8%', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kripto Paralar',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Kripto ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Crypto List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              final cryptos = [
                {'symbol': 'BTC/USDT', 'price': '\$43,250.00', 'change': '+2.5%', 'isPositive': true},
                {'symbol': 'ETH/USDT', 'price': '\$2,650.00', 'change': '-1.2%', 'isPositive': false},
                {'symbol': 'BNB/USDT', 'price': '\$310.00', 'change': '+0.8%', 'isPositive': true},
                {'symbol': 'ADA/USDT', 'price': '\$0.45', 'change': '+1.5%', 'isPositive': true},
                {'symbol': 'SOL/USDT', 'price': '\$95.00', 'change': '-0.5%', 'isPositive': false},
                {'symbol': 'DOT/USDT', 'price': '\$6.80', 'change': '+3.2%', 'isPositive': true},
                {'symbol': 'MATIC/USDT', 'price': '\$0.85', 'change': '-2.1%', 'isPositive': false},
                {'symbol': 'AVAX/USDT', 'price': '\$35.00', 'change': '+1.8%', 'isPositive': true},
                {'symbol': 'LINK/USDT', 'price': '\$14.50', 'change': '+0.3%', 'isPositive': true},
                {'symbol': 'UNI/USDT', 'price': '\$6.20', 'change': '-1.5%', 'isPositive': false},
              ];
              
              final crypto = cryptos[index];
              
              return CustomCard(
                margin: EdgeInsets.only(bottom: 12.h),
                onTap: () => context.go('/crypto/${crypto['symbol']}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppConfig.primaryColor.withOpacity(0.1),
                      child: Text(
                        (crypto['symbol'] as String).substring(0, 3),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crypto['symbol'] as String,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            crypto['price'] as String,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          crypto['change'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: crypto['isPositive'] == true 
                                ? AppConfig.bullishColor 
                                : AppConfig.bearishColor,
                          ),
                        ),
                        Icon(
                          crypto['isPositive'] == true 
                              ? Icons.trending_up 
                              : Icons.trending_down,
                          size: 16.w,
                          color: crypto['isPositive'] == true 
                              ? AppConfig.bullishColor 
                              : AppConfig.bearishColor,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teknik Analiz',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Analysis Cards
          _buildAnalysisCard(
            title: 'Pivot Traditional',
            description: 'R5 seviyesi %50 üzeri kontrolü',
            status: 'Aktif',
            color: AppConfig.primaryColor,
            onTap: () => context.go('/analysis/BTCUSDT'),
          ),
          
          SizedBox(height: 16.h),
          
          _buildAnalysisCard(
            title: 'S1/R1 Temas',
            description: '270 gün sayaç sistemi',
            status: 'İzleniyor',
            color: AppConfig.secondaryColor,
            onTap: () => context.go('/analysis/BTCUSDT'),
          ),
          
          SizedBox(height: 16.h),
          
          _buildAnalysisCard(
            title: 'Hareketli Ortalama',
            description: '25 MA ve 100 MA analizi',
            status: 'Hazır',
            color: AppConfig.infoColor,
            onTap: () => context.go('/analysis/BTCUSDT'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: Column(
        children: [
          // Profile Header
          CustomCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppConfig.primaryColor,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Kullanıcı Adı',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('Profili Düzenle'),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Menu Items
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Bildirimler',
            subtitle: 'Uyarı ayarları',
            onTap: () => context.go('/notifications'),
          ),
          
          _buildMenuItem(
            icon: Icons.security,
            title: 'Güvenlik',
            subtitle: '2FA ve güvenlik ayarları',
            onTap: () => context.go('/settings'),
          ),
          
          _buildMenuItem(
            icon: Icons.help,
            title: 'Yardım',
            subtitle: 'SSS ve destek',
            onTap: () {},
          ),
          
          _buildMenuItem(
            icon: Icons.info,
            title: 'Hakkında',
            subtitle: 'Uygulama bilgileri',
            onTap: () {},
          ),
          
          SizedBox(height: 32.h),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.w,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(String symbol, String price, String change, bool isPositive) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppConfig.primaryColor.withOpacity(0.1),
          child: Text(
            symbol.substring(0, 3),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryColor,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              change,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isPositive ? AppConfig.bullishColor : AppConfig.bearishColor,
              ),
            ),
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 16.w,
              color: isPositive ? AppConfig.bullishColor : AppConfig.bearishColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String description,
    required String status,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.analytics,
              color: color,
              size: 24.w,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppConfig.primaryColor,
              size: 20.w,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
