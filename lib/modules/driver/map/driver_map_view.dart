import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart'; // بدل google_maps_flutter
import 'package:latlong2/latlong.dart';
import 'driver_map_controller.dart';

class DriverMapView extends GetView<DriverMapController> {
  const DriverMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Map')),
      body: Obx(() {
        if (!controller.hasPermission.value) {
          return _Denied(onRetry: () => controller.onInit());
        }
        final p = controller.current.value;
        if (p == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final latlng = LatLng(p.latitude, p.longitude);

        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: latlng,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',

                  // userAgentPackageName:
                  //     'com.yourcompany.busapp', // مهم لسياسة OSM
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlng,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.directions_bus, size: 36),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: _StatusBar(),
            ),
          ],
        );
      }),
    );
  }
}

class _StatusBar extends GetView<DriverMapController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface.withOpacity(.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Obx(() => Icon(
                  controller.lastSendOk.value == false
                      ? Icons.cloud_off
                      : Icons.cloud_done_outlined,
                )),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() => Text(
                    controller.lastError.value == null
                        ? 'Location sending in background…'
                        : 'Last error: ${controller.lastError.value}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
            const SizedBox(width: 8),
            Obx(() => controller.sending.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : OutlinedButton.icon(
                    onPressed: controller.manualSend,
                    icon: const Icon(Icons.send),
                    label: const Text('Send now'),
                  )),
          ],
        ),
      ),
    );
  }
}

class _Denied extends StatelessWidget {
  final VoidCallback onRetry;
  const _Denied({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_disabled, size: 40),
            const SizedBox(height: 12),
            const Text('Location permission or service is disabled.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
