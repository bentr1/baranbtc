import { Router } from 'express';
import { databaseConnection } from '../database/connection';
import { redisConnection } from '../database/redis';
import { logger } from '../utils/logger';
import { config } from '../config/config';

const router = Router();

// Basic health check
router.get('/', async (req, res) => {
  try {
    const healthData = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: config.nodeEnv,
      version: process.env.npm_package_version || '1.0.0',
      requestId: req.requestId
    };

    res.status(200).json({
      success: true,
      data: healthData
    });
  } catch (error) {
    logger.error('Health check failed', { error: error.message });
    res.status(500).json({
      success: false,
      error: 'Health check failed',
      timestamp: new Date().toISOString()
    });
  }
});

// Detailed health check
router.get('/detailed', async (req, res) => {
  try {
    const startTime = Date.now();
    
    // Check database connection
    const dbStatus = databaseConnection.isConnected();
    const dbStats = databaseConnection.getConnectionStats();
    
    // Check Redis connection
    const redisStatus = redisConnection.isConnected();
    const redisStats = redisConnection.getConnectionStats();
    
    // Check system resources
    const systemInfo = {
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      platform: process.platform,
      nodeVersion: process.version,
      pid: process.pid
    };
    
    // Check environment variables
    const envCheck = {
      nodeEnv: config.nodeEnv,
      port: config.port,
      database: {
        host: config.database.host,
        port: config.database.port,
        name: config.database.name
      },
      redis: {
        host: config.redis.host,
        port: config.redis.port
      }
    };
    
    const responseTime = Date.now() - startTime;
    
    const healthData = {
      status: dbStatus && redisStatus ? 'healthy' : 'degraded',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: config.nodeEnv,
      version: process.env.npm_package_version || '1.0.0',
      responseTime,
      services: {
        database: {
          status: dbStatus ? 'healthy' : 'unhealthy',
          stats: dbStats
        },
        redis: {
          status: redisStatus ? 'healthy' : 'unhealthy',
          stats: redisStats
        }
      },
      system: systemInfo,
      environment: envCheck,
      requestId: req.requestId
    };
    
    const overallStatus = dbStatus && redisStatus ? 200 : 503;
    
    res.status(overallStatus).json({
      success: overallStatus === 200,
      data: healthData
    });
    
    // Log health check
    logger.info('Detailed health check completed', {
      status: healthData.status,
      responseTime,
      requestId: req.requestId
    });
    
  } catch (error) {
    logger.error('Detailed health check failed', { 
      error: error.message,
      requestId: req.requestId 
    });
    
    res.status(500).json({
      success: false,
      error: 'Detailed health check failed',
      timestamp: new Date().toISOString(),
      requestId: req.requestId
    });
  }
});

// Readiness probe for Kubernetes
router.get('/ready', async (req, res) => {
  try {
    const dbReady = databaseConnection.isConnected();
    const redisReady = redisConnection.isConnected();
    
    if (dbReady && redisReady) {
      res.status(200).json({
        success: true,
        status: 'ready',
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(503).json({
        success: false,
        status: 'not ready',
        timestamp: new Date().toISOString(),
        services: {
          database: dbReady,
          redis: redisReady
        }
      });
    }
  } catch (error) {
    logger.error('Readiness check failed', { error: error.message });
    res.status(503).json({
      success: false,
      status: 'not ready',
      error: 'Readiness check failed',
      timestamp: new Date().toISOString()
    });
  }
});

// Liveness probe for Kubernetes
router.get('/live', (req, res) => {
  res.status(200).json({
    success: true,
    status: 'alive',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

export default router;
