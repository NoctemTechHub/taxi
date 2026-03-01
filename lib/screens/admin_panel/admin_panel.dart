import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/l10n/app_localizations.dart';
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
                _buildTab(0, 'TAKSİ', Icons.taxi_alert),
                _buildTab(1, 'İSTEK', Icons.request_page),
                _buildTab(2, 'PAKET', Icons.card_giftcard),
                _buildTab(3, 'AYAR', Icons.tune),
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
    final phoneCtrl = TextEditingController();
    final standCtrl = TextEditingController();
    bool isPremium = false;

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
              'Hızlı Ekle',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      hintText: 'TEL',
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: isPremium,
                  onChanged: (v) => setState(() => isPremium = v ?? false),
                ),
                const Text('Premium Üye', style: TextStyle(fontSize: 12)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (plateCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                      final newDriver = Driver(
                        id: DateTime.now().toString(),
                        plate: plateCtrl.text.toUpperCase(),
                        lat: 37.8444,
                        lng: 27.8458,
                        status: 'available',
                        taxiStand: standCtrl.text.isEmpty ? 'Merkez' : standCtrl.text,
                        district: 'Efeler',
                        phone: phoneCtrl.text.isEmpty ? '0555...' : phoneCtrl.text,
                        isPremium: isPremium,
                        password: passCtrl.text,
                        likes: 0,
                      );
                      FirebaseService().addDriver(newDriver);
                      plateCtrl.clear();
                      passCtrl.clear();
                      phoneCtrl.clear();
                      standCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Taksi eklendi')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'KAYDET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
    return packages.when(
      data: (packagesList) => ListView(
        padding: const EdgeInsets.all(16),
        children: packagesList.map((pkg) {
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
            margin: const EdgeInsets.symmetric(vertical: 8),
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
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }

  // SETTINGS TAB
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ayarlar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Admin Şifresi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'WhatsApp Numarası',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'İndirme Linki',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ayarlar kaydedildi')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  child: const Text(
                    'KAYDET',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
