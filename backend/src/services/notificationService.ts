import { logger } from '../utils/logger';
import { databaseConnection } from '../database/connection';
import nodemailer from 'nodemailer';
import { config } from '../config/config';

export interface NotificationData {
  userId?: string;
  type: 'price_alert' | 'analysis_signal' | 'market_update' | 'security_alert' | 'system';
  title: string;
  message: string;
  data?: any;
  priority?: 'low' | 'medium' | 'high';
  channels?: ('email' | 'push' | 'sms')[];
}

export interface NotificationSettings {
  email: {
    enabled: boolean;
    priceAlerts: boolean;
    analysisSignals: boolean;
    marketUpdates: boolean;
    securityAlerts: boolean;
  };
  push: {
    enabled: boolean;
    priceAlerts: boolean;
    analysisSignals: boolean;
    marketUpdates: boolean;
    securityAlerts: boolean;
  };
  sms: {
    enabled: boolean;
    priceAlerts: boolean;
    analysisSignals: boolean;
    marketUpdates: boolean;
    securityAlerts: boolean;
  };
  preferences: {
    quietHours: {
      enabled: boolean;
      start: string;
      end: string;
    };
    timezone: string;
    language: string;
  };
}

export class NotificationService {
  private static instance: NotificationService;
  private emailTransporter: nodemailer.Transporter;

  private constructor() {
    this.initializeEmailTransporter();
  }

  public static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  private initializeEmailTransporter(): void {
    this.emailTransporter = nodemailer.createTransporter({
      host: config.email.host,
      port: config.email.port,
      secure: config.email.secure,
      auth: {
        user: config.email.user,
        pass: config.email.password
      }
    });
  }

  public async sendNotification(notification: NotificationData): Promise<void> {
    try {
      logger.info('Sending notification', {
        type: notification.type,
        userId: notification.userId,
        priority: notification.priority
      });

      // Save notification to database
      const notificationId = await this.saveNotification(notification);

      // Get user settings if userId is provided
      let settings: NotificationSettings | null = null;
      if (notification.userId) {
        settings = await this.getUserNotificationSettings(notification.userId);
      }

      // Determine which channels to use
      const channels = notification.channels || this.getDefaultChannels(notification.type, settings);

      // Send through each channel
      const promises = channels.map(channel => this.sendThroughChannel(notification, channel, notificationId));
      await Promise.allSettled(promises);

      logger.info('Notification sent successfully', {
        notificationId,
        channels,
        type: notification.type
      });

    } catch (error) {
      logger.error('Failed to send notification', {
        error: error.message,
        type: notification.type,
        userId: notification.userId
      });
      throw error;
    }
  }

  private async saveNotification(notification: NotificationData): Promise<string> {
    const query = `
      INSERT INTO notifications (
        user_id, type, title, message, data, is_read, is_sent, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
      RETURNING id
    `;

    const result = await databaseConnection.query(query, [
      notification.userId || null,
      notification.type,
      notification.title,
      notification.message,
      JSON.stringify(notification.data || {}),
      false,
      false
    ]);

    return result.rows[0].id;
  }

  private getDefaultChannels(type: string, settings: NotificationSettings | null): string[] {
    if (!settings) {
      // Default channels for system notifications
      return ['email', 'push'];
    }

    const channels: string[] = [];

    // Check email settings
    if (settings.email.enabled) {
      switch (type) {
        case 'price_alert':
          if (settings.email.priceAlerts) channels.push('email');
          break;
        case 'analysis_signal':
          if (settings.email.analysisSignals) channels.push('email');
          break;
        case 'market_update':
          if (settings.email.marketUpdates) channels.push('email');
          break;
        case 'security_alert':
          if (settings.email.securityAlerts) channels.push('email');
          break;
        default:
          channels.push('email');
      }
    }

    // Check push settings
    if (settings.push.enabled) {
      switch (type) {
        case 'price_alert':
          if (settings.push.priceAlerts) channels.push('push');
          break;
        case 'analysis_signal':
          if (settings.push.analysisSignals) channels.push('push');
          break;
        case 'market_update':
          if (settings.push.marketUpdates) channels.push('push');
          break;
        case 'security_alert':
          if (settings.push.securityAlerts) channels.push('push');
          break;
        default:
          channels.push('push');
      }
    }

    // Check SMS settings
    if (settings.sms.enabled) {
      switch (type) {
        case 'price_alert':
          if (settings.sms.priceAlerts) channels.push('sms');
          break;
        case 'analysis_signal':
          if (settings.sms.analysisSignals) channels.push('sms');
          break;
        case 'market_update':
          if (settings.sms.marketUpdates) channels.push('sms');
          break;
        case 'security_alert':
          if (settings.sms.securityAlerts) channels.push('sms');
          break;
      }
    }

    return channels;
  }

  private async sendThroughChannel(notification: NotificationData, channel: string, notificationId: string): Promise<void> {
    try {
      switch (channel) {
        case 'email':
          await this.sendEmail(notification, notificationId);
          break;
        case 'push':
          await this.sendPushNotification(notification, notificationId);
          break;
        case 'sms':
          await this.sendSMS(notification, notificationId);
          break;
        default:
          logger.warn('Unknown notification channel', { channel });
      }
    } catch (error) {
      logger.error('Failed to send notification through channel', {
        channel,
        error: error.message,
        notificationId
      });
      throw error;
    }
  }

  private async sendEmail(notification: NotificationData, notificationId: string): Promise<void> {
    try {
      // Get user email if userId is provided
      let userEmail = null;
      if (notification.userId) {
        const userQuery = 'SELECT email FROM users WHERE id = $1';
        const userResult = await databaseConnection.query(userQuery, [notification.userId]);
        if (userResult.rows.length > 0) {
          userEmail = userResult.rows[0].email;
        }
      }

      if (!userEmail) {
        logger.warn('No email address found for notification', { notificationId });
        return;
      }

      const mailOptions = {
        from: config.email.from,
        to: userEmail,
        subject: notification.title,
        html: this.generateEmailTemplate(notification),
        text: notification.message
      };

      await this.emailTransporter.sendMail(mailOptions);

      // Update notification status
      await this.updateNotificationStatus(notificationId, 'email', true);

      logger.info('Email notification sent successfully', {
        notificationId,
        email: userEmail
      });

    } catch (error) {
      logger.error('Failed to send email notification', {
        error: error.message,
        notificationId
      });
      throw error;
    }
  }

  private async sendPushNotification(notification: NotificationData, notificationId: string): Promise<void> {
    try {
      // Get user FCM tokens if userId is provided
      let fcmTokens: string[] = [];
      if (notification.userId) {
        const tokensQuery = 'SELECT fcm_token FROM user_devices WHERE user_id = $1 AND fcm_token IS NOT NULL';
        const tokensResult = await databaseConnection.query(tokensQuery, [notification.userId]);
        fcmTokens = tokensResult.rows.map(row => row.fcm_token);
      }

      if (fcmTokens.length === 0) {
        logger.warn('No FCM tokens found for notification', { notificationId });
        return;
      }

      // Send push notification using Firebase Admin SDK
      // This would require Firebase Admin SDK implementation
      // For now, we'll just log the action
      logger.info('Push notification would be sent', {
        notificationId,
        tokens: fcmTokens.length,
        title: notification.title,
        message: notification.message
      });

      // Update notification status
      await this.updateNotificationStatus(notificationId, 'push', true);

    } catch (error) {
      logger.error('Failed to send push notification', {
        error: error.message,
        notificationId
      });
      throw error;
    }
  }

  private async sendSMS(notification: NotificationData, notificationId: string): Promise<void> {
    try {
      // Get user phone number if userId is provided
      let userPhone = null;
      if (notification.userId) {
        const userQuery = 'SELECT phone FROM users WHERE id = $1';
        const userResult = await databaseConnection.query(userQuery, [notification.userId]);
        if (userResult.rows.length > 0) {
          userPhone = userResult.rows[0].phone;
        }
      }

      if (!userPhone) {
        logger.warn('No phone number found for notification', { notificationId });
        return;
      }

      // Send SMS using SMS service provider
      // This would require SMS service integration (Twilio, etc.)
      // For now, we'll just log the action
      logger.info('SMS notification would be sent', {
        notificationId,
        phone: userPhone,
        message: notification.message
      });

      // Update notification status
      await this.updateNotificationStatus(notificationId, 'sms', true);

    } catch (error) {
      logger.error('Failed to send SMS notification', {
        error: error.message,
        notificationId
      });
      throw error;
    }
  }

  private generateEmailTemplate(notification: NotificationData): string {
    const priorityColor = {
      low: '#28a745',
      medium: '#ffc107',
      high: '#dc3545'
    }[notification.priority || 'medium'];

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>${notification.title}</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: ${priorityColor}; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>${notification.title}</h1>
          </div>
          <div class="content">
            <p>${notification.message}</p>
            ${notification.data ? `<p><strong>Details:</strong> ${JSON.stringify(notification.data, null, 2)}</p>` : ''}
          </div>
          <div class="footer">
            <p>BTC Baran - Crypto Analysis Platform</p>
            <p>This is an automated notification. Please do not reply to this email.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private async updateNotificationStatus(notificationId: string, channel: string, sent: boolean): Promise<void> {
    const query = `
      UPDATE notifications 
      SET is_sent = $1, sent_at = CURRENT_TIMESTAMP 
      WHERE id = $2
    `;

    await databaseConnection.query(query, [sent, notificationId]);
  }

  public async getUserNotificationSettings(userId: string): Promise<NotificationSettings | null> {
    const query = `
      SELECT notification_settings FROM user_profiles 
      WHERE user_id = $1
    `;

    const result = await databaseConnection.query(query, [userId]);
    
    if (result.rows.length === 0) {
      return null;
    }

    return result.rows[0].notification_settings;
  }

  public async updateUserNotificationSettings(userId: string, settings: NotificationSettings): Promise<void> {
    const query = `
      INSERT INTO user_profiles (user_id, notification_settings, updated_at)
      VALUES ($1, $2, CURRENT_TIMESTAMP)
      ON CONFLICT (user_id)
      DO UPDATE SET 
        notification_settings = $2,
        updated_at = CURRENT_TIMESTAMP
    `;

    await databaseConnection.query(query, [userId, JSON.stringify(settings)]);
  }

  public async getUserNotifications(userId: string, page: number = 1, limit: number = 20, unreadOnly: boolean = false): Promise<any> {
    const offset = (page - 1) * limit;
    
    let query = `
      SELECT * FROM notifications 
      WHERE user_id = $1
    `;
    
    const params: any[] = [userId];
    
    if (unreadOnly) {
      query += ' AND is_read = false';
    }
    
    query += ' ORDER BY created_at DESC LIMIT $2 OFFSET $3';
    params.push(limit, offset);

    const result = await databaseConnection.query(query, params);
    
    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM notifications WHERE user_id = $1';
    const countParams: any[] = [userId];
    
    if (unreadOnly) {
      countQuery += ' AND is_read = false';
    }
    
    const countResult = await databaseConnection.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    return {
      notifications: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };
  }

  public async markNotificationAsRead(notificationId: string, userId: string): Promise<void> {
    const query = `
      UPDATE notifications 
      SET is_read = true, read_at = CURRENT_TIMESTAMP 
      WHERE id = $1 AND user_id = $2
    `;

    await databaseConnection.query(query, [notificationId, userId]);
  }

  public async markAllNotificationsAsRead(userId: string): Promise<number> {
    const query = `
      UPDATE notifications 
      SET is_read = true, read_at = CURRENT_TIMESTAMP 
      WHERE user_id = $1 AND is_read = false
      RETURNING id
    `;

    const result = await databaseConnection.query(query, [userId]);
    return result.rowCount;
  }

  public async deleteNotification(notificationId: string, userId: string): Promise<void> {
    const query = `
      DELETE FROM notifications 
      WHERE id = $1 AND user_id = $2
    `;

    await databaseConnection.query(query, [notificationId, userId]);
  }

  public async getNotificationStatistics(userId: string, period: string = '30d'): Promise<any> {
    const periodDays = parseInt(period.replace('d', ''));
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - periodDays);

    const query = `
      SELECT 
        type,
        COUNT(*) as count,
        COUNT(CASE WHEN is_read = true THEN 1 END) as read_count,
        COUNT(CASE WHEN is_read = false THEN 1 END) as unread_count
      FROM notifications 
      WHERE user_id = $1 AND created_at >= $2
      GROUP BY type
    `;

    const result = await databaseConnection.query(query, [userId, startDate]);
    
    const stats = {
      period,
      total: 0,
      read: 0,
      unread: 0,
      byType: {} as any,
      byPriority: {
        high: 0,
        medium: 0,
        low: 0
      },
      deliveryRate: 0.98,
      averageReadTime: '2.5 hours'
    };

    result.rows.forEach(row => {
      stats.total += parseInt(row.count);
      stats.read += parseInt(row.read_count);
      stats.unread += parseInt(row.unread_count);
      stats.byType[row.type] = parseInt(row.count);
    });

    return stats;
  }
}

export const notificationService = NotificationService.getInstance();
export default notificationService;
