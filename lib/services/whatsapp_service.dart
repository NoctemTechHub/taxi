import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Opens WhatsApp with a message to the specified phone number
  /// [phoneNumber]: WhatsApp numarası (örn: "905555555555" veya "+905555555555")
  /// [message]: Gönderilecek mesaj
  /// [context]: BuildContext - hata mesajlarını göstermek için
  static Future<bool> openWhatsApp({
    required String phoneNumber,
    required String message,
    required BuildContext context,
  }) async {
    try {
      // Telefon numarasından tüm alfanümerik olmayan karakterleri kaldır
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      
      if (cleanNumber.isEmpty) {
        _showError(context, 'Geçersiz WhatsApp numarası');
        return false;
      }

      // Önce doğrudan WhatsApp uygulamasını aç (whatsapp:// şeması)
      final encodedMessage = Uri.encodeComponent(message);
      final directUri = Uri.parse('whatsapp://send?phone=$cleanNumber&text=$encodedMessage');

      if (await canLaunchUrl(directUri)) {
        await launchUrl(directUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // WhatsApp yüklü değilse hata göster
        _showError(context, 'WhatsApp açılamadı. Lütfen WhatsApp\'ın kurulu olduğundan emin olun.');
        return false;
      }
    } catch (e) {
      debugPrint('WhatsApp açılırken hata: $e');
      _showError(context, 'Hata: ${e.toString()}');
      return false;
    }
  }

  /// Belirli bir telefon numarasına mesaj gönder (taksi çağrısı)
  static Future<bool> sendTaxiMessage({
    required String whatsappNumber,
    required String taxiPlate,
    required BuildContext context,
  }) async {
    final message = 'Merhaba, $taxiPlate plakalı taksiye ihtiyacım var.';
    return openWhatsApp(
      phoneNumber: whatsappNumber,
      message: message,
      context: context,
    );
  }

  /// Taksi şoförü kaydetme mesajı gönder
  static Future<bool> sendDriverRegistrationMessage({
    required String whatsappNumber,
    required BuildContext context,
  }) async {
    const message = 'Merhaba, AydınDaBu Taksi sistemine taksi eklemek istiyorum.';
    return openWhatsApp(
      phoneNumber: whatsappNumber,
      message: message,
      context: context,
    );
  }

  /// Paket yükseltme mesajı gönder
  static Future<bool> sendPackageUpgradeMessage({
    required String whatsappNumber,
    required String taxiPlate,
    required String packageName,
    required BuildContext context,
  }) async {
    final message = 'Merhaba, $taxiPlate plakalı aracım için $packageName paketini talep ediyorum.';
    return openWhatsApp(
      phoneNumber: whatsappNumber,
      message: message,
      context: context,
    );
  }

  /// Hata mesajını göster
  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Başarı mesajını göster
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
