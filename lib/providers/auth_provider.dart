import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/models/user_model.dart';
import 'package:taxi/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final userProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserNotifier(authService);
});

class UserNotifier extends StateNotifier<AppUser?> {
  final AuthService _authService;

  UserNotifier(this._authService) : super(null) {
    _initializeUser();
  }

  void _initializeUser() {
    state = _authService.getCurrentUser();
  }

  Future<bool> login(String plate, String password) async {
    try {
      final user = await _authService.login(plate, password);
      if (user != null) {
        state = user;
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  bool get isLoggedIn => state != null;
  bool get isAdmin => state?.isAdmin ?? false;
  bool get isDriver => state?.isDriver ?? false;
}
