import Redis from 'ioredis';
import { logger, securityLogger } from '../utils/logger';
import { config } from '../config/config';

export class RedisConnection {
  private static instance: RedisConnection;
  private client: Redis;
  private subscriber: Redis;
  private isInitialized: boolean = false;
  private connectionAttempts: number = 0;
  private maxConnectionAttempts: number = 5;

  private constructor() {
    this.initializeClient();
  }

  public static getInstance(): RedisConnection {
    if (!RedisConnection.instance) {
      RedisConnection.instance = new RedisConnection();
    }
    return RedisConnection.instance;
  }

  private initializeClient(): void {
    try {
      // Main Redis client
      this.client = new Redis({
        host: config.redis.host,
        port: config.redis.port,
        password: config.redis.password,
        db: config.redis.db,
        keyPrefix: config.redis.keyPrefix,
        
        // Security configurations
        lazyConnect: true,
        retryDelayOnFailover: 100,
        maxRetriesPerRequest: 3,
        
        // Connection settings
        connectTimeout: 10000,
        commandTimeout: 5000,
        keepAlive: 30000,
        
        // TLS configuration for production
        ...(config.nodeEnv === 'production' && {
          tls: {
            rejectUnauthorized: true,
            ca: process.env.REDIS_SSL_CA,
            key: process.env.REDIS_SSL_KEY,
            cert: process.env.REDIS_SSL_CERT
          }
        }),
        
        // Retry strategy
        retryStrategy: (times: number) => {
          const delay = Math.min(times * 50, 2000);
          return delay;
        }
      });

      // Subscriber client for pub/sub
      this.subscriber = new Redis({
        host: config.redis.host,
        port: config.redis.port,
        password: config.redis.password,
        db: config.redis.db,
        keyPrefix: config.redis.keyPrefix,
        
        lazyConnect: true,
        retryDelayOnFailover: 100,
        maxRetriesPerRequest: 3,
        
        connectTimeout: 10000,
        commandTimeout: 5000,
        keepAlive: 30000,
        
        ...(config.nodeEnv === 'production' && {
          tls: {
            rejectUnauthorized: true,
            ca: process.env.REDIS_SSL_CA,
            key: process.env.REDIS_SSL_KEY,
            cert: process.env.REDIS_SSL_CERT
          }
        })
      });

      // Set up event listeners
      this.setupEventListeners();
      
      logger.info('Redis clients initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize Redis clients', { error: error.message });
      throw error;
    }
  }

  private setupEventListeners(): void {
    // Main client events
    this.client.on('connect', () => {
      logger.info('Redis client connected successfully');
    });

    this.client.on('ready', () => {
      logger.info('Redis client ready');
    });

    this.client.on('error', (error: Error) => {
      logger.error('Redis client error', { error: error.message });
      securityLogger.error('Redis connection error', { error: error.message });
    });

    this.client.on('close', () => {
      logger.warn('Redis client connection closed');
    });

    this.client.on('reconnecting', () => {
      logger.info('Redis client reconnecting...');
    });

    // Subscriber client events
    this.subscriber.on('connect', () => {
      logger.info('Redis subscriber connected successfully');
    });

    this.subscriber.on('ready', () => {
      logger.info('Redis subscriber ready');
    });

    this.subscriber.on('error', (error: Error) => {
      logger.error('Redis subscriber error', { error: error.message });
      securityLogger.error('Redis subscriber error', { error: error.message });
    });

    this.subscriber.on('close', () => {
      logger.warn('Redis subscriber connection closed');
    });

    this.subscriber.on('reconnecting', () => {
      logger.info('Redis subscriber reconnecting...');
    });
  }

  public async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      // Test connections
      await this.testConnections();
      
      // Set up security configurations
      await this.setupSecurityConfigs();
      
      // Initialize default data
      await this.initializeDefaultData();
      
      this.isInitialized = true;
      this.connectionAttempts = 0;
      
      logger.info('Redis connection initialized successfully');
    } catch (error) {
      this.connectionAttempts++;
      
      if (this.connectionAttempts >= this.maxConnectionAttempts) {
        logger.error('Max Redis connection attempts reached', {
          attempts: this.connectionAttempts,
          error: error.message
        });
        throw new Error('Failed to initialize Redis connection after multiple attempts');
      }
      
      logger.warn('Redis connection attempt failed, retrying...', {
        attempt: this.connectionAttempts,
        maxAttempts: this.maxConnectionAttempts,
        error: error.message
      });
      
      // Wait before retrying
      await new Promise(resolve => setTimeout(resolve, 5000));
      await this.initialize();
    }
  }

  private async testConnections(): Promise<void> {
    try {
      // Test main client
      const pingResult = await this.client.ping();
      if (pingResult !== 'PONG') {
        throw new Error('Redis ping failed');
      }
      
      // Test subscriber client
      const subscriberPingResult = await this.subscriber.ping();
      if (subscriberPingResult !== 'PONG') {
        throw new Error('Redis subscriber ping failed');
      }
      
      logger.info('Redis connection test successful');
    } catch (error) {
      logger.error('Redis connection test failed', { error: error.message });
      throw error;
    }
  }

  private async setupSecurityConfigs(): Promise<void> {
    try {
      // Set security configurations
      await this.client.config('SET', 'maxmemory-policy', 'allkeys-lru');
      await this.client.config('SET', 'maxmemory', '512mb');
      await this.client.config('SET', 'timeout', '300');
      await this.client.config('SET', 'tcp-keepalive', '300');
      
      // Set slow log threshold
      await this.client.config('SET', 'slowlog-log-slower-than', '10000');
      await this.client.config('SET', 'slowlog-max-len', '128');
      
      logger.info('Redis security configurations set successfully');
    } catch (error) {
      logger.warn('Failed to set Redis security configurations', { error: error.message });
    }
  }

  private async initializeDefaultData(): Promise<void> {
    try {
      // Set default TTL for session data
      const sessionTTL = config.security.sessionTimeout / 1000; // Convert to seconds
      
      // Set default TTL for cache data
      const cacheTTL = 3600; // 1 hour
      
      // Store configuration in Redis
      await this.client.setex('config:session_ttl', 86400, sessionTTL.toString());
      await this.client.setex('config:cache_ttl', 86400, cacheTTL.toString());
      await this.client.setex('config:max_login_attempts', 86400, config.security.maxLoginAttempts.toString());
      await this.client.setex('config:lockout_duration', 86400, (config.security.lockoutDuration / 1000).toString());
      
      logger.info('Redis default data initialized successfully');
    } catch (error) {
      logger.warn('Failed to initialize Redis default data', { error: error.message });
    }
  }

  // Key-value operations
  public async set(key: string, value: any, ttl?: number): Promise<void> {
    try {
      const serializedValue = JSON.stringify(value);
      if (ttl) {
        await this.client.setex(key, ttl, serializedValue);
      } else {
        await this.client.set(key, serializedValue);
      }
    } catch (error) {
      logger.error('Redis set operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async get(key: string): Promise<any> {
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis get operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async del(key: string): Promise<void> {
    try {
      await this.client.del(key);
    } catch (error) {
      logger.error('Redis del operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async exists(key: string): Promise<boolean> {
    try {
      const result = await this.client.exists(key);
      return result === 1;
    } catch (error) {
      logger.error('Redis exists operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async expire(key: string, ttl: number): Promise<void> {
    try {
      await this.client.expire(key, ttl);
    } catch (error) {
      logger.error('Redis expire operation failed', { key, ttl, error: error.message });
      throw error;
    }
  }

  // Hash operations
  public async hset(key: string, field: string, value: any): Promise<void> {
    try {
      const serializedValue = JSON.stringify(value);
      await this.client.hset(key, field, serializedValue);
    } catch (error) {
      logger.error('Redis hset operation failed', { key, field, error: error.message });
      throw error;
    }
  }

  public async hget(key: string, field: string): Promise<any> {
    try {
      const value = await this.client.hget(key, field);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis hget operation failed', { key, field, error: error.message });
      throw error;
    }
  }

  public async hdel(key: string, field: string): Promise<void> {
    try {
      await this.client.hdel(key, field);
    } catch (error) {
      logger.error('Redis hdel operation failed', { key, field, error: error.message });
      throw error;
    }
  }

  public async hgetall(key: string): Promise<Record<string, any>> {
    try {
      const result = await this.client.hgetall(key);
      const parsed: Record<string, any> = {};
      
      for (const [field, value] of Object.entries(result)) {
        try {
          parsed[field] = JSON.parse(value);
        } catch {
          parsed[field] = value;
        }
      }
      
      return parsed;
    } catch (error) {
      logger.error('Redis hgetall operation failed', { key, error: error.message });
      throw error;
    }
  }

  // List operations
  public async lpush(key: string, value: any): Promise<void> {
    try {
      const serializedValue = JSON.stringify(value);
      await this.client.lpush(key, serializedValue);
    } catch (error) {
      logger.error('Redis lpush operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async rpush(key: string, value: any): Promise<void> {
    try {
      const serializedValue = JSON.stringify(value);
      await this.client.rpush(key, serializedValue);
    } catch (error) {
      logger.error('Redis rpush operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async lpop(key: string): Promise<any> {
    try {
      const value = await this.client.lpop(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis lpop operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async rpop(key: string): Promise<any> {
    try {
      const value = await this.client.rpop(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis rpop operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async lrange(key: string, start: number, stop: number): Promise<any[]> {
    try {
      const values = await this.client.lrange(key, start, stop);
      return values.map(value => {
        try {
          return JSON.parse(value);
        } catch {
          return value;
        }
      });
    } catch (error) {
      logger.error('Redis lrange operation failed', { key, start, stop, error: error.message });
      throw error;
    }
  }

  // Set operations
  public async sadd(key: string, member: any): Promise<void> {
    try {
      const serializedMember = JSON.stringify(member);
      await this.client.sadd(key, serializedMember);
    } catch (error) {
      logger.error('Redis sadd operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async srem(key: string, member: any): Promise<void> {
    try {
      const serializedMember = JSON.stringify(member);
      await this.client.srem(key, serializedMember);
    } catch (error) {
      logger.error('Redis srem operation failed', { key, error: error.message });
      throw error;
    }
  }

  public async smembers(key: string): Promise<any[]> {
    try {
      const members = await this.client.smembers(key);
      return members.map(member => {
        try {
          return JSON.parse(member);
        } catch {
          return member;
        }
      });
    } catch (error) {
      logger.error('Redis smembers operation failed', { key, error: error.message });
      throw error;
    }
  }

  // Pub/Sub operations
  public async publish(channel: string, message: any): Promise<void> {
    try {
      const serializedMessage = JSON.stringify(message);
      await this.client.publish(channel, serializedMessage);
    } catch (error) {
      logger.error('Redis publish operation failed', { channel, error: error.message });
      throw error;
    }
  }

  public async subscribe(channel: string, callback: (message: any) => void): Promise<void> {
    try {
      await this.subscriber.subscribe(channel);
      this.subscriber.on('message', (receivedChannel: string, message: string) => {
        if (receivedChannel === channel) {
          try {
            const parsedMessage = JSON.parse(message);
            callback(parsedMessage);
          } catch {
            callback(message);
          }
        }
      });
    } catch (error) {
      logger.error('Redis subscribe operation failed', { channel, error: error.message });
      throw error;
    }
  }

  public async unsubscribe(channel: string): Promise<void> {
    try {
      await this.subscriber.unsubscribe(channel);
    } catch (error) {
      logger.error('Redis unsubscribe operation failed', { channel, error: error.message });
      throw error;
    }
  }

  // Utility operations
  public async flushdb(): Promise<void> {
    try {
      await this.client.flushdb();
      logger.warn('Redis database flushed');
    } catch (error) {
      logger.error('Redis flushdb operation failed', { error: error.message });
      throw error;
    }
  }

  public async info(): Promise<any> {
    try {
      const info = await this.client.info();
      return this.parseRedisInfo(info);
    } catch (error) {
      logger.error('Redis info operation failed', { error: error.message });
      throw error;
    }
  }

  private parseRedisInfo(info: string): Record<string, any> {
    const lines = info.split('\r\n');
    const result: Record<string, any> = {};
    
    for (const line of lines) {
      if (line.includes(':')) {
        const [key, value] = line.split(':');
        result[key] = value;
      }
    }
    
    return result;
  }

  public async close(): Promise<void> {
    try {
      await this.client.quit();
      await this.subscriber.quit();
      this.isInitialized = false;
      logger.info('Redis connection closed successfully');
    } catch (error) {
      logger.error('Failed to close Redis connection', { error: error.message });
      throw error;
    }
  }

  public getClient(): Redis {
    return this.client;
  }

  public getSubscriber(): Redis {
    return this.subscriber;
  }

  public isConnected(): boolean {
    return this.isInitialized && this.client.status === 'ready';
  }

  public getConnectionStats(): object {
    return {
      clientStatus: this.client.status,
      subscriberStatus: this.subscriber.status,
      isInitialized: this.isInitialized
    };
  }
}

export const redisConnection = RedisConnection.getInstance();
export default redisConnection;
