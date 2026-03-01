import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Konum iznini iste ve kontrol et
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Geolocator.checkPermission();
      
      if (status == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        return result == LocationPermission.whileInUse ||
            result == LocationPermission.always;
      } else if (status == LocationPermission.deniedForever) {
        // İzin kalıcı olarak reddedilmişse, ayarları aç
        await Geolocator.openLocationSettings();
        return false;
      } else if (status == LocationPermission.whileInUse ||
          status == LocationPermission.always) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Konum izni hatası: $e');
      return false;
    }
  }

  /// Mevcut konumu al
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        debugPrint('Konum izni yok');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      debugPrint('Konum alma hatası: $e');
      return null;
    }
  }

  /// Konumu gerçek zamanda dinle
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10 metre hareket ettiğinde güncelle
      ),
    );
  }

  /// Konum servisinin açık olup olmadığını kontrol et
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
