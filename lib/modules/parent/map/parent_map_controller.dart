// lib/modules/parent/map/parent_map_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/repositories/parent_repository.dart';

class ParentMapController extends GetxController {
  final ParentRepository repo;
  ParentMapController(this.repo);

  late final int childId;
  late final String childName;

  final loading = true.obs;
  final error = RxnString();

  final lat = RxnDouble();
  final lng = RxnDouble();
  final updatedAt = RxnString();

  // flutter_map controller
  final mapController = MapController();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    childId = (args['child_id'] ?? args['child']?['id'] ?? 0) as int;
    childName =
        (args['child_name'] ?? args['child']?['name'] ?? 'Child').toString();

    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (childId == 0) {
      error.value = 'Missing child_id';
      loading.value = false;
      return;
    }
    try {
      if (lat.value == null || lng.value == null) loading.value = true;
      error.value = null;

      final bus = await repo.busLocation(childId: childId);
      if (bus == null) {
        error.value = 'No bus assigned';
      } else {
        final newLat = (bus['lat'] as num?)?.toDouble();
        final newLng = (bus['lng'] as num?)?.toDouble();
        lat.value = newLat;
        lng.value = newLng;
        updatedAt.value = bus['updated_at']?.toString();

        // حرّك الكاميرا عند كل تحديث صالح
        if (newLat != null && newLng != null) {
          try {
            mapController.move(LatLng(newLat, newLng), 15);
          } catch (_) {}
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> manualRefresh() => _fetch();

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
