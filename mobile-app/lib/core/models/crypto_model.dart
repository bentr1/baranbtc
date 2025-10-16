import 'package:json_annotation/json_annotation.dart';

part 'crypto_model.g.dart';

@JsonSerializable()
class CryptoPair {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String status;
  final bool isSpotTradingAllowed;
  final bool isMarginTradingAllowed;
  final double minQty;
  final double maxQty;
  final double stepSize;
  final double minPrice;
  final double maxPrice;
  final double tickSize;
  final double minNotional;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CryptoPair({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.status,
    required this.isSpotTradingAllowed,
    required this.isMarginTradingAllowed,
    required this.minQty,
    required this.maxQty,
    required this.stepSize,
    required this.minPrice,
    required this.maxPrice,
    required this.tickSize,
    required this.minNotional,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CryptoPair.fromJson(Map<String, dynamic> json) => _$CryptoPairFromJson(json);
  Map<String, dynamic> toJson() => _$CryptoPairToJson(this);

  String get displayName => '$baseAsset/$quoteAsset';
  String get baseSymbol => baseAsset;
  String get quoteSymbol => quoteAsset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CryptoPair && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() {
    return 'CryptoPair(symbol: $symbol, base: $baseAsset, quote: $quoteAsset)';
  }
}

@JsonSerializable()
class CandlestickData {
  final String symbol;
  final String timeframe;
  final DateTime openTime;
  final DateTime closeTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double quoteVolume;
  final int tradeCount;
  final double takerBuyBaseVolume;
  final double takerBuyQuoteVolume;
  final DateTime createdAt;

  const CandlestickData({
    required this.symbol,
    required this.timeframe,
    required this.openTime,
    required this.closeTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.quoteVolume,
    required this.tradeCount,
    required this.takerBuyBaseVolume,
    required this.takerBuyQuoteVolume,
    required this.createdAt,
  });

  factory CandlestickData.fromJson(Map<String, dynamic> json) => _$CandlestickDataFromJson(json);
  Map<String, dynamic> toJson() => _$CandlestickDataToJson(this);

  double get priceChange => close - open;
  double get priceChangePercent => (priceChange / open) * 100;
  bool get isBullish => close > open;
  bool get isBearish => close < open;
  double get bodySize => (close - open).abs();
  double get upperShadow => high - (open > close ? open : close);
  double get lowerShadow => (open < close ? open : close) - low;
  double get totalRange => high - low;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CandlestickData && 
           other.symbol == symbol && 
           other.timeframe == timeframe && 
           other.openTime == openTime;
  }

  @override
  int get hashCode => Object.hash(symbol, timeframe, openTime);

  @override
  String toString() {
    return 'CandlestickData(symbol: $symbol, timeframe: $timeframe, openTime: $openTime, close: $close)';
  }
}

@JsonSerializable()
class TechnicalAnalysis {
  final String id;
  final String symbol;
  final String timeframe;
  final String analysisType;
  final Map<String, dynamic> data;
  final String signal;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TechnicalAnalysis({
    required this.id,
    required this.symbol,
    required this.timeframe,
    required this.analysisType,
    required this.data,
    required this.signal,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) => _$TechnicalAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalAnalysisToJson(this);

  bool get isBullish => signal == 'BUY';
  bool get isBearish => signal == 'SELL';
  bool get isNeutral => signal == 'HOLD';
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TechnicalAnalysis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TechnicalAnalysis(id: $id, symbol: $symbol, type: $analysisType, signal: $signal, confidence: $confidence)';
  }
}

@JsonSerializable()
class PriceAlert {
  final String id;
  final String userId;
  final String symbol;
  final String condition;
  final double targetPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? triggeredAt;

  const PriceAlert({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.condition,
    required this.targetPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.triggeredAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) => _$PriceAlertFromJson(json);
  Map<String, dynamic> toJson() => _$PriceAlertToJson(this);

  bool get isTriggered => triggeredAt != null;
  bool get isAbove => condition == 'ABOVE';
  bool get isBelow => condition == 'BELOW';

  PriceAlert copyWith({
    String? id,
    String? userId,
    String? symbol,
    String? condition,
    double? targetPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? triggeredAt,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symbol: symbol ?? this.symbol,
      condition: condition ?? this.condition,
      targetPrice: targetPrice ?? this.targetPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceAlert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PriceAlert(id: $id, symbol: $symbol, condition: $condition, targetPrice: $targetPrice, isActive: $isActive)';
  }
}

@JsonSerializable()
class MarketData {
  final String symbol;
  final double price;
  final double priceChange24h;
  final double priceChangePercent24h;
  final double volume24h;
  final double marketCap;
  final double circulatingSupply;
  final double totalSupply;
  final double maxSupply;
  final double high24h;
  final double low24h;
  final DateTime lastUpdated;

  const MarketData({
    required this.symbol,
    required this.price,
    required this.priceChange24h,
    required this.priceChangePercent24h,
    required this.volume24h,
    required this.marketCap,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.high24h,
    required this.low24h,
    required this.lastUpdated,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) => _$MarketDataFromJson(json);
  Map<String, dynamic> toJson() => _$MarketDataToJson(this);

  bool get isPositive => priceChangePercent24h > 0;
  bool get isNegative => priceChangePercent24h < 0;
  bool get isNeutral => priceChangePercent24h == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarketData && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() {
    return 'MarketData(symbol: $symbol, price: $price, change24h: $priceChangePercent24h%)';
  }
}
