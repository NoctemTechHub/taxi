import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/providers/auth_provider.dart';
import 'package:taxi/providers/package_provider.dart';
import 'package:taxi/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverPanel extends ConsumerStatefulWidget {
  const DriverPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverPanel> createState() => _DriverPanelState();
}

class _DriverPanelState extends ConsumerState<DriverPanel> {
  int _selectedTab = 0;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = 'available';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final packages = ref.watch(packageListProvider);

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

    _currentStatus = user.status;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.plate ?? 'Taksi',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (_currentStatus == 'available')
                              const Text(
                                '🟢 MÜSAİT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            else if (_currentStatus == 'busy')
                              const Text(
                                '🔴 DOLU',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            else
                              const Text(
                                '☕ MOLADA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final link = 'https://aydindabutaksi.com/indir.apk';
                            if (await canLaunchUrl(Uri.parse(link))) {
                              await launchUrl(Uri.parse(link));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.download, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            ref.read(userProvider.notifier).logout();
                            context.go('/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.logout, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab(0, 'DURUM'),
                _buildTab(1, 'PROFİL'),
                _buildTab(2, 'PAKET'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildStatusTab(user),
                _buildProfileTab(user),
                _buildPackagesTab(packages),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // STATUS TAB
  Widget _buildStatusTab(user) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Status Buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentStatus = 'available');
                  FirebaseService().updateDriverStatus(user.id, 'available');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _currentStatus == 'available'
                        ? AppColors.available
                        : Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _currentStatus == 'available'
                            ? Colors.white
                            : Colors.black,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MÜSAİT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentStatus == 'available'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentStatus = 'busy');
                  FirebaseService().updateDriverStatus(user.id, 'busy');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color:
                        _currentStatus == 'busy' ? AppColors.busy : Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.navigation,
                        color: _currentStatus == 'busy'
                            ? Colors.white
                            : Colors.black,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'DOLU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentStatus == 'busy'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() => _currentStatus = 'break');
            FirebaseService().updateDriverStatus(user.id, 'break');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _currentStatus == 'break' ? AppColors.break_ : Colors.white,
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.coffee,
                  color: _currentStatus == 'break'
                      ? Colors.white
                      : Colors.grey[500],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'MOLA VER (GİZLEN)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentStatus == 'break'
                        ? Colors.white
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Stats
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'PUAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${user.likes}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'BEĞENİ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // PROFILE TAB
  Widget _buildProfileTab(user) {
    final phoneCtrl = TextEditingController(text: user.phone);
    final passCtrl = TextEditingController(text: user.password);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bilgilerimi Düzenle',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefon No',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (phoneCtrl.text.isNotEmpty || passCtrl.text.isNotEmpty) {
                      final updatedDriver = user.copyWith(
                        phone: phoneCtrl.text,
                        password: passCtrl.text,
                      );
                      FirebaseService().updateDriver(user.id, updatedDriver);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil güncellendi')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'KAYDET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PACKAGES TAB
  Widget _buildPackagesTab(AsyncValue packages) {
    return packages.when(
      data: (packagesList) => ListView(
        padding: const EdgeInsets.all(20),
        children: packagesList.map<Widget>((pkg) {
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paket satın alma başlatılıyor...')),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: pkg.isPremium ? AppColors.primary : Colors.grey[300]!,
                  width: pkg.isPremium ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${pkg.name} ${pkg.isPremium ? '⭐' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${pkg.price} TL',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pkg.duration,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final whatsapp = 'https://wa.me/905555555555?text=Merhaba%20${pkg.name}%20paketini%20satın%20almak%20istiyorum';
                        if (await canLaunchUrl(Uri.parse(whatsapp))) {
                          await launchUrl(Uri.parse(whatsapp));
                        }
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('SATIN AL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.available,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }
}
