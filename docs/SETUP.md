# Proje Kurulum Rehberi

## Ön Gereksinimler

### Sistem Gereksinimleri
- **Node.js:** 18.0.0 veya üzeri
- **npm:** 8.0.0 veya üzeri
- **Flutter:** 3.10.0 veya üzeri
- **Docker:** 20.10.0 veya üzeri
- **Docker Compose:** 2.0.0 veya üzeri
- **Git:** 2.30.0 veya üzeri

### Gerekli Servisler
- **PostgreSQL:** 14.0 veya üzeri (TimescaleDB extension ile)
- **Redis:** 6.0 veya üzeri
- **Binance API:** Geçerli API anahtarları

## Kurulum Adımları

### 1. Proje Klonlama
```bash
git clone https://github.com/username/btcbaran.git
cd btcbaran
```

### 2. Environment Dosyası Oluşturma
```bash
# Backend için
cp backend/.env.example backend/.env

# Mobile app için
cp mobile-app/.env.example mobile-app/.env
```

### 3. Environment Değişkenlerini Düzenleme

#### Backend (.env)
```env
# Application
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database
DATABASE_URL=postgresql://btcbaran_user:btcbaran_password@localhost:5432/btcbaran

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-jwt-key-here
JWT_REFRESH_SECRET=your-super-secret-refresh-key-here

# Binance API
BINANCE_API_KEY=your-binance-api-key-here
BINANCE_API_SECRET=your-binance-api-secret-here

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password-here
```

#### Mobile App (.env)
```env
# API Configuration
API_BASE_URL=http://localhost:3000/api
WS_URL=ws://localhost:3000

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_APP_ID=your-firebase-app-id
```

### 4. Docker ile Kurulum (Önerilen)

#### Docker Compose ile Başlatma
```bash
# Tüm servisleri başlat
docker-compose up -d

# Logları izle
docker-compose logs -f

# Belirli bir servisi başlat
docker-compose up -d postgres redis
```

#### Manuel Docker Kurulumu
```bash
# PostgreSQL + TimescaleDB
docker run -d \
  --name btcbaran_postgres \
  -e POSTGRES_DB=btcbaran \
  -e POSTGRES_USER=btcbaran_user \
  -e POSTGRES_PASSWORD=btcbaran_password \
  -p 5432:5432 \
  timescale/timescaledb:latest-pg14

# Redis
docker run -d \
  --name btcbaran_redis \
  -p 6379:6379 \
  redis:7-alpine
```

### 5. Backend Kurulumu

#### Bağımlılıkları Yükleme
```bash
cd backend
npm install
```

#### Veritabanı Kurulumu
```bash
# Migration'ları çalıştır
npm run migrate

# Seed data'yı yükle
npm run seed
```

#### Development Server'ı Başlatma
```bash
npm run dev
```

### 6. Mobile App Kurulumu

#### Flutter Bağımlılıklarını Yükleme
```bash
cd mobile-app
flutter pub get
```

#### Platform Dependencies
```bash
# iOS için
cd ios && pod install && cd ..

# Android için
flutter doctor --android-licenses
```

#### Development'da Çalıştırma
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Web
flutter run -d chrome
```

## Veritabanı Kurulumu

### PostgreSQL + TimescaleDB
```sql
-- TimescaleDB extension'ı etkinleştir
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Veritabanı şemalarını oluştur
\i docker/postgres/init.sql

-- Hypertable oluştur
SELECT create_hypertable('daily_candles', 'time');
```

### Redis Konfigürasyonu
```bash
# Redis CLI'a bağlan
redis-cli

# Test komutu
127.0.0.1:6379> ping
PONG
```

## API Test Etme

### Health Check
```bash
curl http://localhost:3000/api/health
```

### Swagger Dokümantasyonu
```
http://localhost:3000/api/docs
```

## Development Araçları

### Database Management
- **Adminer:** http://localhost:8081
- **Redis Commander:** http://localhost:8082

### Monitoring
- **Backend Logs:** `docker-compose logs -f backend`
- **Database Logs:** `docker-compose logs -f postgres`
- **Redis Logs:** `docker-compose logs -f redis`

## Troubleshooting

### Yaygın Sorunlar

#### Port Çakışması
```bash
# Kullanılan portları kontrol et
netstat -tulpn | grep :3000
netstat -tulpn | grep :5432
netstat -tulpn | grep :6379

# Servisleri durdur
docker-compose down
```

#### Veritabanı Bağlantı Hatası
```bash
# PostgreSQL servisini kontrol et
docker-compose ps postgres

# Veritabanına bağlan
docker exec -it btcbaran_postgres psql -U btcbaran_user -d btcbaran
```

#### Redis Bağlantı Hatası
```bash
# Redis servisini kontrol et
docker-compose ps redis

# Redis'e bağlan
docker exec -it btcbaran_redis redis-cli
```

#### Flutter Build Hatası
```bash
# Flutter cache'i temizle
flutter clean

# Dependencies'i yeniden yükle
flutter pub get

# Flutter doctor ile kontrol et
flutter doctor
```

### Log Dosyaları
```bash
# Backend logları
tail -f backend/logs/app.log

# Docker logları
docker-compose logs -f [service-name]
```

## Production Deployment

### Environment Variables
```bash
# Production environment
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@host:5432/db
REDIS_URL=redis://host:6379
```

### SSL Sertifikaları
```bash
# Let's Encrypt ile SSL
certbot certonly --standalone -d yourdomain.com

# Nginx konfigürasyonu
cp nginx.conf /etc/nginx/sites-available/btcbaran
ln -s /etc/nginx/sites-available/btcbaran /etc/nginx/sites-enabled/
```

### PM2 ile Process Management
```bash
# PM2 kurulumu
npm install -g pm2

# Uygulamayı başlat
pm2 start ecosystem.config.js

# Monitoring
pm2 monit
```

## Performance Optimization

### Database Indexes
```sql
-- Performance için gerekli indeksler
CREATE INDEX idx_daily_candles_pair_time ON daily_candles(pair_id, time DESC);
CREATE INDEX idx_analysis_results_pair_type ON analysis_results(pair_id, analysis_type);
CREATE INDEX idx_user_logs_user_action ON user_logs(user_id, action);
```

### Redis Caching
```bash
# Cache hit rate'i kontrol et
redis-cli info stats | grep keyspace_hits
redis-cli info stats | grep keyspace_misses
```

### Monitoring Setup
```bash
# Prometheus + Grafana kurulumu
docker-compose -f docker-compose.monitoring.yml up -d
```

## Security Checklist

- [ ] Environment variables güvenli
- [ ] JWT secrets güçlü
- [ ] Database passwords güçlü
- [ ] API rate limiting aktif
- [ ] CORS konfigürasyonu doğru
- [ ] Input validation aktif
- [ ] SQL injection koruması
- [ ] XSS koruması
- [ ] HTTPS aktif (production)
- [ ] Firewall kuralları
- [ ] Regular security updates
- [ ] Backup strategy

## Support

### Dokümantasyon
- [API Dokümantasyonu](./API.md)
- [Teknik Analiz Algoritmaları](./TECHNICAL_ANALYSIS.md)
- [Proje Yapısı](./PROJECT_STRUCTURE.md)

### İletişim
- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions
- **Wiki:** GitHub Wiki

### Development Guidelines
- [Coding Standards](./CODING_STANDARDS.md)
- [Testing Guidelines](./TESTING.md)
- [Deployment Guide](./DEPLOYMENT.md)
