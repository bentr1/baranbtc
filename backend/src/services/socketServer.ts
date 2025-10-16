import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import { logger, securityLogger } from '../utils/logger';
import { config } from '../config/config';
import { redisConnection } from '../database/redis';

export class SocketServerService {
  private static instance: SocketServerService;
  private io: SocketIOServer | null = null;
  private isInitialized: boolean = false;
  private connectedClients: Map<string, any> = new Map();

  private constructor() {}

  public static getInstance(): SocketServerService {
    if (!SocketServerService.instance) {
      SocketServerService.instance = new SocketServerService();
    }
    return SocketServerService.instance;
  }

  public initialize(httpServer?: HTTPServer): void {
    if (this.isInitialized) {
      logger.warn('Socket server is already initialized');
      return;
    }

    try {
      if (httpServer) {
        this.io = new SocketIOServer(httpServer, {
          cors: {
            origin: config.allowedOrigins,
            methods: ['GET', 'POST'],
            credentials: true
          },
          transports: ['websocket', 'polling'],
          allowEIO3: true,
          pingTimeout: 60000,
          pingInterval: 25000,
          upgradeTimeout: 10000,
          maxHttpBufferSize: 1e6, // 1MB
          allowRequest: (req, callback) => {
            // Security check for socket connections
            this.validateSocketConnection(req, callback);
          }
        });
      } else {
        // Standalone socket server
        this.io = new SocketIOServer(3001, {
          cors: {
            origin: config.allowedOrigins,
            methods: ['GET', 'POST'],
            credentials: true
          },
          transports: ['websocket', 'polling'],
          allowEIO3: true,
          pingTimeout: 60000,
          pingInterval: 25000,
          upgradeTimeout: 10000,
          maxHttpBufferSize: 1e6, // 1MB
          allowRequest: (req, callback) => {
            this.validateSocketConnection(req, callback);
          }
        });
      }

      this.setupEventHandlers();
      this.setupRedisPubSub();
      
      this.isInitialized = true;
      logger.info('Socket server initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize socket server', { error: error.message });
      throw error;
    }
  }

  private validateSocketConnection(req: any, callback: (err: string | null, success: boolean) => void): void {
    try {
      const origin = req.headers.origin;
      const userAgent = req.headers['user-agent'];
      
      // Validate origin
      if (origin && !config.allowedOrigins.includes(origin)) {
        securityLogger.warn('Socket connection blocked - invalid origin', {
          origin,
          userAgent,
          ip: req.connection.remoteAddress
        });
        callback('Invalid origin', false);
        return;
      }
      
      // Validate user agent
      if (!userAgent || userAgent.length > 500) {
        securityLogger.warn('Socket connection blocked - invalid user agent', {
          userAgent,
          ip: req.connection.remoteAddress
        });
        callback('Invalid user agent', false);
        return;
      }
      
      // Rate limiting check
      const clientIP = req.connection.remoteAddress;
      if (this.isRateLimited(clientIP)) {
        securityLogger.warn('Socket connection blocked - rate limited', {
          ip: clientIP,
          userAgent
        });
        callback('Rate limited', false);
        return;
      }
      
      callback(null, true);
    } catch (error) {
      securityLogger.error('Socket connection validation error', {
        error: error.message,
        ip: req.connection.remoteAddress
      });
      callback('Validation error', false);
    }
  }

  private isRateLimited(clientIP: string): boolean {
    // Simple in-memory rate limiting
    const now = Date.now();
    const clientConnections = this.connectedClients.get(clientIP) || [];
    
    // Remove old connection attempts (older than 1 minute)
    const recentConnections = clientConnections.filter(time => now - time < 60000);
    
    // Allow max 10 connections per minute per IP
    if (recentConnections.length >= 10) {
      return true;
    }
    
    // Add current connection attempt
    recentConnections.push(now);
    this.connectedClients.set(clientIP, recentConnections);
    
    return false;
  }

  private setupEventHandlers(): void {
    if (!this.io) return;

    this.io.on('connection', (socket) => {
      const clientInfo = {
        id: socket.id,
        ip: socket.handshake.address,
        userAgent: socket.handshake.headers['user-agent'],
        timestamp: new Date().toISOString()
      };

      logger.info('Socket client connected', clientInfo);
      
      // Store client information
      this.connectedClients.set(socket.id, {
        ...clientInfo,
        connectedAt: Date.now()
      });

      // Handle authentication
      socket.on('authenticate', async (data) => {
        try {
          await this.handleAuthentication(socket, data);
        } catch (error) {
          logger.error('Socket authentication failed', {
            socketId: socket.id,
            error: error.message
          });
          socket.emit('auth_error', { message: 'Authentication failed' });
        }
      });

      // Handle room joins
      socket.on('join_room', (roomName) => {
        try {
          this.handleJoinRoom(socket, roomName);
        } catch (error) {
          logger.error('Socket join room failed', {
            socketId: socket.id,
            room: roomName,
            error: error.message
          });
        }
      });

      // Handle room leaves
      socket.on('leave_room', (roomName) => {
        try {
          this.handleLeaveRoom(socket, roomName);
        } catch (error) {
          logger.error('Socket leave room failed', {
            socketId: socket.id,
            room: roomName,
            error: error.message
          });
        }
      });

      // Handle custom events
      socket.on('crypto_analysis_request', (data) => {
        try {
          this.handleCryptoAnalysisRequest(socket, data);
        } catch (error) {
          logger.error('Crypto analysis request failed', {
            socketId: socket.id,
            error: error.message
          });
        }
      });

      // Handle disconnection
      socket.on('disconnect', (reason) => {
        this.handleDisconnection(socket, reason);
      });

      // Handle errors
      socket.on('error', (error) => {
        logger.error('Socket error', {
          socketId: socket.id,
          error: error.message
        });
      });

      // Send welcome message
      socket.emit('connected', {
        message: 'Connected to BTC Baran Socket Server',
        socketId: socket.id,
        timestamp: new Date().toISOString()
      });
    });

    // Handle server errors
    this.io.engine.on('connection_error', (error) => {
      logger.error('Socket connection error', {
        error: error.message,
        context: error.context
      });
    });
  }

  private async handleAuthentication(socket: any, data: any): Promise<void> {
    try {
      // TODO: Implement JWT token validation
      // const token = data.token;
      // const decoded = jwt.verify(token, config.jwtSecret);
      
      // For now, accept all connections
      socket.authenticated = true;
      socket.userId = data.userId || 'anonymous';
      
      socket.emit('authenticated', {
        message: 'Authentication successful',
        userId: socket.userId,
        timestamp: new Date().toISOString()
      });
      
      logger.info('Socket client authenticated', {
        socketId: socket.id,
        userId: socket.userId
      });
      
    } catch (error) {
      throw new Error(`Authentication failed: ${error.message}`);
    }
  }

  private handleJoinRoom(socket: any, roomName: string): void {
    try {
      // Validate room name
      if (!this.isValidRoomName(roomName)) {
        socket.emit('error', { message: 'Invalid room name' });
        return;
      }
      
      // Join the room
      socket.join(roomName);
      
      // Notify other clients in the room
      socket.to(roomName).emit('user_joined', {
        socketId: socket.id,
        room: roomName,
        timestamp: new Date().toISOString()
      });
      
      // Confirm room join
      socket.emit('room_joined', {
        room: roomName,
        message: `Joined room: ${roomName}`,
        timestamp: new Date().toISOString()
      });
      
      logger.info('Socket client joined room', {
        socketId: socket.id,
        room: roomName,
        userId: socket.userId
      });
      
    } catch (error) {
      throw new Error(`Failed to join room: ${error.message}`);
    }
  }

  private handleLeaveRoom(socket: any, roomName: string): void {
    try {
      // Leave the room
      socket.leave(roomName);
      
      // Notify other clients in the room
      socket.to(roomName).emit('user_left', {
        socketId: socket.id,
        room: roomName,
        timestamp: new Date().toISOString()
      });
      
      // Confirm room leave
      socket.emit('room_left', {
        room: roomName,
        message: `Left room: ${roomName}`,
        timestamp: new Date().toISOString()
      });
      
      logger.info('Socket client left room', {
        socketId: socket.id,
        room: roomName,
        userId: socket.userId
      });
      
    } catch (error) {
      throw new Error(`Failed to leave room: ${error.message}`);
    }
  }

  private async handleCryptoAnalysisRequest(socket: any, data: any): Promise<void> {
    try {
      // TODO: Implement crypto analysis logic
      // - Validate request data
      // - Perform technical analysis
      // - Send results back to client
      
      const response = {
        requestId: data.requestId,
        status: 'processing',
        message: 'Analysis request received',
        timestamp: new Date().toISOString()
      };
      
      socket.emit('crypto_analysis_response', response);
      
      logger.info('Crypto analysis request handled', {
        socketId: socket.id,
        requestId: data.requestId,
        userId: socket.userId
      });
      
    } catch (error) {
      throw new Error(`Failed to handle crypto analysis request: ${error.message}`);
    }
  }

  private handleDisconnection(socket: any, reason: string): void {
    const clientInfo = this.connectedClients.get(socket.id);
    
    if (clientInfo) {
      logger.info('Socket client disconnected', {
        socketId: socket.id,
        reason,
        duration: Date.now() - clientInfo.connectedAt,
        userId: socket.userId
      });
      
      this.connectedClients.delete(socket.id);
    }
  }

  private isValidRoomName(roomName: string): boolean {
    // Room name validation rules
    const validPattern = /^[a-zA-Z0-9_-]{1,50}$/;
    return validPattern.test(roomName);
  }

  private setupRedisPubSub(): void {
    try {
      // Subscribe to Redis channels for real-time updates
      redisConnection.subscribe('crypto:signals', (message) => {
        this.broadcastToRoom('crypto_signals', 'crypto:signals', message);
      });
      
      redisConnection.subscribe('crypto:alerts', (message) => {
        this.broadcastToRoom('crypto_alerts', 'crypto:alerts', message);
      });
      
      redisConnection.subscribe('system:notifications', (message) => {
        this.broadcastToAll('system_notification', message);
      });
      
      logger.info('Redis pub/sub setup completed');
    } catch (error) {
      logger.error('Failed to setup Redis pub/sub', { error: error.message });
    }
  }

  // Public methods for broadcasting
  public broadcastToAll(event: string, data: any): void {
    if (this.io) {
      this.io.emit(event, {
        ...data,
        timestamp: new Date().toISOString()
      });
      
      logger.info('Broadcasted to all clients', {
        event,
        dataKeys: Object.keys(data),
        timestamp: new Date().toISOString()
      });
    }
  }

  public broadcastToRoom(event: string, room: string, data: any): void {
    if (this.io) {
      this.io.to(room).emit(event, {
        ...data,
        timestamp: new Date().toISOString()
      });
      
      logger.info('Broadcasted to room', {
        event,
        room,
        dataKeys: Object.keys(data),
        timestamp: new Date().toISOString()
      });
    }
  }

  public sendToClient(socketId: string, event: string, data: any): void {
    if (this.io) {
      this.io.to(socketId).emit(event, {
        ...data,
        timestamp: new Date().toISOString()
      });
      
      logger.info('Sent to specific client', {
        event,
        socketId,
        dataKeys: Object.keys(data),
        timestamp: new Date().toISOString()
      });
    }
  }

  public getConnectedClients(): object {
    const clients: Record<string, any> = {};
    
    this.connectedClients.forEach((client, socketId) => {
      clients[socketId] = {
        ip: client.ip,
        userAgent: client.userAgent,
        connectedAt: client.connectedAt,
        userId: client.userId
      };
    });
    
    return {
      total: this.connectedClients.size,
      clients
    };
  }

  public close(): void {
    if (this.io) {
      this.io.close();
      this.io = null;
      this.isInitialized = false;
      this.connectedClients.clear();
      logger.info('Socket server closed');
    }
  }

  public isRunning(): boolean {
    return this.isInitialized && this.io !== null;
  }
}

export const socketServer = SocketServerService.getInstance();
export default socketServer;
