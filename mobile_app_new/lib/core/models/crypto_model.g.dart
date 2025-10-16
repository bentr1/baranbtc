// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoPair _$CryptoPairFromJson(Map<String, dynamic> json) => CryptoPair(
      symbol: json['symbol'] as String,
      baseAsset: json['baseAsset'] as String,
      quoteAsset: json['quoteAsset'] as String,
      status: json['status'] as String,
      isSpotTradingAllowed: json['isSpotTradingAllowed'] as bool,
      isMarginTradingAllowed: json['isMarginTradingAllowed'] as bool,
      minQty: (json['minQty'] as num).toDouble(),
      maxQty: (json['maxQty'] as num).toDouble(),
      stepSize: (json['stepSize'] as num).toDouble(),
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      tickSize: (json['tickSize'] as num).toDouble(),
      minNotional: (json['minNotional'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CryptoPairToJson(CryptoPair instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'baseAsset': instance.baseAsset,
      'quoteAsset': instance.quoteAsset,
      'status': instance.status,
      'isSpotTradingAllowed': instance.isSpotTradingAllowed,
      'isMarginTradingAllowed': instance.isMarginTradingAllowed,
      'minQty': instance.minQty,
      'maxQty': instance.maxQty,
      'stepSize': instance.stepSize,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'tickSize': instance.tickSize,
      'minNotional': instance.minNotional,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CandlestickData _$CandlestickDataFromJson(Map<String, dynamic> json) =>
    CandlestickData(
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      openTime: DateTime.parse(json['openTime'] as String),
      closeTime: DateTime.parse(json['closeTime'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      quoteVolume: (json['quoteVolume'] as num).toDouble(),
      tradeCount: (json['tradeCount'] as num).toInt(),
      takerBuyBaseVolume: (json['takerBuyBaseVolume'] as num).toDouble(),
      takerBuyQuoteVolume: (json['takerBuyQuoteVolume'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CandlestickDataToJson(CandlestickData instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
      'openTime': instance.openTime.toIso8601String(),
      'closeTime': instance.closeTime.toIso8601String(),
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
      'quoteVolume': instance.quoteVolume,
      'tradeCount': instance.tradeCount,
      'takerBuyBaseVolume': instance.takerBuyBaseVolume,
      'takerBuyQuoteVolume': instance.takerBuyQuoteVolume,
      'createdAt': instance.createdAt.toIso8601String(),
    };

TechnicalAnalysis _$TechnicalAnalysisFromJson(Map<String, dynamic> json) =>
    TechnicalAnalysis(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      analysisType: json['analysisType'] as String,
      data: json['data'] as Map<String, dynamic>,
      signal: json['signal'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TechnicalAnalysisToJson(TechnicalAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
      'analysisType': instance.analysisType,
      'data': instance.data,
      'signal': instance.signal,
      'confidence': instance.confidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PriceAlert _$PriceAlertFromJson(Map<String, dynamic> json) => PriceAlert(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      condition: json['condition'] as String,
      targetPrice: (json['targetPrice'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      triggeredAt: json['triggeredAt'] == null
          ? null
          : DateTime.parse(json['triggeredAt'] as String),
    );

Map<String, dynamic> _$PriceAlertToJson(PriceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'symbol': instance.symbol,
      'condition': instance.condition,
      'targetPrice': instance.targetPrice,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'triggeredAt': instance.triggeredAt?.toIso8601String(),
    };

MarketData _$MarketDataFromJson(Map<String, dynamic> json) => MarketData(
      symbol: json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      priceChange24h: (json['priceChange24h'] as num).toDouble(),
      priceChangePercent24h: (json['priceChangePercent24h'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      marketCap: (json['marketCap'] as num).toDouble(),
      circulatingSupply: (json['circulatingSupply'] as num).toDouble(),
      totalSupply: (json['totalSupply'] as num).toDouble(),
      maxSupply: (json['maxSupply'] as num).toDouble(),
      high24h: (json['high24h'] as num).toDouble(),
      low24h: (json['low24h'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$MarketDataToJson(MarketData instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': instance.price,
      'priceChange24h': instance.priceChange24h,
      'priceChangePercent24h': instance.priceChangePercent24h,
      'volume24h': instance.volume24h,
      'marketCap': instance.marketCap,
      'circulatingSupply': instance.circulatingSupply,
      'totalSupply': instance.totalSupply,
      'maxSupply': instance.maxSupply,
      'high24h': instance.high24h,
      'low24h': instance.low24h,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
