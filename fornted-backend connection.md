Frontend ve Backend İletişimi için Gerekli Bilgiler
Analiz ettiğim konfigürasyonlara göre, frontend ve backend arasında sorunsuz iletişim kurmak için gerekli tüm bilgileri size sunuyorum:
🌐 Network ve Bağlantı Bilgileri
Ana Domain ve IP:
Domain: btc.nazlihw.com
Sunucu IP: 185.8.129.67
Backend Port: 3000
Backend URL: http://185.8.129.67:3000 (doğrudan erişim)
API Base URL: https://btc.nazlihw.com (production)
Port Yapılandırması:
Backend API: Port 3000 (Node.js)
PostgreSQL: Port 5432 (localhost)
Redis: Port 6379 (localhost)
Nginx: Port 80 (HTTP) ve 443 (HTTPS)
🔐 Güvenlik ve Kimlik Doğrulama
JWT Token Ayarları:
JWT Secret: jwt_super_secret_key_2024_btcbaran_production
JWT Refresh Secret: jwt_refresh_super_secret_key_2024_btcbaran_production
Token Süresi: 15m (15 dakika)
Refresh Token Süresi: 7d (7 gün)
Şifreleme:
Encryption Key: encryption_key_32_chars_2024
🗄️ Veritabanı Bağlantı Bilgileri
PostgreSQL:
Host: postgres (Docker içinde) / 127.0.0.1 (doğrudan)
Port: 5432
Database: btcbaran
Username: btcbaran_user
Password: btcbaran_secure_password_2024
Connection String: postgresql://btcbaran_user:btcbaran_secure_password_2024@postgres:5432/btcbaran
Redis Cache:
Host: redis (Docker içinde) / 127.0.0.1 (doğrudan)
Port: 6379
Password: redis_secure_password_2024
Connection String: redis://:redis_secure_password_2024@redis:6379
📱 Frontend Konfigürasyonu (Flutter)
API Ayarları:
Güvenlik Ayarları:
Max Login Attempts: 5
Lockout Duration: 15 dakika
Session Timeout: 24 saat
Token Refresh Threshold: 5 dakika
🔧 API Endpoints
Health Check:
Backend Health: http://localhost:3000/health
API Health: http://localhost:3000/api/health
API Versiyonu: /api/v1
🌍 CORS ve Güvenlik Ayarları
CORS Origin: https://btc.nazlihw.com
Güvenlik Özellikleri:
Security Headers: Aktif
Rate Limiting: Aktif
Session Security: Aktif
HTTPS Zorunlu: Aktif
📧 Email Konfigürasyonu
SMTP Ayarları:
Host: smtp.gmail.com
Port: 587
User: your_email@gmail.com (gerçek email ile değiştirin)
Pass: your_app_password_here (Gmail app password)
From Email: noreply@btc.nazlihw.com
🔥 Firebase Ayarları
Firebase:
Project ID: btcbaran-production
Client Email: firebase-adminsdk@btcbaran-production.iam.gserviceaccount.com
Private Key: your_firebase_private_key_here (gerçek key ile değiştirin)
📊 Monitoring
Grafana:
URL: http://localhost:3001
Password: grafana_admin_password_2024
Prometheus:
URL: http://localhost:9090
⚠️ Önemli Notlar
HTTPS Sertifikası: btc.nazlihw.com için SSL sertifikası kurulu değil
API Erişimi: Backend API'si çalışıyor ve erişilebilir
Güvenlik: Tüm hassas bilgiler environment dosyalarında şifrelenmiş
Docker: Servisler Docker container'larında çalışıyor
🚀 Frontend-Backend Bağlantı Testi
Frontend'den backend'e bağlantı kurmak için:
Base URL: https://btc.nazlihw.com kullanın
API Endpoint: /api/v1/ prefix'i ekleyin
Authentication: JWT token'ları header'da gönderin
Timeout: 30 saniye timeout ayarlayın


📧 Email Konfigürasyonu
SMTP Ayarları:
Host: mail.nazlihw.com
Port: 587
User: btcbaran@nazlihw.com
Pass: BaranBtc123*
From Email: noreply@nazlihw.com


firebase
Add Firebase SDK
Instructions for Gradle
|
UnityC++
tip:
Are you still using the buildscript syntax to manage plugins? Learn how to add Firebase plugins using that syntax.
To make the google-services.json config values accessible to Firebase SDKs, you need the Google services Gradle plugin.


Kotlin DSL (build.gradle.kts)

Groovy (build.gradle)
Add the plugin as a dependency to your project-level build.gradle.kts file:

Root-level (project-level) Gradle file (<project>/build.gradle.kts):
plugins {
  // ...

  // Add the dependency for the Google services Gradle plugin
  id("com.google.gms.google-services") version "4.4.4" apply false

}
Then, in your module (app-level) build.gradle.kts file, add both the google-services plugin and any Firebase SDKs that you want to use in your app:

Module (app-level) Gradle file (<project>/<app-module>/build.gradle.kts):
plugins {
  id("com.android.application")

  // Add the Google services Gradle plugin
  id("com.google.gms.google-services")

  ...
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.4.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}
By using the Firebase Android BoM, your app will always use compatible Firebase library versions. Learn more
After adding the plugin and the desired SDKs, sync your Android project with Gradle files.


SDK setup and configuration
Need to reconfigure the Firebase SDKs for your app? Revisit the SDK setup instructions or just download the configuration file containing keys and identifiers for your app.
App ID 
1:78955542733:android:81201a5f6b578f2fc65184
App nickname
BTC Baran
Package name
com.bozkilinc.btcbaran
SHA certificate fingerprints 
Type 
Actions



Completed
Register app
2
Add Firebase SDK

Use npm

Use a <script> tag
If you're already using npm and a module bundler such as webpack or Rollup, you can run the following command to install the latest SDK (Learn more):

npm install firebase
Then, initialize Firebase and begin using the SDKs for the products you'd like to use.

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBZrt1-KgGBYpzNrvHRd0RlOtJVqgSgrig",
  authDomain: "btcbaran-c7334.firebaseapp.com",
  projectId: "btcbaran-c7334",
  storageBucket: "btcbaran-c7334.firebasestorage.app",
  messagingSenderId: "78955542733",
  appId: "1:78955542733:web:fc21e905ef086992c65184",
  measurementId: "G-VVR58KX1BQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
Note: This option uses the modular JavaScript SDK, which provides reduced SDK size.

Learn more about Firebase for web: Get Started, Web SDK API Reference, Samples


Firebase Cloud Messaging API (V1)Enabled
Recommended for most use cases. Learn more

Check the real time performance of the V1 API on the Status Dashboard

Sender ID
Service Account
78955542733	Manage Service Accounts
Cloud Messaging API (Legacy)Disabled
If you are an existing user of the legacy HTTP or XMPP APIs (deprecated on 6/20/2023), you must migrate to the latest Firebase Cloud Messaging API (HTTP v1) by 6/20/2024. Learn more

Web configuration
Web Push certificates
Web Push certificates
Firebase Cloud Messaging can use Application Identity key pairs to connect with external push services. Learn more
Key pair	Date added	Status	Actions
BDLkQO8zY377jZIZUvd2c6NJzveRcll12e-5umZkWf1QmIztuYegcCdopWunJEoXo73LLb-HrVFiiw7FmKeBgII	Oct 16, 2025		

