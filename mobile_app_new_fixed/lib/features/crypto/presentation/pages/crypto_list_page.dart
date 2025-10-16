import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';
import '../../../../app/providers/crypto/crypto_provider.dart';
import '../../../../core/models/crypto_model.dart';

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
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppConfig.primaryColor),
                ),
              ),
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
    return Consumer(
      builder: (context, ref, child) {
        final cryptoPairsAsync = ref.watch(cryptoPairsProvider);
        
        return cryptoPairsAsync.when(
          data: (cryptoPairs) {
            // Filter cryptos based on search query
            final filteredCryptos = cryptoPairs.where((crypto) {
              final symbol = crypto.symbol.toLowerCase();
              final baseAsset = crypto.baseAsset.toLowerCase();
              final query = _searchQuery.toLowerCase();
              return symbol.contains(query) || baseAsset.contains(query);
            }).toList();

            if (filteredCryptos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No cryptocurrencies found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(cryptoPairsProvider);
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: filteredCryptos.length,
                itemBuilder: (context, index) {
                  final crypto = filteredCryptos[index];
                  return _buildCryptoItem(crypto);
                },
              ),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppConfig.primaryColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading cryptocurrencies...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.w,
                  color: AppConfig.errorColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load cryptocurrencies',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppConfig.errorColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(cryptoPairsProvider);
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCryptoItem(CryptoPair crypto) {
    final symbol = crypto.symbol;
    final name = crypto.baseAsset;
    final price = crypto.price;
    final change24h = crypto.changePercent24h;
    final volume24h = crypto.volume24h;

    final isPositive = change24h >= 0;
    final changeColor =
        isPositive ? AppConfig.successColor : AppConfig.errorColor;

    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => context.go('/crypto/$symbol'),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Crypto Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.currency_bitcoin,
                size: 24.w,
                color: AppConfig.primaryColor,
              ),
            ),

            SizedBox(width: 16.w),

            // Crypto Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'Vol: ${_formatVolume(volume24h.toInt())}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'High: \$${_formatPrice(crypto.high24h)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatPrice(price)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12.w,
                        color: changeColor,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${isPositive ? '+' : ''}${change24h.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1) {
      return price.toStringAsFixed(2);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toString();
    }
  }

  String _formatMarketCap(int marketCap) {
    if (marketCap >= 1000000000000) {
      return '\$${(marketCap / 1000000000000).toStringAsFixed(1)}T';
    } else if (marketCap >= 1000000000) {
      return '\$${(marketCap / 1000000000).toStringAsFixed(1)}B';
    } else if (marketCap >= 1000000) {
      return '\$${(marketCap / 1000000).toStringAsFixed(1)}M';
    } else {
      return '\$${marketCap.toString()}';
    }
  }
}
