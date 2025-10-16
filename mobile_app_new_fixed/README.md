
# mobile_app_new_fixed

This repository contains the BTC Baran Flutter mobile application.

## Getting Started

This project is a Flutter application scaffold and contains documentation and setup steps for local development and deployment.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# BTC Baran - Comprehensive Crypto Analysis and Notification Application

[![Security](https://img.shields.io/badge/Security-OWASP%20Top%2010%20Protected-brightgreen.svg)](https://owasp.org/www-project-top-ten/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)

## 🚀 Project Overview

BTC Baran is a comprehensive, security-focused cryptocurrency analysis and notification application that provides real-time technical analysis, automated trading signals, and instant notifications for cryptocurrency markets. The application fetches daily candlestick data from Binance.com and performs advanced technical analysis including Pivot Traditional R5 + 50%, S1/R1 Touch analysis for 270 days, and Moving Average analysis for 25 MA/50 candles and 100 MA/200 candles across multiple timeframes.

## ✨ Key Features

### 🔐 Security & Integrity
- **OWASP Top 10 Protection**: Comprehensive security measures against all major web vulnerabilities
- **Anti-Tampering**: Advanced protection against code modification and reverse engineering
- **Multi-Factor Authentication (MFA)**: TOTP and SMS-based authentication
- **Biometric Authentication**: Fingerprint and Face ID support
- **End-to-End Encryption**: AES-256 encryption for all sensitive data
- **Audit Logging**: Complete security event tracking and monitoring

### 📊 Technical Analysis
- **Pivot Analysis**: Traditional R5 + 50% calculations
- **Support/Resistance**: S1/R1 Touch analysis for 270 days
- **Moving Averages**: 25 MA for 50 candles, 100 MA for 200 candles
- **Multi-Timeframe Analysis**: Daily, 3-day, weekly analysis
- **Real-time Signals**: Automated trading signal generation

### 🌍 Multi-Language Support
- **Turkish (TR)** - Primary language
- **English (EN)** - International support
- **French (FR)** - European market support
- **German (DE)** - German-speaking market support

### 📱 Mobile Application
- **Cross-Platform**: iOS and Android support
- **Modern UI/UX**: Material Design 3 with dark/light themes
- **Real-time Updates**: Live price updates and notifications
- **Offline Support**: Local data caching and offline functionality

### 🔔 Notification System
- **Push Notifications**: Firebase Cloud Messaging integration
- **Price Alerts**: Customizable price level notifications
- **Signal Alerts**: Technical analysis signal notifications
- **Security Alerts**: Account security and system notifications

## 🏗️ Architecture

### Backend (Node.js + TypeScript)
```
backend/
├── src/
│   ├── config/          # Configuration management
│   ├── database/        # Database connections and models
│   ├── middleware/      # Security and request middleware
│   ├── routes/          # API endpoints
│   ├── services/        # Business logic services
│   ├── security/        # Security implementations
│   ├── utils/           # Utility functions
│   └── main.ts          # Application entry point
├── Dockerfile           # Production Docker configuration
└── package.json         # Dependencies and scripts
```

### Frontend (Flutter)
```
frontend/
├── lib/
│   ├── app/             # App configuration and routing
│   ├── core/            # Core services and models
│   ├── features/        # Feature-specific modules
│   └── main.dart        # Application entry point
├── assets/              # Images, fonts, and translations
└── pubspec.yaml         # Dependencies and configuration
```

### Database & Infrastructure
- **PostgreSQL 14+**: Main database with TimescaleDB extension
- **Redis 7+**: Caching and session management
- **Docker**: Containerized deployment
- **Nginx**: Reverse proxy and load balancing

## 🛠️ Technology Stack

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js with TypeScript
- **Database**: PostgreSQL with TimescaleDB
- **Cache**: Redis
- **Authentication**: JWT with refresh tokens
- **Security**: Helmet, CORS, Rate Limiting
- **Logging**: Winston with daily rotation
- **Validation**: Joi schema validation

### Frontend
- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Charts**: FL Chart and TradingView integration
- **Storage**: Hive and SharedPreferences
- **Networking**: Dio with Retrofit
- **Notifications**: Firebase Cloud Messaging

### DevOps & Security
- **Containerization**: Docker and Docker Compose
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus and Grafana
- **Security**: OWASP compliance, anti-tampering
- **SSL/TLS**: Let's Encrypt with auto-renewal

## 📋 Prerequisites

### System Requirements
- **Operating System**: Ubuntu 20.04+ / CentOS 8+ / macOS 12+
- **Memory**: Minimum 4GB RAM, Recommended 8GB+
- **Storage**: Minimum 20GB free space
- **Network**: Stable internet connection for API calls

### Software Requirements
- **Node.js**: 18.x or higher
- **PostgreSQL**: 14.x or higher
- **Redis**: 7.x or higher
- **Docker**: 20.10+ and Docker Compose 2.0+
- **Flutter**: 3.10+ (for development)
- **Git**: Latest version

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/btcbaran.git
cd btcbaran
```

### 2. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Configure environment variables
nano .env

# Start development server
npm run dev
```

### 3. Frontend Setup
```bash
# Navigate to frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Run the application
flutter run
```

### 4. Database Setup
```bash
# Start PostgreSQL and Redis
docker-compose up -d postgres redis

# Run database migrations
cd backend
npm run migrate

# Seed initial data
npm run seed
```

## ⚙️ Configuration

### Environment Variables

#### Backend (.env)
```bash
# Server Configuration
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Security
JWT_SECRET=your-super-secret-jwt-key-change-in-production
ENCRYPTION_KEY=your-32-character-encryption-key
SESSION_SECRET=your-session-secret-key

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=btcbaran
DB_USER=btcbaran_user
DB_PASSWORD=secure_password_here

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis_password_here

# Binance API
BINANCE_API_KEY=your_binance_api_key
BINANCE_API_SECRET=your_binance_api_secret

# Email Service
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

#### Frontend (lib/core/config/app_config.dart)
```dart
// Update these values in your configuration
static const String baseUrl = 'https://your-domain.com';
static const String apiVersion = '/api/v1';
```

### Database Configuration
```sql
-- Create database
CREATE DATABASE btcbaran;

-- Create user
CREATE USER btcbaran_user WITH PASSWORD 'secure_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE btcbaran TO btcbaran_user;

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;
```

## 🐳 Docker Deployment

### Production Deployment
```bash
# Build and start all services
docker-compose -f docker-compose.production.yml up -d

# View logs
docker-compose -f docker-compose.production.yml logs -f

# Stop services
docker-compose -f docker-compose.production.yml down
```

### Development Deployment
```bash
# Start development environment
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🔒 Security Features

### OWASP Top 10 Protection
1. **Injection Prevention**: Parameterized queries and input validation
2. **Broken Authentication**: JWT with refresh tokens, MFA support
3. **Sensitive Data Exposure**: AES-256 encryption, secure headers
4. **XML External Entities**: XXE protection enabled
5. **Broken Access Control**: Role-based access control (RBAC)
6. **Security Misconfiguration**: Secure defaults, environment validation
7. **Cross-Site Scripting**: Content Security Policy, XSS protection
8. **Insecure Deserialization**: Input validation and sanitization
9. **Using Components with Known Vulnerabilities**: Regular dependency updates
10. **Insufficient Logging**: Comprehensive audit and security logging

### Anti-Tampering Measures
- **Code Integrity**: SHA256 checksums for critical files
- **Anti-Debugging**: Runtime protection against debugging tools
- **Process Monitoring**: Continuous process integrity verification
- **File System Monitoring**: Real-time file modification detection

## 📱 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Token refresh
- `POST /api/auth/logout` - User logout
- `POST /api/auth/verify-email` - Email verification
- `POST /api/auth/forgot-password` - Password reset request
- `POST /api/auth/reset-password` - Password reset
- `POST /api/auth/mfa/setup` - MFA setup
- `POST /api/auth/mfa/verify` - MFA verification

### User Management Endpoints
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `PUT /api/users/change-password` - Change password
- `GET /api/users/sessions` - Get user sessions
- `DELETE /api/users/sessions/:sessionId` - Revoke session
- `GET /api/users/notifications` - Get user notifications
- `PUT /api/users/notifications/:id/read` - Mark notification as read
- `DELETE /api/users/account` - Delete user account

### Crypto Analysis Endpoints
- `GET /api/crypto/pairs` - Get available crypto pairs
- `GET /api/crypto/candles/:symbol` - Get candlestick data
- `GET /api/crypto/price/:symbol` - Get real-time price
- `GET /api/crypto/market-overview` - Get market overview
- `GET /api/crypto/signals` - Get trading signals
- `GET /api/crypto/alerts` - Get price alerts
- `POST /api/crypto/alerts` - Create price alert
- `DELETE /api/crypto/alerts/:id` - Delete price alert

### Technical Analysis Endpoints
- `GET /api/analysis/:symbol` - Get technical analysis
- `POST /api/analysis/calculate` - Calculate analysis
- `GET /api/analysis/history` - Get analysis history

## 🧪 Testing

### Backend Testing
```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration

# Run security tests
npm run test:security

# Generate coverage report
npm run test:coverage
```

### Frontend Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

## 📊 Monitoring & Logging

### Application Monitoring
- **Health Checks**: `/health`, `/health/detailed`, `/ready`, `/live`
- **Performance Metrics**: Response times, throughput, error rates
- **Resource Monitoring**: CPU, memory, disk usage
- **Security Monitoring**: Failed login attempts, suspicious activities

### Logging
- **Application Logs**: Winston with daily rotation
- **Security Logs**: Dedicated security event logging
- **Audit Logs**: User action tracking
- **Performance Logs**: Slow query and operation logging

## 🔧 Development

### Code Generation
```bash
# Backend (TypeScript)
npm run build:types
npm run generate:docs

# Frontend (Flutter)
flutter packages pub run build_runner build
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Code Quality
```bash
# Backend
npm run lint
npm run lint:fix
npm run format

# Frontend
flutter analyze
flutter format .
```

## 📚 Documentation

- [Security Architecture](docs/SECURITY_ARCHITECTURE.md)
- [API Reference](docs/API_REFERENCE.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Development Guide](docs/DEVELOPMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing code style and conventions
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure security best practices are followed
- Use conventional commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help
- **Documentation**: Check the [docs](docs/) folder
- **Issues**: Search existing [issues](https://github.com/yourusername/btcbaran/issues)
- **Discussions**: Join [discussions](https://github.com/yourusername/btcbaran/discussions)
- **Security**: Report security issues to security@yourdomain.com

### Community
- **Discord**: Join our [Discord server](https://discord.gg/btcbaran)
- **Telegram**: Follow our [Telegram channel](https://t.me/btcbaran)
- **Twitter**: Follow [@BTCBaran](https://twitter.com/BTCBaran)

## 🙏 Acknowledgments

- **Binance**: For providing the cryptocurrency data API
- **Flutter Team**: For the amazing cross-platform framework
- **Node.js Community**: For the robust runtime environment
- **Security Researchers**: For identifying and helping fix vulnerabilities

## 📈 Roadmap

### Phase 1 (Current) - Foundation
- [x] Basic application structure
- [x] Security architecture implementation
- [x] Multi-language support
- [x] Basic API endpoints

### Phase 2 (Q2 2024) - Core Features
- [ ] Technical analysis algorithms
- [ ] Real-time data processing
- [ ] Notification system
- [ ] User management

### Phase 3 (Q3 2024) - Advanced Features
- [ ] Advanced charting
- [ ] Portfolio tracking
- [ ] Social features
- [ ] Mobile app optimization

### Phase 4 (Q4 2024) - Enterprise
- [ ] White-label solutions
- [ ] API marketplace
- [ ] Advanced analytics
- [ ] Institutional features

---

**BTC Baran** - Empowering traders with advanced crypto analysis and security-first design.

*Built with ❤️ and 🔒 for the cryptocurrency community.*
