import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi/config/app_colors.dart';
import 'package:taxi/config/app_constants.dart';
import 'package:taxi/providers/driver_provider.dart';
import 'package:taxi/providers/map_provider.dart';
import 'package:taxi/widgets/modals/taxi_detail_modal.dart';
import 'package:taxi/widgets/osm_map_widget.dart';
import 'package:taxi/widgets/top_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driverListProvider);
    final selectedDriver = ref.watch(selectedDriverProvider);
    final activeMapType = ref.watch(activeMapTypeProvider);
    final osmAvailable = ref.watch(osmAvailableProvider);

    return Scaffold(
      body: Stack(
        children: [
          drivers.when(
            data: (driversList) {
              final visibleDrivers = driversList
                  .where((d) => d.status != 'suspended')
                  .toList();

              // ─── OSM (Birincil) ───────────────────────────────────────────
              if (activeMapType == MapType.osm) {
                return OsmMapWidget(
                  drivers: visibleDrivers,
                  onDriverTap: (driver) {
                    ref.read(selectedDriverProvider.notifier).state = driver;
                  },
                );
              }

              // ─── Google Maps (Fallback) ────────────────────────────────────
              return gm.GoogleMap(
                initialCameraPosition: const gm.CameraPosition(
                  target: gm.LatLng(
                    AppConstants.aydinLatitude,
                    AppConstants.aydinLongitude,
                  ),
                  zoom: AppConstants.initialZoom,
                ),
                markers: _buildGoogleMarkers(visibleDrivers, ref),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text('Hata: $error'),
            ),
          ),
          
          // TopBar — görsel katman (dokunma geçirir)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: TopBar(),
            ),
          ),
          // TopBar butonları — sağ üst (dokunulabilir, sadece butonları kaplar)
          const Positioned(
            top: 0,
            right: 0,
            child: _TopBarButtons(),
          ),

          // Harita türü değiştirme butonu
          Positioned(
            top: 100,
            right: 12,
            child: _MapTypeToggleButton(
              isOsm: activeMapType == MapType.osm,
              osmAvailable: osmAvailable,
              onToggle: () {
                if (activeMapType == MapType.osm) {
                  ref.read(activeMapTypeProvider.notifier).state =
                      MapType.google;
                } else {
                  // OSM'yi tekrar dene
                  ref.read(osmAvailableProvider.notifier).state = true;
                  ref.read(activeMapTypeProvider.notifier).state = MapType.osm;
                }
              },
            ),
          ),
          
          // DownloadBar
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Taksici misin?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Hemen indir, kazan!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      final url = 'https://aydindabutaksi.com/indir.apk';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.download,
                              color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'İNDİR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Driver Card Popup
          if (selectedDriver != null)
            TaxiDetailModal(
              driver: selectedDriver,
              onClose: () {
                ref.read(selectedDriverProvider.notifier).state = null;
              },
            ),
        ],
      ),
    );
  }

  Set<gm.Marker> _buildGoogleMarkers(List drivers, WidgetRef ref) {
    return drivers.map<gm.Marker>((driver) {
      return gm.Marker(
        markerId: gm.MarkerId(driver.id),
        position: gm.LatLng(driver.lat, driver.lng),
        infoWindow: gm.InfoWindow(
          title: driver.plate,
          snippet: '${driver.district} - ${driver.status}',
        ),
        onTap: () {
          ref.read(selectedDriverProvider.notifier).state = driver;
        },
        icon: gm.BitmapDescriptor.defaultMarkerWithHue(
          _getHueForStatus(driver.status),
        ),
      );
    }).toSet();
  }

  double _getHueForStatus(String status) {
    switch (status) {
      case 'available':
        return gm.BitmapDescriptor.hueGreen;
      case 'busy':
        return gm.BitmapDescriptor.hueRed;
      case 'break':
        return gm.BitmapDescriptor.hueOrange;
      default:
        return gm.BitmapDescriptor.hueYellow;
    }
  }
}

/// Sağ üstteki butonlar — GİRİŞ ve LİSTE.
/// TopBar görsel olarak IgnorePointer ile render edilir, butonlar bu widget üzerinden tıklanır.
class _TopBarButtons extends StatelessWidget {
  const _TopBarButtons();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => context.push('/login'),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('👤', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'GİRİŞ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showDriversList(context),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('📋', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'LİSTE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriversList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DriverListModal(),
    );
  }
}

class _MapTypeToggleButton extends StatelessWidget {
  final bool isOsm;
  final bool osmAvailable;
  final VoidCallback onToggle;

  const _MapTypeToggleButton({
    required this.isOsm,
    required this.osmAvailable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isOsm ? 'Google Maps\'e geç' : 'OpenStreetMap\'e geç',
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                isOsm ? Icons.map_outlined : Icons.layers_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              if (!osmAvailable)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
