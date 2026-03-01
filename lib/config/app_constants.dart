class AppConstants {
  // Aydın Center Location
  static const double aydinLatitude = 37.8444;
  static const double aydinLongitude = 27.8458;
  static const double latitudeDelta = 0.04;
  static const double longitudeDelta = 0.04;
  
  // Initial Map Zoom
  static const double initialZoom = 13.0;
  
  // Admin Credentials (from example.md)
  static const String adminPlate = 'ADMIN';
  static const String adminDefaultPassword = '123456';
  
  // WhatsApp
  static const String defaultWhatsappNumber = '905555555555';
  
  // Default Download Link
  static const String defaultDownloadLink = 'https://aydindabutaksi.com/indir.apk';
  
  // Firestore Collections
  static const String driversCollection = 'drivers';
  static const String requestsCollection = 'requests';
  static const String packagesCollection = 'packages';
  static const String settingsCollection = 'admin_settings';
  static const String settingsDocument = 'config';
}
