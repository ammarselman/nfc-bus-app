import 'package:get/get.dart';
import '../../core/http/api_client.dart';
import '../../data/repositories/driver_repository.dart';
import '../../services/incident_queue_service.dart';
import '../../services/offline_queue_service.dart';
import '../../services/nfc_service.dart';
import 'driver_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    // إذا ApiClient مُسجّل مسبقًا في AuthBinding بنفس الـ baseUrl فسنستخدمه
    Get.find<ApiClient>();

    Get.lazyPut<DriverRepository>(
        () => DriverRepository(Get.find<ApiClient>()));
    Get.lazyPut<NfcService>(() => NfcService());
    Get.lazyPut<OfflineQueueService>(() => OfflineQueueService());
    Get.lazyPut<IncidentQueueService>(() => IncidentQueueService());

    Get.lazyPut<DriverController>(() => DriverController());
  }
}
