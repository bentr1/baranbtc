// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoPair _$CryptoPairFromJson(Map<String, dynamic> json) => CryptoPair(
      symbol: json['symbol'] as String,
      baseAsset: json['baseAsset'] as String,
      quoteAsset: json['quoteAsset'] as String,
      price: (json['price'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
      changePercent24h: (json['changePercent24h'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      high24h: (json['high24h'] as num).toDouble(),
      low24h: (json['low24h'] as num).toDouble(),
      open24h: (json['open24h'] as num).toDouble(),
      close24h: (json['close24h'] as num).toDouble(),
      lastUpdateTime: (json['lastUpdateTime'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      orderTypes: (json['orderTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CryptoPairToJson(CryptoPair instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'baseAsset': instance.baseAsset,
      'quoteAsset': instance.quoteAsset,
      'price': instance.price,
      'change24h': instance.change24h,
      'changePercent24h': instance.changePercent24h,
      'volume24h': instance.volume24h,
      'high24h': instance.high24h,
      'low24h': instance.low24h,
      'open24h': instance.open24h,
      'close24h': instance.close24h,
      'lastUpdateTime': instance.lastUpdateTime,
      'isActive': instance.isActive,
      'orderTypes': instance.orderTypes,
      'permissions': instance.permissions,
    };

CryptoKline _$CryptoKlineFromJson(Map<String, dynamic> json) => CryptoKline(
      openTime: (json['openTime'] as num).toInt(),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      closeTime: (json['closeTime'] as num).toInt(),
      quoteAssetVolume: (json['quoteAssetVolume'] as num).toDouble(),
      numberOfTrades: (json['numberOfTrades'] as num).toInt(),
      takerBuyBaseAssetVolume:
          (json['takerBuyBaseAssetVolume'] as num).toDouble(),
      takerBuyQuoteAssetVolume:
          (json['takerBuyQuoteAssetVolume'] as num).toDouble(),
      ignore: json['ignore'] as String,
    );

Map<String, dynamic> _$CryptoKlineToJson(CryptoKline instance) =>
    <String, dynamic>{
      'openTime': instance.openTime,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
      'closeTime': instance.closeTime,
      'quoteAssetVolume': instance.quoteAssetVolume,
      'numberOfTrades': instance.numberOfTrades,
      'takerBuyBaseAssetVolume': instance.takerBuyBaseAssetVolume,
      'takerBuyQuoteAssetVolume': instance.takerBuyQuoteAssetVolume,
      'ignore': instance.ignore,
    };

TechnicalAnalysis _$TechnicalAnalysisFromJson(Map<String, dynamic> json) =>
    TechnicalAnalysis(
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      indicators: TechnicalIndicators.fromJson(
          json['indicators'] as Map<String, dynamic>),
      signals:
          TechnicalSignals.fromJson(json['signals'] as Map<String, dynamic>),
      trends: TechnicalTrends.fromJson(json['trends'] as Map<String, dynamic>),
      supportResistance: TechnicalSupportResistance.fromJson(
          json['supportResistance'] as Map<String, dynamic>),
      lastUpdateTime: (json['lastUpdateTime'] as num).toInt(),
    );

Map<String, dynamic> _$TechnicalAnalysisToJson(TechnicalAnalysis instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
      'indicators': instance.indicators,
      'signals': instance.signals,
      'trends': instance.trends,
      'supportResistance': instance.supportResistance,
      'lastUpdateTime': instance.lastUpdateTime,
    };

TechnicalIndicators _$TechnicalIndicatorsFromJson(Map<String, dynamic> json) =>
    TechnicalIndicators(
      rsi: (json['rsi'] as num?)?.toDouble(),
      macd: (json['macd'] as num?)?.toDouble(),
      macdSignal: (json['macdSignal'] as num?)?.toDouble(),
      macdHistogram: (json['macdHistogram'] as num?)?.toDouble(),
      bollingerUpper: (json['bollingerUpper'] as num?)?.toDouble(),
      bollingerMiddle: (json['bollingerMiddle'] as num?)?.toDouble(),
      bollingerLower: (json['bollingerLower'] as num?)?.toDouble(),
      sma20: (json['sma20'] as num?)?.toDouble(),
      sma50: (json['sma50'] as num?)?.toDouble(),
      sma200: (json['sma200'] as num?)?.toDouble(),
      ema12: (json['ema12'] as num?)?.toDouble(),
      ema26: (json['ema26'] as num?)?.toDouble(),
      stochK: (json['stochK'] as num?)?.toDouble(),
      stochD: (json['stochD'] as num?)?.toDouble(),
      williamsR: (json['williamsR'] as num?)?.toDouble(),
      atr: (json['atr'] as num?)?.toDouble(),
      adx: (json['adx'] as num?)?.toDouble(),
      cci: (json['cci'] as num?)?.toDouble(),
      mfi: (json['mfi'] as num?)?.toDouble(),
      obv: (json['obv'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TechnicalIndicatorsToJson(
        TechnicalIndicators instance) =>
    <String, dynamic>{
      'rsi': instance.rsi,
      'macd': instance.macd,
      'macdSignal': instance.macdSignal,
      'macdHistogram': instance.macdHistogram,
      'bollingerUpper': instance.bollingerUpper,
      'bollingerMiddle': instance.bollingerMiddle,
      'bollingerLower': instance.bollingerLower,
      'sma20': instance.sma20,
      'sma50': instance.sma50,
      'sma200': instance.sma200,
      'ema12': instance.ema12,
      'ema26': instance.ema26,
      'stochK': instance.stochK,
      'stochD': instance.stochD,
      'williamsR': instance.williamsR,
      'atr': instance.atr,
      'adx': instance.adx,
      'cci': instance.cci,
      'mfi': instance.mfi,
      'obv': instance.obv,
    };

TechnicalSignals _$TechnicalSignalsFromJson(Map<String, dynamic> json) =>
    TechnicalSignals(
      overall: json['overall'] as String,
      trend: json['trend'] as String,
      momentum: json['momentum'] as String,
      volume: json['volume'] as String,
      volatility: json['volatility'] as String,
      buySignals: (json['buySignals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sellSignals: (json['sellSignals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      neutralSignals: (json['neutralSignals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TechnicalSignalsToJson(TechnicalSignals instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'trend': instance.trend,
      'momentum': instance.momentum,
      'volume': instance.volume,
      'volatility': instance.volatility,
      'buySignals': instance.buySignals,
      'sellSignals': instance.sellSignals,
      'neutralSignals': instance.neutralSignals,
    };

TechnicalTrends _$TechnicalTrendsFromJson(Map<String, dynamic> json) =>
    TechnicalTrends(
      shortTerm: json['shortTerm'] as String,
      mediumTerm: json['mediumTerm'] as String,
      longTerm: json['longTerm'] as String,
      trendStrength: (json['trendStrength'] as num?)?.toDouble(),
      trendDirection: json['trendDirection'] as String?,
      trendChanges: (json['trendChanges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TechnicalTrendsToJson(TechnicalTrends instance) =>
    <String, dynamic>{
      'shortTerm': instance.shortTerm,
      'mediumTerm': instance.mediumTerm,
      'longTerm': instance.longTerm,
      'trendStrength': instance.trendStrength,
      'trendDirection': instance.trendDirection,
      'trendChanges': instance.trendChanges,
    };

TechnicalSupportResistance _$TechnicalSupportResistanceFromJson(
        Map<String, dynamic> json) =>
    TechnicalSupportResistance(
      supportLevels: (json['supportLevels'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      resistanceLevels: (json['resistanceLevels'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      currentSupport: (json['currentSupport'] as num?)?.toDouble(),
      currentResistance: (json['currentResistance'] as num?)?.toDouble(),
      pivotPoint: (json['pivotPoint'] as num?)?.toDouble(),
      r1: (json['r1'] as num?)?.toDouble(),
      r2: (json['r2'] as num?)?.toDouble(),
      r3: (json['r3'] as num?)?.toDouble(),
      s1: (json['s1'] as num?)?.toDouble(),
      s2: (json['s2'] as num?)?.toDouble(),
      s3: (json['s3'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TechnicalSupportResistanceToJson(
        TechnicalSupportResistance instance) =>
    <String, dynamic>{
      'supportLevels': instance.supportLevels,
      'resistanceLevels': instance.resistanceLevels,
      'currentSupport': instance.currentSupport,
      'currentResistance': instance.currentResistance,
      'pivotPoint': instance.pivotPoint,
      'r1': instance.r1,
      'r2': instance.r2,
      'r3': instance.r3,
      's1': instance.s1,
      's2': instance.s2,
      's3': instance.s3,
    };
