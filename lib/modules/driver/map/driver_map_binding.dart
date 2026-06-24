// lib/modules/driver/map/driver_map_binding.dart
import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../../services/location_service.dart';
import 'driver_map_controller.dart';

class DriverMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationService>(() => LocationService());
    Get.lazyPut<DriverMapController>(() => DriverMapController(
          Get.find<DriverRepository>(),
          Get.find<LocationService>(),
        ));
  }
}
