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
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const ll.LatLng(
              AppConstants.aydinLatitude,
              AppConstants.aydinLongitude,
            ),
            initialZoom: AppConstants.initialZoom,
            minZoom: 4,
            maxZoom: 19,
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
            MarkerLayer(markers: _buildMarkers()),

            // Atıf (OSM lisans gereği zorunlu)
            _OsmAttribution(),
          ],
        ),

        // ─── Zoom Butonları ──────────────────────────────────────────
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _ZoomButton(
                icon: Icons.add,
                onTap: () {
                  final zoom = _mapController.camera.zoom + 1;
                  _mapController.move(
                    _mapController.camera.center,
                    zoom.clamp(4, 19),
                  );
                },
              ),
              const SizedBox(height: 4),
              _ZoomButton(
                icon: Icons.remove,
                onTap: () {
                  final zoom = _mapController.camera.zoom - 1;
                  _mapController.move(
                    _mapController.camera.center,
                    zoom.clamp(4, 19),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    debugPrint(
      '[OsmMap] Marker oluşturuluyor: ${widget.drivers.length} sürücü',
    );
    return widget.drivers.map((driver) {
      debugPrint(
        '  → ${driver.plate}: ${driver.lat.toStringAsFixed(6)}, ${driver.lng.toStringAsFixed(6)}',
      );
      const color = Color(0xFFFFC107); // sarı
      return Marker(
        point: ll.LatLng(driver.lat, driver.lng),
        width: 56,
        height: 66,
        child: GestureDetector(
          onTap: () => widget.onDriverTap(driver),
          child: Tooltip(
            message: '${driver.plate} — ${driver.district}',
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: driver.isPremium
                          ? const Color(0xFFFFD700)
                          : Colors.white,
                      width: driver.isPremium ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: driver.isPremium
                            ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                            : Colors.black26,
                        blurRadius: driver.isPremium ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_taxi,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (driver.isPremium)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF8F00,
                            ).withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Color(0xFFFF8F00),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Zoom +/- butonu.
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
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
