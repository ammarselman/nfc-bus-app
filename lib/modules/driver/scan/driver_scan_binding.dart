import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../../services/offline_queue_service.dart';
import '../../../services/nfc_service.dart';
import 'driver_scan_controller.dart';

class DriverScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverScanController>(() => DriverScanController(
        Get.find<NfcService>(),
        Get.find<DriverRepository>(),
        Get.find<OfflineQueueService>()));
  }
}
