import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/services/firebase_service.dart';
import 'package:taxi/services/notification_service.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _initializeApp(context);
      return null;
    }, []);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🚖',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            const Text(
              'AydınDaBu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'TAKSİ',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    try {
      
      final firebaseService = FirebaseService();
      await firebaseService.initialize();

      
      final notificationService = NotificationService();
      await notificationService.initialize();

      
      if (context.mounted) {
        context.go('/map');
      }
    } catch (e) {
      print('Initialization error: $e');
      if (context.mounted) {
        context.go('/map');
      }
    }
  }
}
