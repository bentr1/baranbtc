import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/crypto_model.dart';
import '../../../core/services/crypto_service.dart';

// Crypto pairs provider
final cryptoPairsProvider = FutureProvider<List<CryptoPair>>((ref) async {
  return await CryptoService.getCryptoPairs();
});

// Real-time price provider for a specific symbol
final realTimePriceProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  return await CryptoService.getRealTimePrice(symbol: symbol);
});

// Market overview provider
final marketOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await CryptoService.getMarketOverview();
});

// Trading signals provider
final tradingSignalsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, String?>>((ref, params) async {
  return await CryptoService.getTradingSignals(
    symbol: params['symbol'],
    timeframe: params['timeframe'] ?? '1d',
    limit: int.tryParse(params['limit'] ?? '20') ?? 20,
  );
});

// Price alerts provider
final priceAlertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await CryptoService.getPriceAlerts();
});

// Candlestick data provider
final candlestickDataProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  return await CryptoService.getCandlestickData(
    symbol: params['symbol'] as String,
    interval: params['interval'] as String? ?? '1d',
    limit: params['limit'] as int? ?? 100,
  );
});

// Crypto state notifier for managing crypto data
class CryptoNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  CryptoNotifier() : super(const AsyncValue.loading());

  Future<void> loadMarketOverview() async {
    state = const AsyncValue.loading();
    try {
      final data = await CryptoService.getMarketOverview();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadCryptoPairs() async {
    state = const AsyncValue.loading();
    try {
      final pairs = await CryptoService.getCryptoPairs();
      state = AsyncValue.data({'pairs': pairs});
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshData() async {
    await loadMarketOverview();
  }
}

final cryptoNotifierProvider = StateNotifierProvider<CryptoNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return CryptoNotifier();
});

// Price alert notifier
class PriceAlertNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  PriceAlertNotifier() : super(const AsyncValue.loading());

  Future<void> loadAlerts() async {
    state = const AsyncValue.loading();
    try {
      final alerts = await CryptoService.getPriceAlerts();
      state = AsyncValue.data(alerts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createAlert({
    required String symbol,
    required double targetPrice,
    required String condition,
  }) async {
    try {
      await CryptoService.createPriceAlert(
        symbol: symbol,
        targetPrice: targetPrice,
        condition: condition,
      );
      // Reload alerts after creating
      await loadAlerts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      await CryptoService.deletePriceAlert(alertId: alertId);
      // Reload alerts after deleting
      await loadAlerts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final priceAlertNotifierProvider = StateNotifierProvider<PriceAlertNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return PriceAlertNotifier();
});
