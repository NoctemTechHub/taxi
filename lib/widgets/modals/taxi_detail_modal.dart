import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/l10n/app_localizations.dart';
import 'package:taxi/models/driver_model.dart';
import 'package:taxi/providers/settings_provider.dart';

class TaxiDetailModal extends ConsumerWidget {
  final Driver driver;
  final VoidCallback onClose;

  const TaxiDetailModal({
    Key? key,
    required this.driver,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taksi Detayları',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoRow(
                    'Plaka',
                    driver.plate,
                    Icons.directions_car,
                  ),
                  _buildInfoRow(
                    'Telefon',
                    driver.phone,
                    Icons.phone,
                  ),
                  _buildInfoRow(
                    'Stand',
                    driver.taxiStand,
                    Icons.location_on,
                  ),
                  _buildInfoRow(
                    'İlçe',
                    driver.district,
                    Icons.map,
                  ),
                  _buildInfoRow(
                    'Beğeni',
                    '${driver.likes}',
                    Icons.favorite,
                  ),
                  if (driver.isPremium)
                    _buildInfoRow(
                      'Paket',
                      'Premium',
                      Icons.star,
                      color: AppColors.premium,
                    ),
                  
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(driver.status).withOpacity(0.1),
                      border: Border.all(
                        color: _getStatusColor(driver.status),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Durum: ${_getStatusText(driver.status)}',
                      style: TextStyle(
                        color: _getStatusColor(driver.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _callDriver(driver.phone),
                          icon: const Icon(Icons.phone),
                          label: const Text('Ara'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: settings.when(
                          data: (settingsData) => ElevatedButton.icon(
                            onPressed: () => _openWhatsApp(
                              settingsData.whatsappNumber,
                              driver.plate,
                            ),
                            icon: const Icon(Icons.message),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                          loading: () => const SizedBox(
                            height: 40,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          error: (error, stackTrace) => ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.message),
                            label: const Text('WhatsApp'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color color = AppColors.secondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.available;
      case 'busy':
        return AppColors.busy;
      case 'break':
        return AppColors.break_;
      default:
        return AppColors.darkGray;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return AppStrings.musait;
      case 'busy':
        return AppStrings.dolu;
      case 'break':
        return AppStrings.mola;
      default:
        return status;
    }
  }

  Future<void> _callDriver(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error calling: $e');
    }
  }

  Future<void> _openWhatsApp(String whatsappNumber, String plate) async {
    try {
      final message =
          'Merhaba, $plate plakalı taksiye ihtiyacım var.';
      final uri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: '/$whatsappNumber',
        queryParameters: {'text': message},
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
    }
  }
}
