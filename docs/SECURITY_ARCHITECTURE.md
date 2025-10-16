# 🛡️ Güvenlik Mimarisi ve Güvenlik Önlemleri

## Genel Güvenlik Yaklaşımı

BTC Baran uygulaması, **"Defense in Depth"** (Derinlemesine Savunma) prensibi ile tasarlanmıştır. Her katmanda güvenlik önlemleri alınarak, tek bir güvenlik açığının bile tüm sistemi tehlikeye atması engellenmiştir.

## 🔐 Güvenlik Katmanları

### 1. Network Layer Security
```
┌─────────────────────────────────────────────────────────┐
│                    Internet                             │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                 Cloudflare DDoS Protection              │
│              Rate Limiting & Bot Detection             │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                    Firewall (UFW)                      │
│              Port 443 (HTTPS) Only                     │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                    Nginx Reverse Proxy                  │
│              SSL Termination & Headers                 │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                    Application Layer                    │
│              Express.js + Security Middleware          │
└─────────────────────────────────────────────────────────┘
```

### 2. Application Security Middleware Stack
```typescript
// Security middleware sıralaması
app.use(helmet());                    // Security headers
app.use(cors(corsOptions));           // CORS protection
app.use(rateLimit(rateLimitConfig));  // Rate limiting
app.use(express.json({ limit: '10mb' })); // Request size limit
app.use(express.urlencoded({ extended: false, limit: '10mb' }));
app.use(compression());               // Response compression
app.use(morgan('combined'));          // Request logging
app.use(securityMiddleware);          // Custom security
app.use(authMiddleware);              // Authentication
app.use(authorizationMiddleware);     // Authorization
```

## 🚫 OWASP Top 10 Korumaları

### 1. Broken Access Control
```typescript
// Role-based access control
const requireRole = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userRole = req.user?.role;
    if (!roles.includes(userRole)) {
      return res.status(403).json({ 
        error: 'Insufficient permissions' 
      });
    }
    next();
  };
};

// Usage
app.get('/admin/users', 
  requireRole(['admin', 'super_admin']), 
  adminController.getUsers
);
```

### 2. Cryptographic Failures
```typescript
// AES-256 encryption for sensitive data
import { createCipher, createDecipher, randomBytes } from 'crypto';

class EncryptionService {
  private algorithm = 'aes-256-gcm';
  private key = process.env.ENCRYPTION_KEY;

  encrypt(text: string): string {
    const iv = randomBytes(16);
    const cipher = createCipher(this.algorithm, this.key);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return `${iv.toString('hex')}:${encrypted}`;
  }

  decrypt(encryptedText: string): string {
    const [ivHex, encrypted] = encryptedText.split(':');
    const iv = Buffer.from(ivHex, 'hex');
    const decipher = createDecipher(this.algorithm, this.key);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  }
}
```

### 3. Injection (SQL, NoSQL, Command)
```typescript
// SQL Injection koruması - Parameterized queries
const getUserById = async (userId: string): Promise<User> => {
  const query = 'SELECT * FROM users WHERE id = $1 AND is_active = $2';
  const result = await pool.query(query, [userId, true]);
  return result.rows[0];
};

// Input validation ve sanitization
import Joi from 'joi';

const userSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).required(),
  firstName: Joi.string().min(2).max(50).pattern(/^[a-zA-Z\s]+$/).required(),
  lastName: Joi.string().min(2).max(50).pattern(/^[a-zA-Z\s]+$/).required(),
  tcIdentity: Joi.string().length(11).pattern(/^\d+$/).required()
});

const validateUserInput = (data: any) => {
  return userSchema.validate(data, { abortEarly: false });
};
```

### 4. Insecure Design
```typescript
// Secure session management
class SessionManager {
  private sessions = new Map<string, SessionData>();
  private readonly SESSION_TIMEOUT = 15 * 60 * 1000; // 15 minutes

  createSession(userId: string, ip: string): string {
    const sessionId = crypto.randomBytes(32).toString('hex');
    const session: SessionData = {
      userId,
      ip,
      createdAt: Date.now(),
      lastActivity: Date.now(),
      isActive: true
    };
    
    this.sessions.set(sessionId, session);
    return sessionId;
  }

  validateSession(sessionId: string, ip: string): boolean {
    const session = this.sessions.get(sessionId);
    if (!session || !session.isActive) return false;
    
    // IP address validation
    if (session.ip !== ip) {
      this.invalidateSession(sessionId);
      return false;
    }
    
    // Session timeout check
    if (Date.now() - session.lastActivity > this.SESSION_TIMEOUT) {
      this.invalidateSession(sessionId);
      return false;
    }
    
    session.lastActivity = Date.now();
    return true;
  }
}
```

### 5. Security Misconfiguration
```typescript
// Environment-based security configuration
const securityConfig = {
  development: {
    cors: {
      origin: ['http://localhost:3000', 'http://localhost:8080'],
      credentials: true
    },
    rateLimit: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100 // limit each IP to 100 requests per windowMs
    }
  },
  production: {
    cors: {
      origin: ['https://btc.nazlihw.com'],
      credentials: true
    },
    rateLimit: {
      windowMs: 15 * 60 * 1000,
      max: 50 // stricter limits in production
    }
  }
};

// Security headers configuration
const helmetConfig = {
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
      frameSrc: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
};
```

## 🛡️ Anti-Tampering ve Anti-Reverse Engineering

### 1. Code Obfuscation
```typescript
// Production build için code obfuscation
import JavaScriptObfuscator from 'webpack-obfuscator';

const obfuscatorConfig = {
  compact: true,
  controlFlowFlattening: true,
  controlFlowFlatteningThreshold: 0.75,
  deadCodeInjection: true,
  deadCodeInjectionThreshold: 0.4,
  debugProtection: true,
  debugProtectionInterval: true,
  disableConsoleOutput: true,
  identifierNamesGenerator: 'hexadecimal',
  log: false,
  numbersToExpressions: true,
  renameGlobals: false,
  selfDefending: true,
  simplify: true,
  splitStrings: true,
  splitStringsChunkLength: 10,
  stringArray: true,
  stringArrayEncoding: ['base64'],
  stringArrayThreshold: 0.75,
  transformObjectKeys: true,
  unicodeEscapeSequence: false
};
```

### 2. Certificate Pinning
```typescript
// SSL certificate pinning
const certificatePinning = {
  'btc.nazlihw.com': [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB='
  ]
};

// Certificate validation
const validateCertificate = (hostname: string, cert: any): boolean => {
  const pins = certificatePinning[hostname];
  if (!pins) return true;
  
  const certHash = crypto
    .createHash('sha256')
    .update(cert.raw)
    .digest('base64');
    
  return pins.includes(certHash);
};
```

### 3. Runtime Protection
```typescript
// Anti-debugging protection
class AntiDebugProtection {
  private checkInterval: NodeJS.Timeout;

  constructor() {
    this.startProtection();
  }

  private startProtection(): void {
    this.checkInterval = setInterval(() => {
      this.checkDebugger();
      this.checkDevTools();
      this.checkPerformance();
    }, 1000);
  }

  private checkDebugger(): void {
    const start = performance.now();
    debugger;
    const end = performance.now();
    
    if (end - start > 100) {
      this.handleViolation('Debugger detected');
    }
  }

  private checkDevTools(): void {
    const devtools = {
      open: false,
      orientation: null
    };

    const threshold = 160;
    const widthThreshold = window.outerWidth - window.innerWidth > threshold;
    const heightThreshold = window.outerHeight - window.innerHeight > threshold;
    
    if (widthThreshold || heightThreshold) {
      this.handleViolation('DevTools detected');
    }
  }

  private handleViolation(type: string): void {
    console.error(`Security violation: ${type}`);
    // Log violation ve gerekli aksiyonları al
    this.reportViolation(type);
  }
}
```

## 🔐 Multi-Factor Authentication (MFA)

### 1. TOTP Implementation
```typescript
import { authenticator } from 'otplib';
import QRCode from 'qrcode';

class MFAService {
  generateSecret(userId: string): string {
    const secret = authenticator.generateSecret();
    const otpauth = authenticator.keyuri(
      userId, 
      'BTC Baran', 
      secret
    );
    
    return { secret, otpauth };
  }

  generateQRCode(otpauth: string): Promise<string> {
    return QRCode.toDataURL(otpauth);
  }

  verifyToken(token: string, secret: string): boolean {
    return authenticator.verify({ token, secret });
  }

  generateBackupCodes(): string[] {
    const codes = [];
    for (let i = 0; i < 10; i++) {
      codes.push(crypto.randomBytes(4).toString('hex').toUpperCase());
    }
    return codes;
  }
}
```

### 2. SMS Verification
```typescript
import twilio from 'twilio';

class SMSVerificationService {
  private client: twilio.Twilio;
  private verificationSid: string;

  constructor() {
    this.client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
    this.verificationSid = process.env.TWILIO_VERIFICATION_SID;
  }

  async sendVerification(phoneNumber: string): Promise<boolean> {
    try {
      await this.client.verify.v2
        .services(this.verificationSid)
        .verifications.create({
          to: phoneNumber,
          channel: 'sms'
        });
      return true;
    } catch (error) {
      console.error('SMS verification error:', error);
      return false;
    }
  }

  async verifyCode(phoneNumber: string, code: string): Promise<boolean> {
    try {
      const verification = await this.client.verify.v2
        .services(this.verificationSid)
        .verificationChecks.create({
          to: phoneNumber,
          code
        });
      
      return verification.status === 'approved';
    } catch (error) {
      console.error('SMS verification check error:', error);
      return false;
    }
  }
}
```

## 🔍 Security Monitoring ve Logging

### 1. Security Event Logging
```typescript
import winston from 'winston';

class SecurityLogger {
  private logger: winston.Logger;

  constructor() {
    this.logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
      transports: [
        new winston.transports.File({ 
          filename: 'logs/security.log',
          maxsize: 5242880, // 5MB
          maxFiles: 5
        }),
        new winston.transports.Console({
          format: winston.format.simple()
        })
      ]
    });
  }

  logSecurityEvent(event: SecurityEvent): void {
    this.logger.info('Security Event', {
      timestamp: new Date().toISOString(),
      eventType: event.type,
      severity: event.severity,
      userId: event.userId,
      ipAddress: event.ipAddress,
      userAgent: event.userAgent,
      details: event.details,
      sessionId: event.sessionId
    });
  }

  logFailedLogin(ip: string, email: string, reason: string): void {
    this.logger.warn('Failed Login Attempt', {
      timestamp: new Date().toISOString(),
      ipAddress: ip,
      email,
      reason,
      userAgent: req.headers['user-agent']
    });
  }
}
```

### 2. Intrusion Detection
```typescript
class IntrusionDetectionSystem {
  private suspiciousActivities = new Map<string, ActivityLog[]>();
  private readonly MAX_ATTEMPTS = 5;
  private readonly WINDOW_MS = 15 * 60 * 1000; // 15 minutes

  recordActivity(ip: string, activity: string): boolean {
    const now = Date.now();
    const activities = this.suspiciousActivities.get(ip) || [];
    
    // Remove old activities
    const recentActivities = activities.filter(
      a => now - a.timestamp < this.WINDOW_MS
    );
    
    recentActivities.push({
      activity,
      timestamp: now
    });
    
    this.suspiciousActivities.set(ip, recentActivities);
    
    // Check for suspicious patterns
    if (this.isSuspicious(ip, recentActivities)) {
      this.handleSuspiciousActivity(ip, recentActivities);
      return false;
    }
    
    return true;
  }

  private isSuspicious(ip: string, activities: ActivityLog[]): boolean {
    const failedLogins = activities.filter(a => 
      a.activity === 'failed_login'
    ).length;
    
    const rapidRequests = activities.filter(a => 
      a.activity === 'rapid_request'
    ).length;
    
    return failedLogins >= this.MAX_ATTEMPTS || rapidRequests >= 100;
  }

  private handleSuspiciousActivity(ip: string, activities: ActivityLog[]): void {
    // Block IP temporarily
    this.blockIP(ip);
    
    // Log security event
    securityLogger.logSecurityEvent({
      type: 'SUSPICIOUS_ACTIVITY',
      severity: 'HIGH',
      ipAddress: ip,
      details: { activities }
    });
    
    // Send alert to security team
    this.sendSecurityAlert(ip, activities);
  }
}
```

## 🚨 Incident Response Plan

### 1. Security Incident Classification
```typescript
enum IncidentSeverity {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL'
}

enum IncidentType {
  UNAUTHORIZED_ACCESS = 'UNAUTHORIZED_ACCESS',
  DATA_BREACH = 'DATA_BREACH',
  MALWARE_INFECTION = 'MALWARE_INFECTION',
  DDOS_ATTACK = 'DDOS_ATTACK',
  PHISHING_ATTEMPT = 'PHISHING_ATTEMPT'
}

interface SecurityIncident {
  id: string;
  type: IncidentType;
  severity: IncidentSeverity;
  description: string;
  detectedAt: Date;
  status: 'OPEN' | 'INVESTIGATING' | 'CONTAINED' | 'RESOLVED';
  affectedSystems: string[];
  impact: string;
  responseActions: string[];
}
```

### 2. Automated Response
```typescript
class IncidentResponseAutomation {
  async handleIncident(incident: SecurityIncident): Promise<void> {
    switch (incident.severity) {
      case IncidentSeverity.CRITICAL:
        await this.handleCriticalIncident(incident);
        break;
      case IncidentSeverity.HIGH:
        await this.handleHighSeverityIncident(incident);
        break;
      case IncidentSeverity.MEDIUM:
        await this.handleMediumSeverityIncident(incident);
        break;
      case IncidentSeverity.LOW:
        await this.handleLowSeverityIncident(incident);
        break;
    }
  }

  private async handleCriticalIncident(incident: SecurityIncident): Promise<void> {
    // Immediate containment
    await this.containThreat(incident);
    
    // Notify security team
    await this.notifySecurityTeam(incident, 'IMMEDIATE');
    
    // Isolate affected systems
    await this.isolateSystems(incident.affectedSystems);
    
    // Initiate emergency response
    await this.initiateEmergencyResponse(incident);
  }

  private async containThreat(incident: SecurityIncident): Promise<void> {
    // Block suspicious IPs
    if (incident.type === IncidentType.UNAUTHORIZED_ACCESS) {
      await this.blockSuspiciousIPs(incident);
    }
    
    // Disable compromised accounts
    if (incident.type === IncidentType.DATA_BREACH) {
      await this.disableCompromisedAccounts(incident);
    }
    
    // Update firewall rules
    await this.updateFirewallRules(incident);
  }
}
```

## 📊 Security Metrics ve Reporting

### 1. Security Dashboard Metrics
```typescript
interface SecurityMetrics {
  totalIncidents: number;
  incidentsBySeverity: Record<IncidentSeverity, number>;
  incidentsByType: Record<IncidentType, number>;
  averageResponseTime: number;
  threatsBlocked: number;
  failedLoginAttempts: number;
  suspiciousActivities: number;
  securityScore: number;
}

class SecurityMetricsCollector {
  async getSecurityMetrics(): Promise<SecurityMetrics> {
    const [
      totalIncidents,
      incidentsBySeverity,
      incidentsByType,
      averageResponseTime,
      threatsBlocked,
      failedLoginAttempts,
      suspiciousActivities
    ] = await Promise.all([
      this.getTotalIncidents(),
      this.getIncidentsBySeverity(),
      this.getIncidentsByType(),
      this.getAverageResponseTime(),
      this.getThreatsBlocked(),
      this.getFailedLoginAttempts(),
      this.getSuspiciousActivities()
    ]);

    const securityScore = this.calculateSecurityScore({
      totalIncidents,
      averageResponseTime,
      threatsBlocked
    });

    return {
      totalIncidents,
      incidentsBySeverity,
      incidentsByType,
      averageResponseTime,
      threatsBlocked,
      failedLoginAttempts,
      suspiciousActivities,
      securityScore
    };
  }

  private calculateSecurityScore(metrics: Partial<SecurityMetrics>): number {
    let score = 100;
    
    // Deduct points for incidents
    score -= metrics.totalIncidents * 5;
    
    // Deduct points for slow response
    if (metrics.averageResponseTime > 300000) { // 5 minutes
      score -= 20;
    }
    
    // Add points for blocked threats
    score += Math.min(metrics.threatsBlocked * 2, 20);
    
    return Math.max(0, Math.min(100, score));
  }
}
```

## 🔒 Compliance ve Audit

### 1. GDPR Compliance
```typescript
class GDPRComplianceService {
  async processDataSubjectRequest(
    userId: string, 
    requestType: 'ACCESS' | 'DELETION' | 'PORTABILITY'
  ): Promise<void> {
    switch (requestType) {
      case 'ACCESS':
        await this.provideDataAccess(userId);
        break;
      case 'DELETION':
        await this.deleteUserData(userId);
        break;
      case 'PORTABILITY':
        await this.exportUserData(userId);
        break;
    }
  }

  private async deleteUserData(userId: string): Promise<void> {
    // Anonymize personal data
    await this.anonymizePersonalData(userId);
    
    // Log deletion for audit
    await this.logDataDeletion(userId);
    
    // Notify data protection officer
    await this.notifyDPO('DATA_DELETION', { userId });
  }

  private async anonymizePersonalData(userId: string): Promise<void> {
    const anonymizedData = {
      firstName: 'ANONYMIZED',
      lastName: 'ANONYMIZED',
      email: `anonymized_${userId}@deleted.com`,
      tcIdentity: 'ANONYMIZED',
      phone: 'ANONYMIZED'
    };

    await db.query(
      'UPDATE users SET $1 WHERE id = $2',
      [anonymizedData, userId]
    );
  }
}
```

### 2. Audit Trail
```typescript
class AuditTrailService {
  async logAuditEvent(event: AuditEvent): Promise<void> {
    const auditLog = {
      id: crypto.randomUUID(),
      timestamp: new Date(),
      userId: event.userId,
      action: event.action,
      resource: event.resource,
      details: event.details,
      ipAddress: event.ipAddress,
      userAgent: event.userAgent,
      sessionId: event.sessionId,
      result: event.result
    };

    await db.query(
      'INSERT INTO audit_logs VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)',
      Object.values(auditLog)
    );
  }

  async getAuditTrail(
    filters: AuditTrailFilters
  ): Promise<AuditEvent[]> {
    let query = 'SELECT * FROM audit_logs WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (filters.userId) {
      query += ` AND user_id = $${paramIndex++}`;
      params.push(filters.userId);
    }

    if (filters.action) {
      query += ` AND action = $${paramIndex++}`;
      params.push(filters.action);
    }

    if (filters.startDate) {
      query += ` AND timestamp >= $${paramIndex++}`;
      params.push(filters.startDate);
    }

    if (filters.endDate) {
      query += ` AND timestamp <= $${paramIndex++}`;
      params.push(filters.endDate);
    }

    query += ' ORDER BY timestamp DESC LIMIT $' + paramIndex;
    params.push(filters.limit || 100);

    const result = await db.query(query, params);
    return result.rows;
  }
}
```

## 🚀 Production Deployment Security

### 1. Production Environment Security
```bash
# Production environment variables
NODE_ENV=production
HOST=btc.nazlihw.com
PORT=443
SSL_ENABLED=true

# Security settings
SECURITY_HEADERS_ENABLED=true
RATE_LIMITING_ENABLED=true
CORS_ORIGIN=https://btc.nazlihw.com
SESSION_SECURE=true
SESSION_HTTPONLY=true
SESSION_SAMESITE=strict

# Encryption
ENCRYPTION_KEY=your-256-bit-encryption-key
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-key

# Database security
DATABASE_SSL=true
DATABASE_SSL_REJECT_UNAUTHORIZED=true
DATABASE_ENCRYPTION_KEY=your-database-encryption-key

# Monitoring
SECURITY_MONITORING_ENABLED=true
INTRUSION_DETECTION_ENABLED=true
AUDIT_LOGGING_ENABLED=true
```

### 2. Nginx Security Configuration
```nginx
# /etc/nginx/sites-available/btc.nazlihw.com
server {
    listen 443 ssl http2;
    server_name btc.nazlihw.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/btc.nazlihw.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/btc.nazlihw.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/auth/login {
        limit_req zone=login burst=5 nodelay;
        proxy_pass http://localhost:3000;
    }
}
```

Bu güvenlik mimarisi, BTC Baran uygulamasının `btc.nazlihw.com` sunucusunda production ortamında güvenli bir şekilde çalışmasını sağlayacaktır. Tüm güvenlik önlemleri OWASP Top 10 standartlarına uygun olarak implement edilmiştir.
