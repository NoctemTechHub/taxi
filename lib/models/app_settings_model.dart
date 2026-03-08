class AppSettings {
  final String? adminPassword;
  final String? whatsappNumber;
  final String? downloadLink;

  AppSettings({this.adminPassword, this.whatsappNumber, this.downloadLink});

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      adminPassword: json['adminPassword'] ?? '123456',
      whatsappNumber: json['whatsappNumber'] ?? '905555555555',
      downloadLink:
          json['downloadLink'] ?? 'https://aydindabutaksi.com/indir.apk',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminPassword': adminPassword,
      'whatsappNumber': whatsappNumber,
      'downloadLink': downloadLink,
    };
  }

  AppSettings copyWith({
    String? adminPassword,
    String? whatsappNumber,
    String? downloadLink,
  }) {
    return AppSettings(
      adminPassword: adminPassword ?? this.adminPassword,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      downloadLink: downloadLink ?? this.downloadLink,
    );
  }
}
