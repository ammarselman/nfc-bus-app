import 'package:get/get.dart';

import '../../services/notifications_api_poller.dart';

import '../../data/repositories/parent_repository.dart';

class ParentController extends GetxController {
  final ParentRepository repo;
  ParentController(this.repo);

  final loading = false.obs;
  final error = RxnString();
  final children = <Map<dynamic, dynamic>>[].obs;
  final lastUpdated = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    NotificationsApiPoller().start(); // تشغيل المراقبة
    fetch();
  }

  Future<void> fetch() async {
    loading.value = true;
    error.value = null;
    try {
      final list = await repo.children();
      print("this is from list :$list");
      children.assignAll(list);
      print(children);
      lastUpdated.value = DateTime.now();
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
