import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/providers/auth_provider.dart';
import 'package:taxi/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverPanel extends ConsumerStatefulWidget {
  const DriverPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverPanel> createState() => _DriverPanelState();
}

class _DriverPanelState extends ConsumerState<DriverPanel> {
  String _currentStatus = 'available';
  bool _statusInitialized = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null || user.isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Yetkiniz yok'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_statusInitialized) {
      _currentStatus = user.status;
      _statusInitialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/map'),
                    child: const Text(
                      '← Geri Dön',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  Text(
                    user.plate ?? 'Taksi',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(userProvider.notifier).logout();
                      context.go('/map');
                    },
                    child: const Icon(Icons.logout, color: Colors.white70, size: 22),
                  ),
                ],
              ),
            ),

            // Big status button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: GestureDetector(
                onTap: () => _cycleStatus(user),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: _statusColor(_currentStatus),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor(_currentStatus).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _statusIcon(_currentStatus),
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusLabel(_currentStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Durumu değiştirmek için dokun',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Status mini buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildMiniStatus('available', 'Müsait', Icons.check_circle),
                  const SizedBox(width: 8),
                  _buildMiniStatus('busy', 'Dolu', Icons.navigation),
                  const SizedBox(width: 8),
                  _buildMiniStatus('break', 'Mola', Icons.coffee),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const Text(
                    'Ayarlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Şifre
                  _buildSettingsCard(
                    title: 'Şifre',
                    icon: Icons.lock,
                    child: _PasswordChangeCard(user: user),
                  ),

                  const SizedBox(height: 12),

                  // Telefon Değiştir
                  _buildSettingsCard(
                    title: 'Telefon Değiştir',
                    icon: Icons.phone,
                    child: _PhoneChangeCard(user: user),
                  ),

                  const SizedBox(height: 12),

                  // Paket Yükselt
                  _buildSettingsCard(
                    title: 'Paket Yükselt',
                    icon: Icons.card_giftcard,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final whatsapp =
                              'https://wa.me/905555555555?text=Merhaba%20paket%20yükseltmek%20istiyorum.%20Plaka:%20${user.plate}';
                          if (await canLaunchUrl(Uri.parse(whatsapp))) {
                            await launchUrl(Uri.parse(whatsapp));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'WHATSAPP İLE YAZ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cycleStatus(user) {
    String next;
    if (_currentStatus == 'available') {
      next = 'busy';
    } else if (_currentStatus == 'busy') {
      next = 'break';
    } else {
      next = 'available';
    }
    setState(() => _currentStatus = next);
    ref.read(userProvider.notifier).updateStatus(next);
    FirebaseService().updateDriverStatus(user.id, next);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.available;
      case 'busy':
        return AppColors.busy;
      case 'break':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'busy':
        return Icons.navigation;
      case 'break':
        return Icons.coffee;
      default:
        return Icons.help;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'ÇALIŞIYOR';
      case 'busy':
        return 'DOLU';
      case 'break':
        return 'MOLADA';
      default:
        return 'BİLİNMİYOR';
    }
  }

  Widget _buildMiniStatus(String status, String label, IconData icon) {
    final isActive = _currentStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final user = ref.read(userProvider);
          if (user == null) return;
          setState(() => _currentStatus = status);
          ref.read(userProvider.notifier).updateStatus(status);
          FirebaseService().updateDriverStatus(user.id, status);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? _statusColor(status).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? _statusColor(status) : Colors.white12,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isActive ? _statusColor(status) : Colors.white38,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? _statusColor(status) : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PasswordChangeCard extends StatefulWidget {
  final dynamic user;
  const _PasswordChangeCard({required this.user});

  @override
  State<_PasswordChangeCard> createState() => _PasswordChangeCardState();
}

class _PasswordChangeCardState extends State<_PasswordChangeCard> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _ctrl,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Yeni Şifre',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : () {
                    if (_ctrl.text.trim().isEmpty) return;
                    final newPass = _ctrl.text.trim();
                    setState(() => _saving = true);

                    // Fire-and-forget: Firestore'a gönder, beklemeden devam et
                    FirebaseService().updateDriverField(
                      widget.user.id,
                      'password',
                      newPass,
                    ).then((_) {
                      debugPrint('✅ Şifre Firestore\'da güncellendi');
                    }).catchError((e) {
                      debugPrint('❌ Şifre güncelleme hatası: $e');
                    });

                    _ctrl.clear();
                    Future.delayed(const Duration(milliseconds: 400), () {
                      if (mounted) {
                        setState(() => _saving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Şifre güncellendi ✓'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'GÜNCELLE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PhoneChangeCard extends StatefulWidget {
  final dynamic user;
  const _PhoneChangeCard({required this.user});

  @override
  State<_PhoneChangeCard> createState() => _PhoneChangeCardState();
}

class _PhoneChangeCardState extends State<_PhoneChangeCard> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Yeni Numara',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : () {
                    if (_ctrl.text.trim().isEmpty) return;
                    final newPhone = _ctrl.text.trim();
                    setState(() => _saving = true);

                    // Fire-and-forget: Firestore'a gönder, beklemeden devam et
                    FirebaseService().updateDriverField(
                      widget.user.id,
                      'phone',
                      newPhone,
                    ).then((_) {
                      debugPrint('✅ Telefon Firestore\'da güncellendi');
                    }).catchError((e) {
                      debugPrint('❌ Telefon güncelleme hatası: $e');
                    });

                    _ctrl.clear();
                    Future.delayed(const Duration(milliseconds: 400), () {
                      if (mounted) {
                        setState(() => _saving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Telefon güncellendi ✓'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'ONAY İSTE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
