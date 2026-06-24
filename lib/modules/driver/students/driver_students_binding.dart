import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';
import 'driver_students_controller.dart';

class DriverStudentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverStudentsController>(
      () => DriverStudentsController(Get.find<DriverRepository>()),
    );
  }
}
