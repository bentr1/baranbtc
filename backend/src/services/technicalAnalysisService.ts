import { logger } from '../utils/logger';
import { databaseConnection } from '../database/connection';

export interface CandlestickData {
  time: number;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

export interface TechnicalIndicators {
  rsi: number;
  macd: number;
  macdSignal: number;
  macdHistogram: number;
  bollingerUpper: number;
  bollingerMiddle: number;
  bollingerLower: number;
  sma20: number;
  sma50: number;
  sma200: number;
  ema12: number;
  ema26: number;
  stochK: number;
  stochD: number;
  williamsR: number;
  atr: number;
  adx: number;
  cci: number;
  mfi: number;
  obv: number;
}

export interface TechnicalSignals {
  overall: 'bullish' | 'bearish' | 'neutral';
  trend: 'bullish' | 'bearish' | 'neutral';
  momentum: 'strong' | 'weak' | 'neutral';
  volume: 'high' | 'low' | 'normal';
  volatility: 'high' | 'low' | 'normal';
  buySignals: string[];
  sellSignals: string[];
  neutralSignals: string[];
}

export interface TechnicalTrends {
  shortTerm: 'bullish' | 'bearish' | 'neutral';
  mediumTerm: 'bullish' | 'bearish' | 'neutral';
  longTerm: 'bullish' | 'bearish' | 'neutral';
  trendStrength: number;
  trendDirection: 'up' | 'down' | 'sideways';
  trendChanges: string[];
}

export interface SupportResistance {
  supportLevels: number[];
  resistanceLevels: number[];
  currentSupport: number;
  currentResistance: number;
  pivotPoint: number;
  r1: number;
  r2: number;
  r3: number;
  s1: number;
  s2: number;
  s3: number;
}

export interface TechnicalAnalysis {
  symbol: string;
  timeframe: string;
  indicators: TechnicalIndicators;
  signals: TechnicalSignals;
  trends: TechnicalTrends;
  supportResistance: SupportResistance;
  lastUpdateTime: number;
}

export class TechnicalAnalysisService {
  private static instance: TechnicalAnalysisService;

  private constructor() {}

  public static getInstance(): TechnicalAnalysisService {
    if (!TechnicalAnalysisService.instance) {
      TechnicalAnalysisService.instance = new TechnicalAnalysisService();
    }
    return TechnicalAnalysisService.instance;
  }

  public async analyzeSymbol(symbol: string, timeframe: string = '1d'): Promise<TechnicalAnalysis> {
    try {
      logger.info(`Starting technical analysis for ${symbol} on ${timeframe} timeframe`);

      // Get candlestick data
      const candlestickData = await this.getCandlestickData(symbol, timeframe);
      
      if (candlestickData.length < 200) {
        throw new Error(`Insufficient data for analysis. Need at least 200 candles, got ${candlestickData.length}`);
      }

      // Calculate technical indicators
      const indicators = this.calculateIndicators(candlestickData);

      // Generate signals
      const signals = this.generateSignals(indicators, candlestickData);

      // Analyze trends
      const trends = this.analyzeTrends(indicators, candlestickData);

      // Calculate support and resistance
      const supportResistance = this.calculateSupportResistance(candlestickData);

      const analysis: TechnicalAnalysis = {
        symbol,
        timeframe,
        indicators,
        signals,
        trends,
        supportResistance,
        lastUpdateTime: Date.now()
      };

      // Save analysis to database
      await this.saveAnalysis(analysis);

      logger.info(`Technical analysis completed for ${symbol}`);
      return analysis;

    } catch (error) {
      logger.error(`Failed to analyze ${symbol}:`, error);
      throw error;
    }
  }

  private async getCandlestickData(symbol: string, timeframe: string): Promise<CandlestickData[]> {
    const query = `
      SELECT 
        EXTRACT(EPOCH FROM time) * 1000 as time,
        open as open,
        high as high,
        low as low,
        close as close,
        volume as volume
      FROM candlestick_data 
      WHERE symbol = $1 
      ORDER BY time DESC 
      LIMIT 500
    `;

    const result = await databaseConnection.query(query, [symbol]);
    return result.rows.reverse(); // Reverse to get chronological order
  }

  private calculateIndicators(data: CandlestickData[]): TechnicalIndicators {
    const closes = data.map(d => d.close);
    const highs = data.map(d => d.high);
    const lows = data.map(d => d.low);
    const volumes = data.map(d => d.volume);

    return {
      rsi: this.calculateRSI(closes, 14),
      macd: this.calculateMACD(closes, 12, 26, 9).macd,
      macdSignal: this.calculateMACD(closes, 12, 26, 9).signal,
      macdHistogram: this.calculateMACD(closes, 12, 26, 9).histogram,
      bollingerUpper: this.calculateBollingerBands(closes, 20, 2).upper,
      bollingerMiddle: this.calculateBollingerBands(closes, 20, 2).middle,
      bollingerLower: this.calculateBollingerBands(closes, 20, 2).lower,
      sma20: this.calculateSMA(closes, 20),
      sma50: this.calculateSMA(closes, 50),
      sma200: this.calculateSMA(closes, 200),
      ema12: this.calculateEMA(closes, 12),
      ema26: this.calculateEMA(closes, 26),
      stochK: this.calculateStochastic(highs, lows, closes, 14).k,
      stochD: this.calculateStochastic(highs, lows, closes, 14).d,
      williamsR: this.calculateWilliamsR(highs, lows, closes, 14),
      atr: this.calculateATR(highs, lows, closes, 14),
      adx: this.calculateADX(highs, lows, closes, 14),
      cci: this.calculateCCI(highs, lows, closes, 20),
      mfi: this.calculateMFI(highs, lows, closes, volumes, 14),
      obv: this.calculateOBV(closes, volumes)
    };
  }

  private calculateRSI(prices: number[], period: number): number {
    if (prices.length < period + 1) return 50;

    let gains = 0;
    let losses = 0;

    for (let i = 1; i <= period; i++) {
      const change = prices[i] - prices[i - 1];
      if (change > 0) gains += change;
      else losses -= change;
    }

    const avgGain = gains / period;
    const avgLoss = losses / period;

    if (avgLoss === 0) return 100;

    const rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  private calculateMACD(prices: number[], fastPeriod: number, slowPeriod: number, signalPeriod: number): { macd: number, signal: number, histogram: number } {
    const emaFast = this.calculateEMA(prices, fastPeriod);
    const emaSlow = this.calculateEMA(prices, slowPeriod);
    const macd = emaFast - emaSlow;

    // For signal line, we need MACD values over time
    const macdValues = [];
    for (let i = Math.max(fastPeriod, slowPeriod); i < prices.length; i++) {
      const fastEMA = this.calculateEMA(prices.slice(0, i + 1), fastPeriod);
      const slowEMA = this.calculateEMA(prices.slice(0, i + 1), slowPeriod);
      macdValues.push(fastEMA - slowEMA);
    }

    const signal = this.calculateEMA(macdValues, signalPeriod);
    const histogram = macd - signal;

    return { macd, signal, histogram };
  }

  private calculateBollingerBands(prices: number[], period: number, stdDev: number): { upper: number, middle: number, lower: number } {
    const sma = this.calculateSMA(prices, period);
    const recentPrices = prices.slice(-period);
    
    const variance = recentPrices.reduce((sum, price) => sum + Math.pow(price - sma, 2), 0) / period;
    const standardDeviation = Math.sqrt(variance);

    return {
      upper: sma + (standardDeviation * stdDev),
      middle: sma,
      lower: sma - (standardDeviation * stdDev)
    };
  }

  private calculateSMA(prices: number[], period: number): number {
    if (prices.length < period) return prices[prices.length - 1];
    
    const recentPrices = prices.slice(-period);
    return recentPrices.reduce((sum, price) => sum + price, 0) / period;
  }

  private calculateEMA(prices: number[], period: number): number {
    if (prices.length < period) return prices[prices.length - 1];

    const multiplier = 2 / (period + 1);
    let ema = prices[0];

    for (let i = 1; i < prices.length; i++) {
      ema = (prices[i] * multiplier) + (ema * (1 - multiplier));
    }

    return ema;
  }

  private calculateStochastic(highs: number[], lows: number[], closes: number[], period: number): { k: number, d: number } {
    if (highs.length < period) return { k: 50, d: 50 };

    const recentHighs = highs.slice(-period);
    const recentLows = lows.slice(-period);
    const currentClose = closes[closes.length - 1];

    const highestHigh = Math.max(...recentHighs);
    const lowestLow = Math.min(...recentLows);

    const k = ((currentClose - lowestLow) / (highestHigh - lowestLow)) * 100;

    // For %D, we need multiple %K values
    const kValues = [];
    for (let i = period; i < closes.length; i++) {
      const periodHighs = highs.slice(i - period, i);
      const periodLows = lows.slice(i - period, i);
      const periodClose = closes[i - 1];

      const periodHighestHigh = Math.max(...periodHighs);
      const periodLowestLow = Math.min(...periodLows);

      const periodK = ((periodClose - periodLowestLow) / (periodHighestHigh - periodLowestLow)) * 100;
      kValues.push(periodK);
    }

    const d = kValues.length > 0 ? kValues.reduce((sum, k) => sum + k, 0) / kValues.length : k;

    return { k, d };
  }

  private calculateWilliamsR(highs: number[], lows: number[], closes: number[], period: number): number {
    if (highs.length < period) return -50;

    const recentHighs = highs.slice(-period);
    const recentLows = lows.slice(-period);
    const currentClose = closes[closes.length - 1];

    const highestHigh = Math.max(...recentHighs);
    const lowestLow = Math.min(...recentLows);

    return ((highestHigh - currentClose) / (highestHigh - lowestLow)) * -100;
  }

  private calculateATR(highs: number[], lows: number[], closes: number[], period: number): number {
    if (highs.length < period + 1) return 0;

    const trueRanges = [];
    for (let i = 1; i < highs.length; i++) {
      const tr1 = highs[i] - lows[i];
      const tr2 = Math.abs(highs[i] - closes[i - 1]);
      const tr3 = Math.abs(lows[i] - closes[i - 1]);
      trueRanges.push(Math.max(tr1, tr2, tr3));
    }

    return this.calculateSMA(trueRanges, period);
  }

  private calculateADX(highs: number[], lows: number[], closes: number[], period: number): number {
    // Simplified ADX calculation
    if (highs.length < period * 2) return 25;

    const atr = this.calculateATR(highs, lows, closes, period);
    const currentPrice = closes[closes.length - 1];
    const previousPrice = closes[closes.length - 2];

    const priceChange = Math.abs(currentPrice - previousPrice);
    const adx = (priceChange / atr) * 100;

    return Math.min(adx, 100);
  }

  private calculateCCI(highs: number[], lows: number[], closes: number[], period: number): number {
    if (highs.length < period) return 0;

    const recentHighs = highs.slice(-period);
    const recentLows = lows.slice(-period);
    const recentCloses = closes.slice(-period);

    const typicalPrices = recentHighs.map((high, i) => (high + recentLows[i] + recentCloses[i]) / 3);
    const sma = this.calculateSMA(typicalPrices, period);
    const currentTP = (recentHighs[recentHighs.length - 1] + recentLows[recentLows.length - 1] + recentCloses[recentCloses.length - 1]) / 3;

    const meanDeviation = typicalPrices.reduce((sum, tp) => sum + Math.abs(tp - sma), 0) / period;

    return meanDeviation === 0 ? 0 : (currentTP - sma) / (0.015 * meanDeviation);
  }

  private calculateMFI(highs: number[], lows: number[], closes: number[], volumes: number[], period: number): number {
    if (highs.length < period + 1) return 50;

    let positiveFlow = 0;
    let negativeFlow = 0;

    for (let i = 1; i <= period; i++) {
      const typicalPrice = (highs[i] + lows[i] + closes[i]) / 3;
      const previousTP = (highs[i - 1] + lows[i - 1] + closes[i - 1]) / 3;

      const moneyFlow = typicalPrice * volumes[i];

      if (typicalPrice > previousTP) {
        positiveFlow += moneyFlow;
      } else if (typicalPrice < previousTP) {
        negativeFlow += moneyFlow;
      }
    }

    if (negativeFlow === 0) return 100;

    const moneyFlowRatio = positiveFlow / negativeFlow;
    return 100 - (100 / (1 + moneyFlowRatio));
  }

  private calculateOBV(closes: number[], volumes: number[]): number {
    let obv = 0;

    for (let i = 1; i < closes.length; i++) {
      if (closes[i] > closes[i - 1]) {
        obv += volumes[i];
      } else if (closes[i] < closes[i - 1]) {
        obv -= volumes[i];
      }
    }

    return obv;
  }

  private generateSignals(indicators: TechnicalIndicators, data: CandlestickData[]): TechnicalSignals {
    const buySignals: string[] = [];
    const sellSignals: string[] = [];
    const neutralSignals: string[] = [];

    // RSI signals
    if (indicators.rsi < 30) {
      buySignals.push('RSI oversold');
    } else if (indicators.rsi > 70) {
      sellSignals.push('RSI overbought');
    } else {
      neutralSignals.push('RSI neutral');
    }

    // MACD signals
    if (indicators.macd > indicators.macdSignal && indicators.macdHistogram > 0) {
      buySignals.push('MACD bullish crossover');
    } else if (indicators.macd < indicators.macdSignal && indicators.macdHistogram < 0) {
      sellSignals.push('MACD bearish crossover');
    } else {
      neutralSignals.push('MACD neutral');
    }

    // Bollinger Bands signals
    const currentPrice = data[data.length - 1].close;
    if (currentPrice < indicators.bollingerLower) {
      buySignals.push('Price below lower Bollinger Band');
    } else if (currentPrice > indicators.bollingerUpper) {
      sellSignals.push('Price above upper Bollinger Band');
    } else {
      neutralSignals.push('Price within Bollinger Bands');
    }

    // Moving average signals
    if (currentPrice > indicators.sma20 && indicators.sma20 > indicators.sma50) {
      buySignals.push('Price above moving averages');
    } else if (currentPrice < indicators.sma20 && indicators.sma20 < indicators.sma50) {
      sellSignals.push('Price below moving averages');
    } else {
      neutralSignals.push('Mixed moving average signals');
    }

    // Determine overall signal
    let overall: 'bullish' | 'bearish' | 'neutral' = 'neutral';
    if (buySignals.length > sellSignals.length) {
      overall = 'bullish';
    } else if (sellSignals.length > buySignals.length) {
      overall = 'bearish';
    }

    // Determine trend
    let trend: 'bullish' | 'bearish' | 'neutral' = 'neutral';
    if (indicators.sma20 > indicators.sma50 && indicators.sma50 > indicators.sma200) {
      trend = 'bullish';
    } else if (indicators.sma20 < indicators.sma50 && indicators.sma50 < indicators.sma200) {
      trend = 'bearish';
    }

    // Determine momentum
    let momentum: 'strong' | 'weak' | 'neutral' = 'neutral';
    if (indicators.rsi > 60 && indicators.macd > 0) {
      momentum = 'strong';
    } else if (indicators.rsi < 40 && indicators.macd < 0) {
      momentum = 'weak';
    }

    // Determine volume
    const avgVolume = data.slice(-20).reduce((sum, d) => sum + d.volume, 0) / 20;
    const currentVolume = data[data.length - 1].volume;
    let volume: 'high' | 'low' | 'normal' = 'normal';
    if (currentVolume > avgVolume * 1.5) {
      volume = 'high';
    } else if (currentVolume < avgVolume * 0.5) {
      volume = 'low';
    }

    // Determine volatility
    const priceRange = Math.max(...data.slice(-20).map(d => d.high)) - Math.min(...data.slice(-20).map(d => d.low));
    const avgPrice = data.slice(-20).reduce((sum, d) => sum + d.close, 0) / 20;
    const volatilityPercent = (priceRange / avgPrice) * 100;
    let volatility: 'high' | 'low' | 'normal' = 'normal';
    if (volatilityPercent > 10) {
      volatility = 'high';
    } else if (volatilityPercent < 3) {
      volatility = 'low';
    }

    return {
      overall,
      trend,
      momentum,
      volume,
      volatility,
      buySignals,
      sellSignals,
      neutralSignals
    };
  }

  private analyzeTrends(indicators: TechnicalIndicators, data: CandlestickData[]): TechnicalTrends {
    const currentPrice = data[data.length - 1].close;
    const shortTermPrices = data.slice(-5);
    const mediumTermPrices = data.slice(-20);
    const longTermPrices = data.slice(-50);

    // Short term trend
    let shortTerm: 'bullish' | 'bearish' | 'neutral' = 'neutral';
    if (currentPrice > shortTermPrices[0].close) {
      shortTerm = 'bullish';
    } else if (currentPrice < shortTermPrices[0].close) {
      shortTerm = 'bearish';
    }

    // Medium term trend
    let mediumTerm: 'bullish' | 'bearish' | 'neutral' = 'neutral';
    if (currentPrice > mediumTermPrices[0].close) {
      mediumTerm = 'bullish';
    } else if (currentPrice < mediumTermPrices[0].close) {
      mediumTerm = 'bearish';
    }

    // Long term trend
    let longTerm: 'bullish' | 'bearish' | 'neutral' = 'neutral';
    if (currentPrice > longTermPrices[0].close) {
      longTerm = 'bullish';
    } else if (currentPrice < longTermPrices[0].close) {
      longTerm = 'bearish';
    }

    // Trend strength
    const trendStrength = Math.abs(indicators.sma20 - indicators.sma50) / indicators.sma50 * 100;

    // Trend direction
    let trendDirection: 'up' | 'down' | 'sideways' = 'sideways';
    if (indicators.sma20 > indicators.sma50 && indicators.sma50 > indicators.sma200) {
      trendDirection = 'up';
    } else if (indicators.sma20 < indicators.sma50 && indicators.sma50 < indicators.sma200) {
      trendDirection = 'down';
    }

    // Trend changes
    const trendChanges: string[] = [];
    if (shortTerm !== mediumTerm) {
      trendChanges.push('Short-term trend divergence');
    }
    if (mediumTerm !== longTerm) {
      trendChanges.push('Medium-term trend divergence');
    }

    return {
      shortTerm,
      mediumTerm,
      longTerm,
      trendStrength,
      trendDirection,
      trendChanges
    };
  }

  private calculateSupportResistance(data: CandlestickData[]): SupportResistance {
    const highs = data.map(d => d.high);
    const lows = data.map(d => d.low);
    const closes = data.map(d => d.close);

    // Find pivot points
    const pivotHighs: number[] = [];
    const pivotLows: number[] = [];

    for (let i = 2; i < highs.length - 2; i++) {
      // Pivot high
      if (highs[i] > highs[i - 1] && highs[i] > highs[i - 2] && 
          highs[i] > highs[i + 1] && highs[i] > highs[i + 2]) {
        pivotHighs.push(highs[i]);
      }
      
      // Pivot low
      if (lows[i] < lows[i - 1] && lows[i] < lows[i - 2] && 
          lows[i] < lows[i + 1] && lows[i] < lows[i + 2]) {
        pivotLows.push(lows[i]);
      }
    }

    // Sort and get significant levels
    const resistanceLevels = pivotHighs.sort((a, b) => b - a).slice(0, 5);
    const supportLevels = pivotLows.sort((a, b) => a - b).slice(0, 5);

    // Current support and resistance
    const currentPrice = closes[closes.length - 1];
    const currentSupport = supportLevels.find(level => level < currentPrice) || supportLevels[0] || currentPrice * 0.95;
    const currentResistance = resistanceLevels.find(level => level > currentPrice) || resistanceLevels[0] || currentPrice * 1.05;

    // Pivot point calculation
    const recentHigh = Math.max(...highs.slice(-1));
    const recentLow = Math.min(...lows.slice(-1));
    const recentClose = closes[closes.length - 1];
    const pivotPoint = (recentHigh + recentLow + recentClose) / 3;

    // Pivot levels
    const r1 = 2 * pivotPoint - recentLow;
    const r2 = pivotPoint + (recentHigh - recentLow);
    const r3 = recentHigh + 2 * (pivotPoint - recentLow);
    const s1 = 2 * pivotPoint - recentHigh;
    const s2 = pivotPoint - (recentHigh - recentLow);
    const s3 = recentLow - 2 * (recentHigh - pivotPoint);

    return {
      supportLevels,
      resistanceLevels,
      currentSupport,
      currentResistance,
      pivotPoint,
      r1,
      r2,
      r3,
      s1,
      s2,
      s3
    };
  }

  private async saveAnalysis(analysis: TechnicalAnalysis): Promise<void> {
    const query = `
      INSERT INTO technical_analysis (
        symbol, timeframe, indicators, signals, trends, support_resistance, last_update_time
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (symbol, timeframe) 
      DO UPDATE SET 
        indicators = $3,
        signals = $4,
        trends = $5,
        support_resistance = $6,
        last_update_time = $7,
        updated_at = CURRENT_TIMESTAMP
    `;

    await databaseConnection.query(query, [
      analysis.symbol,
      analysis.timeframe,
      JSON.stringify(analysis.indicators),
      JSON.stringify(analysis.signals),
      JSON.stringify(analysis.trends),
      JSON.stringify(analysis.supportResistance),
      analysis.lastUpdateTime
    ]);
  }

  public async getAnalysis(symbol: string, timeframe: string = '1d'): Promise<TechnicalAnalysis | null> {
    const query = `
      SELECT * FROM technical_analysis 
      WHERE symbol = $1 AND timeframe = $2
      ORDER BY last_update_time DESC 
      LIMIT 1
    `;

    const result = await databaseConnection.query(query, [symbol, timeframe]);
    
    if (result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    return {
      symbol: row.symbol,
      timeframe: row.timeframe,
      indicators: row.indicators,
      signals: row.signals,
      trends: row.trends,
      supportResistance: row.support_resistance,
      lastUpdateTime: row.last_update_time
    };
  }
}

export const technicalAnalysisService = TechnicalAnalysisService.getInstance();
export default technicalAnalysisService;
