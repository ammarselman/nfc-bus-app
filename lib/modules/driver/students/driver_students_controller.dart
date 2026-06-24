import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';

class DriverStudentsController extends GetxController {
  final DriverRepository repo;
  DriverStudentsController(this.repo);
  // حالة الرحلة والعداد
  final tripActive = false.obs;
  final onboardCount = 0.obs;
  // معلومات واجهة
  final loading = false.obs;
  final lastUpdated = Rxn<DateTime>();
  final pendingCount = 0.obs;
  final items = <Map<String, dynamic>>[].obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    loading.value = true;
    error.value = null;
    try {
      final list = await repo.onboardList();
      items.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
