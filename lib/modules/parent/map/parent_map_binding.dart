import 'package:get/get.dart';
import '../../../data/repositories/parent_repository.dart';
import 'parent_map_controller.dart';

class ParentMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentMapController>(
        () => ParentMapController(Get.find<ParentRepository>()));
  }
}
