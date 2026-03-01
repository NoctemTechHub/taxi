import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/l10n/app_localizations.dart';
import 'package:taxi/models/driver_model.dart';
import 'package:taxi/providers/auth_provider.dart';
import 'package:taxi/services/firebase_service.dart';

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

                const SizedBox(height: 16),

                // ─── Taksini Ekle / Başvur ───────────────────────
                OutlinedButton.icon(
                  onPressed: () => _showRegistrationDialog(context),
                  icon: const Icon(Icons.local_taxi),
                  label: const Text(
                    'Taksini Ekle / Başvur',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  void _showRegistrationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _RegistrationForm(),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final plateCtrl = TextEditingController();
  final passwordCtrl2 = TextEditingController();
  final phoneCtrl = TextEditingController();
  final standCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  bool isSending = false;
  bool isSuccess = false;

  @override
  void dispose() {
    plateCtrl.dispose();
    passwordCtrl2.dispose();
    phoneCtrl.dispose();
    standCtrl.dispose();
    districtCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final plate = plateCtrl.text.trim();
    final password = passwordCtrl2.text.trim();
    final phone = phoneCtrl.text.trim();

    if (plate.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plaka, şifre ve telefon zorunludur'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      final newDriver = Driver(
        id: '',
        plate: plate.toUpperCase(),
        lat: 37.8444,
        lng: 27.8458,
        status: 'pending',
        taxiStand: standCtrl.text.trim(),
        district: districtCtrl.text.trim(),
        phone: phone,
        isPremium: false,
        password: password,
        likes: 0,
      );

      // Firestore'a gönder ama beklemeden devam et (optimistic)
      FirebaseService().addDriver(newDriver).then((_) {
        debugPrint('✅ Firestore kayıt tamamlandı');
      }).catchError((e) {
        debugPrint('❌ Firestore kayıt hatası: $e');
      });

      // Kısa bir bekleme yap ve hemen başarı göster
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ Başvuru gönderildi, başarı ekranı gösteriliyor');
      if (mounted) {
        setState(() {
          isSending = false;
          isSuccess = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Kayıt hatası: $e');
      if (mounted) {
        setState(() => isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSuccess) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Başvurunuz Onaylandı!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Plaka ve şifreniz ile giriş yapabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TAMAM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_taxi,
                      color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Taksi Kaydı Başvurusu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Bilgilerinizi doldurun, hemen giriş yapabilirsiniz.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: plateCtrl,
              decoration: InputDecoration(
                labelText: 'Plaka *',
                hintText: '09 T 0001',
                prefixIcon: const Icon(Icons.directions_car),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordCtrl2,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre *',
                hintText: 'Giriş şifrenizi belirleyin',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: 'Telefon *',
                hintText: '05XX XXX XX XX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: standCtrl,
              decoration: InputDecoration(
                labelText: 'Taksi Durağı',
                hintText: 'Örn: Merkez Durak',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: districtCtrl,
              decoration: InputDecoration(
                labelText: 'İlçe',
                hintText: 'Örn: Efeler',
                prefixIcon: const Icon(Icons.map),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Başvur',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
