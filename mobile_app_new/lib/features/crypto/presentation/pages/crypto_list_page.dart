import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';

class CryptoListPage extends ConsumerStatefulWidget {
  const CryptoListPage({super.key});

  @override
  ConsumerState<CryptoListPage> createState() => _CryptoListPageState();
}

class _CryptoListPageState extends ConsumerState<CryptoListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crypto Markets',
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
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search cryptocurrencies...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          
          // Crypto List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _getFilteredCryptoList().length,
              itemBuilder: (context, index) {
                final crypto = _getFilteredCryptoList()[index];
                return _buildCryptoCard(crypto);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCryptoList() {
    final cryptoList = [
      {
        'symbol': 'BTCUSDT',
        'name': 'Bitcoin',
        'price': 43250.50,
        'change24h': 1250.30,
        'changePercent24h': 2.98,
        'volume24h': 28500000000,
        'marketCap': 850000000000,
      },
      {
        'symbol': 'ETHUSDT',
        'name': 'Ethereum',
        'price': 2650.75,
        'change24h': -45.25,
        'changePercent24h': -1.68,
        'volume24h': 15000000000,
        'marketCap': 320000000000,
      },
      {
        'symbol': 'ADAUSDT',
        'name': 'Cardano',
        'price': 0.485,
        'change24h': 0.025,
        'changePercent24h': 5.43,
        'volume24h': 1200000000,
        'marketCap': 17000000000,
      },
      {
        'symbol': 'SOLUSDT',
        'name': 'Solana',
        'price': 98.45,
        'change24h': 3.20,
        'changePercent24h': 3.36,
        'volume24h': 2500000000,
        'marketCap': 42000000000,
      },
      {
        'symbol': 'DOTUSDT',
        'name': 'Polkadot',
        'price': 7.85,
        'change24h': -0.15,
        'changePercent24h': -1.88,
        'volume24h': 800000000,
        'marketCap': 9500000000,
      },
    ];

    if (_searchQuery.isEmpty) {
      return cryptoList;
    }

    return cryptoList.where((crypto) {
      final symbol = crypto['symbol'].toString().toLowerCase();
      final name = crypto['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return symbol.contains(query) || name.contains(query);
    }).toList();
  }

  Widget _buildCryptoCard(Map<String, dynamic> crypto) {
    final isPositive = crypto['changePercent24h'] > 0;
    final changeColor = isPositive ? AppConfig.successColor : AppConfig.errorColor;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return CustomCard(
      onTap: () => context.go('/crypto/${crypto['symbol']}'),
      child: Row(
        children: [
          // Crypto Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.currency_bitcoin,
              color: AppConfig.primaryColor,
              size: 24.w,
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Crypto Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  crypto['symbol'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Price Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${crypto['price'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    changeIcon,
                    size: 16.w,
                    color: changeColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${isPositive ? '+' : ''}${crypto['changePercent24h'].toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: changeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}