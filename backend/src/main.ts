import express from 'express';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import cors from 'cors';
import compression from 'compression';
import { config } from './config/config';
import { logger } from './utils/logger';
import { securityMiddleware } from './middleware/security';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import { databaseConnection } from './database/connection';
import { redisConnection } from './database/redis';
import { routes } from './routes';
import { cronJobs } from './services/cronJobs';
import { socketServer } from './services/socketServer';
import { antiTamperProtection } from './security/antiTamperProtection';

class BTCBaranApp {
  private app: express.Application;
  private server: any;

  constructor() {
    this.app = express();
    this.setupSecurity();
    this.setupMiddleware();
    this.setupRoutes();
    this.setupErrorHandling();
  }

  private setupSecurity(): void {
    // Anti-tampering protection
    antiTamperProtection.initialize();

    // Security headers
    this.app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", "data:", "https:"],
          connectSrc: ["'self'", "wss:", "https:"],
          fontSrc: ["'self'"],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
        },
      },
      hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true
      }
    }));

    // Rate limiting
    const limiter = rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100, // limit each IP to 100 requests per windowMs
      message: 'Too many requests from this IP, please try again later.',
      standardHeaders: true,
      legacyHeaders: false,
    });
    this.app.use('/api/', limiter);

    // CORS configuration
    this.app.use(cors({
      origin: config.allowedOrigins,
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
    }));

    // Security middleware
    this.app.use(securityMiddleware);
  }

  private setupMiddleware(): void {
    this.app.use(compression());
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));
    this.app.use(requestLogger);
  }

  private setupRoutes(): void {
    this.app.use('/api', routes);
    
    // Health check endpoint
    this.app.get('/health', (req, res) => {
      res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: config.nodeEnv
      });
    });
  }

  private setupErrorHandling(): void {
    this.app.use(errorHandler);
  }

  public async start(): Promise<void> {
    try {
      // Initialize database connections
      await databaseConnection.initialize();
      await redisConnection.initialize();

      // Start cron jobs
      cronJobs.start();

      // Start socket server
      socketServer.initialize();

      // Start HTTP server
      this.server = this.app.listen(config.port, () => {
        logger.info(`🚀 BTC Baran Backend started on port ${config.port}`);
        logger.info(`🔒 Security features: ${config.securityFeatures.join(', ')}`);
        logger.info(`🌍 Environment: ${config.nodeEnv}`);
        logger.info(`📊 Database: ${config.database.host}:${config.database.port}`);
      });

      // Graceful shutdown
      process.on('SIGTERM', () => this.gracefulShutdown());
      process.on('SIGINT', () => this.gracefulShutdown());

    } catch (error) {
      logger.error('Failed to start application:', error);
      process.exit(1);
    }
  }

  private async gracefulShutdown(): Promise<void> {
    logger.info('🛑 Graceful shutdown initiated...');
    
    try {
      // Stop accepting new connections
      this.server.close();
      
      // Close database connections
      await databaseConnection.close();
      await redisConnection.close();
      
      // Stop cron jobs
      cronJobs.stop();
      
      // Stop socket server
      socketServer.close();
      
      logger.info('✅ Graceful shutdown completed');
      process.exit(0);
    } catch (error) {
      logger.error('❌ Error during graceful shutdown:', error);
      process.exit(1);
    }
  }
}

// Start the application
const app = new BTCBaranApp();
app.start().catch((error) => {
  logger.error('Failed to start BTC Baran application:', error);
  process.exit(1);
});
