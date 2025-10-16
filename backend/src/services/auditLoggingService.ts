import { logger, securityLogger } from '../utils/logger';
import { databaseConnection } from '../database/connection';
import { Request, Response } from 'express';

export interface AuditLogEntry {
  userId?: string;
  action: string;
  resourceType: string;
  resourceId?: string;
  details?: any;
  ipAddress?: string;
  userAgent?: string;
  timestamp?: Date;
}

export interface SecurityEvent {
  eventType: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  description: string;
  userId?: string;
  ipAddress?: string;
  userAgent?: string;
  metadata?: any;
  timestamp?: Date;
}

export class AuditLoggingService {
  private static instance: AuditLoggingService;

  private constructor() {}

  public static getInstance(): AuditLoggingService {
    if (!AuditLoggingService.instance) {
      AuditLoggingService.instance = new AuditLoggingService();
    }
    return AuditLoggingService.instance;
  }

  public async logAuditEvent(entry: AuditLogEntry): Promise<void> {
    try {
      const query = `
        INSERT INTO audit_log (
          user_id, action, resource_type, resource_id, details, 
          ip_address, user_agent, timestamp
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `;

      await databaseConnection.query(query, [
        entry.userId || null,
        entry.action,
        entry.resourceType,
        entry.resourceId || null,
        JSON.stringify(entry.details || {}),
        entry.ipAddress || null,
        entry.userAgent || null,
        entry.timestamp || new Date()
      ]);

      logger.debug('Audit event logged', {
        action: entry.action,
        resourceType: entry.resourceType,
        userId: entry.userId
      });

    } catch (error) {
      logger.error('Failed to log audit event', {
        error: error.message,
        entry
      });
    }
  }

  public async logSecurityEvent(event: SecurityEvent): Promise<void> {
    try {
      const query = `
        INSERT INTO security_events (
          event_type, severity, description, user_id, 
          ip_address, user_agent, metadata, timestamp
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `;

      await databaseConnection.query(query, [
        event.eventType,
        event.severity,
        event.description,
        event.userId || null,
        event.ipAddress || null,
        event.userAgent || null,
        JSON.stringify(event.metadata || {}),
        event.timestamp || new Date()
      ]);

      // Log to security logger based on severity
      switch (event.severity) {
        case 'critical':
          securityLogger.error('Critical security event', event);
          break;
        case 'high':
          securityLogger.error('High severity security event', event);
          break;
        case 'medium':
          securityLogger.warn('Medium severity security event', event);
          break;
        case 'low':
          securityLogger.info('Low severity security event', event);
          break;
      }

    } catch (error) {
      logger.error('Failed to log security event', {
        error: error.message,
        event
      });
    }
  }

  public async logUserAction(
    userId: string,
    action: string,
    resourceType: string,
    resourceId: string | null = null,
    details: any = null,
    req: Request
  ): Promise<void> {
    await this.logAuditEvent({
      userId,
      action,
      resourceType,
      resourceId,
      details,
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent'),
      timestamp: new Date()
    });
  }

  public async logAuthenticationEvent(
    userId: string | null,
    action: 'login' | 'logout' | 'login_failed' | 'password_reset' | 'mfa_setup' | 'mfa_verify',
    success: boolean,
    details: any = null,
    req: Request
  ): Promise<void> {
    const severity = success ? 'low' : 'medium';
    
    await this.logSecurityEvent({
      eventType: `AUTH_${action.toUpperCase()}`,
      severity,
      description: `Authentication event: ${action} ${success ? 'successful' : 'failed'}`,
      userId,
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent'),
      metadata: {
        success,
        action,
        details
      },
      timestamp: new Date()
    });
  }

  public async logDataAccess(
    userId: string,
    resourceType: string,
    resourceId: string | null = null,
    action: 'read' | 'create' | 'update' | 'delete',
    details: any = null,
    req: Request
  ): Promise<void> {
    await this.logAuditEvent({
      userId,
      action: `DATA_${action.toUpperCase()}`,
      resourceType,
      resourceId,
      details,
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent'),
      timestamp: new Date()
    });
  }

  public async logSystemEvent(
    eventType: string,
    description: string,
    severity: 'low' | 'medium' | 'high' | 'critical' = 'medium',
    metadata: any = null
  ): Promise<void> {
    await this.logSecurityEvent({
      eventType,
      severity,
      description,
      metadata,
      timestamp: new Date()
    });
  }

  public async logAPIRequest(
    userId: string | null,
    method: string,
    path: string,
    statusCode: number,
    responseTime: number,
    req: Request
  ): Promise<void> {
    const severity = statusCode >= 400 ? 'medium' : 'low';
    
    await this.logAuditEvent({
      userId,
      action: 'API_REQUEST',
      resourceType: 'API',
      resourceId: `${method} ${path}`,
      details: {
        method,
        path,
        statusCode,
        responseTime,
        query: req.query,
        body: this.sanitizeRequestBody(req.body)
      },
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent'),
      timestamp: new Date()
    });

    // Log high response times as security events
    if (responseTime > 5000) { // 5 seconds
      await this.logSecurityEvent({
        eventType: 'SLOW_API_RESPONSE',
        severity: 'medium',
        description: `Slow API response detected: ${method} ${path}`,
        userId,
        ipAddress: req.ip || req.connection.remoteAddress,
        userAgent: req.get('User-Agent'),
        metadata: {
          method,
          path,
          responseTime,
          statusCode
        },
        timestamp: new Date()
      });
    }
  }

  public async logError(
    error: Error,
    context: string,
    userId: string | null = null,
    req: Request | null = null
  ): Promise<void> {
    const severity = this.determineErrorSeverity(error);
    
    await this.logSecurityEvent({
      eventType: 'ERROR',
      severity,
      description: `Error in ${context}: ${error.message}`,
      userId,
      ipAddress: req?.ip || req?.connection.remoteAddress,
      userAgent: req?.get('User-Agent'),
      metadata: {
        context,
        error: {
          name: error.name,
          message: error.message,
          stack: error.stack
        }
      },
      timestamp: new Date()
    });
  }

  public async logSuspiciousActivity(
    description: string,
    userId: string | null = null,
    ipAddress: string | null = null,
    userAgent: string | null = null,
    metadata: any = null
  ): Promise<void> {
    await this.logSecurityEvent({
      eventType: 'SUSPICIOUS_ACTIVITY',
      severity: 'high',
      description,
      userId,
      ipAddress,
      userAgent,
      metadata,
      timestamp: new Date()
    });
  }

  public async getAuditLogs(
    userId?: string,
    action?: string,
    resourceType?: string,
    startDate?: Date,
    endDate?: Date,
    page: number = 1,
    limit: number = 50
  ): Promise<any> {
    const offset = (page - 1) * limit;
    let query = 'SELECT * FROM audit_log WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (userId) {
      query += ` AND user_id = $${paramIndex}`;
      params.push(userId);
      paramIndex++;
    }

    if (action) {
      query += ` AND action = $${paramIndex}`;
      params.push(action);
      paramIndex++;
    }

    if (resourceType) {
      query += ` AND resource_type = $${paramIndex}`;
      params.push(resourceType);
      paramIndex++;
    }

    if (startDate) {
      query += ` AND timestamp >= $${paramIndex}`;
      params.push(startDate);
      paramIndex++;
    }

    if (endDate) {
      query += ` AND timestamp <= $${paramIndex}`;
      params.push(endDate);
      paramIndex++;
    }

    query += ` ORDER BY timestamp DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await databaseConnection.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM audit_log WHERE 1=1';
    const countParams: any[] = [];
    let countParamIndex = 1;

    if (userId) {
      countQuery += ` AND user_id = $${countParamIndex}`;
      countParams.push(userId);
      countParamIndex++;
    }

    if (action) {
      countQuery += ` AND action = $${countParamIndex}`;
      countParams.push(action);
      countParamIndex++;
    }

    if (resourceType) {
      countQuery += ` AND resource_type = $${countParamIndex}`;
      countParams.push(resourceType);
      countParamIndex++;
    }

    if (startDate) {
      countQuery += ` AND timestamp >= $${countParamIndex}`;
      countParams.push(startDate);
      countParamIndex++;
    }

    if (endDate) {
      countQuery += ` AND timestamp <= $${countParamIndex}`;
      countParams.push(endDate);
      countParamIndex++;
    }

    const countResult = await databaseConnection.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    return {
      logs: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };
  }

  public async getSecurityEvents(
    eventType?: string,
    severity?: string,
    startDate?: Date,
    endDate?: Date,
    page: number = 1,
    limit: number = 50
  ): Promise<any> {
    const offset = (page - 1) * limit;
    let query = 'SELECT * FROM security_events WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (eventType) {
      query += ` AND event_type = $${paramIndex}`;
      params.push(eventType);
      paramIndex++;
    }

    if (severity) {
      query += ` AND severity = $${paramIndex}`;
      params.push(severity);
      paramIndex++;
    }

    if (startDate) {
      query += ` AND timestamp >= $${paramIndex}`;
      params.push(startDate);
      paramIndex++;
    }

    if (endDate) {
      query += ` AND timestamp <= $${paramIndex}`;
      params.push(endDate);
      paramIndex++;
    }

    query += ` ORDER BY timestamp DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await databaseConnection.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM security_events WHERE 1=1';
    const countParams: any[] = [];
    let countParamIndex = 1;

    if (eventType) {
      countQuery += ` AND event_type = $${countParamIndex}`;
      countParams.push(eventType);
      countParamIndex++;
    }

    if (severity) {
      countQuery += ` AND severity = $${countParamIndex}`;
      countParams.push(severity);
      countParamIndex++;
    }

    if (startDate) {
      countQuery += ` AND timestamp >= $${countParamIndex}`;
      countParams.push(startDate);
      countParamIndex++;
    }

    if (endDate) {
      countQuery += ` AND timestamp <= $${countParamIndex}`;
      countParams.push(endDate);
      countParamIndex++;
    }

    const countResult = await databaseConnection.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    return {
      events: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };
  }

  private sanitizeRequestBody(body: any): any {
    if (!body) return null;

    const sanitized = { ...body };
    
    // Remove sensitive fields
    const sensitiveFields = ['password', 'token', 'secret', 'key', 'auth'];
    sensitiveFields.forEach(field => {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    });

    return sanitized;
  }

  private determineErrorSeverity(error: Error): 'low' | 'medium' | 'high' | 'critical' {
    const errorMessage = error.message.toLowerCase();
    
    if (errorMessage.includes('unauthorized') || 
        errorMessage.includes('forbidden') ||
        errorMessage.includes('authentication')) {
      return 'high';
    }
    
    if (errorMessage.includes('database') || 
        errorMessage.includes('connection') ||
        errorMessage.includes('timeout')) {
      return 'medium';
    }
    
    if (errorMessage.includes('validation') || 
        errorMessage.includes('format')) {
      return 'low';
    }
    
    return 'medium';
  }
}

export const auditLoggingService = AuditLoggingService.getInstance();
export default auditLoggingService;
