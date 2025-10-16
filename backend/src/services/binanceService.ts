import axios from 'axios';
import { config } from '../config/config';
import { logger } from '../utils/logger';

interface BinanceTicker {
  symbol: string;
  price: string;
  priceChange: string;
  priceChangePercent: string;
  weightedAvgPrice: string;
  prevClosePrice: string;
  lastPrice: string;
  lastQty: string;
  bidPrice: string;
  askPrice: string;
  openPrice: string;
  highPrice: string;
  lowPrice: string;
  volume: string;
  quoteVolume: string;
  openTime: number;
  closeTime: number;
  firstId: number;
  lastId: number;
  count: number;
}

interface BinanceKline {
  0: number; // Open time
  1: string; // Open
  2: string; // High
  3: string; // Low
  4: string; // Close
  5: string; // Volume
  6: number; // Close time
  7: string; // Quote asset volume
  8: number; // Number of trades
  9: string; // Taker buy base asset volume
  10: string; // Taker buy quote asset volume
  11: string; // Ignore
}

class BinanceService {
  private baseUrl: string;
  private apiKey: string;
  private apiSecret: string;

  constructor() {
    this.baseUrl = config.binance.baseUrl;
    this.apiKey = config.binance.apiKey;
    this.apiSecret = config.binance.apiSecret;
  }

  // Get 24hr ticker price change statistics
  async get24hrTicker(symbol?: string): Promise<BinanceTicker[]> {
    try {
      const url = symbol 
        ? `${this.baseUrl}/api/v3/ticker/24hr?symbol=${symbol}`
        : `${this.baseUrl}/api/v3/ticker/24hr`;
      
      const response = await axios.get(url);
      return Array.isArray(response.data) ? response.data : [response.data];
    } catch (error) {
      logger.error('Binance 24hr ticker error:', error);
      throw new Error('Failed to fetch 24hr ticker data');
    }
  }

  // Get current average price
  async getCurrentPrice(symbol: string): Promise<{ symbol: string; price: string }> {
    try {
      const response = await axios.get(`${this.baseUrl}/api/v3/avgPrice?symbol=${symbol}`);
      return response.data;
    } catch (error) {
      logger.error('Binance current price error:', error);
      throw new Error(`Failed to fetch current price for ${symbol}`);
    }
  }

  // Get kline/candlestick data
  async getKlines(
    symbol: string,
    interval: string = '1d',
    limit: number = 100,
    startTime?: number,
    endTime?: number
  ): Promise<BinanceKline[]> {
    try {
      let url = `${this.baseUrl}/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${limit}`;
      
      if (startTime) {
        url += `&startTime=${startTime}`;
      }
      if (endTime) {
        url += `&endTime=${endTime}`;
      }

      const response = await axios.get(url);
      return response.data;
    } catch (error) {
      logger.error('Binance klines error:', error);
      throw new Error(`Failed to fetch klines for ${symbol}`);
    }
  }

  // Get exchange info
  async getExchangeInfo(): Promise<any> {
    try {
      const response = await axios.get(`${this.baseUrl}/api/v3/exchangeInfo`);
      return response.data;
    } catch (error) {
      logger.error('Binance exchange info error:', error);
      throw new Error('Failed to fetch exchange info');
    }
  }

  // Get server time
  async getServerTime(): Promise<{ serverTime: number }> {
    try {
      const response = await axios.get(`${this.baseUrl}/api/v3/time`);
      return response.data;
    } catch (error) {
      logger.error('Binance server time error:', error);
      throw new Error('Failed to fetch server time');
    }
  }

  // Format kline data for API response
  formatKlineData(kline: BinanceKline): any {
    return {
      time: new Date(kline[0]).toISOString(),
      open: parseFloat(kline[1]),
      high: parseFloat(kline[2]),
      low: parseFloat(kline[3]),
      close: parseFloat(kline[4]),
      volume: parseFloat(kline[5]),
      closeTime: new Date(kline[6]).toISOString(),
      quoteVolume: parseFloat(kline[7]),
      trades: kline[8],
      takerBuyBaseVolume: parseFloat(kline[9]),
      takerBuyQuoteVolume: parseFloat(kline[10])
    };
  }

  // Format ticker data for API response
  formatTickerData(ticker: BinanceTicker): any {
    return {
      symbol: ticker.symbol,
      baseAsset: ticker.symbol.replace('USDT', '').replace('BUSD', ''),
      quoteAsset: ticker.symbol.includes('USDT') ? 'USDT' : 'BUSD',
      price: parseFloat(ticker.lastPrice),
      change24h: parseFloat(ticker.priceChange),
      changePercent24h: parseFloat(ticker.priceChangePercent),
      volume24h: parseFloat(ticker.volume),
      high24h: parseFloat(ticker.highPrice),
      low24h: parseFloat(ticker.lowPrice),
      open24h: parseFloat(ticker.openPrice),
      close24h: parseFloat(ticker.prevClosePrice),
      lastUpdateTime: ticker.closeTime,
      isActive: true,
      orderTypes: ['LIMIT', 'MARKET', 'STOP_LOSS_LIMIT', 'TAKE_PROFIT_LIMIT'],
      permissions: ['SPOT']
    };
  }

  // Get popular trading pairs
  async getPopularPairs(): Promise<any[]> {
    try {
      const tickers = await this.get24hrTicker();
      const popularSymbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'SOLUSDT', 'XRPUSDT', 'DOTUSDT', 'DOGEUSDT'];
      
      return tickers
        .filter(ticker => popularSymbols.includes(ticker.symbol))
        .map(ticker => this.formatTickerData(ticker))
        .sort((a, b) => b.volume24h - a.volume24h);
    } catch (error) {
      logger.error('Binance popular pairs error:', error);
      throw new Error('Failed to fetch popular pairs');
    }
  }

  // Get market overview data
  async getMarketOverview(): Promise<any> {
    try {
      const tickers = await this.get24hrTicker();
      const totalVolume = tickers.reduce((sum, ticker) => sum + parseFloat(ticker.quoteVolume), 0);
      const totalMarketCap = tickers.reduce((sum, ticker) => sum + parseFloat(ticker.quoteVolume), 0);
      
      const topGainers = tickers
        .filter(ticker => parseFloat(ticker.priceChangePercent) > 0)
        .sort((a, b) => parseFloat(b.priceChangePercent) - parseFloat(a.priceChangePercent))
        .slice(0, 10)
        .map(ticker => this.formatTickerData(ticker));

      const topLosers = tickers
        .filter(ticker => parseFloat(ticker.priceChangePercent) < 0)
        .sort((a, b) => parseFloat(a.priceChangePercent) - parseFloat(b.priceChangePercent))
        .slice(0, 10)
        .map(ticker => this.formatTickerData(ticker));

      return {
        totalVolume,
        totalMarketCap,
        activePairs: tickers.length,
        topGainers,
        topLosers,
        lastUpdate: new Date().toISOString()
      };
    } catch (error) {
      logger.error('Binance market overview error:', error);
      throw new Error('Failed to fetch market overview');
    }
  }
}

export const binanceService = new BinanceService();
export default binanceService;
