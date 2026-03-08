import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi/config/app_constants.dart';
import 'package:taxi/models/user_model.dart';
import 'package:taxi/services/firebase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  final FirebaseService _firebaseService = FirebaseService();
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<AppUser?> login(String plate, String password) async {
    try {
      final trimmedPlate = plate.trim();
      final trimmedPassword = password.trim();

      debugPrint('Login attempt: plate=$trimmedPlate');
      // Avoid logging raw passwords
      debugPrint('Login attempt: password=*** (hidden)');

      // Admin girişi
      if (trimmedPlate.toUpperCase() == AppConstants.adminPlate) {
        debugPrint('Admin login detected');

        // 1) Önce local cache'den kontrol et
        final cachedAdminPw = _prefs.getString('cached_admin_password');
        if (cachedAdminPw != null && cachedAdminPw.isNotEmpty) {
          if (trimmedPassword == cachedAdminPw) {
            debugPrint('Admin login with cached password');
            final user = AppUser.admin('admin');
            await _saveUserLocal(user);
            return user;
          }
        }

        // 2) Firestore'dan şifreyi getir (getSettings artık asla exception atmaz)
        final settings = await _firebaseService.getSettings();
        final fetchedPw = settings.adminPassword ?? '';

        if (fetchedPw.isEmpty) {
          // Firestore'da settings/config dökümanı yok veya ulaşılamıyor
          // Cache de yok → giriş yapılamaz, kullanıcıya bilgi ver
          debugPrint(
            'Admin login failed: settings/config Firestore dökümanı bulunamadı. '
            'Firebase Console → Firestore → settings/config dökümanını oluştur ve adminPassword alanını ekle.',
          );
          return null;
        }

        // Başarılı ise SharedPreferences cache'e yaz (offline için)
        await _prefs.setString('cached_admin_password', fetchedPw);

        if (trimmedPassword == fetchedPw) {
          debugPrint('Admin login success with Firestore password');
          final user = AppUser.admin('admin');
          await _saveUserLocal(user);
          return user;
        }

        debugPrint('Admin password mismatch');
        return null;
      }

      // Şoför girişi
      final uppercasedPlate = trimmedPlate.toUpperCase();
      debugPrint('Driver login: searching plate=$uppercasedPlate');
      final driver = await _firebaseService.getDriverByPlate(uppercasedPlate);
      debugPrint('Driver found: ${driver != null}');

      if (driver != null && driver.password == trimmedPassword) {
        debugPrint('Driver login success: ${driver.plate}');
        final user = AppUser.driver(
          id: driver.id,
          plate: driver.plate,
          phone: driver.phone,
          isPremium: driver.isPremium,
          status: driver.status,
          likes: driver.likes,
          password: driver.password,
        );
        await _saveUserLocal(user);
        return user;
      }

      debugPrint(
        'Login failed: driver=${driver != null}, password match=${driver?.password == trimmedPassword}',
      );
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _prefs.remove('user_id');
    await _prefs.remove('user_role');
    await _prefs.remove('user_plate');
    await _prefs.remove('user_phone');
  }

  AppUser? getCurrentUser() {
    final userId = _prefs.getString('user_id');
    final role = _prefs.getString('user_role');

    if (userId == null || role == null) {
      return null;
    }

    if (role == 'admin') {
      return AppUser.admin(userId);
    } else {
      return AppUser.driver(
        id: userId,
        plate: _prefs.getString('user_plate') ?? '',
        phone: _prefs.getString('user_phone'),
        isPremium: _prefs.getBool('user_isPremium') ?? false,
      );
    }
  }

  bool isLoggedIn() {
    return getCurrentUser() != null;
  }

  Future<void> _saveUserLocal(AppUser user) async {
    await _prefs.setString('user_id', user.id);
    await _prefs.setString('user_role', user.role);
    if (user.plate != null) {
      await _prefs.setString('user_plate', user.plate!);
    }
    if (user.phone != null) {
      await _prefs.setString('user_phone', user.phone!);
    }
    await _prefs.setBool('user_isPremium', user.isPremium);
  }
}
