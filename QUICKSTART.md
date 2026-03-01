# 🚀 Hızlı Başlangıç Rehberi

## ✅ Tamamlandı (MVP - Faz 1)

Aşağıdakiler **zaten kurulu ve hazır**:
- ✅ Flutter project setup (pubspec.yaml güncellendi)
- ✅ Folder structure oluşturuldu
- ✅ Models, Services, Providers oluşturuldu
- ✅ Authentication system (Login screen)
- ✅ Maps screen (Harita)
- ✅ Türkçe UI (app_localizations)
- ✅ Riverpod + Hooks state management
- ✅ GoRouter navigation

---

## ⚠️ ÖNEMLİ: Yapılması Gereken

### 1️⃣ Firebase Project Oluşturun
[FIREBASE_SETUP.md](FIREBASE_SETUP.md) dosyasını **TAMAMEN** okuyun ve adımları izleyin:

- [ ] Firebase project oluştur
- [ ] Google Maps API key'ları al (Android & iOS)
- [ ] google-services.json indir (Android)
- [ ] GoogleService-Info.plist indir (iOS)
- [ ] API key'ları AndroidManifest.xml ve Info.plist'e ekle
- [ ] Firestore database oluştur
- [ ] Test verisi ekle (drivers, packages, settings)

### 2️⃣ FlutterFire Configure Çalıştır
```bash
cd c:\Users\pelin\OneDrive\Masaüstü\dincer\taxi
dart pub global run flutterfire_cli:flutterfire configure
```

İstenecek sorulara işinize göre cevap verin.

---

## 🎮 Uygulamayı Çalıştır

### Android Emülatör ile
```bash
flutter run
```

### iOS Simulator ile (macOS)
```bash
flutter run -d "iPhone 15 Pro"
```

### Fiziksel Cihaz ile
```bash
flutter run -d <device_id>
```

---

## 🧪 Test Etme

### Login Screen
1. **Admin Girişi**
   - Plaka: `ADMIN`
   - Şifre: `123456`
   - ✅ Map screen'e git

2. **Driver Girişi** (test data eklendiyse)
   - Plaka: `09 T 0001`
   - Şifre: `123`
   - ✅ Map screen'e git

### Map Screen
1. ✅ Harita yüklenir
2. ✅ Taksi marker'ları görünür (Firestore'dan)
3. ✅ Marker'a tap → Detay modal açılır
4. ✅ Arama butonu işler (tel: URI)
5. ✅ WhatsApp butonu işler (WhatsApp yüklüyse)
6. ✅ Top bar'da "GİRİŞ" butonu görünür (logged out)
7. ✅ Top bar'da kullanıcı info ve "Oturum Kapat" (logged in)

---

## 📁 Dosya Konumları

### Android
- API Key: `android/app/src/main/AndroidManifest.xml`
- google-services.json: `android/app/google-services.json`

### iOS
- API Key: `ios/Runner/Info.plist`
- GoogleService-Info.plist: `ios/Runner/GoogleService-Info.plist`

### Flutter
- Config: `lib/config/`
- Models: `lib/models/`
- Services: `lib/services/`
- Providers: `lib/providers/`
- Screens: `lib/screens/`
- Widgets: `lib/widgets/`

---

## 🐛 Hataları Gidermek

### "Permission denied" (Firestore)
→ Firestore Security Rules'i kontrol edin (FIREBASE_SETUP.md Adım 6)

### "Google Maps API key invalid"
→ AndroidManifest.xml ve Info.plist'te doğru? (FIREBASE_SETUP.md Adım 3-4)

### "pod install" hatası
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### "flutterfire: command not found"
Yeni terminal açın ve yeniden deneyin. Proje klasöründe olunduğundan emin olun.

---

## 📚 Belge Referansları

- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Tamamlanmış ve planlanan tüm features
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Detaylı Firebase kurulum kılavuzu
- **[example.md](example.md)** - Orijinal React Native uygulaması referansı

---

## 🎯 Sonraki Adımlar (Faz 2-5)

### Faz 2: Admin Panel
- Admin dashboard
- Taksi yönetimi
- İstek işleme
- Ayarlar

### Faz 3: Driver Panel
- Driver dashboard
- Status updates
- Profil yönetimi

### Faz 4: Real-time & Notifications
- Live location tracking
- Push notifications

### Faz 5: Deploy
- APK/IPA build
- App Store submission

---

## ⚡ Kısa İpuçları

```dart
// Login test
userNotifier.login("ADMIN", "123456");

// Driver listesi stream'i
final drivers = ref.watch(driverListProvider);

// Marker tap
ref.read(selectedDriverProvider.notifier).state = driver;

// Logout
ref.read(userProvider.notifier).logout();
```

---

## 🆘 Yardım Gerekli mi?

1. **Flutter kurulumu**: `flutter doctor` çalıştırın
2. **Dependencies**: `flutter pub get` çalıştırın
3. **Firebase issues**: FIREBASE_SETUP.md'i tekrar okuyun
4. **Code issues**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) mimarisini kontrol edin

---

**Firebase setup'ından sonra `flutter run` yapın ve uygulamayı test edin!** 🚀

Herhangi bir sorunu rapor edin, devam etmek için hazırım!
