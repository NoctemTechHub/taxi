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
      
      if (plate.toUpperCase() == AppConstants.adminPlate) {
        
        final settings = await _firebaseService.getSettings();
        if (password == settings.adminPassword) {
          final user = AppUser.admin('admin');
          await _saveUserLocal(user);
          return user;
        }
        return null;
      }

      
      final driver = await _firebaseService.getDriverByPlate(plate);
      if (driver != null && driver.password == password) {
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

      return null;
    } catch (e) {
      print('Login error: $e');
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
