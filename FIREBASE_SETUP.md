# Firebase & Google Maps Setup Guide

## Adım 1: Firebase Project Oluşturun

### 1.1 Firebase Console'a Giriş
1. [Firebase Console](https://console.firebase.google.com/) açın
2. Google hesabınızla giriş yapın
3. "Create a new project" (Yeni proje oluştur) seçeneğine tıklayın

### 1.2 Proje Ayarları
- **Project Name**: "AydınDaBu TAKSİ" (veya istediğiniz ad)
- **Enable Google Analytics**: Opsiyonel (İndirebilirsiniz)
- "Create Project" (Proje Oluştur) tıklayın

### 1.3 Uygulamaları Kaydedin
Firebase Console'da, aşağıdaki platformlar için uygulamaları kaydedin:

#### iOS Uygulamasını Kaydet
1. "iOS" ikonuna tıklayın
2. Bundle ID: `com.example.taxi` (iOS/Runner/Info.plist'te kontrol edin)
3. Diğer bilgileri (App Store ID vb.) boş bırakabilirsiniz
4. Google Services dosyasını indirin (GoogleService-Info.plist)
5. Dosyayı: `ios/Runner/` dizinine kopyalayın

#### Android Uygulamasını Kaydet
1. "Android" ikonuna tıklayın
2. Package Name: `com.example.taxi` (android/app/build.gradle'de kontrol edin)
3. SHA-1 Certificate Hash: Almak için terminal'de çalıştırın:
   ```bash
   ./gradlew signingReport
   ```
4. Google Services dosyasını indirin (google-services.json)
5. Dosyayı: `android/app/` dizinine kopyalayın

#### Web Uygulamasını Kaydet (Opsiyonel)
1. "Web" ikonuna tıklayın
2. App Nickname: "AydınDaBu TAKSİ Web"
3. Hosting URL'i boş bırakabilirsiniz

---

## Adım 2: Google Maps API Anahtarı Almak

### 2.1 Google Cloud Console'da Proje Oluşturun
1. [Google Cloud Console](https://console.cloud.google.com/) açın
2. Proje oluşturun veya Firebase projenizi seçin
3. Sols menüden "APIs & Services" → "Credentials" açın

### 2.2 API Anahtarı Oluşturun
1. "Create Credentials" → "API key" seçin
2. API anahtarı oluşturulacaktır
3. "Restrict Keys" seçeneğine tıklayın
4. **Key restrictions** bölümünde:
   - **Application restriction**: "Android apps" kullanly seçin
   - PackageName ve SHA-1 değerlerini ekleyin
5. **API restrictions** bölümünde:
   - "Maps SDK for Android" API'sini seçin
   - "Save" tıklayın

### 2.3 iOS için API Anahtarı Konfigürasyonu
Ayrı bir API anahtarı oluşturun (iOS için):
1. "Create Credentials" → "API key"
2. Key restrictions:
   - **Application restriction**: "iOS apps"
   - Bundle ID: `com.example.taxi`
3. API restrictions: "Maps SDK for iOS"

---

## Adım 3: Android Konfigürasyonu

### 3.1 google-services.json Yerleştirildi
Dosya: `android/app/google-services.json` (Firebase adımından indirildi)

### 3.2 AndroidManifest.xml Google Maps Anahtarını Ekle
Dosya: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest ...>
    <application ...>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY" />
    </application>
</manifest>
```

**NOT**: `YOUR_GOOGLE_MAPS_API_KEY` yerine adım 2'de aldığınız Android API anahtarını yapıştırın.

### 3.3 android/build.gradle Kontrol Edin
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### 3.4 android/app/build.gradle Kontrol Edin
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.android.gms:play-services-maps:18.2.0'
}
```

---

## Adım 4: iOS Konfigürasyonu

### 4.1 GoogleService-Info.plist Yerleştirildi
Dosya: `ios/Runner/GoogleService-Info.plist` (Firebase adımından indirildi)

Xcode'da:
1. `ios/Runner.xcworkspace` açın (NOT: Runner.xcodeproj değil!)
2. Runner projesini seçin → Runner (app) hedefi
3. "Build Phases" → "Copy Bundle Resources"
4. `GoogleService-Info.plist` dosyasının listelenip listelenmediklerini kontrol edin

### 4.2 iOS Pod'ları Güncelleyin
```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
pod install --repo-update
cd ..
```

### 4.3 iOS Info.plist'e Google Maps Anahtarını Ekle
Dosya: `ios/Runner/Info.plist`

```xml
<dict>
    ...
    <key>googlemaps_ios_api_key</key>
    <string>YOUR_IOS_GOOGLE_MAPS_API_KEY</string>
    ...
</dict>
```

**NOT**: `YOUR_IOS_GOOGLE_MAPS_API_KEY` yerine adım 2'de aldığınız iOS API anahtarını yapıştırın.

---

## Adım 5: Firebase Services Etkinleştirin

Firebase Console'da:
1. "App Check" etkinleştirin (opsiyonel, güvenlik için)
2. "Cloud Firestore" database oluşturun:
   - Region: En yakın bölgeyi seçin
   - Security Rules başlangıç olarak "Test Mode"
3. "Authentication" etkinleştirin:
   - Email/Password provider'ı enable edin

---

## Adım 6: Firestore Security Rules Ayarlayın

Firebase Console → Cloud Firestore → Rules sekmesi

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Drivers - Herkese oku, yazı sadece admin
    match /drivers/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Requests - Sadece authenticated
    match /requests/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Packages - Herkese oku
    match /packages/{document=**} {
      allow read: if true;
      allow write: if false;
    }
    
    // Admin Settings - Sadece authenticated
    match /admin_settings/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

"Publish" tıklayın.

---

## Adım 7: Test Verileri Ekleyin (İsteğe Bağlı)

### Driver Ekleme
Firebase Console → Cloud Firestore → Collection "drivers"

Aşağıdaki veriyi ekleyin:
```json
{
  "plate": "09 T 0001",
  "lat": 37.8460,
  "lng": 27.8470,
  "status": "available",
  "taxiStand": "Merkez",
  "district": "Efeler",
  "phone": "05550000001",
  "isPremium": true,
  "password": "123",
  "likes": 45
}
```

### Settings Ekleme
Collection "admin_settings" → Document "config"

```json
{
  "adminPassword": "123456",
  "whatsappNumber": "905555555555",
  "downloadLink": "https://aydindabutaksi.com/indir.apk"
}
```

---

## Adım 8: Flutter Uygulamasını Çalıştırın

### FlutterFire Konfigürasyonunu Çalıştırın
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

İstenecek sorulara cevap verin:
- Firebase project seçin
- Hangi platformlar: Android, iOS, Web (istediğinize göre)
- Uygulama kayıt problemi varsa adayı atla

### Flutter'ı Çalıştırın
```bash
flutter run
```

---

## Sorun Giderme

### "Firestore database not found"
- Firebase Console'a gidip Firestore database oluşturduğunuzü kontrol edin

### "Google Maps API key invalid"
- AndroidManifest.xml ve Info.plist'te doğru anahtarları yapıştırdığınızı kontrol edin
- API key'in Google Cloud Console'da etkinleştirilip etkinleştirilmediğini kontrol edin

### "Permission denied" hatası
- Firestore Security Rules'i kontrol edin (yazı izni etkinleştirilmiş mi?)

### "Pod install" hatası (macOS/iOS)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

---

## Sonraki Adımlar

1. **Admin Panel implementasyonu** (Faz 2)
   - Taksi yönetimi (CRUD)
   - İstek işleme
   - Paket yönetimi
   - Ayarlar ekranı

2. **Driver Panel implementasyonu** (Faz 3)
   - Profil yönetimi
   - Status updates
   - Şifre değiştirme

3. **Real-time Updates** (Faz 4)
   - Firestore listeners kullanarak gerçek zamanlı veri senkronizasyonu
   - Push notifications

4. **Testing & Deployment** (Faz 5)
   - Unit tests
   - Widget tests
   - APK/IPA build

---

**Başlamaya hazır mısınız? Yukarıdaki adımları tamamladıktan sonra `flutter run` komutunu çalıştırabilirsiniz!** 🚀
