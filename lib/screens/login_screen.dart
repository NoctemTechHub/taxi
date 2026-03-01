import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/l10n/app_localizations.dart';
import 'package:taxi/providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plateController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    final userNotifier = ref.read(userProvider.notifier);

    Future<void> handleLogin() async {
      isLoading.value = true;
      errorMessage.value = null;

      final success = await userNotifier.login(
        plateController.text.trim(),
        passwordController.text.trim(),
      );

      isLoading.value = false;

      if (success && context.mounted) {
        // Get current user to determine route
        final user = ref.read(userProvider);
        if (user?.isAdmin ?? false) {
          context.go('/admin');
        } else {
          context.go('/driver');
        }
      } else {
        errorMessage.value = AppStrings.wrongCredentials;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
    appBar: AppBar(

        leading: BackButton(
          onPressed: () => context.pop(),
          color: AppColors.secondary,
         
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.secondary,
        elevation: 0,
      ), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🚖',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AydınDaBu TAKSİ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                
                TextField(
                  controller: plateController,
                  decoration: InputDecoration(
                    labelText: AppStrings.plate,
                    hintText: '09 T 0001',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.directions_car),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => handleLogin(),
                ),
                if (errorMessage.value != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      errorMessage.value!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: isLoading.value ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondary,
                            ),
                          ),
                        )
                      : Text(
                          AppStrings.loginButtonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                
                Center(
                  child: Text(
                    'Admin: ADMIN / 123456',
                    style: TextStyle(
                      color: AppColors.darkGray.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
