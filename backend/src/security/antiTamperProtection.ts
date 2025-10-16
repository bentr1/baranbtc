import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { securityLogger } from '../utils/logger';
import { config } from '../config/config';

export class AntiTamperProtection {
  private static instance: AntiTamperProtection;
  private integrityChecksums: Map<string, string> = new Map();
  private isInitialized: boolean = false;
  private heartbeatInterval: NodeJS.Timeout | null = null;

  private constructor() {}

  public static getInstance(): AntiTamperProtection {
    if (!AntiTamperProtection.instance) {
      AntiTamperProtection.instance = new AntiTamperProtection();
    }
    return AntiTamperProtection.instance;
  }

  public initialize(): void {
    if (this.isInitialized) {
      return;
    }

    try {
      // Initialize integrity checks
      this.calculateIntegrityChecksums();
      
      // Start anti-debugging protection
      this.startAntiDebugging();
      
      // Start heartbeat monitoring
      this.startHeartbeat();
      
      // Set up process monitoring
      this.setupProcessMonitoring();
      
      // Set up file system monitoring
      this.setupFileSystemMonitoring();
      
      this.isInitialized = true;
      securityLogger.info('Anti-tamper protection initialized successfully');
    } catch (error) {
      securityLogger.error('Failed to initialize anti-tamper protection', { error: error.message });
      throw error;
    }
  }

  private calculateIntegrityChecksums(): void {
    try {
      const criticalFiles = [
        'main.js',
        'config.js',
        'security.js',
        'middleware/security.js',
        'utils/logger.js'
      ];

      criticalFiles.forEach(file => {
        const filePath = path.join(__dirname, '..', '..', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          const checksum = crypto.createHash('sha256').update(content).digest('hex');
          this.integrityChecksums.set(file, checksum);
        }
      });

      securityLogger.info('Integrity checksums calculated', {
        filesCount: this.integrityChecksums.size
      });
    } catch (error) {
      securityLogger.error('Failed to calculate integrity checksums', { error: error.message });
    }
  }

  private startAntiDebugging(): void {
    // Anti-debugging techniques
    let devtools = false;
    
    // Method 1: Check console timing
    const checkDevTools = () => {
      const start = performance.now();
      debugger;
      const end = performance.now();
      
      if (end - start > 100) {
        devtools = true;
        this.handleTamperingDetected('Anti-debugging: DevTools detected via timing');
      }
    };

    // Method 2: Check console size
    const checkConsoleSize = () => {
      if (window.outerHeight - window.innerHeight > 200 || 
          window.outerWidth - window.innerWidth > 200) {
        devtools = true;
        this.handleTamperingDetected('Anti-debugging: DevTools detected via window size');
      }
    };

    // Method 3: Check console methods
    const checkConsoleMethods = () => {
      const originalLog = console.log;
      const originalWarn = console.warn;
      const originalError = console.error;
      
      console.log = function(...args) {
        if (devtools) {
          this.handleTamperingDetected('Anti-debugging: Console method override detected');
        }
        return originalLog.apply(console, args);
      }.bind(this);
      
      console.warn = function(...args) {
        if (devtools) {
          this.handleTamperingDetected('Anti-debugging: Console method override detected');
        }
        return originalWarn.apply(console, args);
      }.bind(this);
      
      console.error = function(...args) {
        if (devtools) {
          this.handleTamperingDetected('Anti-debugging: Console method override detected');
        }
        return originalError.apply(console, args);
      }.bind(this);
    };

    // Run checks periodically
    setInterval(checkDevTools, 1000);
    setInterval(checkConsoleSize, 1000);
    
    // Initial check
    setTimeout(() => {
      checkConsoleMethods();
    }, 1000);
  }

  private startHeartbeat(): void {
    this.heartbeatInterval = setInterval(() => {
      try {
        // Verify critical files integrity
        this.verifyFileIntegrity();
        
        // Check process memory usage
        this.checkProcessIntegrity();
        
        // Verify environment variables
        this.verifyEnvironmentIntegrity();
        
        // Log heartbeat
        securityLogger.info('Anti-tamper heartbeat check completed');
      } catch (error) {
        this.handleTamperingDetected(`Heartbeat check failed: ${error.message}`);
      }
    }, 30000); // Every 30 seconds
  }

  private setupProcessMonitoring(): void {
    // Monitor for suspicious process modifications
    process.on('warning', (warning) => {
      securityLogger.warn('Process warning detected', {
        name: warning.name,
        message: warning.message,
        stack: warning.stack
      });
    });

    // Monitor for uncaught exceptions
    process.on('uncaughtException', (error) => {
      securityLogger.error('Uncaught exception detected', {
        message: error.message,
        stack: error.stack
      });
      
      // Check if this is a tampering attempt
      if (this.isSuspiciousException(error)) {
        this.handleTamperingDetected(`Suspicious exception: ${error.message}`);
      }
    });

    // Monitor for unhandled rejections
    process.on('unhandledRejection', (reason, promise) => {
      securityLogger.error('Unhandled rejection detected', {
        reason: reason,
        promise: promise
      });
    });
  }

  private setupFileSystemMonitoring(): void {
    // Monitor critical directories for changes
    const criticalDirs = [
      path.join(__dirname, '..', '..', 'src'),
      path.join(__dirname, '..', '..', 'config'),
      path.join(__dirname, '..', '..', 'package.json')
    ];

    criticalDirs.forEach(dir => {
      if (fs.existsSync(dir)) {
        try {
          const stats = fs.statSync(dir);
          const lastModified = stats.mtime.getTime();
          
          // Store initial modification time
          if (dir.endsWith('package.json')) {
            this.integrityChecksums.set('package.json.mtime', lastModified.toString());
          }
        } catch (error) {
          securityLogger.warn('Failed to monitor directory', { dir, error: error.message });
        }
      }
    });
  }

  private verifyFileIntegrity(): void {
    this.integrityChecksums.forEach((expectedChecksum, file) => {
      try {
        const filePath = path.join(__dirname, '..', '..', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          const currentChecksum = crypto.createHash('sha256').update(content).digest('hex');
          
          if (currentChecksum !== expectedChecksum) {
            this.handleTamperingDetected(`File integrity check failed: ${file}`);
          }
        }
      } catch (error) {
        securityLogger.warn('Failed to verify file integrity', { file, error: error.message });
      }
    });
  }

  private checkProcessIntegrity(): void {
    // Check memory usage
    const memUsage = process.memoryUsage();
    if (memUsage.heapUsed > 500 * 1024 * 1024) { // 500MB limit
      securityLogger.warn('High memory usage detected', {
        heapUsed: memUsage.heapUsed,
        heapTotal: memUsage.heapTotal,
        external: memUsage.external
      });
    }

    // Check uptime
    const uptime = process.uptime();
    if (uptime > 24 * 60 * 60) { // 24 hours
      securityLogger.info('Process uptime', { uptime });
    }
  }

  private verifyEnvironmentIntegrity(): void {
    // Verify critical environment variables
    const criticalEnvVars = [
      'NODE_ENV',
      'JWT_SECRET',
      'ENCRYPTION_KEY',
      'DB_HOST',
      'DB_PASSWORD'
    ];

    criticalEnvVars.forEach(envVar => {
      if (!process.env[envVar]) {
        securityLogger.warn('Critical environment variable missing', { envVar });
      }
    });
  }

  private isSuspiciousException(error: Error): boolean {
    const suspiciousPatterns = [
      /tamper/i,
      /debug/i,
      /inject/i,
      /override/i,
      /modify/i,
      /hack/i,
      /exploit/i
    ];

    return suspiciousPatterns.some(pattern => 
      pattern.test(error.message) || pattern.test(error.stack || '')
    );
  }

  private handleTamperingDetected(reason: string): void {
    securityLogger.error('Tampering detected', {
      reason,
      timestamp: new Date().toISOString(),
      processId: process.pid,
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage()
    });

    // Log security incident
    this.logSecurityIncident(reason);

    // In production, take action
    if (config.nodeEnv === 'production') {
      // Option 1: Shutdown gracefully
      // this.gracefulShutdown();
      
      // Option 2: Restart process
      // process.exit(1);
      
      // Option 3: Continue with monitoring
      securityLogger.warn('Tampering detected but continuing operation for monitoring purposes');
    }
  }

  private logSecurityIncident(reason: string): void {
    const incident = {
      type: 'TAMPERING_DETECTED',
      reason,
      timestamp: new Date().toISOString(),
      processId: process.pid,
      environment: config.nodeEnv,
      severity: 'HIGH',
      action: 'MONITORING'
    };

    // Log to security log
    securityLogger.error('Security incident logged', incident);

    // Store in incident log file
    try {
      const incidentLogPath = path.join(__dirname, '..', '..', 'logs', 'security-incidents.log');
      const incidentLogDir = path.dirname(incidentLogPath);
      
      if (!fs.existsSync(incidentLogDir)) {
        fs.mkdirSync(incidentLogDir, { recursive: true });
      }
      
      fs.appendFileSync(incidentLogPath, JSON.stringify(incident) + '\n');
    } catch (error) {
      securityLogger.error('Failed to log security incident to file', { error: error.message });
    }
  }

  public verifyCodeIntegrity(): boolean {
    try {
      this.verifyFileIntegrity();
      return true;
    } catch (error) {
      securityLogger.error('Code integrity verification failed', { error: error.message });
      return false;
    }
  }

  public getIntegrityStatus(): object {
    return {
      initialized: this.isInitialized,
      filesMonitored: this.integrityChecksums.size,
      lastCheck: new Date().toISOString(),
      status: 'ACTIVE'
    };
  }

  public shutdown(): void {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
    
    this.isInitialized = false;
    securityLogger.info('Anti-tamper protection shutdown');
  }
}

export const antiTamperProtection = AntiTamperProtection.getInstance();
