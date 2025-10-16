// Kullanıcı Temel Tipleri
export interface User {
  id: string;
  firstName: string;
  lastName: string;
  tcIdentity: string;
  phone: string;
  email: string;
  isActive: boolean;
  emailVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Kullanıcı Kayıt Verisi
export interface UserRegistration {
  firstName: string;
  lastName: string;
  tcIdentity: string;
  phone: string;
  email: string;
  password: string;
  confirmPassword: string;
}

// Kullanıcı Giriş Verisi
export interface UserLogin {
  email: string;
  password: string;
  rememberMe?: boolean;
}

// Kullanıcı Profil Güncelleme
export interface UserProfileUpdate {
  firstName?: string;
  lastName?: string;
  phone?: string;
  email?: string;
}

// Şifre Değiştirme
export interface PasswordChange {
  currentPassword: string;
  newPassword: string;
  confirmNewPassword: string;
}

// Şifre Sıfırlama
export interface PasswordReset {
  email: string;
}

// Şifre Sıfırlama Onayı
export interface PasswordResetConfirm {
  token: string;
  newPassword: string;
  confirmNewPassword: string;
}

// E-posta Aktivasyonu
export interface EmailVerification {
  token: string;
}

// JWT Token Yapısı
export interface JWTToken {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
}

// Token Payload
export interface TokenPayload {
  userId: string;
  email: string;
  tcIdentity: string;
  iat: number;
  exp: number;
}

// Kullanıcı Oturum Bilgisi
export interface UserSession {
  userId: string;
  email: string;
  tcIdentity: string;
  isActive: boolean;
  lastLoginAt: Date;
  ipAddress: string;
  userAgent: string;
}

// Kullanıcı Aktivite Logu
export interface UserActivityLog {
  id: string;
  userId: string;
  action: UserAction;
  details: Record<string, any>;
  ipAddress: string;
  userAgent: string;
  createdAt: Date;
}

// Kullanıcı Aksiyonları
export type UserAction = 
  | 'USER_LOGIN'
  | 'USER_LOGOUT'
  | 'USER_REGISTER'
  | 'EMAIL_VERIFIED'
  | 'PASSWORD_CHANGED'
  | 'PASSWORD_RESET'
  | 'PROFILE_UPDATED'
  | 'VIEW_CRYPTO_PAIR'
  | 'VIEW_ANALYSIS'
  | 'SET_NOTIFICATION_PREFERENCE'
  | 'VIEW_CHART'
  | 'SEARCH_CRYPTO'
  | 'EXPORT_DATA'
  | 'API_REQUEST'
  | 'ERROR_OCCURRED';

// Kullanıcı Tercihleri
export interface UserPreferences {
  id: string;
  userId: string;
  language: string;
  timezone: string;
  currency: string;
  theme: 'light' | 'dark' | 'system';
  notifications: NotificationPreferences;
  chartPreferences: ChartPreferences;
  createdAt: Date;
  updatedAt: Date;
}

// Bildirim Tercihleri
export interface NotificationPreferences {
  pushNotifications: boolean;
  emailNotifications: boolean;
  smsNotifications: boolean;
  alertTypes: {
    pivotTraditional: boolean;
    s1R1Touch: boolean;
    maTouch: boolean;
  };
  quietHours: {
    enabled: boolean;
    startTime: string; // HH:mm format
    endTime: string;   // HH:mm format
  };
  frequency: 'immediate' | 'hourly' | 'daily';
}

// Grafik Tercihleri
export interface ChartPreferences {
  defaultTimeframe: '1D' | '3D' | '1W' | '1M' | '3M' | '1Y';
  defaultChartType: 'candlestick' | 'line' | 'area';
  showVolume: boolean;
  showIndicators: boolean;
  defaultIndicators: string[];
  colorScheme: 'default' | 'custom';
}

// Kullanıcı İstatistikleri
export interface UserStatistics {
  userId: string;
  totalLogins: number;
  lastLoginAt: Date;
  totalSessions: number;
  averageSessionDuration: number; // dakika
  mostViewedPairs: string[];
  favoriteTimeframes: string[];
  totalNotifications: number;
  readNotifications: number;
  createdAt: Date;
  updatedAt: Date;
}

// Kullanıcı Güvenlik Bilgileri
export interface UserSecurity {
  userId: string;
  failedLoginAttempts: number;
  lastFailedLoginAt: Date | null;
  accountLocked: boolean;
  accountLockedAt: Date | null;
  twoFactorEnabled: boolean;
  twoFactorSecret: string | null;
  backupCodes: string[];
  lastPasswordChangeAt: Date;
  passwordHistory: string[]; // son 5 şifre hash'i
  createdAt: Date;
  updatedAt: Date;
}

// Kullanıcı API Kullanımı
export interface UserAPIUsage {
  userId: string;
  date: Date;
  totalRequests: number;
  successfulRequests: number;
  failedRequests: number;
  rateLimitHits: number;
  bandwidthUsed: number; // bytes
  createdAt: Date;
}

// Kullanıcı Cihaz Bilgileri
export interface UserDevice {
  id: string;
  userId: string;
  deviceId: string;
  deviceName: string;
  deviceType: 'mobile' | 'tablet' | 'desktop' | 'web';
  os: string;
  osVersion: string;
  appVersion: string;
  pushToken: string | null;
  isActive: boolean;
  lastSeenAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

// Kullanıcı Abonelik Bilgileri
export interface UserSubscription {
  id: string;
  userId: string;
  planType: 'free' | 'basic' | 'premium' | 'enterprise';
  status: 'active' | 'inactive' | 'cancelled' | 'expired';
  startDate: Date;
  endDate: Date;
  autoRenew: boolean;
  features: string[];
  limits: {
    maxPairs: number;
    maxAlerts: number;
    maxHistoricalData: number;
    apiRateLimit: number;
  };
  createdAt: Date;
  updatedAt: Date;
}

// Kullanıcı Destek Talebi
export interface UserSupportTicket {
  id: string;
  userId: string;
  subject: string;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  status: 'open' | 'in_progress' | 'resolved' | 'closed';
  category: 'technical' | 'billing' | 'feature_request' | 'bug_report' | 'general';
  assignedTo: string | null;
  createdAt: Date;
  updatedAt: Date;
  resolvedAt: Date | null;
}
