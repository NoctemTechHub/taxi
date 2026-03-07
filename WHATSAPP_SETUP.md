# WhatsApp Entegrasyonu - Kurulum ve Yapılandırma

## 📱 Yapılan Değişiklikler

### 1. **Android Yapılandırması** (`android/app/src/main/AndroidManifest.xml`)
✅ WhatsApp intent'leri ve paketleri için query izinleri eklendi:
- `com.whatsapp` - WhatsApp Messenger
- `com.whatsapp.w4b` - WhatsApp Busines

```xml
<queries>
    <!-- Existing queries... -->
    <intent>
        <action android:name="android.intent.action.VIEW"/>
        <data android:scheme="whatsapp"/>
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW"/>
        <data android:scheme="vnd.whatsapp"/>
    </intent>
    <package android:name="com.whatsapp"/>
    <package android:name="com.whatsapp.w4b"/>
</queries>
```

### 2. **iOS Yapılandırması** (`ios/Runner/Info.plist`)
✅ LSApplicationQueriesSchemes ve izin açıklamaları eklendi:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>whatsapp</string>
    <string>vnd.whatsapp</string>
    <string>tel</string>
    <string>http</string>
    <string>https</string>
</array>

<key>NSPhotoLibraryUsageDescription</key>
<string>AydınDaBu Taxi uygulaması profil fotoğrafı seçmek için galeriye erişmek istemektedir.</string>

<key>NSCameraUsageDescription</key>
<string>AydınDaBu Taxi uygulaması kamera erişmek istemektedir.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>AydınDaBu Taxi uygulaması konumunuza erişmek istemektedir.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>AydınDaBu Taxi uygulaması her zaman konumunuza erişmek istemektedir.</string>
```

### 3. **Yeni WhatsApp Service** (`lib/services/whatsapp_service.dart`)
✅ Yeni bir hizmet sınıfı oluşturuldu, bu sayfa şunlar bir fonksiyonalite sağlar:

**Temel Metotlar:**
- `openWhatsApp()` - Belirtilen numaraya ve mesaja WhatsApp aç
- `sendTaxiMessage()` - Taksi çağrısı mesajı gönder
- `sendDriverRegistrationMessage()` - Taksi şoförü kaydetme mesajı
- `sendPackageUpgradeMessage()` - Paket yükseltme mesajı

**Özellikler:**
- Telefon numarası temizleme (gereksiz karakterleri kaldırma)
- Hata yönetimi ve kullanıcı bildirimi
- URL encoding ile güvenli mesaj gönderme

### 4. **Geliştirilmiş Modal Bileşeni** (`lib/widgets/modals/taxi_detail_modal.dart`)
✅ Taksi detay modalı güncellendi:
- WhatsAppService entegrasyonu
- BuildContext geçerek uygun hata mesajları gösterme
- Daha temiz ve bakım yapılabilir kod

---

## 🚀 Kullanım Örnekleri

### Taksi Çağrısı Yapma
```dart
await WhatsAppService.sendTaxiMessage(
  whatsappNumber: '905555555555',
  taxiPlate: '09 T 0001',
  context: context,
);
```

### Taksi Şoförü Kaydetme
```dart
await WhatsAppService.sendDriverRegistrationMessage(
  whatsappNumber: '905555555555',
  context: context,
);
```

### Paket Yükseltme
```dart
await WhatsAppService.sendPackageUpgradeMessage(
  whatsappNumber: '905555555555',
  taxiPlate: '09 T 0001',
  packageName: 'Premium',
  context: context,
);
```

---

## 📋 Kontrol Listesi - Kurulum Tamamlandıktan Sonra Kontrol Edin

### Android Cihazlar
- [ ] `android/app/src/main/AndroidManifest.xml` güncellenmiş
- [ ] Manifest dosyasında `<queries>` bölümünde WhatsApp paketleri var
- [ ] Android Studio'da project clean ve rebuild yap
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### iOS Cihazlar
- [ ] `ios/Runner/Info.plist` güncellenmiş
- [ ] `LSApplicationQueriesSchemes` dizisinde whatsapp şemaları var
- [ ] Tüm permissya açıklamaları (foto, kamera, konum) eklendi
- [ ] Xcode'da pod clean ve rebuild yap
  ```bash
  rm -rf ios/Pods ios/Podfile.lock
  flutter clean
  flutter pub get
  flutter run
  ```

---

## 🔗 WhatsApp Link Yapısı

Uygulama `wa.me` URL şemasını kullanır (web ve app'de çalışır):
```
https://wa.me/[PHONENUMBER]?text=[MESSAGE]
```

**Örnek:**
```
https://wa.me/905555555555?text=Merhaba%2C%2009%20T%200001%20pla%C4%9F%C4%B1%20taksiye%20ihtiyac%C4%B1m%20var.
```

---

## ⚠️ Sorun Giderme

### Sorun: "WhatsApp açılamadı" hatası
**Çözüm:**
1. Cihazda WhatsApp yüklü olduğundan emin olun
2. Android: `android/app/src/main/AndroidManifest.xml` içindeki `<queries>` bölümünü kontrol edin
3. iOS: `ios/Runner/Info.plist` içindeki `LSApplicationQueriesSchemes` kontrol edin
4. `flutter clean` ve `flutter pub get` çalıştırın

### Sorun: Türkçe karakterler hatalı görünüyor
**Çözüm:** Kod zaten UTF-8 URL encoding kullanıyor, sorun yoktur. WhatsApp otomatik olarak karakterleri doğru gösterecek.

### Sorun: Telefon numarası hatasında boş mesaj
**Çözüm:** Admin panelinde WhatsApp numarasının formatını kontrol edin (örn: "905555555555")

---

## 📱 Admin Panelinden Ayarlar

Admin panelinde WhatsApp numarasını ayarlayabilirsiniz:
1. Admin panelinize giriş yapın
2. **AYARLAR** sekmesine geçin
3. **WhatsApp Linki** alanını güncelleyin
4. Formatta hata olmadığından emin olun (örn: 905555555555)

---

## ✨ Ekstra Bilgiler

- **URL Launcher paketi:** `url_launcher: ^6.1.0` (zaten birlikte)
- **Desteklenen Platform:** Android 6.0+, iOS 9.0+
- **WhatsApp İnternet Bağlantısı:** Çalışmak için WhatApp'ın internet bağlantısına ihtiyacı vardır

---

**Son Güncelleme:** 6 Mart 2026
