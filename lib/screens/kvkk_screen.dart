import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi/config/app_colors.dart';

class KvkkScreen extends StatelessWidget {
  const KvkkScreen({Key? key}) : super(key: key);

  static const String _kvkkAcceptedKey = 'kvkk_accepted';


  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kvkkAcceptedKey) ?? false;
  }

  static Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kvkkAcceptedKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
              ),
              child: const Column(
                children: [
                  Text('🚖', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text(
                    'AydınDaBu TAKSİ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kişisel Verilerin İşlenmesi Aydınlatma Metni',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // KVKK Text
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _kvkkText,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Accept Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await accept();
                    if (context.mounted) {
                      context.go('/map');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OKUDUM, KABUL EDİYORUM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

const String _kvkkText = '''Aydindabu Taksi Uygulaması Kişisel Verilerin İşlenmesi Aydınlatma Metni (KVKK)

Veri Sorumlusu: Aydindabu.com

Değerli Kullanıcımız,

Aydindabu.com olarak, Aydın ve ilçelerinde (Efeler, Kuşadası, Didim, Söke vd.) güvenli ve konforlu bir ulaşım deneyimi yaşamanız için geliştirdiğimiz taksi uygulamamızı kullanırken paylaştığınız kişisel verilerinizin güvenliği bizim için çok önemlidir. 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında, verilerinizi nasıl işlediğimizi aşağıda bilgilerinize sunuyoruz.

1. Hangi Kişisel Verilerinizi İşliyoruz?

• Kimlik ve İletişim Bilgileriniz: Adınız, soyadınız, telefon numaranız ve e-posta adresiniz (Sürücü ile iletişimi sağlamak ve hesap oluşturmak için).
• Konum Bilgileriniz: GPS üzerinden alınan anlık konum verileriniz (Size en yakın taksiyi yönlendirmek ve yolculuk rotasını takip etmek için).
• İşlem Güvenliği ve Finansal Bilgiler: Uygulama içi ödeme yapmanız durumunda, kredi kartı bilgileriniz (yalnızca yetkili ödeme kuruluşları tarafından şifrelenerek işlenir, sunucularımızda saklanmaz) ve yolculuk geçmişiniz.

2. Kişisel Verilerinizi Hangi Amaçlarla İşliyoruz?

• Ulaşım hizmetinin (taksi çağırma, eşleştirme, rota oluşturma) eksiksiz ve güvenli bir şekilde yerine getirilmesi.
• Yolcu ve sürücü güvenliğinin sağlanması.
• Hizmet kalitemizi artırmak amacıyla müşteri destek süreçlerinin yürütülmesi ve şikayetlerin çözümlenmesi.
• Yasal yükümlülüklerimizin (örneğin; yetkili kamu kurumlarının bilgi talepleri) yerine getirilmesi.

3. Kişisel Verilerinizi Kimlere ve Hangi Amaçla Aktarıyoruz?

• Sürücüler: Yolculuğun gerçekleşebilmesi için anlık konumunuz, adınız ve gerekirse telefon numaranız yalnızca o an eşleştiğiniz taksi sürücüsü ile paylaşılır.
• İş Ortakları: Uygulama içi ödeme altyapısı için BDDK lisanslı ödeme kuruluşlarıyla.
• Yetkili Kurumlar: Yasal bir zorunluluk olması halinde, adli makamlar veya ilgili emniyet birimleriyle.

4. Veri Toplama Yöntemi ve Hukuki Sebebi

Kişisel verileriniz, uygulamamızı cihazınıza indirip hesap oluşturduğunuzda, uygulamayı kullandığınızda (konum erişim izni vb.) elektronik ortamda otomatik olarak toplanmaktadır. Bu veriler, KVKK Madde 5'te yer alan "bir sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması", "veri sorumlusunun hukuki yükümlülüğünü yerine getirebilmesi" ve "ilgili kişinin temel hak ve özgürlüklerine zarar vermemek kaydıyla, veri sorumlusunun meşru menfaatleri için veri işlenmesinin zorunlu olması" hukuki sebeplerine dayanılarak işlenmektedir.

5. KVKK Kapsamındaki Haklarınız

KVKK'nın 11. maddesi uyarınca; verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, eksik/yanlış işlenmişse düzeltilmesini isteme, silinmesini talep etme gibi haklara sahipsiniz. Taleplerinizi info@aydindabu.com adresi üzerinden bize her zaman iletebilirsiniz.

Bu metni okuduğunuz ve Aydın sokaklarını bizimle keşfettiğiniz için teşekkür ederiz!''';
