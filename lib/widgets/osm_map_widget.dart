import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:taxi/config/app_constants.dart';
import 'package:taxi/models/driver_model.dart';
import 'package:taxi/providers/map_provider.dart';

/// OpenStreetMap tabanlı harita widget'ı.
/// 
/// Tile yüklemelerinde ardı ardına hata gelirse [osmAvailableProvider]'ı
/// false yaparak [activeMapTypeProvider]'ı Google Maps'e döndürür.
class OsmMapWidget extends ConsumerStatefulWidget {
  final List<Driver> drivers;
  final void Function(Driver driver) onDriverTap;

  const OsmMapWidget({
    super.key,
    required this.drivers,
    required this.onDriverTap,
  });

  @override
  ConsumerState<OsmMapWidget> createState() => _OsmMapWidgetState();
}

class _OsmMapWidgetState extends ConsumerState<OsmMapWidget> {
  final MapController _mapController = MapController();

  int _tileErrorCount = 0;
  static const int _maxTileErrors = 3;

  // OSM'nin peş peşe çok fazla hata vermesi durumunda Google Maps'e geç
  void _onTileError(TileImage tile, Object error, StackTrace? stackTrace) {
    _tileErrorCount++;
    debugPrint('[OSM] Tile yükleme hatası ($_tileErrorCount): $error');
    if (_tileErrorCount >= _maxTileErrors) {
      _fallbackToGoogle();
    }
  }

  void _fallbackToGoogle() {
    if (!mounted) return;
    debugPrint('[OSM] Fallback: Google Maps\'e geçiliyor.');
    ref.read(osmAvailableProvider.notifier).state = false;
    ref.read(activeMapTypeProvider.notifier).state = MapType.google;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const ll.LatLng(
          AppConstants.aydinLatitude,
          AppConstants.aydinLongitude,
        ),
        initialZoom: AppConstants.initialZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // OSM Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.aydindabutaksi.taxi',
          maxZoom: 19,
          // Hata callback — fallback tetikler
          errorTileCallback: _onTileError,
        ),

        // Sürücü Marker'ları
        MarkerLayer(
          markers: _buildMarkers(),
        ),

        // Atıf (OSM lisans gereği zorunlu)
        _OsmAttribution(),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return widget.drivers.map((driver) {
      final color = _colorForStatus(driver.status);
      return Marker(
        point: ll.LatLng(driver.lat, driver.lng),
        width: 52,
        height: 52,
        child: GestureDetector(
          onTap: () => widget.onDriverTap(driver),
          child: Tooltip(
            message: '${driver.plate} — ${driver.district}',
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_taxi,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Color _colorForStatus(String status) {
    switch (status) {
      case 'available':
        return Colors.green.shade600;
      case 'busy':
        return Colors.red.shade600;
      case 'break':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

/// OSM lisans gereği haritanın köşesine atıf metni ekler.
class _OsmAttribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '© OpenStreetMap katkıda bulunanlar',
            style: TextStyle(fontSize: 10, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
