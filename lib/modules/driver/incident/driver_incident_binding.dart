import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../../services/incident_queue_service.dart';
import 'driver_incident_controller.dart';

class DriverIncidentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverIncidentController>(() => DriverIncidentController(
        Get.find<DriverRepository>(), Get.find<IncidentQueueService>()));
  }
}
