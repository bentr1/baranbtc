import { Request, Response, NextFunction } from 'express';
import { logger, securityLogger, auditLogger } from '../utils/logger';
import { config } from '../config/config';
import { v4 as uuidv4 } from 'uuid';

// Extend Request interface to include request ID
declare global {
  namespace Express {
    interface Request {
      requestId: string;
      startTime: number;
      user?: any;
    }
  }
}

export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  // Generate unique request ID
  req.requestId = uuidv4();
  req.startTime = Date.now();

  // Set request ID in response headers
  res.setHeader('X-Request-ID', req.requestId);

  // Log request start
  logger.info('Request started', {
    requestId: req.requestId,
    method: req.method,
    path: req.path,
    query: req.query,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString()
  });

  // Log sensitive operations
  if (isSensitiveOperation(req)) {
    securityLogger.info('Sensitive operation requested', {
      requestId: req.requestId,
      method: req.method,
      path: req.path,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      timestamp: new Date().toISOString()
    });
  }

  // Override res.end to log response
  const originalEnd = res.end;
  res.end = function(chunk?: any, encoding?: any) {
    const responseTime = Date.now() - req.startTime;
    const statusCode = res.statusCode;
    const contentLength = res.get('Content-Length') || 0;

    // Log response
    const logData = {
      requestId: req.requestId,
      method: req.method,
      path: req.path,
      statusCode,
      responseTime,
      contentLength,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: req.user?.id || 'anonymous',
      timestamp: new Date().toISOString()
    };

    // Log based on status code
    if (statusCode >= 500) {
      logger.error('Request failed with server error', logData);
    } else if (statusCode >= 400) {
      logger.warn('Request failed with client error', logData);
    } else {
      logger.info('Request completed successfully', logData);
    }

    // Log slow requests
    if (responseTime > 1000) { // 1 second
      logger.warn('Slow request detected', {
        ...logData,
        threshold: 1000
      });
    }

    // Log security events
    if (statusCode === 401 || statusCode === 403) {
      securityLogger.warn('Authentication/Authorization failure', {
        ...logData,
        failureType: statusCode === 401 ? 'authentication' : 'authorization'
      });
    }

    // Audit log for sensitive operations
    if (isSensitiveOperation(req)) {
      auditLogger.log(
        `${req.method} ${req.path}`,
        req.path,
        req.user?.id || 'anonymous',
        {
          requestId: req.requestId,
          statusCode,
          responseTime,
          ip: req.ip,
          userAgent: req.get('User-Agent'),
          timestamp: new Date().toISOString()
        }
      );
    }

    // Call original end method
    originalEnd.call(this, chunk, encoding);
  };

  next();
};

// Check if operation is sensitive
function isSensitiveOperation(req: Request): boolean {
  const sensitivePaths = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/logout',
    '/api/auth/refresh',
    '/api/users',
    '/api/admin',
    '/api/crypto/analysis'
  ];

  const sensitiveMethods = ['POST', 'PUT', 'DELETE', 'PATCH'];

  return sensitivePaths.some(path => req.path.startsWith(path)) ||
         sensitiveMethods.includes(req.method);
}

// Request ID middleware for external use
export const requestIdMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.requestId) {
    req.requestId = uuidv4();
    res.setHeader('X-Request-ID', req.requestId);
  }
  next();
};

// Performance monitoring middleware
export const performanceMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const startTime = process.hrtime.bigint();

  res.on('finish', () => {
    const endTime = process.hrtime.bigint();
    const duration = Number(endTime - startTime) / 1000000; // Convert to milliseconds

    // Log performance metrics
    if (duration > 100) { // Log requests taking more than 100ms
      logger.info('Performance metric', {
        requestId: req.requestId,
        path: req.path,
        method: req.method,
        duration,
        statusCode: res.statusCode,
        timestamp: new Date().toISOString()
      });
    }
  });

  next();
};

// Security monitoring middleware
export const securityMonitoringMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  // Monitor for suspicious patterns
  const suspiciousPatterns = [
    /\.\.\//, // Directory traversal
    /<script/i, // Script tags
    /javascript:/i, // JavaScript protocol
    /on\w+\s*=/i, // Event handlers
    /eval\s*\(/i, // Eval function
    /union\s+select/i, // SQL injection
    /drop\s+table/i, // SQL injection
    /insert\s+into/i, // SQL injection
    /update\s+set/i, // SQL injection
    /delete\s+from/i // SQL injection
  ];

  const userInput = JSON.stringify({
    path: req.path,
    query: req.query,
    body: req.body,
    params: req.params,
    headers: req.headers
  });

  suspiciousPatterns.forEach(pattern => {
    if (pattern.test(userInput)) {
      securityLogger.warn('Suspicious request pattern detected', {
        requestId: req.requestId,
        pattern: pattern.source,
        path: req.path,
        method: req.method,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        timestamp: new Date().toISOString()
      });
    }
  });

  // Monitor for unusual request patterns
  const unusualPatterns = [
    // Multiple failed login attempts
    req.path.includes('/auth/login') && req.method === 'POST',
    // Rapid requests
    req.path.includes('/api/') && req.method === 'GET',
    // Large payloads
    req.headers['content-length'] && parseInt(req.headers['content-length']) > 1000000
  ];

  if (unusualPatterns.some(pattern => pattern)) {
    securityLogger.info('Unusual request pattern detected', {
      requestId: req.requestId,
      path: req.path,
      method: req.method,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      contentLength: req.headers['content-length'],
      timestamp: new Date().toISOString()
    });
  }

  next();
};

export default requestLogger;
