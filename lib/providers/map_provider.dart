import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/config/app_constants.dart';

// Hangi harita motorunun aktif olduğunu takip eder
enum MapType { osm, google }

/// OSM birincil, Google Maps fallback.
/// OSM tile yüklenemezse [osmAvailableProvider] false yapılır ve
/// [activeMapTypeProvider] otomatik olarak google'a döner.
final activeMapTypeProvider = StateProvider<MapType>((ref) => MapType.osm);

/// OSM tile sunucusunun erişilebilir olup olmadığı.
/// OsmMapWidget hata alırsa bunu false yapar.
final osmAvailableProvider = StateProvider<bool>((ref) => true);

// Google Maps kamera pozisyonu (fallback için)
final mapCameraPositionProvider =
    StateProvider<gm.CameraPosition>((ref) {
  return const gm.CameraPosition(
    target: gm.LatLng(
      AppConstants.aydinLatitude,
      AppConstants.aydinLongitude,
    ),
    zoom: AppConstants.initialZoom,
  );
});

// Kullanıcı konumu (lat, lng) ikilisi — her iki harita motoruyla uyumlu
final userLocationProvider = StateProvider<(double, double)?>((ref) => null);

final mapMarkerCountProvider = StateProvider<int>((ref) => 0);
