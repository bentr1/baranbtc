import { Pool, PoolClient, QueryResult } from 'pg';
import { logger, securityLogger } from '../utils/logger';
import { config } from '../config/config';

export class DatabaseConnection {
  private static instance: DatabaseConnection;
  private pool: Pool;
  private isInitialized: boolean = false;
  private connectionAttempts: number = 0;
  private maxConnectionAttempts: number = 5;

  private constructor() {
    this.initializePool();
  }

  public static getInstance(): DatabaseConnection {
    if (!DatabaseConnection.instance) {
      DatabaseConnection.instance = new DatabaseConnection();
    }
    return DatabaseConnection.instance;
  }

  private initializePool(): void {
    try {
      this.pool = new Pool({
        host: config.database.host,
        port: config.database.port,
        database: config.database.name,
        user: config.database.user,
        password: config.database.password,
        ssl: config.database.ssl ? { rejectUnauthorized: false } : false,
        max: config.database.maxConnections,
        idleTimeoutMillis: config.database.idleTimeoutMillis,
        connectionTimeoutMillis: config.database.connectionTimeoutMillis,
        
        // Security configurations
        application_name: 'btcbaran-backend',
        statement_timeout: 30000, // 30 seconds
        query_timeout: 30000, // 30 seconds
        idle_in_transaction_session_timeout: 60000, // 1 minute
        
        // Connection validation
        connectionTimeoutMillis: 5000,
        idleTimeoutMillis: 30000,
        
        // SSL configuration for production
        ...(config.database.ssl && {
          ssl: {
            rejectUnauthorized: true,
            ca: process.env.DB_SSL_CA,
            key: process.env.DB_SSL_KEY,
            cert: process.env.DB_SSL_CERT
          }
        })
      });

      // Set up event listeners
      this.setupEventListeners();
      
      logger.info('Database pool initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize database pool', { error: error.message });
      throw error;
    }
  }

  private setupEventListeners(): void {
    // Connection events
    this.pool.on('connect', (client: PoolClient) => {
      logger.debug('New database client connected', {
        clientId: client.processID,
        timestamp: new Date().toISOString()
      });
      
      // Set session-level security parameters
      this.setClientSecurityParams(client);
    });

    this.pool.on('acquire', (client: PoolClient) => {
      logger.debug('Client acquired from pool', {
        clientId: client.processID,
        timestamp: new Date().toISOString()
      });
    });

    this.pool.on('release', (client: PoolClient) => {
      logger.debug('Client released to pool', {
        clientId: client.processID,
        timestamp: new Date().toISOString()
      });
    });

    this.pool.on('error', (err: Error, client: PoolClient) => {
      logger.error('Database pool error', {
        error: err.message,
        clientId: client?.processID,
        timestamp: new Date().toISOString()
      });
      
      securityLogger.error('Database connection error', {
        error: err.message,
        clientId: client?.processID
      });
    });
  }

  private async setClientSecurityParams(client: PoolClient): Promise<void> {
    try {
      // Set session-level security parameters
      await client.query('SET statement_timeout = 30000'); // 30 seconds
      await client.query('SET lock_timeout = 10000'); // 10 seconds
      await client.query('SET idle_in_transaction_session_timeout = 60000'); // 1 minute
      
      // Set application name for monitoring
      await client.query(`SET application_name = 'btcbaran-backend-${process.pid}'`);
      
      // Set timezone
      await client.query('SET timezone = \'UTC\'');
      
      logger.debug('Client security parameters set', {
        clientId: client.processID
      });
    } catch (error) {
      logger.warn('Failed to set client security parameters', {
        error: error.message,
        clientId: client.processID
      });
    }
  }

  public async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      // Test connection
      await this.testConnection();
      
      // Create tables if they don't exist
      await this.createTables();
      
      // Create indexes
      await this.createIndexes();
      
      // Set up triggers for audit logging
      await this.setupAuditTriggers();
      
      this.isInitialized = true;
      this.connectionAttempts = 0;
      
      logger.info('Database connection initialized successfully');
    } catch (error) {
      this.connectionAttempts++;
      
      if (this.connectionAttempts >= this.maxConnectionAttempts) {
        logger.error('Max database connection attempts reached', {
          attempts: this.connectionAttempts,
          error: error.message
        });
        throw new Error('Failed to initialize database connection after multiple attempts');
      }
      
      logger.warn('Database connection attempt failed, retrying...', {
        attempt: this.connectionAttempts,
        maxAttempts: this.maxConnectionAttempts,
        error: error.message
      });
      
      // Wait before retrying
      await new Promise(resolve => setTimeout(resolve, 5000));
      await this.initialize();
    }
  }

  private async testConnection(): Promise<void> {
    const client = await this.pool.connect();
    try {
      const result = await client.query('SELECT NOW() as current_time, version() as db_version');
      logger.info('Database connection test successful', {
        currentTime: result.rows[0].current_time,
        version: result.rows[0].db_version.split(' ')[0] // Extract version number
      });
    } finally {
      client.release();
    }
  }

  private async createTables(): Promise<void> {
    const client = await this.pool.connect();
    try {
      // Users table
      await client.query(`
        CREATE TABLE IF NOT EXISTS users (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          tc_id VARCHAR(11) UNIQUE NOT NULL,
          email VARCHAR(255) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          first_name VARCHAR(100) NOT NULL,
          last_name VARCHAR(100) NOT NULL,
          phone VARCHAR(20),
          is_active BOOLEAN DEFAULT false,
          is_verified BOOLEAN DEFAULT false,
          email_verification_token VARCHAR(255),
          email_verification_expires TIMESTAMP,
          mfa_enabled BOOLEAN DEFAULT false,
          mfa_secret VARCHAR(255),
          last_login TIMESTAMP,
          login_attempts INTEGER DEFAULT 0,
          locked_until TIMESTAMP,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP,
          
          CONSTRAINT tc_id_format CHECK (tc_id ~ '^[0-9]{11}$'),
          CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
          CONSTRAINT phone_format CHECK (phone ~ '^[+]?[0-9]{10,15}$')
        )
      `);

      // User sessions table
      await client.query(`
        CREATE TABLE IF NOT EXISTS user_sessions (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          refresh_token VARCHAR(255) NOT NULL,
          device_info JSONB,
          ip_address INET,
          user_agent TEXT,
          expires_at TIMESTAMP NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          
          CONSTRAINT refresh_token_unique UNIQUE(refresh_token)
        )
      `);

      // Crypto pairs table
      await client.query(`
        CREATE TABLE IF NOT EXISTS crypto_pairs (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          symbol VARCHAR(20) UNIQUE NOT NULL,
          base_asset VARCHAR(20) NOT NULL,
          quote_asset VARCHAR(20) NOT NULL,
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Candlestick data table (TimescaleDB hypertable)
      await client.query(`
        CREATE TABLE IF NOT EXISTS candlestick_data (
          time TIMESTAMP NOT NULL,
          symbol VARCHAR(20) NOT NULL,
          open DECIMAL(20,8) NOT NULL,
          high DECIMAL(20,8) NOT NULL,
          low DECIMAL(20,8) NOT NULL,
          close DECIMAL(20,8) NOT NULL,
          volume DECIMAL(20,8) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Create TimescaleDB hypertable
      await client.query(`
        SELECT create_hypertable('candlestick_data', 'time', 
          if_not_exists => TRUE,
          chunk_time_interval => INTERVAL '1 day'
        )
      `);

      // Technical analysis results table
      await client.query(`
        CREATE TABLE IF NOT EXISTS technical_analysis (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          symbol VARCHAR(20) NOT NULL,
          analysis_type VARCHAR(50) NOT NULL,
          timeframe VARCHAR(20) NOT NULL,
          pivot_levels JSONB,
          support_resistance JSONB,
          moving_averages JSONB,
          signal_type VARCHAR(20),
          confidence_score DECIMAL(3,2),
          analysis_date TIMESTAMP NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          
          CONSTRAINT analysis_type_check CHECK (analysis_type IN ('pivot', 'support_resistance', 'moving_average')),
          CONSTRAINT timeframe_check CHECK (timeframe IN ('1d', '3d', '1w')),
          CONSTRAINT signal_type_check CHECK (signal_type IN ('bullish', 'bearish', 'neutral')),
          CONSTRAINT confidence_score_check CHECK (confidence_score >= 0 AND confidence_score <= 1)
        )
      `);

      // User notifications table
      await client.query(`
        CREATE TABLE IF NOT EXISTS user_notifications (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          type VARCHAR(50) NOT NULL,
          title VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          data JSONB,
          is_read BOOLEAN DEFAULT false,
          sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          read_at TIMESTAMP,
          
          CONSTRAINT notification_type_check CHECK (type IN ('signal', 'price_alert', 'system', 'security'))
        )
      `);

      // Audit log table
      await client.query(`
        CREATE TABLE IF NOT EXISTS audit_log (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID REFERENCES users(id),
          action VARCHAR(100) NOT NULL,
          resource VARCHAR(100) NOT NULL,
          resource_id VARCHAR(255),
          details JSONB,
          ip_address INET,
          user_agent TEXT,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Security events table
      await client.query(`
        CREATE TABLE IF NOT EXISTS security_events (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          event_type VARCHAR(50) NOT NULL,
          severity VARCHAR(20) NOT NULL,
          description TEXT NOT NULL,
          user_id UUID REFERENCES users(id),
          ip_address INET,
          user_agent TEXT,
          metadata JSONB,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          
          CONSTRAINT severity_check CHECK (severity IN ('low', 'medium', 'high', 'critical'))
        )
      `);

      logger.info('Database tables created successfully');
    } catch (error) {
      logger.error('Failed to create database tables', { error: error.message });
      throw error;
    } finally {
      client.release();
    }
  }

  private async createIndexes(): Promise<void> {
    const client = await this.pool.connect();
    try {
      // Performance indexes
      await client.query('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_users_tc_id ON users(tc_id)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)');
      
      await client.query('CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_sessions_refresh_token ON user_sessions(refresh_token)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON user_sessions(expires_at)');
      
      await client.query('CREATE INDEX IF NOT EXISTS idx_candlestick_symbol_time ON candlestick_data(symbol, time DESC)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_candlestick_time ON candlestick_data(time DESC)');
      
      await client.query('CREATE INDEX IF NOT EXISTS idx_analysis_symbol_date ON technical_analysis(symbol, analysis_date DESC)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_analysis_type_timeframe ON technical_analysis(analysis_type, timeframe)');
      
      await client.query('CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON user_notifications(user_id)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_notifications_type ON user_notifications(type)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_notifications_sent_at ON user_notifications(sent_at DESC)');
      
      await client.query('CREATE INDEX IF NOT EXISTS idx_audit_user_id ON audit_log(user_id)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_log(action)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_log(timestamp DESC)');
      
      await client.query('CREATE INDEX IF NOT EXISTS idx_security_events_type ON security_events(event_type)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_security_events_severity ON security_events(severity)');
      await client.query('CREATE INDEX IF NOT EXISTS idx_security_events_timestamp ON security_events(timestamp DESC)');
      
      logger.info('Database indexes created successfully');
    } catch (error) {
      logger.error('Failed to create database indexes', { error: error.message });
      throw error;
    } finally {
      client.release();
    }
  }

  private async setupAuditTriggers(): Promise<void> {
    const client = await this.pool.connect();
    try {
      // Function to update updated_at timestamp
      await client.query(`
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
          NEW.updated_at = CURRENT_TIMESTAMP;
          RETURN NEW;
        END;
        $$ language 'plpgsql'
      `);

      // Triggers for updated_at
      await client.query(`
        DROP TRIGGER IF EXISTS update_users_updated_at ON users;
        CREATE TRIGGER update_users_updated_at
          BEFORE UPDATE ON users
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column()
      `);

      await client.query(`
        DROP TRIGGER IF EXISTS update_crypto_pairs_updated_at ON crypto_pairs;
        CREATE TRIGGER update_crypto_pairs_updated_at
          BEFORE UPDATE ON crypto_pairs
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column()
      `);

      await client.query(`
        DROP TRIGGER IF EXISTS update_technical_analysis_updated_at ON technical_analysis;
        CREATE TRIGGER update_technical_analysis_updated_at
          BEFORE UPDATE ON technical_analysis
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column()
      `);

      logger.info('Database audit triggers created successfully');
    } catch (error) {
      logger.error('Failed to create database audit triggers', { error: error.message });
      throw error;
    } finally {
      client.release();
    }
  }

  public async query(text: string, params?: any[]): Promise<QueryResult> {
    try {
      const startTime = Date.now();
      const result = await this.pool.query(text, params);
      const executionTime = Date.now() - startTime;
      
      // Log slow queries
      if (executionTime > 1000) { // 1 second
        logger.warn('Slow database query detected', {
          query: text.substring(0, 100) + '...',
          executionTime,
          rowCount: result.rowCount
        });
      }
      
      return result;
    } catch (error) {
      logger.error('Database query error', {
        query: text.substring(0, 100) + '...',
        error: error.message,
        params: params
      });
      
      securityLogger.error('Database query error', {
        query: text.substring(0, 100) + '...',
        error: error.message
      });
      
      throw error;
    }
  }

  public async getClient(): Promise<PoolClient> {
    try {
      const client = await this.pool.connect();
      return client;
    } catch (error) {
      logger.error('Failed to get database client', { error: error.message });
      throw error;
    }
  }

  public async close(): Promise<void> {
    try {
      await this.pool.end();
      this.isInitialized = false;
      logger.info('Database connection closed successfully');
    } catch (error) {
      logger.error('Failed to close database connection', { error: error.message });
      throw error;
    }
  }

  public getPool(): Pool {
    return this.pool;
  }

  public isConnected(): boolean {
    return this.isInitialized && this.pool.totalCount > 0;
  }

  public getConnectionStats(): object {
    return {
      totalCount: this.pool.totalCount,
      idleCount: this.pool.idleCount,
      waitingCount: this.pool.waitingCount,
      isInitialized: this.isInitialized
    };
  }
}

export const databaseConnection = DatabaseConnection.getInstance();
export default databaseConnection;
