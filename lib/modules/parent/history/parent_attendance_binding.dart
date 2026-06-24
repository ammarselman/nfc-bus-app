import 'package:get/get.dart';
import '../../../data/repositories/parent_repository.dart';
import 'parent_attendance_controller.dart';

class ParentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentAttendanceController>(
      () => ParentAttendanceController(Get.find<ParentRepository>()),
    );
  }
}
