import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/l10n/app_localizations.dart';
import 'package:taxi/models/app_settings_model.dart';
import 'package:taxi/models/driver_model.dart';
import 'package:taxi/models/package_model.dart';
import 'package:taxi/providers/auth_provider.dart';
import 'package:taxi/providers/driver_provider.dart';
import 'package:taxi/providers/package_provider.dart';
import 'package:taxi/services/firebase_service.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final drivers = ref.watch(driverListProvider);
    final packages = ref.watch(packageListProvider);

    if (user == null || !user.isAdmin) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'ADMİN PANELİ',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              context.push('/login');
            },
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab(0, 'TAKSİLER', Icons.taxi_alert),
                _buildTab(1, 'İSTEKLER', Icons.request_page),
                _buildTab(2, 'PAKETLER', Icons.card_giftcard),
                _buildTab(3, 'AYARLAR', Icons.tune),
              ],
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildTaxisTab(drivers),
                _buildRequestsTab(),
                _buildPackagesTab(packages),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAXIS TAB
  Widget _buildTaxisTab(AsyncValue<List<Driver>> drivers) {
    return drivers.when(
      data: (driversList) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddDriverForm(),
          const SizedBox(height: 20),
          Text(
            'Kayıtlı Taksiler (${driversList.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...driversList.map((driver) => _buildDriverCard(driver)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }

  Widget _buildAddDriverForm() {
    final plateCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final standCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ekle',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              decoration: InputDecoration(
                hintText: 'PLAKA',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'ŞİFRE',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: standCtrl,
              decoration: InputDecoration(
                hintText: 'DURAK',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (plateCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                    final newDriver = Driver(
                      id: DateTime.now().toString(),
                      plate: plateCtrl.text.trim().toUpperCase(),
                      lat: 37.8444,
                      lng: 27.8458,
                      status: 'available',
                      taxiStand: standCtrl.text.trim().isEmpty ? 'Merkez' : standCtrl.text.trim(),
                      district: 'Efeler',
                      phone: '',
                      isPremium: false,
                      password: passCtrl.text.trim(),
                      likes: 0,
                    );
                    FirebaseService().addDriver(newDriver);
                    plateCtrl.clear();
                    passCtrl.clear();
                    standCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Taksi eklendi'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'EKLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.plate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (driver.isPremium)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('⭐'),
                      ),
                  ],
                ),
                Text(
                  '${driver.taxiStand} - ${driver.status}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => FirebaseService().deleteDriver(driver.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete, size: 16, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // REQUESTS TAB
  Widget _buildRequestsTab() {
    return const Center(
      child: Text('İstek yok'),
    );
  }

  // PACKAGES TAB
  Widget _buildPackagesTab(AsyncValue<List<TaxiPackage>> packages) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAddPackageForm(),
        const SizedBox(height: 20),
        const Text(
          'Mevcut Paketler',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        packages.when(
          data: (packagesList) => Column(
            children: packagesList.isEmpty
                ? [const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Henüz paket yok', style: TextStyle(color: Colors.grey)),
                  )]
                : packagesList.map((pkg) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: pkg.isPremium ? AppColors.primary : Colors.grey[300]!,
                          width: pkg.isPremium ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pkg.name} ${pkg.isPremium ? '⭐' : ''}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${pkg.price} TL / ${pkg.duration}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => FirebaseService().deletePackage(pkg.id),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.delete, size: 16, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Hata: $e')),
        ),
      ],
    );
  }

  Widget _buildAddPackageForm() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paket Ekle',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Paket Adı',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Fiyat (TL)',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Süre (Ay)',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = priceCtrl.text.trim();
                  final duration = durationCtrl.text.trim();

                  if (name.isEmpty || price.isEmpty || duration.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tüm alanları doldurun'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final pkg = TaxiPackage(
                    id: '',
                    name: name,
                    price: price,
                    duration: '$duration Ay',
                    isPremium: false,
                  );
                  FirebaseService().addPackage(pkg);
                  nameCtrl.clear();
                  priceCtrl.clear();
                  durationCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paket eklendi'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'EKLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SETTINGS TAB
  Widget _buildSettingsTab() {
    final whatsappCtrl = TextEditingController();
    final downloadCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool isLoading = true;

    return StatefulBuilder(
      builder: (context, setState) {
        // Mevcut ayarları yükle
        if (isLoading) {
          FirebaseService().getSettings().then((settings) {
            whatsappCtrl.text = settings.whatsappNumber;
            downloadCtrl.text = settings.downloadLink;
            setState(() => isLoading = false);
          }).catchError((_) {
            setState(() => isLoading = false);
          });
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // WhatsApp Linki
            _buildSettingsCard(
              icon: Icons.chat,
              title: 'WhatsApp Linki',
              controller: whatsappCtrl,
              hint: '905XXXXXXXXX',
              keyboardType: TextInputType.phone,
              onSave: () {
                FirebaseService().getSettings().then((current) {
                  FirebaseService().updateSettings(
                    current.copyWith(whatsappNumber: whatsappCtrl.text.trim()),
                  );
                }).catchError((e) => debugPrint('WhatsApp kayıt hatası: $e'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('WhatsApp linki güncellendi ✓'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // Uygulama İndirme Linki
            _buildSettingsCard(
              icon: Icons.download,
              title: 'Uygulama İndirme Linki',
              controller: downloadCtrl,
              hint: 'https://...',
              keyboardType: TextInputType.url,
              onSave: () {
                FirebaseService().getSettings().then((current) {
                  FirebaseService().updateSettings(
                    current.copyWith(downloadLink: downloadCtrl.text.trim()),
                  );
                }).catchError((e) => debugPrint('İndirme link kayıt hatası: $e'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('İndirme linki güncellendi ✓'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // Admin Şifresi
            _buildSettingsCard(
              icon: Icons.lock,
              title: 'Admin Şifresi',
              controller: passwordCtrl,
              hint: 'Değiştirmek için yeni şifre yaz',
              obscureText: true,
              onSave: () {
                if (passwordCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Şifre boş olamaz'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                final newPass = passwordCtrl.text.trim();
                FirebaseService().getSettings().then((current) {
                  FirebaseService().updateSettings(
                    current.copyWith(adminPassword: newPass),
                  );
                }).catchError((e) => debugPrint('Admin şifre kayıt hatası: $e'));
                passwordCtrl.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin şifresi güncellendi ✓'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSave,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    bool isSaving = false;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () {
                        setState(() => isSaving = true);
                        onSave();
                        Future.delayed(const Duration(milliseconds: 400), () {
                          if (context.mounted) {
                            setState(() => isSaving = false);
                          }
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'KAYDET',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
