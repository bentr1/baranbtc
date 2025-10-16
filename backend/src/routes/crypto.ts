import { Router } from 'express';
import { asyncHandler } from '../middleware/errorHandler';
import { logger, securityLogger } from '../utils/logger';
import { i18n } from '../utils/i18n';
import { binanceService } from '../services/binanceService';

const router = Router();

// Get available crypto pairs
router.get('/pairs', asyncHandler(async (req, res) => {
  try {
    const { language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Crypto pairs request', {
      requestId: req.requestId
    });
    
    // Fetch popular trading pairs from Binance
    const pairs = await binanceService.getPopularPairs();
    
    const response = {
      success: true,
      message: 'Crypto pairs retrieved successfully',
      data: {
        pairs
      }
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Crypto pairs request failed', {
      error: error.message,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to retrieve crypto pairs',
      message: error.message
    });
  }
}));

// Get candlestick data
router.get('/candles/:symbol', asyncHandler(async (req, res) => {
  try {
    const { symbol } = req.params;
    const { interval = '1d', limit = 100, language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Candlestick data request', {
      symbol,
      interval,
      limit,
      requestId: req.requestId
    });
    
    // Fetch candlestick data from Binance
    const klines = await binanceService.getKlines(symbol, interval as string, limit as number);
    const candles = klines.map(kline => binanceService.formatKlineData(kline));
    
    const response = {
      success: true,
      message: 'Candlestick data retrieved successfully',
      data: {
        symbol,
        interval,
        candles
      }
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Candlestick data request failed', {
      error: error.message,
      symbol: req.params.symbol,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to retrieve candlestick data',
      message: error.message
    });
  }
}));

// Get real-time price
router.get('/price/:symbol', asyncHandler(async (req, res) => {
  try {
    const { symbol } = req.params;
    const { language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Real-time price request', {
      symbol,
      requestId: req.requestId
    });
    
    // Get real-time price from Binance
    const currentPrice = await binanceService.getCurrentPrice(symbol);
    const tickerData = await binanceService.get24hrTicker(symbol);
    const ticker = tickerData[0];
    
    const response = {
      success: true,
      message: 'Real-time price retrieved successfully',
      data: {
        symbol,
        price: parseFloat(currentPrice.price),
        timestamp: new Date().toISOString(),
        change24h: parseFloat(ticker.priceChange),
        changePercent24h: parseFloat(ticker.priceChangePercent),
        volume24h: parseFloat(ticker.volume),
        high24h: parseFloat(ticker.highPrice),
        low24h: parseFloat(ticker.lowPrice)
      }
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Real-time price request failed', {
      error: error.message,
      symbol: req.params.symbol,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to retrieve real-time price',
      message: error.message
    });
  }
}));

// Get market overview
router.get('/market-overview', asyncHandler(async (req, res) => {
  try {
    const { language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Market overview request', {
      requestId: req.requestId
    });
    
    // Get market overview from Binance
    const marketOverview = await binanceService.getMarketOverview();
    
    const response = {
      success: true,
      message: 'Market overview retrieved successfully',
      data: marketOverview
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Market overview request failed', {
      error: error.message,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to retrieve market overview',
      message: error.message
    });
  }
}));

// Get trading signals
router.get('/signals', asyncHandler(async (req, res) => {
  try {
    const { symbol, timeframe = '1d', limit = 20, language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Trading signals request', {
      symbol,
      timeframe,
      limit,
      requestId: req.requestId
    });
    
    // TODO: Implement trading signals logic
    // - Get signals from technical analysis
    // - Filter by symbol and timeframe
    // - Return signal list
    
    const response = {
      success: true,
      message: 'Trading signals retrieved successfully',
      data: {
        signals: [
          {
            id: 'signal-1',
            symbol: 'BTCUSDT',
            timeframe: '1d',
            type: 'bullish',
            confidence: 0.85,
            description: 'Strong bullish signal based on pivot levels',
            timestamp: new Date().toISOString()
          },
          {
            id: 'signal-2',
            symbol: 'ETHUSDT',
            timeframe: '1d',
            type: 'bearish',
            confidence: 0.72,
            description: 'Bearish signal from moving average crossover',
            timestamp: new Date().toISOString()
          }
        ]
      }
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Trading signals request failed', {
      error: error.message,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to retrieve trading signals',
      message: error.message
    });
  }
}));

// Get price alerts
router.get('/alerts', asyncHandler(async (req, res) => {
  try {
    const { symbol, language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Price alerts request', {
      symbol,
      requestId: req.requestId
    });
    
    // TODO: Implement price alerts logic
    // - Get user's price alerts
    // - Filter by symbol if provided
    // - Return alert list
    
    const response = {
      success: true,
      message: 'Price alerts retrieved successfully',
      data: {
        alerts: [
          {
            id: 'alert-1',
            symbol: 'BTCUSDT',
            type: 'above',
            price: 50000.00,
            isActive: true,
            createdAt: new Date().toISOString()
          },
          {
            id: 'alert-2',
            symbol: 'ETHUSDT',
            type: 'below',
            price: 2500.00,
            isActive: true,
            createdAt: new Date().toISOString()
          }
        ]
      }
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Price alerts request failed', {
      error: error.message,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to retrieve price alerts',
      message: error.message
    });
  }
}));

// Create price alert
router.post('/alerts', asyncHandler(async (req, res) => {
  try {
    const { symbol, type, price, language } = req.body;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language)) {
      i18n.setLanguage(language);
    }
    
    logger.info('Price alert creation request', {
      symbol,
      type,
      price,
      requestId: req.requestId
    });
    
    // TODO: Implement price alert creation logic
    // - Validate input data
    // - Create alert record
    // - Set up monitoring
    
    const response = {
      success: true,
      message: 'Price alert created successfully',
      data: {
        alert: {
          id: 'new-alert-id',
          symbol,
          type,
          price,
          isActive: true,
          createdAt: new Date().toISOString()
        }
      }
    };
    
    res.status(201).json(response);
    
  } catch (error) {
    logger.error('Price alert creation failed', {
      error: error.message,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to create price alert',
      message: error.message
    });
  }
}));

// Delete price alert
router.delete('/alerts/:alertId', asyncHandler(async (req, res) => {
  try {
    const { alertId } = req.params;
    const { language } = req.query;
    
    // Set language for response
    if (language && i18n.getSupportedLanguages().includes(language as string)) {
      i18n.setLanguage(language as string);
    }
    
    logger.info('Price alert deletion request', {
      alertId,
      requestId: req.requestId
    });
    
    // TODO: Implement price alert deletion logic
    // - Validate alert ownership
    // - Delete alert record
    // - Stop monitoring
    
    const response = {
      success: true,
      message: 'Price alert deleted successfully',
      data: {
        alertId,
        message: 'Price alert has been deleted successfully.'
      }
    };
    
    res.status(200).json(response);
    
  } catch (error) {
    logger.error('Price alert deletion failed', {
      error: error.message,
      alertId: req.params.alertId,
      requestId: req.requestId
    });
    
    res.status(400).json({
      success: false,
      error: 'Failed to delete price alert',
      message: error.message
    });
  }
}));

export default router;
