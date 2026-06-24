import 'package:get/get.dart';
import '../../core/http/api_client.dart';
import '../../data/repositories/parent_repository.dart';
import 'notifications/parent_notifications_controller.dart';
import 'parent_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<ApiClient>(); // موجود من AuthBinding
    Get.lazyPut<ParentRepository>(
        () => ParentRepository(Get.find<ApiClient>()));
    Get.lazyPut<ParentController>(
        () => ParentController(Get.find<ParentRepository>()));
    Get.put(ParentNotificationsController(Get.find()));
  }
}
