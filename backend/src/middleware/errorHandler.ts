import { Request, Response, NextFunction } from 'express';
import { logger, securityLogger } from '../utils/logger';
import { config } from '../config/config';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
  code?: string;
}

export const errorHandler = (
  error: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Set default values
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';
  const isOperational = error.isOperational !== undefined ? error.isOperational : true;

  // Log error details
  const errorDetails = {
    message: error.message,
    stack: error.stack,
    statusCode,
    isOperational,
    path: req.path,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: (req as any).user?.id || 'anonymous',
    timestamp: new Date().toISOString(),
    requestId: req.headers['x-request-id'] || 'unknown'
  };

  // Log based on error type
  if (statusCode >= 500) {
    logger.error('Server error occurred', errorDetails);
    
    // Log security events for server errors
    if (error.message.includes('security') || error.message.includes('auth')) {
      securityLogger.error('Security-related server error', errorDetails);
    }
  } else if (statusCode >= 400) {
    logger.warn('Client error occurred', errorDetails);
    
    // Log security events for client errors
    if (statusCode === 401 || statusCode === 403) {
      securityLogger.warn('Authentication/Authorization error', errorDetails);
    }
  } else {
    logger.info('Application error occurred', errorDetails);
  }

  // Sanitize error response for production
  let responseMessage = message;
  let responseDetails = {};

  if (config.nodeEnv === 'production') {
    // Hide sensitive information in production
    if (statusCode >= 500) {
      responseMessage = 'Internal Server Error';
      responseDetails = {
        error: 'Internal Server Error',
        requestId: req.headers['x-request-id'] || 'unknown'
      };
    } else {
      responseDetails = {
        error: message,
        requestId: req.headers['x-request-id'] || 'unknown'
      };
    }
  } else {
    // Development mode - show full error details
    responseDetails = {
      error: message,
      stack: error.stack,
      statusCode,
      isOperational,
      path: req.path,
      method: req.method,
      timestamp: new Date().toISOString()
    };
  }

  // Set response headers
  res.status(statusCode);
  res.setHeader('X-Request-ID', req.headers['x-request-id'] || 'unknown');
  res.setHeader('X-Error-Type', isOperational ? 'operational' : 'programming');

  // Send error response
  res.json({
    success: false,
    ...responseDetails
  });
};

// Async error wrapper
export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Custom error classes
export class ValidationError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(message: string, details?: any) {
    super(message);
    this.name = 'ValidationError';
    this.statusCode = 400;
    this.isOperational = true;
    this.code = 'VALIDATION_ERROR';
    
    if (details) {
      this.message = `${message}: ${JSON.stringify(details)}`;
    }
  }
}

export class AuthenticationError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(message: string = 'Authentication failed') {
    super(message);
    this.name = 'AuthenticationError';
    this.statusCode = 401;
    this.isOperational = true;
    this.code = 'AUTHENTICATION_ERROR';
  }
}

export class AuthorizationError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(message: string = 'Access denied') {
    super(message);
    this.name = 'AuthorizationError';
    this.statusCode = 403;
    this.isOperational = true;
    this.code = 'AUTHORIZATION_ERROR';
  }
}

export class NotFoundError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(resource: string = 'Resource') {
    super(`${resource} not found`);
    this.name = 'NotFoundError';
    this.statusCode = 404;
    this.isOperational = true;
    this.code = 'NOT_FOUND_ERROR';
  }
}

export class ConflictError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(message: string = 'Resource conflict') {
    super(message);
    this.name = 'ConflictError';
    this.statusCode = 409;
    this.isOperational = true;
    this.code = 'CONFLICT_ERROR';
  }
}

export class RateLimitError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(message: string = 'Rate limit exceeded') {
    super(message);
    this.name = 'RateLimitError';
    this.statusCode = 429;
    this.isOperational = true;
    this.code = 'RATE_LIMIT_ERROR';
  }
}

export class SecurityError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public code: string;

  constructor(message: string = 'Security violation detected') {
    super(message);
    this.name = 'SecurityError';
    this.statusCode = 403;
    this.isOperational = true;
    this.code = 'SECURITY_ERROR';
    
    // Log security error immediately
    securityLogger.error('Security error occurred', {
      message,
      timestamp: new Date().toISOString(),
      type: 'SECURITY_VIOLATION'
    });
  }
}

export default errorHandler;
