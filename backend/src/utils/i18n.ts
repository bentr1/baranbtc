import { config } from '../config/config';

// Multi-language support for BTC Baran
export class I18nService {
  private static instance: I18nService;
  private translations: Map<string, any> = new Map();
  private currentLanguage: string = config.defaultLanguage;

  private constructor() {
    this.loadTranslations();
  }

  public static getInstance(): I18nService {
    if (!I18nService.instance) {
      I18nService.instance = new I18nService();
    }
    return I18nService.instance;
  }

  private loadTranslations(): void {
    // Turkish translations
    this.translations.set('tr', {
      // Auth messages
      auth: {
        loginSuccess: 'Giriş başarılı',
        loginFailed: 'Giriş başarısız',
        registerSuccess: 'Kayıt başarılı',
        registerFailed: 'Kayıt başarısız',
        invalidCredentials: 'Geçersiz kimlik bilgileri',
        userNotFound: 'Kullanıcı bulunamadı',
        emailAlreadyExists: 'E-posta adresi zaten mevcut',
        tcIdAlreadyExists: 'TC Kimlik numarası zaten mevcut',
        passwordTooWeak: 'Şifre çok zayıf',
        emailActivationRequired: 'E-posta aktivasyonu gerekli',
        accountLocked: 'Hesap kilitlendi',
        mfaRequired: 'İki faktörlü kimlik doğrulama gerekli'
      },
      
      // Crypto analysis
      crypto: {
        analysisComplete: 'Analiz tamamlandı',
        analysisFailed: 'Analiz başarısız',
        pivotLevels: 'Pivot Seviyeleri',
        supportResistance: 'Destek/Direnç',
        movingAverages: 'Hareketli Ortalamalar',
        bullishSignal: 'Yükseliş sinyali',
        bearishSignal: 'Düşüş sinyali',
        neutralSignal: 'Nötr sinyal'
      },
      
      // Notifications
      notifications: {
        newSignal: 'Yeni sinyal',
        priceAlert: 'Fiyat uyarısı',
        analysisUpdate: 'Analiz güncellendi',
        systemMaintenance: 'Sistem bakımı',
        securityAlert: 'Güvenlik uyarısı'
      },
      
      // Errors
      errors: {
        internalError: 'İç sunucu hatası',
        validationError: 'Doğrulama hatası',
        unauthorized: 'Yetkisiz erişim',
        forbidden: 'Erişim yasak',
        notFound: 'Bulunamadı',
        rateLimitExceeded: 'İstek limiti aşıldı',
        serviceUnavailable: 'Servis kullanılamıyor'
      },
      
      // Success messages
      success: {
        operationCompleted: 'İşlem tamamlandı',
        dataSaved: 'Veri kaydedildi',
        dataUpdated: 'Veri güncellendi',
        dataDeleted: 'Veri silindi'
      }
    });

    // English translations
    this.translations.set('en', {
      auth: {
        loginSuccess: 'Login successful',
        loginFailed: 'Login failed',
        registerSuccess: 'Registration successful',
        registerFailed: 'Registration failed',
        invalidCredentials: 'Invalid credentials',
        userNotFound: 'User not found',
        emailAlreadyExists: 'Email already exists',
        tcIdAlreadyExists: 'TC ID already exists',
        passwordTooWeak: 'Password too weak',
        emailActivationRequired: 'Email activation required',
        accountLocked: 'Account locked',
        mfaRequired: 'Two-factor authentication required'
      },
      
      crypto: {
        analysisComplete: 'Analysis complete',
        analysisFailed: 'Analysis failed',
        pivotLevels: 'Pivot Levels',
        supportResistance: 'Support/Resistance',
        movingAverages: 'Moving Averages',
        bullishSignal: 'Bullish signal',
        bearishSignal: 'Bearish signal',
        neutralSignal: 'Neutral signal'
      },
      
      notifications: {
        newSignal: 'New signal',
        priceAlert: 'Price alert',
        analysisUpdate: 'Analysis updated',
        systemMaintenance: 'System maintenance',
        securityAlert: 'Security alert'
      },
      
      errors: {
        internalError: 'Internal server error',
        validationError: 'Validation error',
        unauthorized: 'Unauthorized access',
        forbidden: 'Access forbidden',
        notFound: 'Not found',
        rateLimitExceeded: 'Rate limit exceeded',
        serviceUnavailable: 'Service unavailable'
      },
      
      success: {
        operationCompleted: 'Operation completed',
        dataSaved: 'Data saved',
        dataUpdated: 'Data updated',
        dataDeleted: 'Data deleted'
      }
    });

    // French translations
    this.translations.set('fr', {
      auth: {
        loginSuccess: 'Connexion réussie',
        loginFailed: 'Échec de la connexion',
        registerSuccess: 'Inscription réussie',
        registerFailed: 'Échec de l\'inscription',
        invalidCredentials: 'Identifiants invalides',
        userNotFound: 'Utilisateur non trouvé',
        emailAlreadyExists: 'L\'email existe déjà',
        tcIdAlreadyExists: 'L\'ID TC existe déjà',
        passwordTooWeak: 'Mot de passe trop faible',
        emailActivationRequired: 'Activation par email requise',
        accountLocked: 'Compte verrouillé',
        mfaRequired: 'Authentification à deux facteurs requise'
      },
      
      crypto: {
        analysisComplete: 'Analyse terminée',
        analysisFailed: 'Échec de l\'analyse',
        pivotLevels: 'Niveaux de pivot',
        supportResistance: 'Support/Résistance',
        movingAverages: 'Moyennes mobiles',
        bullishSignal: 'Signal haussier',
        bearishSignal: 'Signal baissier',
        neutralSignal: 'Signal neutre'
      },
      
      notifications: {
        newSignal: 'Nouveau signal',
        priceAlert: 'Alerte de prix',
        analysisUpdate: 'Analyse mise à jour',
        systemMaintenance: 'Maintenance système',
        securityAlert: 'Alerte de sécurité'
      },
      
      errors: {
        internalError: 'Erreur interne du serveur',
        validationError: 'Erreur de validation',
        unauthorized: 'Accès non autorisé',
        forbidden: 'Accès interdit',
        notFound: 'Non trouvé',
        rateLimitExceeded: 'Limite de taux dépassée',
        serviceUnavailable: 'Service indisponible'
      },
      
      success: {
        operationCompleted: 'Opération terminée',
        dataSaved: 'Données sauvegardées',
        dataUpdated: 'Données mises à jour',
        dataDeleted: 'Données supprimées'
      }
    });

    // German translations
    this.translations.set('de', {
      auth: {
        loginSuccess: 'Anmeldung erfolgreich',
        loginFailed: 'Anmeldung fehlgeschlagen',
        registerSuccess: 'Registrierung erfolgreich',
        registerFailed: 'Registrierung fehlgeschlagen',
        invalidCredentials: 'Ungültige Anmeldedaten',
        userNotFound: 'Benutzer nicht gefunden',
        emailAlreadyExists: 'E-Mail existiert bereits',
        tcIdAlreadyExists: 'TC-ID existiert bereits',
        passwordTooWeak: 'Passwort zu schwach',
        emailActivationRequired: 'E-Mail-Aktivierung erforderlich',
        accountLocked: 'Konto gesperrt',
        mfaRequired: 'Zwei-Faktor-Authentifizierung erforderlich'
      },
      
      crypto: {
        analysisComplete: 'Analyse abgeschlossen',
        analysisFailed: 'Analyse fehlgeschlagen',
        pivotLevels: 'Pivot-Levels',
        supportResistance: 'Unterstützung/Widerstand',
        movingAverages: 'Gleitende Durchschnitte',
        bullishSignal: 'Hausse-Signal',
        bearishSignal: 'Baisse-Signal',
        neutralSignal: 'Neutrales Signal'
      },
      
      notifications: {
        newSignal: 'Neues Signal',
        priceAlert: 'Preiswarnung',
        analysisUpdate: 'Analyse aktualisiert',
        systemMaintenance: 'Systemwartung',
        securityAlert: 'Sicherheitswarnung'
      },
      
      errors: {
        internalError: 'Interner Serverfehler',
        validationError: 'Validierungsfehler',
        unauthorized: 'Nicht autorisierter Zugriff',
        forbidden: 'Zugriff verboten',
        notFound: 'Nicht gefunden',
        rateLimitExceeded: 'Rate-Limit überschritten',
        serviceUnavailable: 'Dienst nicht verfügbar'
      },
      
      success: {
        operationCompleted: 'Vorgang abgeschlossen',
        dataSaved: 'Daten gespeichert',
        dataUpdated: 'Daten aktualisiert',
        dataDeleted: 'Daten gelöscht'
      }
    });
  }

  public setLanguage(language: string): void {
    if (config.languages.includes(language)) {
      this.currentLanguage = language;
    } else {
      this.currentLanguage = config.defaultLanguage;
    }
  }

  public getLanguage(): string {
    return this.currentLanguage;
  }

  public getSupportedLanguages(): string[] {
    return config.languages;
  }

  public translate(key: string, params: Record<string, any> = {}): string {
    const keys = key.split('.');
    let translation = this.translations.get(this.currentLanguage);
    
    // Navigate to nested key
    for (const k of keys) {
      if (translation && translation[k]) {
        translation = translation[k];
      } else {
        // Fallback to default language
        translation = this.translations.get(config.defaultLanguage);
        for (const fallbackKey of keys) {
          if (translation && translation[fallbackKey]) {
            translation = translation[fallbackKey];
          } else {
            return key; // Return key if translation not found
          }
        }
        break;
      }
    }
    
    if (typeof translation === 'string') {
      // Replace parameters
      return translation.replace(/\{(\w+)\}/g, (match, param) => {
        return params[param] !== undefined ? params[param] : match;
      });
    }
    
    return key;
  }

  public getTranslations(language: string): any {
    return this.translations.get(language) || this.translations.get(config.defaultLanguage);
  }
}

export const i18n = I18nService.getInstance();
export default i18n;
