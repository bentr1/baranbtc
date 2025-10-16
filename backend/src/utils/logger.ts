import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import { config } from '../config/config';

// Custom format for security-sensitive logging
const securityFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    // Sanitize sensitive data
    const sanitizedMeta = sanitizeLogData(meta);
    return JSON.stringify({
      timestamp,
      level,
      message,
      ...sanitizedMeta
    });
  })
);

// Sanitize sensitive data from logs
function sanitizeLogData(data: any): any {
  const sensitiveFields = [
    'password', 'token', 'secret', 'key', 'apiKey', 'apiSecret',
    'authorization', 'cookie', 'session', 'creditCard', 'ssn'
  ];
  
  if (typeof data === 'object' && data !== null) {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(data)) {
      if (sensitiveFields.some(field => key.toLowerCase().includes(field))) {
        sanitized[key] = '[REDACTED]';
      } else if (typeof value === 'object' && value !== null) {
        sanitized[key] = sanitizeLogData(value);
      } else {
        sanitized[key] = value;
      }
    }
    return sanitized;
  }
  return data;
}

// Create logger instance
export const logger = winston.createLogger({
  level: config.logging.level,
  format: securityFormat,
  defaultMeta: {
    service: 'btcbaran-backend',
    environment: config.nodeEnv,
    version: process.env.npm_package_version || '1.0.0'
  },
  transports: [
    // Console transport for development
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple(),
        winston.format.printf(({ timestamp, level, message, ...meta }) => {
          const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
          return `${timestamp} [${level}]: ${message}${metaStr}`;
        })
      )
    }),
    
    // File transport for production
    new DailyRotateFile({
      filename: config.logging.file,
      datePattern: 'YYYY-MM-DD',
      maxSize: config.logging.maxSize,
      maxFiles: config.logging.maxFiles,
      zippedArchive: true,
      auditFile: 'logs/audit.json'
    })
  ],
  
  // Handle uncaught exceptions
  exceptionHandlers: [
    new DailyRotateFile({
      filename: 'logs/exceptions.log',
      datePattern: 'YYYY-MM-DD',
      maxSize: '20m',
      maxFiles: '14d'
    })
  ],
  
  // Handle unhandled rejections
  rejectionHandlers: [
    new DailyRotateFile({
      filename: 'logs/rejections.log',
      datePattern: 'YYYY-MM-DD',
      maxSize: '20m',
      maxFiles: '14d'
    })
  ]
});

// Security event logger
export const securityLogger = {
  info: (event: string, details: any = {}) => {
    logger.info(`SECURITY_EVENT: ${event}`, {
      eventType: 'security',
      event,
      details: sanitizeLogData(details),
      timestamp: new Date().toISOString(),
      ip: details.ip || 'unknown',
      userId: details.userId || 'anonymous'
    });
  },
  
  warn: (event: string, details: any = {}) => {
    logger.warn(`SECURITY_WARNING: ${event}`, {
      eventType: 'security_warning',
      event,
      details: sanitizeLogData(details),
      timestamp: new Date().toISOString(),
      ip: details.ip || 'unknown',
      userId: details.userId || 'anonymous'
    });
  },
  
  error: (event: string, details: any = {}) => {
    logger.error(`SECURITY_ERROR: ${event}`, {
      eventType: 'security_error',
      event,
      details: sanitizeLogData(details),
      timestamp: new Date().toISOString(),
      ip: details.ip || 'unknown',
      userId: details.userId || 'anonymous'
    });
  }
};

// Audit logger for compliance
export const auditLogger = {
  log: (action: string, resource: string, userId: string, details: any = {}) => {
    logger.info(`AUDIT: ${action}`, {
      eventType: 'audit',
      action,
      resource,
      userId,
      details: sanitizeLogData(details),
      timestamp: new Date().toISOString(),
      ip: details.ip || 'unknown',
      userAgent: details.userAgent || 'unknown'
    });
  }
};

// Performance logger
export const performanceLogger = {
  log: (operation: string, duration: number, details: any = {}) => {
    logger.info(`PERFORMANCE: ${operation}`, {
      eventType: 'performance',
      operation,
      duration,
      details: sanitizeLogData(details),
      timestamp: new Date().toISOString()
    });
  }
};

export default logger;
