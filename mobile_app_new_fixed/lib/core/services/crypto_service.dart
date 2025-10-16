import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/crypto_model.dart';
import 'api_service.dart';

class CryptoService {
  // Get available crypto pairs
  static Future<List<CryptoPair>> getCryptoPairs({
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await ApiService.get('/crypto/pairs', queryParameters: queryParams);

      if (response['success'] && response['data'] != null) {
        final pairsData = response['data']['pairs'] as List;
        return pairsData.map((pair) => CryptoPair.fromJson(pair)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch crypto pairs');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.getCryptoPairs error: $e');
      }
      rethrow;
    }
  }

  // Get candlestick data
  static Future<List<Map<String, dynamic>>> getCandlestickData({
    required String symbol,
    String interval = '1d',
    int limit = 100,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'interval': interval,
        'limit': limit,
      };
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await ApiService.get(
        '/crypto/candles/$symbol',
        queryParameters: queryParams,
      );

      if (response['success'] && response['data'] != null) {
        final candlesData = response['data']['candles'] as List;
        return candlesData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch candlestick data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.getCandlestickData error: $e');
      }
      rethrow;
    }
  }

  // Get real-time price
  static Future<Map<String, dynamic>> getRealTimePrice({
    required String symbol,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await ApiService.get(
        '/crypto/price/$symbol',
        queryParameters: queryParams,
      );

      if (response['success'] && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch real-time price');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.getRealTimePrice error: $e');
      }
      rethrow;
    }
  }

  // Get market overview
  static Future<Map<String, dynamic>> getMarketOverview({
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await ApiService.get(
        '/crypto/market-overview',
        queryParameters: queryParams,
      );

      if (response['success'] && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch market overview');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.getMarketOverview error: $e');
      }
      rethrow;
    }
  }

  // Get trading signals
  static Future<List<Map<String, dynamic>>> getTradingSignals({
    String? symbol,
    String timeframe = '1d',
    int limit = 20,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'timeframe': timeframe,
        'limit': limit,
      };
      if (symbol != null) {
        queryParams['symbol'] = symbol;
      }
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await ApiService.get(
        '/crypto/signals',
        queryParameters: queryParams,
      );

      if (response['success'] && response['data'] != null) {
        final signalsData = response['data']['signals'] as List;
        return signalsData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch trading signals');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.getTradingSignals error: $e');
      }
      rethrow;
    }
  }

  // Get price alerts
  static Future<List<Map<String, dynamic>>> getPriceAlerts({
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await ApiService.get(
        '/crypto/alerts',
        queryParameters: queryParams,
      );

      if (response['success'] && response['data'] != null) {
        final alertsData = response['data']['alerts'] as List;
        return alertsData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch price alerts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.getPriceAlerts error: $e');
      }
      rethrow;
    }
  }

  // Create price alert
  static Future<Map<String, dynamic>> createPriceAlert({
    required String symbol,
    required double targetPrice,
    required String condition, // 'above' or 'below'
    String? language,
  }) async {
    try {
      final data = {
        'symbol': symbol,
        'targetPrice': targetPrice,
        'condition': condition,
      };

      final response = await ApiService.post('/crypto/alerts', data: data);

      if (response['success'] && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to create price alert');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.createPriceAlert error: $e');
      }
      rethrow;
    }
  }

  // Delete price alert
  static Future<void> deletePriceAlert({
    required String alertId,
  }) async {
    try {
      final response = await ApiService.delete('/crypto/alerts/$alertId');

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Failed to delete price alert');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CryptoService.deletePriceAlert error: $e');
      }
      rethrow;
    }
  }
}
