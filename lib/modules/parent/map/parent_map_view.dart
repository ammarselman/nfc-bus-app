// lib/modules/parent/map/parent_map_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'parent_map_controller.dart';

class ParentMapView extends GetView<ParentMapController> {
  const ParentMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Location – ${controller.childName}'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.manualRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value && controller.lat.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(controller.error.value!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: controller.manualRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final a = controller.lat.value;
        final b = controller.lng.value;
        if (a == null || b == null) {
          return const Center(child: Text('No location available yet.'));
        }

        final pos = LatLng(a, b);

        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: pos,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pos,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.directions_bus, size: 36),
                    ),
                  ],
                ),
              ],
            ),

            // شريط حالة آخر تحديث
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Obx(() => Text(
                        controller.updatedAt.value == null
                            ? 'Waiting for location updates…'
                            : 'Last update: ${controller.updatedAt.value}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
