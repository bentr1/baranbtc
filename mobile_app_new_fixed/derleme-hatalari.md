# APK Derleme Hataları

## 16.10.2025 - 18:08 - Build Hatası

### Hata Türü: Kotlin Compilation Error + Java Compilation Error

### Ana Hatalar:

1. **flutter_local_notifications Plugin Hatası:**
   ```
   D:\flutter_pub_cache\hosted\pub.dev\flutter_local_notifications-15.1.3\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java:1019: error: reference to bigLargeIcon is ambiguous
   bigPictureStyle.bigLargeIcon(null);
   ^
   both method bigLargeIcon(Bitmap) in BigPictureStyle and method bigLargeIcon(Icon) in BigPictureStyle match
   ```

2. **device_info_plus Plugin Kotlin Hatası:**
   - Kotlin standard library bağımlılık sorunu
   - MutableMap, HashMap, String gibi temel Kotlin tiplerine erişim hatası
   - Build.VERSION sınıfına erişim sorunları

### Detaylı Hata Mesajları:

#### Java Compilation Warnings:
- `warning: [options] source value 8 is obsolete and will be removed in a future release`
- `warning: [options] target value 8 is obsolete and will be removed in a future release`

#### Kotlin Compilation Errors:
- `cannot access built-in declaration 'kotlin.collections.MutableMap'`
- `cannot access built-in declaration 'kotlin.String'`
- `cannot access built-in declaration 'kotlin.Int'`
- `unresolved reference 'HashMap'`
- `unresolved reference 'success'`
- `unresolved reference 'notImplemented'`

### Çözüm Önerileri:

1. **flutter_local_notifications güncellemesi:**
   - Plugin versiyonunu güncelle
   - Android API seviyesini kontrol et

2. **device_info_plus sorunu:**
   - Kotlin standard library bağımlılığını ekle
   - Plugin versiyonunu güncelle

3. **Gradle yapılandırması:**
   - Kotlin versiyonunu güncelle
   - Android Gradle Plugin versiyonunu kontrol et

### Yapılan Denemeler:
- Flutter cache temizlendi
- Pub cache D:\flutter_pub_cache olarak ayarlandı
- Dependencies yeniden yüklendi
- Build klasörü temizlendi

### Sonraki Adımlar:
1. Plugin versiyonlarını güncelle
2. Android Gradle Plugin ve Kotlin versiyonlarını kontrol et
3. Gradle wrapper versiyonunu güncelle
4. Alternatif plugin'ler araştır

---

## 16.10.2025 - 18:15 - Build Hatası (Devam)

### Plugin Güncellemeleri Yapıldı:
- flutter_local_notifications: 15.1.3 → 17.2.4
- device_info_plus: 9.1.2 → 10.1.2

### Hala Devam Eden Sorunlar:
1. **device_info_plus Plugin Kotlin Standard Library Hatası:**
   - Kotlin temel tiplerine erişim sorunu devam ediyor
   - MutableMap, HashMap, String, Int, Boolean gibi temel tipler tanınmıyor
   - Build.VERSION sınıfına erişim sorunları

2. **Kotlin Compilation Cache Sorunu:**
   - Incremental cache dosyaları kilitleniyor
   - Storage registration sorunları

### Yeni Denenecek Çözümler:
1. device_info_plus plugin'ini tamamen kaldır
2. Alternatif device info plugin kullan
3. Kotlin compilation cache'i manuel temizle
4. Gradle daemon'ı restart et
