# Proje Yapısı ve Mimari

## Genel Mimari

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Mobile App   │    │     Backend     │    │   Database      │
│   (Flutter)    │◄──►│   (Node.js)     │◄──►│  (PostgreSQL)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Push Notif.    │    │   Binance API   │    │   Redis Cache   │
│  (Firebase)     │    │   Integration   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Dizin Yapısı

### 1. Mobile App (Flutter)
```
mobile-app/
├── lib/
│   ├── main.dart                 # Ana uygulama girişi
│   ├── app/                      # Uygulama konfigürasyonu
│   ├── core/                     # Temel utilities
│   │   ├── constants/            # Sabitler
│   │   ├── errors/               # Hata yönetimi
│   │   ├── network/              # Network işlemleri
│   │   └── utils/                # Yardımcı fonksiyonlar
│   ├── features/                 # Özellik bazlı modüller
│   │   ├── auth/                 # Kimlik doğrulama
│   │   ├── dashboard/            # Ana dashboard
│   │   ├── charts/               # Grafik ekranları
│   │   ├── notifications/        # Bildirim yönetimi
│   │   └── settings/             # Ayarlar
│   ├── shared/                   # Paylaşılan bileşenler
│   │   ├── widgets/              # Ortak widget'lar
│   │   ├── models/               # Veri modelleri
│   │   └── services/             # Ortak servisler
│   └── l10n/                     # Çoklu dil desteği
├── assets/                       # Resimler, fontlar
├── test/                         # Test dosyaları
└── pubspec.yaml                  # Flutter dependencies
```

### 2. Backend (Node.js)
```
backend/
├── src/
│   ├── main.ts                   # Ana giriş noktası
│   ├── app.ts                    # Express app konfigürasyonu
│   ├── config/                   # Konfigürasyon dosyaları
│   │   ├── database.ts           # Veritabanı ayarları
│   │   ├── redis.ts              # Redis ayarları
│   │   └── environment.ts        # Ortam değişkenleri
│   ├── modules/                  # Modüler yapı
│   │   ├── auth/                 # Kimlik doğrulama modülü
│   │   ├── users/                # Kullanıcı yönetimi
│   │   ├── crypto/               # Kripto analiz
│   │   ├── notifications/        # Bildirim sistemi
│   │   └── analytics/            # Kullanım analitikleri
│   ├── shared/                   # Paylaşılan bileşenler
│   │   ├── middleware/           # Express middleware'leri
│   │   ├── services/             # Ortak servisler
│   │   ├── types/                # TypeScript tipleri
│   │   └── utils/                # Yardımcı fonksiyonlar
│   └── jobs/                     # Background jobs
│       ├── data-collector.ts     # Veri toplama
│       ├── analysis-engine.ts    # Analiz motoru
│       └── notification-sender.ts # Bildirim gönderimi
├── tests/                        # Test dosyaları
├── package.json                  # Node.js dependencies
└── tsconfig.json                 # TypeScript konfigürasyonu
```

### 3. Shared (Ortak)
```
shared/
├── types/                        # Ortak TypeScript tipleri
│   ├── user.ts                   # Kullanıcı tipleri
│   ├── crypto.ts                 # Kripto veri tipleri
│   ├── analysis.ts               # Analiz sonuç tipleri
│   └── notifications.ts          # Bildirim tipleri
├── constants/                     # Ortak sabitler
└── utils/                        # Ortak yardımcı fonksiyonlar
```

## Veritabanı Şeması

### Users Tablosu
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    tc_identity VARCHAR(11) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Crypto Pairs Tablosu
```sql
CREATE TABLE crypto_pairs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(20) UNIQUE NOT NULL,
    base_asset VARCHAR(10) NOT NULL,
    quote_asset VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Daily Candles Tablosu (TimescaleDB)
```sql
CREATE TABLE daily_candles (
    time TIMESTAMP NOT NULL,
    pair_id UUID NOT NULL,
    open DECIMAL(20,8) NOT NULL,
    high DECIMAL(20,8) NOT NULL,
    low DECIMAL(20,8) NOT NULL,
    close DECIMAL(20,8) NOT NULL,
    volume DECIMAL(20,8) NOT NULL,
    PRIMARY KEY (time, pair_id)
);

-- TimescaleDB hypertable oluştur
SELECT create_hypertable('daily_candles', 'time');
```

### Analysis Results Tablosu
```sql
CREATE TABLE analysis_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pair_id UUID NOT NULL,
    analysis_type VARCHAR(50) NOT NULL,
    result_data JSONB NOT NULL,
    triggered_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### User Logs Tablosu
```sql
CREATE TABLE user_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    action VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## API Endpoint Yapısı

### Authentication
- `POST /api/auth/register` - Kullanıcı kaydı
- `POST /api/auth/login` - Kullanıcı girişi
- `POST /api/auth/verify-email` - E-posta doğrulama
- `POST /api/auth/refresh-token` - Token yenileme

### Users
- `GET /api/users/profile` - Kullanıcı profili
- `PUT /api/users/profile` - Profil güncelleme
- `GET /api/users/logs` - Kullanım logları

### Crypto Analysis
- `GET /api/crypto/pairs` - Mevcut pariteler
- `GET /api/crypto/analysis/:pair` - Analiz sonuçları
- `GET /api/crypto/chart-data/:pair` - Grafik verileri
- `GET /api/crypto/alerts` - Aktif uyarılar

### Notifications
- `GET /api/notifications` - Kullanıcı bildirimleri
- `PUT /api/notifications/:id/read` - Bildirim okundu
- `POST /api/notifications/settings` - Bildirim ayarları

## Real-time İletişim

### Socket.io Events
- `crypto:price-update` - Fiyat güncellemeleri
- `crypto:analysis-trigger` - Analiz tetiklenmeleri
- `notification:new` - Yeni bildirimler
- `user:activity` - Kullanıcı aktiviteleri

## Background Jobs

### 1. Data Collector (Her 1 dakikada)
- Binance API'den günlük mum verilerini çek
- Veritabanına kaydet
- Cache'i güncelle

### 2. Analysis Engine (Her 5 dakikada)
- Pivot Traditional analizi
- S1/R1 temas kontrolü
- MA temas analizi
- Sonuçları veritabanına kaydet

### 3. Notification Sender (Her 1 dakikada)
- Tetiklenen analizleri kontrol et
- Kullanıcılara bildirim gönder
- Push notification'ları tetikle

## Güvenlik Önlemleri

### Authentication
- JWT token tabanlı kimlik doğrulama
- Refresh token rotation
- Rate limiting (IP bazlı)
- CORS konfigürasyonu

### Data Protection
- Şifre hash'leme (bcrypt)
- API key encryption
- HTTPS zorunluluğu
- Input validation ve sanitization

### Monitoring
- Request logging
- Error tracking
- Performance monitoring
- Security audit logging
