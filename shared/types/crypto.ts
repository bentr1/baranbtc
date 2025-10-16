// Kripto Para Birimi Temel Tipleri
export interface CryptoPair {
  id: string;
  symbol: string;
  baseAsset: string;
  quoteAsset: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Mum Verisi (Candlestick)
export interface Candlestick {
  time: Date;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

// Günlük Mum Verisi
export interface DailyCandle extends Candlestick {
  pairId: string;
  pairSymbol: string;
}

// Pivot Traditional Analiz Sonuçları
export interface PivotAnalysis {
  id: string;
  pairId: string;
  pairSymbol: string;
  date: Date;
  pivot: number;
  r1: number;
  r2: number;
  r3: number;
  r4: number;
  r5: number;
  alertLevel: number;
  isTriggered: boolean;
  highPrice: number;
  createdAt: Date;
}

// S1/R1 Temas Analiz Sonuçları
export interface S1R1Analysis {
  id: string;
  pairId: string;
  pairSymbol: string;
  date: Date;
  s1: number;
  r1: number;
  s1TouchCount: number;
  r1TouchCount: number;
  lastS1Touch: Date | null;
  lastR1Touch: Date | null;
  s1Alert: boolean;
  r1Alert: boolean;
  createdAt: Date;
}

// Hareketli Ortalama Analiz Sonuçları
export interface MAAnalysis {
  id: string;
  pairId: string;
  pairSymbol: string;
  timeframe: TimeFrame;
  date: Date;
  ma25: number;
  ma100: number;
  ma25TouchCount: number;
  ma100TouchCount: number;
  ma25Alert: boolean;
  ma100Alert: boolean;
  createdAt: Date;
}

// Zaman Dilimleri
export type TimeFrame = '1D' | '3D' | '1W';

// Analiz Türleri
export type AnalysisType = 
  | 'PIVOT_TRADITIONAL'
  | 'S1_R1_TOUCH'
  | 'MA_TOUCH';

// Uyarı Türleri
export type AlertType = 
  | 'PIVOT_R5_BREAK'
  | 'S1_NO_TOUCH_270'
  | 'R1_NO_TOUCH_270'
  | 'MA25_NO_TOUCH_50'
  | 'MA100_NO_TOUCH_200';

// Uyarı Öncelik Seviyeleri
export type AlertSeverity = 'LOW' | 'MEDIUM' | 'HIGH';

// Uyarı Veri Yapısı
export interface Alert {
  id: string;
  pairId: string;
  pairSymbol: string;
  alertType: AlertType;
  message: string;
  severity: AlertSeverity;
  triggeredAt: Date;
  data: Record<string, any>;
  isRead: boolean;
  createdAt: Date;
}

// Binance API Response Tipleri
export interface BinanceExchangeInfo {
  timezone: string;
  serverTime: number;
  rateLimits: BinanceRateLimit[];
  exchangeFilters: any[];
  symbols: BinanceSymbol[];
}

export interface BinanceSymbol {
  symbol: string;
  status: string;
  baseAsset: string;
  quoteAsset: string;
  isSpotTradingAllowed: boolean;
  isMarginTradingAllowed: boolean;
  filters: BinanceFilter[];
}

export interface BinanceFilter {
  filterType: string;
  [key: string]: any;
}

export interface BinanceRateLimit {
  rateLimitType: string;
  interval: string;
  intervalNum: number;
  limit: number;
}

export interface BinanceKline {
  openTime: number;
  open: string;
  high: string;
  low: string;
  close: string;
  volume: string;
  closeTime: number;
  quoteAssetVolume: string;
  numberOfTrades: number;
  takerBuyBaseAssetVolume: string;
  takerBuyQuoteAssetVolume: string;
  ignore: string;
}

// Analiz Sonuçları Birleşik Tip
export interface AnalysisResult {
  id: string;
  pairId: string;
  pairSymbol: string;
  analysisType: AnalysisType;
  resultData: PivotAnalysis | S1R1Analysis | MAAnalysis;
  triggeredAt: Date;
  createdAt: Date;
}

// Fiyat Güncelleme
export interface PriceUpdate {
  pairSymbol: string;
  price: number;
  change24h: number;
  changePercent24h: number;
  volume24h: number;
  timestamp: Date;
}

// Market Overview
export interface MarketOverview {
  totalMarketCap: number;
  totalVolume24h: number;
  btcDominance: number;
  ethDominance: number;
  activeCryptocurrencies: number;
  lastUpdated: Date;
}

// Trading Pair Info
export interface TradingPairInfo {
  symbol: string;
  baseAsset: string;
  quoteAsset: string;
  price: number;
  priceChange: number;
  priceChangePercent: number;
  volume: number;
  marketCap: number;
  circulatingSupply: number;
  maxSupply: number | null;
  rank: number;
  lastUpdated: Date;
}
