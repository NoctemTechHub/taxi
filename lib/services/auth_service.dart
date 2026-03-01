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

      debugPrint('Login attempt: plate="$trimmedPlate"');

      // Admin girişi
      if (trimmedPlate.toUpperCase() == AppConstants.adminPlate) {
        debugPrint('Admin login detected');

        // Default şifre her zaman kabul edilsin
        if (trimmedPassword == AppConstants.adminDefaultPassword) {
          debugPrint('Admin login with default password');
          final user = AppUser.admin('admin');
          await _saveUserLocal(user);
          return user;
        }

        // Firestore'daki özel şifreyi kontrol et
        try {
          final settings = await _firebaseService.getSettings();
          if (trimmedPassword == settings.adminPassword) {
            debugPrint('Admin login with Firestore password');
            final user = AppUser.admin('admin');
            await _saveUserLocal(user);
            return user;
          }
        } catch (e) {
          debugPrint('Ayarlar alınamadı: $e');
        }

        debugPrint('Admin password mismatch');
        return null;
      }

      // Şoför girişi
      debugPrint('Driver login: searching plate "$trimmedPlate"');
      final driver = await _firebaseService.getDriverByPlate(trimmedPlate);
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

      debugPrint('Login failed: driver=${driver != null}, password match=${driver?.password == trimmedPassword}');
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
