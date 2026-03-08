import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';

import 'package:taxi/models/driver_model.dart';
import 'package:taxi/models/package_model.dart';
import 'package:taxi/providers/auth_provider.dart';
import 'package:taxi/providers/driver_provider.dart';
import 'package:taxi/providers/package_provider.dart';
import 'package:taxi/services/firebase_service.dart';
import 'package:taxi/utils/district_coordinates.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  int _selectedTab = 0;

  // Settings tab controllers
  final _whatsappCtrl = TextEditingController();
  final _downloadCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _settingsLoaded = false;

  // Edit driver state
  Driver? _editingDriver;
  final _editPlateCtrl = TextEditingController();
  final _editPassCtrl = TextEditingController();
  final _editStandCtrl = TextEditingController();
  String _editDistrict = 'Efeler';
  bool _editIsPremium = false;

  // Package form state
  bool _pkgIsPremium = false;

  // Add driver form state
  bool _addIsPremium = false;

  /// Firebase'den gelen ilçe adını dropdown listesindeki doğru eşleşmeye çevir.
  String _findMatchingDistrict(String district) {
    if (district.isEmpty) return 'Efeler';
    final names = DistrictCoordinates.sortedDistrictNames;
    // Birebir eşleşme
    if (names.contains(district)) return district;
    // Case-insensitive eşleşme
    final lower = district.toLowerCase().trim();
    for (final name in names) {
      if (name.toLowerCase() == lower) return name;
    }
    return 'Efeler';
  }

  @override
  void dispose() {
    _whatsappCtrl.dispose();
    _downloadCtrl.dispose();
    _passwordCtrl.dispose();
    _editPlateCtrl.dispose();
    _editPassCtrl.dispose();
    _editStandCtrl.dispose();
    super.dispose();
  }

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
              'ADMİN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
          if (_editingDriver != null) ...[
            _buildEditDriverForm(),
            const SizedBox(height: 20),
          ] else ...[
            _buildAddDriverForm(),
            const SizedBox(height: 20),
          ],
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
    String selectedDistrict = 'Efeler';

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
            const SizedBox(height: 8),
            // İlçe seçici dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDistrict,
                  hint: const Text('İLÇE SEÇ', style: TextStyle(fontSize: 12)),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: DistrictCoordinates.sortedDistrictNames
                      .map(
                        (name) => DropdownMenuItem(
                          value: name,
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedDistrict = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (plateCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                    final coords = DistrictCoordinates.getCoordinatesOrDefault(
                      selectedDistrict,
                    );
                    final newDriver = Driver(
                      id: DateTime.now().toString(),
                      plate: plateCtrl.text.trim().toUpperCase(),
                      lat: coords.lat,
                      lng: coords.lng,
                      status: 'available',
                      taxiStand: standCtrl.text.trim().isEmpty
                          ? 'Merkez'
                          : standCtrl.text.trim(),
                      district: selectedDistrict,
                      phone: '',
                      isPremium: _addIsPremium,
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
    final isSuspended = driver.status == 'suspended';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEE)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    if (driver.isPremium || driver.isVip)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.premium.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.premium,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  driver.taxiStand,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // BAŞLAT / DURDUR butonu
          GestureDetector(
            onTap: () {
              final newStatus = isSuspended ? 'available' : 'suspended';
              FirebaseService().updateDriverStatus(driver.id, newStatus);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSuspended
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSuspended ? 'BAŞLAT' : 'DURDUR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSuspended ? AppColors.success : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Düzenle butonu
          GestureDetector(
            onTap: () {
              setState(() {
                _editingDriver = driver;
                _editPlateCtrl.text = driver.plate;
                _editPassCtrl.text = driver.password;
                _editStandCtrl.text = driver.taxiStand;
                _editDistrict = _findMatchingDistrict(driver.district);
                _editIsPremium = driver.isPremium || driver.isVip;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDriverForm() {
    return Container(
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
            'DÜZENLE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editPlateCtrl,
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
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _editPassCtrl,
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
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _editStandCtrl,
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
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          // İlçe dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _editDistrict,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: DistrictCoordinates.sortedDistrictNames
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _editDistrict = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Premium Üye checkbox
          GestureDetector(
            onTap: () => setState(() => _editIsPremium = !_editIsPremium),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _editIsPremium ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _editIsPremium ? AppColors.primary : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: _editIsPremium
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Premium Üye',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Güncelle ve İptal butonları
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_editingDriver == null) return;
                    final coords = DistrictCoordinates.getCoordinatesOrDefault(
                      _editDistrict,
                    );
                    final updated = _editingDriver!.copyWith(
                      plate: _editPlateCtrl.text.trim().toUpperCase(),
                      password: _editPassCtrl.text.trim(),
                      taxiStand: _editStandCtrl.text.trim(),
                      district: _editDistrict,
                      lat: coords.lat,
                      lng: coords.lng,
                      isPremium: _editIsPremium,
                      isVip: _editIsPremium,
                    );
                    FirebaseService().updateDriver(_editingDriver!.id, updated);
                    setState(() => _editingDriver = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Taksi güncellendi ✓'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'GÜNCELLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => setState(() => _editingDriver = null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
                child: const Text(
                  'İPTAL',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
    return const Center(child: Text('İstek yok'));
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
                ? [
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Henüz paket yok',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ]
                : packagesList.map((pkg) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: pkg.isPremium
                              ? AppColors.primary
                              : Colors.grey[300]!,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${pkg.price} TL / ${pkg.duration}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                FirebaseService().deletePackage(pkg.id),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red,
                              ),
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
            const SizedBox(height: 12),
            // Premium Üye checkbox
            GestureDetector(
              onTap: () => setState(() => _pkgIsPremium = !_pkgIsPremium),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _pkgIsPremium ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _pkgIsPremium ? AppColors.primary : Colors.grey,
                      ),
                    ),
                    child: _pkgIsPremium
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  const Text('Premium Üye', style: TextStyle(fontSize: 13)),
                ],
              ),
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
                    isPremium: _pkgIsPremium,
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
                child: Text(
                  _pkgIsPremium ? 'PREMIUM OLARAK EKLE' : 'PAKET EKLE',
                  style: const TextStyle(
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
    if (!_settingsLoaded) {
      _settingsLoaded = true;
      FirebaseService()
          .getSettings()
          .then((settings) {
            if (settings.whatsappNumber != null) {
              _whatsappCtrl.text = settings.whatsappNumber!;
            }

            if (settings.downloadLink != null) {
              _downloadCtrl.text = settings.downloadLink!;
            }

            if (mounted) setState(() {});
          })
          .catchError((_) {
            if (mounted) setState(() {});
          });
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // WhatsApp Linki
        _buildSettingsCard(
          icon: Icons.chat,
          title: 'WhatsApp Linki',
          controller: _whatsappCtrl,
          hint: '905XXXXXXXXX',
          keyboardType: TextInputType.phone,
          onSave: () {
            FirebaseService()
                .getSettings()
                .then((current) {
                  FirebaseService().updateSettings(
                    current.copyWith(whatsappNumber: _whatsappCtrl.text.trim()),
                  );
                })
                .catchError((e) {
                  debugPrint('WhatsApp kayıt hatası: $e');
                });
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
          controller: _downloadCtrl,
          hint: 'https://...',
          keyboardType: TextInputType.url,
          onSave: () {
            FirebaseService()
                .getSettings()
                .then((current) {
                  FirebaseService().updateSettings(
                    current.copyWith(downloadLink: _downloadCtrl.text.trim()),
                  );
                })
                .catchError((e) {
                  debugPrint('İndirme link kayıt hatası: $e');
                });
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
          controller: _passwordCtrl,
          hint: 'Değiştirmek için yeni şifre yaz',
          obscureText: true,
          onSave: () {
            if (_passwordCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifre boş olamaz'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            final newPass = _passwordCtrl.text.trim();
            FirebaseService()
                .getSettings()
                .then((current) {
                  FirebaseService().updateSettings(
                    current.copyWith(adminPassword: newPass),
                  );
                })
                .catchError((e) {
                  debugPrint('Admin şifre kayıt hatası: $e');
                });
            _passwordCtrl.clear();
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
                  horizontal: 12,
                  vertical: 10,
                ),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
