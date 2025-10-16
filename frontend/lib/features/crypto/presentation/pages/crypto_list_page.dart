import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/loading_indicator.dart';

class CryptoListPage extends ConsumerStatefulWidget {
  const CryptoListPage({super.key});

  @override
  ConsumerState<CryptoListPage> createState() => _CryptoListPageState();
}

class _CryptoListPageState extends ConsumerState<CryptoListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Kripto Paralar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh crypto data
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppConfig.defaultPadding.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Kripto ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Crypto List
          Expanded(
            child: _buildCryptoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList() {
    final cryptos = [
      {'symbol': 'BTC/USDT', 'name': 'Bitcoin', 'price': '\$43,250.00', 'change': '+2.5%', 'isPositive': true, 'volume': '2.5B'},
      {'symbol': 'ETH/USDT', 'name': 'Ethereum', 'price': '\$2,650.00', 'change': '-1.2%', 'isPositive': false, 'volume': '1.8B'},
      {'symbol': 'BNB/USDT', 'name': 'Binance Coin', 'price': '\$310.00', 'change': '+0.8%', 'isPositive': true, 'volume': '450M'},
      {'symbol': 'ADA/USDT', 'name': 'Cardano', 'price': '\$0.45', 'change': '+1.5%', 'isPositive': true, 'volume': '320M'},
      {'symbol': 'SOL/USDT', 'name': 'Solana', 'price': '\$95.00', 'change': '-0.5%', 'isPositive': false, 'volume': '280M'},
      {'symbol': 'DOT/USDT', 'name': 'Polkadot', 'price': '\$6.80', 'change': '+3.2%', 'isPositive': true, 'volume': '180M'},
      {'symbol': 'MATIC/USDT', 'name': 'Polygon', 'price': '\$0.85', 'change': '-2.1%', 'isPositive': false, 'volume': '150M'},
      {'symbol': 'AVAX/USDT', 'name': 'Avalanche', 'price': '\$35.00', 'change': '+1.8%', 'isPositive': true, 'volume': '120M'},
      {'symbol': 'LINK/USDT', 'name': 'Chainlink', 'price': '\$14.50', 'change': '+0.3%', 'isPositive': true, 'volume': '95M'},
      {'symbol': 'UNI/USDT', 'name': 'Uniswap', 'price': '\$6.20', 'change': '-1.5%', 'isPositive': false, 'volume': '80M'},
    ];

    final filteredCryptos = cryptos.where((crypto) {
      if (_searchQuery.isEmpty) return true;
      return (crypto['symbol'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (crypto['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding.w),
      itemCount: filteredCryptos.length,
      itemBuilder: (context, index) {
        final crypto = filteredCryptos[index];
        
        return CustomCard(
          margin: EdgeInsets.only(bottom: 12.h),
          onTap: () => context.go('/crypto/${crypto['symbol']}'),
          child: Row(
            children: [
              // Crypto Icon
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppConfig.primaryColor.withOpacity(0.1),
                child: Text(
                  (crypto['symbol'] as String).substring(0, 3),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Crypto Info
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
                    SizedBox(height: 2.h),
                    Text(
                      crypto['name'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Hacim: ${crypto['volume']}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price and Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    crypto['price'] as String,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        crypto['isPositive'] == true 
                            ? Icons.trending_up 
                            : Icons.trending_down,
                        size: 14.w,
                        color: crypto['isPositive'] == true 
                            ? AppConfig.bullishColor 
                            : AppConfig.bearishColor,
                      ),
                      SizedBox(width: 4.w),
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
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
