import { Request, Response, NextFunction } from 'express';
import { securityLogger } from '../utils/logger';
import { config } from '../config/config';

// Security middleware for OWASP Top 10 protection
export const securityMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const startTime = Date.now();
  
  try {
    // 1. SQL Injection Protection - Validate and sanitize input
    sanitizeInput(req);
    
    // 2. XSS Protection - Set security headers
    setSecurityHeaders(res);
    
    // 3. CSRF Protection - Validate origin and referer
    validateCSRF(req, res);
    
    // 4. Broken Access Control - Log access attempts
    logAccessAttempt(req);
    
    // 5. Security Misconfiguration - Validate request structure
    validateRequestStructure(req);
    
    // 6. Sensitive Data Exposure - Remove sensitive headers
    removeSensitiveHeaders(res);
    
    // 7. Missing Function Level Access Control - Basic route protection
    basicRouteProtection(req);
    
    // 8. Software and Data Integrity Failures - Validate request integrity
    validateRequestIntegrity(req);
    
    // 9. Security Logging and Monitoring Failures - Log security events
    logSecurityEvent(req);
    
    // 10. Server-Side Request Forgery - Validate external URLs
    validateExternalUrls(req);
    
    // Log security middleware execution time
    const executionTime = Date.now() - startTime;
    if (executionTime > 100) { // Log slow security checks
      securityLogger.warn('Slow security middleware execution', {
        executionTime,
        path: req.path,
        method: req.method,
        ip: req.ip
      });
    }
    
    next();
  } catch (error) {
    securityLogger.error('Security middleware error', {
      error: error.message,
      path: req.path,
      method: req.method,
      ip: req.ip,
      userAgent: req.get('User-Agent')
    });
    
    res.status(403).json({
      error: 'Security validation failed',
      message: 'Request blocked by security middleware'
    });
  }
};

// 1. SQL Injection Protection
function sanitizeInput(req: Request): void {
  const sanitizeValue = (value: any): any => {
    if (typeof value === 'string') {
      // Remove SQL injection patterns
      const sqlPatterns = [
        /(\b(union|select|insert|update|delete|drop|create|alter|exec|execute|script|javascript|vbscript|onload|onerror|onclick)\b)/gi,
        /(\b(or|and)\s+\d+\s*=\s*\d+)/gi,
        /(\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\s+.*\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b)/gi,
        /(\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\s+.*\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b)/gi
      ];
      
      let sanitized = value;
      sqlPatterns.forEach(pattern => {
        sanitized = sanitized.replace(pattern, '[BLOCKED]');
      });
      
      return sanitized;
    }
    return value;
  };
  
  // Sanitize query parameters
  if (req.query) {
    Object.keys(req.query).forEach(key => {
      req.query[key] = sanitizeValue(req.query[key]);
    });
  }
  
  // Sanitize body parameters
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      req.body[key] = sanitizeValue(req.body[key]);
    });
  }
  
  // Sanitize URL parameters
  if (req.params) {
    Object.keys(req.params).forEach(key => {
      req.params[key] = sanitizeValue(req.params[key]);
    });
  }
}

// 2. XSS Protection
function setSecurityHeaders(res: Response): void {
  // Content Security Policy
  res.setHeader('Content-Security-Policy', "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' wss: https:;");
  
  // XSS Protection
  res.setHeader('X-XSS-Protection', '1; mode=block');
  
  // Content Type Options
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  // Frame Options
  res.setHeader('X-Frame-Options', 'DENY');
  
  // Referrer Policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Permissions Policy
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
}

// 3. CSRF Protection
function validateCSRF(req: Request, res: Response): void {
  // Skip CSRF validation for GET requests
  if (req.method === 'GET') return;
  
  const origin = req.get('Origin');
  const referer = req.get('Referer');
  
  // Validate origin header
  if (origin && !config.allowedOrigins.includes(origin)) {
    throw new Error('Invalid origin header');
  }
  
  // Validate referer header for sensitive operations
  if (req.path.includes('/api/auth') || req.path.includes('/api/users')) {
    if (!referer || !config.allowedOrigins.some(allowed => referer.startsWith(allowed))) {
      throw new Error('Invalid referer header');
    }
  }
}

// 4. Broken Access Control
function logAccessAttempt(req: Request): void {
  const sensitiveEndpoints = [
    '/api/admin',
    '/api/users',
    '/api/auth',
    '/api/crypto'
  ];
  
  if (sensitiveEndpoints.some(endpoint => req.path.startsWith(endpoint))) {
    securityLogger.info('Access attempt to sensitive endpoint', {
      path: req.path,
      method: req.method,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      timestamp: new Date().toISOString()
    });
  }
}

// 5. Security Misconfiguration
function validateRequestStructure(req: Request): void {
  // Validate content length
  const contentLength = parseInt(req.get('Content-Length') || '0', 10);
  if (contentLength > 10 * 1024 * 1024) { // 10MB limit
    throw new Error('Request too large');
  }
  
  // Validate content type for POST/PUT requests
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    const contentType = req.get('Content-Type');
    if (!contentType || !contentType.includes('application/json')) {
      throw new Error('Invalid content type');
    }
  }
}

// 6. Sensitive Data Exposure
function removeSensitiveHeaders(res: Response): void {
  // Remove server information
  res.removeHeader('Server');
  res.removeHeader('X-Powered-By');
  
  // Remove version information
  res.removeHeader('X-AspNet-Version');
  res.removeHeader('X-AspNetMvc-Version');
}

// 7. Basic Route Protection
function basicRouteProtection(req: Request): void {
  // Block access to sensitive files
  const blockedPaths = [
    '.env',
    'package.json',
    'package-lock.json',
    'node_modules',
    '.git',
    'logs',
    'config'
  ];
  
  if (blockedPaths.some(path => req.path.includes(path))) {
    throw new Error('Access to sensitive path blocked');
  }
}

// 8. Request Integrity Validation
function validateRequestIntegrity(req: Request): void {
  // Validate request timestamp (prevent replay attacks)
  const timestamp = req.get('X-Request-Timestamp');
  if (timestamp) {
    const requestTime = parseInt(timestamp, 10);
    const currentTime = Date.now();
    const timeDiff = Math.abs(currentTime - requestTime);
    
    if (timeDiff > 5 * 60 * 1000) { // 5 minutes tolerance
      throw new Error('Request timestamp expired');
    }
  }
}

// 9. Security Event Logging
function logSecurityEvent(req: Request): void {
  // Log suspicious patterns
  const suspiciousPatterns = [
    /\.\.\//, // Directory traversal
    /<script/i, // Script tags
    /javascript:/i, // JavaScript protocol
    /vbscript:/i, // VBScript protocol
    /on\w+\s*=/i, // Event handlers
    /eval\s*\(/i, // Eval function
    /document\./i, // Document object access
    /window\./i, // Window object access
    /localStorage/i, // Local storage access
    /sessionStorage/i // Session storage access
  ];
  
  const userInput = JSON.stringify({
    query: req.query,
    body: req.body,
    params: req.params
  });
  
  suspiciousPatterns.forEach(pattern => {
    if (pattern.test(userInput)) {
      securityLogger.warn('Suspicious input pattern detected', {
        pattern: pattern.source,
        path: req.path,
        method: req.method,
        ip: req.ip,
        userAgent: req.get('User-Agent')
      });
    }
  });
}

// 10. External URL Validation
function validateExternalUrls(req: Request): void {
  // Check for potential SSRF in request body
  if (req.body) {
    const urlFields = ['url', 'callback', 'redirect', 'webhook'];
    urlFields.forEach(field => {
      if (req.body[field] && typeof req.body[field] === 'string') {
        try {
          const url = new URL(req.body[field]);
          if (!['http:', 'https:'].includes(url.protocol)) {
            throw new Error('Invalid URL protocol');
          }
          
          // Block access to internal networks
          const hostname = url.hostname;
          if (hostname === 'localhost' || 
              hostname === '127.0.0.1' || 
              hostname === '0.0.0.0' ||
              hostname.startsWith('10.') ||
              hostname.startsWith('172.') ||
              hostname.startsWith('192.168.')) {
            throw new Error('Access to internal network blocked');
          }
        } catch (error) {
          if (error.message.includes('Invalid URL')) {
            throw new Error('Invalid URL format');
          }
        }
      }
    });
  }
}

export default securityMiddleware;
