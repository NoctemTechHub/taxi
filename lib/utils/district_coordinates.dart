import 'package:taxi/config/app_constants.dart';

/// Türkiye ilçe / şehir merkez koordinatları.
///
/// Her ilçe/ilçe-il çifti için yaklaşık merkez enlem-boylam değerleri tutulur.
/// Admin panelinden taksi eklerken seçilen ilçeye göre doğru konum atanır.
class DistrictCoordinates {
  DistrictCoordinates._();

  /// İlçe adı → (lat, lng)
  static const Map<String, ({double lat, double lng})> districts = {
    // ─── AYDIN ──────────────────────────────────────────────────────
    'Efeler': (lat: 37.8444, lng: 27.8458),
    'Nazilli': (lat: 37.9137, lng: 28.3214),
    'Söke': (lat: 37.7513, lng: 27.4103),
    'Kuşadası': (lat: 37.8579, lng: 27.2610),
    'Didim': (lat: 37.3753, lng: 27.2684),
    'İncirliova': (lat: 37.8519, lng: 27.7233),
    'Germencik': (lat: 37.8714, lng: 27.5973),
    'Çine': (lat: 37.6137, lng: 28.0628),
    'Bozdoğan': (lat: 37.6725, lng: 28.3117),
    'Karacasu': (lat: 37.7247, lng: 28.5967),
    'Koçarlı': (lat: 37.7625, lng: 27.7014),
    'Sultanhisar': (lat: 37.8891, lng: 28.1603),
    'Yenipazar': (lat: 37.8256, lng: 28.1953),
    'Buharkent': (lat: 37.9636, lng: 28.7444),
    'Karpuzlu': (lat: 37.5614, lng: 27.8356),
    'Köşk': (lat: 37.8544, lng: 27.9522),

    // ─── ANKARA ─────────────────────────────────────────────────────
    'Çankaya': (lat: 39.9000, lng: 32.8597),
    'Keçiören': (lat: 39.9833, lng: 32.8667),
    'Mamak': (lat: 39.9253, lng: 32.9139),
    'Yenimahalle': (lat: 39.9667, lng: 32.8100),
    'Etimesgut': (lat: 39.9500, lng: 32.6667),
    'Sincan': (lat: 39.9697, lng: 32.5833),
    'Altındağ': (lat: 39.9606, lng: 32.8694),
    'Pursaklar': (lat: 40.0333, lng: 32.8833),
    'Gölbaşı (Ankara)': (lat: 39.7833, lng: 32.8000),
    'Polatlı': (lat: 39.5833, lng: 32.1500),
    'Çubuk': (lat: 40.2333, lng: 33.0333),
    'Beypazarı': (lat: 40.1667, lng: 31.9167),

    // ─── İSTANBUL ───────────────────────────────────────────────────
    'Kadıköy': (lat: 40.9928, lng: 29.0230),
    'Beşiktaş': (lat: 41.0422, lng: 29.0083),
    'Üsküdar': (lat: 41.0250, lng: 29.0153),
    'Fatih': (lat: 41.0186, lng: 28.9397),
    'Beyoğlu': (lat: 41.0370, lng: 28.9770),
    'Şişli': (lat: 41.0600, lng: 28.9870),
    'Bakırköy': (lat: 40.9800, lng: 28.8770),
    'Ataşehir': (lat: 40.9833, lng: 29.1167),
    'Maltepe': (lat: 40.9333, lng: 29.1333),
    'Pendik': (lat: 40.8750, lng: 29.2333),
    'Kartal': (lat: 40.8900, lng: 29.1880),
    'Sultanbeyli': (lat: 40.9667, lng: 29.2667),
    'Tuzla': (lat: 40.8167, lng: 29.3000),
    'Sarıyer': (lat: 41.1667, lng: 29.0500),
    'Beylikdüzü': (lat: 40.9833, lng: 28.6333),
    'Esenyurt': (lat: 41.0333, lng: 28.6833),
    'Başakşehir': (lat: 41.0833, lng: 28.8000),
    'Bağcılar': (lat: 41.0333, lng: 28.8500),
    'Küçükçekmece': (lat: 41.0000, lng: 28.7833),
    'Esenler': (lat: 41.0500, lng: 28.8833),
    'Bayrampaşa': (lat: 41.0500, lng: 28.9000),
    'Güngören': (lat: 41.0167, lng: 28.8833),
    'Zeytinburnu': (lat: 41.0000, lng: 28.9000),
    'Avcılar': (lat: 40.9833, lng: 28.7167),
    'Büyükçekmece': (lat: 41.0167, lng: 28.5833),
    'Çatalca': (lat: 41.1333, lng: 28.4667),
    'Silivri': (lat: 41.0833, lng: 28.2500),
    'Arnavutköy': (lat: 41.1833, lng: 28.7333),
    'Çekmeköy': (lat: 41.0333, lng: 29.1833),
    'Sancaktepe': (lat: 41.0000, lng: 29.2333),
    'Sultangazİ': (lat: 41.1000, lng: 28.8667),
    'Gaziosmanpaşa': (lat: 41.0667, lng: 28.9167),
    'Eyüpsultan': (lat: 41.0500, lng: 28.9333),
    'Kağıthane': (lat: 41.0833, lng: 28.9667),
    'Beykoz': (lat: 41.1167, lng: 29.1000),
    'Şile': (lat: 41.1833, lng: 29.6167),
    'Adalar': (lat: 40.8667, lng: 29.0833),
    'Ümraniye': (lat: 41.0167, lng: 29.1167),
    'Bahçelievler': (lat: 41.0000, lng: 28.8500),

    // ─── İZMİR ──────────────────────────────────────────────────────
    'Konak': (lat: 38.4189, lng: 27.1287),
    'Bornova': (lat: 38.4667, lng: 27.2167),
    'Karşıyaka': (lat: 38.4600, lng: 27.1100),
    'Buca': (lat: 38.3833, lng: 27.1667),
    'Bayraklı': (lat: 38.4667, lng: 27.1667),
    'Çiğli': (lat: 38.5000, lng: 27.0833),
    'Gaziemir': (lat: 38.3167, lng: 27.1333),
    'Balçova': (lat: 38.3833, lng: 27.0333),
    'Narlıdere': (lat: 38.3833, lng: 26.9500),
    'Karabağlar': (lat: 38.3833, lng: 27.1167),
    'Menemen': (lat: 38.6000, lng: 27.0667),
    'Torbalı': (lat: 38.1500, lng: 27.3667),
    'Ödemiş': (lat: 38.2333, lng: 27.9667),
    'Bergama': (lat: 39.1167, lng: 27.1833),
    'Aliağa': (lat: 38.8000, lng: 26.9667),
    'Tire': (lat: 38.0833, lng: 27.7333),
    'Seferihisar': (lat: 38.2000, lng: 26.8333),
    'Urla': (lat: 38.3167, lng: 26.7667),
    'Çeşme': (lat: 38.3200, lng: 26.3000),
    'Dikili': (lat: 39.0667, lng: 26.8833),
    'Foça': (lat: 38.6667, lng: 26.7500),
    'Kemalpaşa': (lat: 38.4333, lng: 27.4167),
    'Kiraz': (lat: 38.2167, lng: 28.2000),
    'Selçuk': (lat: 37.9500, lng: 27.3667),

    // ─── BURSA ──────────────────────────────────────────────────────
    'Osmangazi': (lat: 40.1833, lng: 29.0667),
    'Nilüfer': (lat: 40.2167, lng: 28.9833),
    'Yıldırım': (lat: 40.1833, lng: 29.0833),
    'Mudanya': (lat: 40.3833, lng: 28.8833),
    'Gemlik': (lat: 40.4333, lng: 29.1500),
    'İnegöl': (lat: 40.0833, lng: 29.5167),

    // ─── ANTALYA ────────────────────────────────────────────────────
    'Muratpaşa': (lat: 36.8833, lng: 30.7000),
    'Konyaaltı': (lat: 36.8667, lng: 30.6333),
    'Kepez': (lat: 36.9333, lng: 30.7000),
    'Aksu': (lat: 36.9333, lng: 30.8333),
    'Döşemealtı': (lat: 37.0500, lng: 30.5833),
    'Alanya': (lat: 36.5500, lng: 32.0000),
    'Manavgat': (lat: 36.7833, lng: 31.4333),
    'Serik': (lat: 36.9167, lng: 31.1000),
    'Kemer': (lat: 36.5833, lng: 30.5667),
    'Kaş': (lat: 36.2000, lng: 29.6333),

    // ─── ADANA ──────────────────────────────────────────────────────
    'Seyhan': (lat: 37.0000, lng: 35.3213),
    'Yüreğir': (lat: 36.9833, lng: 35.3833),
    'Çukurova': (lat: 37.0167, lng: 35.3667),
    'Sarıçam': (lat: 37.0500, lng: 35.4500),
    'Ceyhan': (lat: 37.0333, lng: 35.8167),
    'Kozan': (lat: 37.4500, lng: 35.8167),

    // ─── GAZİANTEP ──────────────────────────────────────────────────
    'Şahinbey': (lat: 37.0500, lng: 37.3833),
    'Şehitkamil': (lat: 37.0833, lng: 37.3500),
    'Nizip': (lat: 37.0167, lng: 37.8000),
    'İslahiye': (lat: 37.0167, lng: 36.6167),

    // ─── KONYA ──────────────────────────────────────────────────────
    'Selçuklu': (lat: 37.8833, lng: 32.4833),
    'Meram': (lat: 37.8500, lng: 32.4333),
    'Karatay': (lat: 37.8833, lng: 32.5000),
    'Ereğli (Konya)': (lat: 37.5167, lng: 34.0500),
    'Akşehir': (lat: 38.3500, lng: 31.4167),

    // ─── MERSİN ─────────────────────────────────────────────────────
    'Yenişehir (Mersin)': (lat: 36.8000, lng: 34.6333),
    'Toroslar': (lat: 36.8167, lng: 34.6167),
    'Akdeniz': (lat: 36.8000, lng: 34.5833),
    'Mezitli': (lat: 36.7667, lng: 34.5500),
    'Tarsus': (lat: 36.9167, lng: 34.8833),
    'Erdemli': (lat: 36.6167, lng: 34.3000),
    'Silifke': (lat: 36.3833, lng: 33.9333),

    // ─── MUĞLA ──────────────────────────────────────────────────────
    'Menteşe': (lat: 37.2167, lng: 28.3667),
    'Bodrum': (lat: 37.0344, lng: 27.4305),
    'Fethiye': (lat: 36.6500, lng: 29.1167),
    'Marmaris': (lat: 36.8500, lng: 28.2667),
    'Milas': (lat: 37.3167, lng: 27.7833),
    'Dalaman': (lat: 36.7667, lng: 28.8000),
    'Köyceğiz': (lat: 36.9667, lng: 28.6833),
    'Datça': (lat: 36.7333, lng: 27.6833),
    'Ortaca': (lat: 36.8333, lng: 28.7667),
    'Seydikemer': (lat: 36.6333, lng: 29.3500),
    'Ula': (lat: 37.1000, lng: 28.4167),
    'Yatağan': (lat: 37.3500, lng: 28.1333),
    'Kavaklıdere': (lat: 37.4333, lng: 28.3667),

    // ─── DENİZLİ ────────────────────────────────────────────────────
    'Merkezefendi': (lat: 37.7833, lng: 29.1000),
    'Pamukkale': (lat: 37.7500, lng: 29.1167),
    'Çivril': (lat: 38.3000, lng: 29.7333),
    'Acıpayam': (lat: 37.4167, lng: 29.3500),

    // ─── KAYSERİ ────────────────────────────────────────────────────
    'Melikgazi': (lat: 38.7167, lng: 35.5000),
    'Kocasinan': (lat: 38.7500, lng: 35.4833),
    'Talas': (lat: 38.6833, lng: 35.5500),
    'Develi': (lat: 38.3833, lng: 35.4833),

    // ─── ESKİŞEHİR ─────────────────────────────────────────────────
    'Odunpazarı': (lat: 39.7667, lng: 30.5167),
    'Tepebaşı': (lat: 39.7833, lng: 30.5000),

    // ─── TRABZON ────────────────────────────────────────────────────
    'Ortahisar': (lat: 41.0027, lng: 39.7168),
    'Akçaabat': (lat: 41.0167, lng: 39.5667),
    'Of': (lat: 40.9500, lng: 40.2667),
    'Araklı': (lat: 40.9333, lng: 40.0667),

    // ─── SAMSUN ─────────────────────────────────────────────────────
    'İlkadım': (lat: 41.2867, lng: 36.3300),
    'Atakum': (lat: 41.3333, lng: 36.2167),
    'Canik': (lat: 41.2667, lng: 36.3500),
    'Tekkeköy': (lat: 41.2167, lng: 36.4667),
    'Bafra': (lat: 41.5667, lng: 35.9000),
    'Çarşamba': (lat: 41.2000, lng: 36.7167),

    // ─── DİYARBAKIR ─────────────────────────────────────────────────
    'Bağlar': (lat: 37.9167, lng: 40.2167),
    'Kayapınar': (lat: 37.9333, lng: 40.1667),
    'Yenişehir (Diyarbakır)': (lat: 37.9167, lng: 40.2333),
    'Sur': (lat: 37.9167, lng: 40.2333),

    // ─── ERZURUM ────────────────────────────────────────────────────
    'Yakutiye': (lat: 39.9000, lng: 41.2667),
    'Palandöken': (lat: 39.8833, lng: 41.2500),
    'Aziziye': (lat: 39.9167, lng: 41.1333),

    // ─── ŞANLIURFA ──────────────────────────────────────────────────
    'Eyyübiye': (lat: 37.1500, lng: 38.7833),
    'Haliliye': (lat: 37.1500, lng: 38.7833),
    'Karaköprü': (lat: 37.2000, lng: 38.7667),
    'Siverek': (lat: 37.7500, lng: 39.3167),
    'Viranşehir': (lat: 37.2333, lng: 39.7667),

    // ─── MANİSA ─────────────────────────────────────────────────────
    'Yunusemre': (lat: 38.6167, lng: 27.4167),
    'Şehzadeler': (lat: 38.6167, lng: 27.4333),
    'Akhisar': (lat: 38.9167, lng: 27.8333),
    'Turgutlu': (lat: 38.5000, lng: 27.7000),
    'Salihli': (lat: 38.4833, lng: 28.1333),
    'Soma': (lat: 39.1833, lng: 27.6000),

    // ─── MALATYA ────────────────────────────────────────────────────
    'Battalgazi': (lat: 38.4000, lng: 38.3167),
    'Yeşilyurt (Malatya)': (lat: 38.3167, lng: 38.2500),

    // ─── VAN ────────────────────────────────────────────────────────
    'İpekyolu': (lat: 38.5000, lng: 43.3833),
    'Tuşba': (lat: 38.5167, lng: 43.4167),
    'Edremit (Van)': (lat: 38.4167, lng: 43.3000),
    'Erciş': (lat: 39.0167, lng: 43.3667),

    // ─── TEKİRDAĞ ───────────────────────────────────────────────────
    'Süleymanpaşa': (lat: 41.0000, lng: 27.5167),
    'Çorlu': (lat: 41.1500, lng: 27.8000),
    'Çerkezköy': (lat: 41.2833, lng: 28.0000),
    'Ergene': (lat: 41.2833, lng: 27.9000),
    'Kapaklı': (lat: 41.3333, lng: 28.0333),

    // ─── SAKARYA ────────────────────────────────────────────────────
    'Adapazarı': (lat: 40.6667, lng: 30.4000),
    'Serdivan': (lat: 40.7000, lng: 30.3500),
    'Erenler': (lat: 40.6833, lng: 30.3833),
    'Arifiye': (lat: 40.7167, lng: 30.3667),

    // ─── KOCAELİ ────────────────────────────────────────────────────
    'İzmit': (lat: 40.7667, lng: 29.9167),
    'Gebze': (lat: 40.8000, lng: 29.4333),
    'Darıca': (lat: 40.7667, lng: 29.3833),
    'Gölcük': (lat: 40.7167, lng: 29.8333),
    'Körfez': (lat: 40.7500, lng: 29.7667),
    'Derince': (lat: 40.7500, lng: 29.8333),
    'Kartepe': (lat: 40.6833, lng: 30.0333),
    'Başiskele': (lat: 40.7167, lng: 29.9333),
    'Çayırova': (lat: 40.8167, lng: 29.3833),
    'Dilovası': (lat: 40.7833, lng: 29.5333),

    // ─── HATAY ──────────────────────────────────────────────────────
    'Antakya': (lat: 36.2000, lng: 36.1500),
    'İskenderun': (lat: 36.5833, lng: 36.1667),
    'Defne': (lat: 36.1833, lng: 36.1667),
    'Dörtyol': (lat: 36.8500, lng: 36.2167),

    // ─── BALIKESİR ──────────────────────────────────────────────────
    'Altıeylül': (lat: 39.6500, lng: 27.8833),
    'Karesi': (lat: 39.6500, lng: 27.8833),
    'Bandırma': (lat: 40.3500, lng: 27.9667),
    'Edremit (Balıkesir)': (lat: 39.5833, lng: 27.0167),
    'Gönen': (lat: 40.1000, lng: 27.6500),

    // ─── DÜZCE ──────────────────────────────────────────────────────
    'Düzce Merkez': (lat: 40.8389, lng: 31.1639),

    // ─── BOLU ───────────────────────────────────────────────────────
    'Bolu Merkez': (lat: 40.7333, lng: 31.6167),

    // ─── ZONGULDAK ──────────────────────────────────────────────────
    'Zonguldak Merkez': (lat: 41.4500, lng: 31.8000),
    'Ereğli (Zonguldak)': (lat: 41.2833, lng: 31.4167),
    'Çaycuma': (lat: 41.4333, lng: 32.0833),

    // ─── KASTAMONU ──────────────────────────────────────────────────
    'Kastamonu Merkez': (lat: 41.3833, lng: 33.7833),

    // ─── ÇANAKKALE ──────────────────────────────────────────────────
    'Çanakkale Merkez': (lat: 40.1553, lng: 26.4142),

    // ─── SİVAS ──────────────────────────────────────────────────────
    'Sivas Merkez': (lat: 39.7500, lng: 37.0167),

    // ─── TOKAT ──────────────────────────────────────────────────────
    'Tokat Merkez': (lat: 40.3167, lng: 36.5500),

    // ─── AMASYA ─────────────────────────────────────────────────────
    'Amasya Merkez': (lat: 40.6500, lng: 35.8333),

    // ─── ÇORUM ──────────────────────────────────────────────────────
    'Çorum Merkez': (lat: 40.5500, lng: 34.9500),

    // ─── YOZGAT ─────────────────────────────────────────────────────
    'Yozgat Merkez': (lat: 39.8167, lng: 34.8000),

    // ─── KIRŞEHİR ──────────────────────────────────────────────────
    'Kırşehir Merkez': (lat: 39.1500, lng: 34.1667),

    // ─── NEVŞEHİR ──────────────────────────────────────────────────
    'Nevşehir Merkez': (lat: 38.6333, lng: 34.7167),

    // ─── NİĞDE ──────────────────────────────────────────────────────
    'Niğde Merkez': (lat: 37.9667, lng: 34.6833),

    // ─── AKSARAY ────────────────────────────────────────────────────
    'Aksaray Merkez': (lat: 38.3667, lng: 34.0333),

    // ─── KARAMAN ────────────────────────────────────────────────────
    'Karaman Merkez': (lat: 37.1833, lng: 33.2167),

    // ─── ISPARTA ────────────────────────────────────────────────────
    'Isparta Merkez': (lat: 37.7667, lng: 30.5500),

    // ─── BURDUR ─────────────────────────────────────────────────────
    'Burdur Merkez': (lat: 37.7167, lng: 30.2833),

    // ─── AFYON ──────────────────────────────────────────────────────
    'Afyon Merkez': (lat: 38.7333, lng: 30.5333),

    // ─── KÜTAHYA ────────────────────────────────────────────────────
    'Kütahya Merkez': (lat: 39.4167, lng: 29.9833),

    // ─── BİLECİK ────────────────────────────────────────────────────
    'Bilecik Merkez': (lat: 40.0500, lng: 30.0000),

    // ─── EDİRNE ─────────────────────────────────────────────────────
    'Edirne Merkez': (lat: 41.6667, lng: 26.5500),

    // ─── KIRKLARELİ ─────────────────────────────────────────────────
    'Kırklareli Merkez': (lat: 41.7333, lng: 27.2167),

    // ─── OSMANİYE ───────────────────────────────────────────────────
    'Osmaniye Merkez': (lat: 37.0667, lng: 36.2500),

    // ─── KAHRAMANMARAŞ ──────────────────────────────────────────────
    'Onikişubat': (lat: 37.5833, lng: 36.9333),
    'Dulkadiroğlu': (lat: 37.5833, lng: 36.9167),

    // ─── ADIYAMAN ───────────────────────────────────────────────────
    'Adıyaman Merkez': (lat: 37.7667, lng: 38.2833),

    // ─── MARDİN ─────────────────────────────────────────────────────
    'Artuklu': (lat: 37.3167, lng: 40.7333),
    'Kızıltepe': (lat: 37.1833, lng: 40.5667),
    'Nusaybin': (lat: 37.0667, lng: 41.2167),
    'Midyat': (lat: 37.4167, lng: 41.3333),

    // ─── BATMAN ─────────────────────────────────────────────────────
    'Batman Merkez': (lat: 37.8833, lng: 41.1333),

    // ─── ŞIRNAK ─────────────────────────────────────────────────────
    'Şırnak Merkez': (lat: 37.4167, lng: 42.4500),
    'Cizre': (lat: 37.3333, lng: 42.2000),
    'Silopi': (lat: 37.2500, lng: 42.4667),

    // ─── SİİRT ──────────────────────────────────────────────────────
    'Siirt Merkez': (lat: 37.9333, lng: 41.9333),

    // ─── BİTLİS ─────────────────────────────────────────────────────
    'Bitlis Merkez': (lat: 38.4000, lng: 42.1167),
    'Tatvan': (lat: 38.5000, lng: 42.2833),

    // ─── MUŞ ────────────────────────────────────────────────────────
    'Muş Merkez': (lat: 38.7333, lng: 41.5000),

    // ─── HAKKARİ ────────────────────────────────────────────────────
    'Hakkari Merkez': (lat: 37.5833, lng: 43.7333),

    // ─── AĞRI ───────────────────────────────────────────────────────
    'Ağrı Merkez': (lat: 39.7167, lng: 43.0500),
    'Doğubayazıt': (lat: 39.7167, lng: 44.0833),
    'Patnos': (lat: 39.2333, lng: 43.3000),

    // ─── IĞDIR ──────────────────────────────────────────────────────
    'Iğdır Merkez': (lat: 39.9167, lng: 44.0500),

    // ─── KARS ───────────────────────────────────────────────────────
    'Kars Merkez': (lat: 40.6000, lng: 43.1000),

    // ─── ARDAHAN ────────────────────────────────────────────────────
    'Ardahan Merkez': (lat: 41.1167, lng: 42.7000),

    // ─── ARTVİN ─────────────────────────────────────────────────────
    'Artvin Merkez': (lat: 41.1833, lng: 41.8167),

    // ─── RİZE ───────────────────────────────────────────────────────
    'Rize Merkez': (lat: 41.0167, lng: 40.5167),

    // ─── GİRESUN ────────────────────────────────────────────────────
    'Giresun Merkez': (lat: 40.9167, lng: 38.3833),

    // ─── ORDU ───────────────────────────────────────────────────────
    'Altınordu': (lat: 41.0000, lng: 37.8833),

    // ─── SİNOP ──────────────────────────────────────────────────────
    'Sinop Merkez': (lat: 42.0167, lng: 35.1500),

    // ─── BARTIN ─────────────────────────────────────────────────────
    'Bartın Merkez': (lat: 41.6333, lng: 32.3333),

    // ─── KARABÜK ────────────────────────────────────────────────────
    'Karabük Merkez': (lat: 41.2000, lng: 32.6167),
    'Safranbolu': (lat: 41.2500, lng: 32.6833),

    // ─── ÇANKIRI ────────────────────────────────────────────────────
    'Çankırı Merkez': (lat: 40.6000, lng: 33.6167),

    // ─── KIRIKKALE ──────────────────────────────────────────────────
    'Kırıkkale Merkez': (lat: 39.8500, lng: 33.5167),

    // ─── UŞAK ───────────────────────────────────────────────────────
    'Uşak Merkez': (lat: 38.6833, lng: 29.4000),

    // ─── ELAZIĞ ─────────────────────────────────────────────────────
    'Elazığ Merkez': (lat: 38.6667, lng: 39.2167),

    // ─── BİNGÖL ─────────────────────────────────────────────────────
    'Bingöl Merkez': (lat: 38.8833, lng: 40.5000),

    // ─── TUNCELİ ────────────────────────────────────────────────────
    'Tunceli Merkez': (lat: 39.1167, lng: 39.5333),

    // ─── GÜMÜŞHANE ──────────────────────────────────────────────────
    'Gümüşhane Merkez': (lat: 40.4667, lng: 39.4833),

    // ─── BAYBURT ────────────────────────────────────────────────────
    'Bayburt Merkez': (lat: 40.2500, lng: 40.2333),

    // ─── YALOVA ─────────────────────────────────────────────────────
    'Yalova Merkez': (lat: 40.6500, lng: 29.2667),

    // ─── KİLİS ──────────────────────────────────────────────────────
    'Kilis Merkez': (lat: 36.7167, lng: 37.1167),
  };

  /// Küçük / büyük harf farkını yok sayarak ilçe adından koordinat döndürür.
  /// Bulunamazsa null döner.
  static ({double lat, double lng})? getCoordinates(String district) {
    // Önce birebir eşleşme dene
    final direct = districts[district];
    if (direct != null) return direct;

    // Case-insensitive arama
    final normalized = district.toLowerCase();
    for (final entry in districts.entries) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.value;
      }
    }
    return null;
  }

  /// İlçe adı listesi (sıralı).
  static List<String> get sortedDistrictNames {
    final list = districts.keys.toList()..sort((a, b) => a.compareTo(b));
    return list;
  }

  /// Küçük / büyük harf farkını yok sayarak ilçe adından koordinat döndürür.
  /// Bulunamazsa varsayılan Aydın merkez koordinatlarını döndürür.
  static ({double lat, double lng}) getCoordinatesOrDefault(String district) {
    return getCoordinates(district) ?? (lat: AppConstants.aydinLatitude, lng: AppConstants.aydinLongitude);
  }
}
