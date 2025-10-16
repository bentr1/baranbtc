import 'package:json_annotation/json_annotation.dart';

part 'crypto_model.g.dart';

@JsonSerializable()
class CryptoPair {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double price;
  final double change24h;
  final double changePercent24h;
  final double volume24h;
  final double high24h;
  final double low24h;
  final double open24h;
  final double close24h;
  final int lastUpdateTime;
  final bool isActive;
  final List<String> orderTypes;
  final List<String> permissions;

  const CryptoPair({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.open24h,
    required this.close24h,
    required this.lastUpdateTime,
    this.isActive = true,
    this.orderTypes = const [],
    this.permissions = const [],
  });

  factory CryptoPair.fromJson(Map<String, dynamic> json) =>
      _$CryptoPairFromJson(json);
  Map<String, dynamic> toJson() => _$CryptoPairToJson(this);

  CryptoPair copyWith({
    String? symbol,
    String? baseAsset,
    String? quoteAsset,
    double? price,
    double? change24h,
    double? changePercent24h,
    double? volume24h,
    double? high24h,
    double? low24h,
    double? open24h,
    double? close24h,
    int? lastUpdateTime,
    bool? isActive,
    List<String>? orderTypes,
    List<String>? permissions,
  }) {
    return CryptoPair(
      symbol: symbol ?? this.symbol,
      baseAsset: baseAsset ?? this.baseAsset,
      quoteAsset: quoteAsset ?? this.quoteAsset,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      changePercent24h: changePercent24h ?? this.changePercent24h,
      volume24h: volume24h ?? this.volume24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      open24h: open24h ?? this.open24h,
      close24h: close24h ?? this.close24h,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      isActive: isActive ?? this.isActive,
      orderTypes: orderTypes ?? this.orderTypes,
      permissions: permissions ?? this.permissions,
    );
  }
}

@JsonSerializable()
class CryptoKline {
  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int closeTime;
  final double quoteAssetVolume;
  final int numberOfTrades;
  final double takerBuyBaseAssetVolume;
  final double takerBuyQuoteAssetVolume;
  final String ignore;

  const CryptoKline({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
    required this.quoteAssetVolume,
    required this.numberOfTrades,
    required this.takerBuyBaseAssetVolume,
    required this.takerBuyQuoteAssetVolume,
    required this.ignore,
  });

  factory CryptoKline.fromJson(Map<String, dynamic> json) =>
      _$CryptoKlineFromJson(json);
  Map<String, dynamic> toJson() => _$CryptoKlineToJson(this);

  CryptoKline copyWith({
    int? openTime,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
    int? closeTime,
    double? quoteAssetVolume,
    int? numberOfTrades,
    double? takerBuyBaseAssetVolume,
    double? takerBuyQuoteAssetVolume,
    String? ignore,
  }) {
    return CryptoKline(
      openTime: openTime ?? this.openTime,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      closeTime: closeTime ?? this.closeTime,
      quoteAssetVolume: quoteAssetVolume ?? this.quoteAssetVolume,
      numberOfTrades: numberOfTrades ?? this.numberOfTrades,
      takerBuyBaseAssetVolume:
          takerBuyBaseAssetVolume ?? this.takerBuyBaseAssetVolume,
      takerBuyQuoteAssetVolume:
          takerBuyQuoteAssetVolume ?? this.takerBuyQuoteAssetVolume,
      ignore: ignore ?? this.ignore,
    );
  }
}

@JsonSerializable()
class TechnicalAnalysis {
  final String symbol;
  final String timeframe;
  final TechnicalIndicators indicators;
  final TechnicalSignals signals;
  final TechnicalTrends trends;
  final TechnicalSupportResistance supportResistance;
  final int lastUpdateTime;

  const TechnicalAnalysis({
    required this.symbol,
    required this.timeframe,
    required this.indicators,
    required this.signals,
    required this.trends,
    required this.supportResistance,
    required this.lastUpdateTime,
  });

  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TechnicalAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalAnalysisToJson(this);

  TechnicalAnalysis copyWith({
    String? symbol,
    String? timeframe,
    TechnicalIndicators? indicators,
    TechnicalSignals? signals,
    TechnicalTrends? trends,
    TechnicalSupportResistance? supportResistance,
    int? lastUpdateTime,
  }) {
    return TechnicalAnalysis(
      symbol: symbol ?? this.symbol,
      timeframe: timeframe ?? this.timeframe,
      indicators: indicators ?? this.indicators,
      signals: signals ?? this.signals,
      trends: trends ?? this.trends,
      supportResistance: supportResistance ?? this.supportResistance,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }
}

@JsonSerializable()
class TechnicalIndicators {
  final double? rsi;
  final double? macd;
  final double? macdSignal;
  final double? macdHistogram;
  final double? bollingerUpper;
  final double? bollingerMiddle;
  final double? bollingerLower;
  final double? sma20;
  final double? sma50;
  final double? sma200;
  final double? ema12;
  final double? ema26;
  final double? stochK;
  final double? stochD;
  final double? williamsR;
  final double? atr;
  final double? adx;
  final double? cci;
  final double? mfi;
  final double? obv;

  const TechnicalIndicators({
    this.rsi,
    this.macd,
    this.macdSignal,
    this.macdHistogram,
    this.bollingerUpper,
    this.bollingerMiddle,
    this.bollingerLower,
    this.sma20,
    this.sma50,
    this.sma200,
    this.ema12,
    this.ema26,
    this.stochK,
    this.stochD,
    this.williamsR,
    this.atr,
    this.adx,
    this.cci,
    this.mfi,
    this.obv,
  });

  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) =>
      _$TechnicalIndicatorsFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalIndicatorsToJson(this);
}

@JsonSerializable()
class TechnicalSignals {
  final String overall;
  final String trend;
  final String momentum;
  final String volume;
  final String volatility;
  final List<String> buySignals;
  final List<String> sellSignals;
  final List<String> neutralSignals;

  const TechnicalSignals({
    required this.overall,
    required this.trend,
    required this.momentum,
    required this.volume,
    required this.volatility,
    this.buySignals = const [],
    this.sellSignals = const [],
    this.neutralSignals = const [],
  });

  factory TechnicalSignals.fromJson(Map<String, dynamic> json) =>
      _$TechnicalSignalsFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalSignalsToJson(this);
}

@JsonSerializable()
class TechnicalTrends {
  final String shortTerm;
  final String mediumTerm;
  final String longTerm;
  final double? trendStrength;
  final String? trendDirection;
  final List<String> trendChanges;

  const TechnicalTrends({
    required this.shortTerm,
    required this.mediumTerm,
    required this.longTerm,
    this.trendStrength,
    this.trendDirection,
    this.trendChanges = const [],
  });

  factory TechnicalTrends.fromJson(Map<String, dynamic> json) =>
      _$TechnicalTrendsFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalTrendsToJson(this);
}

@JsonSerializable()
class TechnicalSupportResistance {
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final double? currentSupport;
  final double? currentResistance;
  final double? pivotPoint;
  final double? r1;
  final double? r2;
  final double? r3;
  final double? s1;
  final double? s2;
  final double? s3;

  const TechnicalSupportResistance({
    this.supportLevels = const [],
    this.resistanceLevels = const [],
    this.currentSupport,
    this.currentResistance,
    this.pivotPoint,
    this.r1,
    this.r2,
    this.r3,
    this.s1,
    this.s2,
    this.s3,
  });

  factory TechnicalSupportResistance.fromJson(Map<String, dynamic> json) =>
      _$TechnicalSupportResistanceFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalSupportResistanceToJson(this);
}
