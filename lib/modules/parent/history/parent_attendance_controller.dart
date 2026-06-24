import 'package:get/get.dart';
import '../../../data/repositories/parent_repository.dart';

class ParentAttendanceController extends GetxController {
  final ParentRepository repo;
  ParentAttendanceController(this.repo);

  late final int childId;
  late final String childName;

  final loading = false.obs;
  final error = RxnString();

  final items = <Map<String, dynamic>>[].obs;

  // مدى التاريخ (افتراضي: اليوم)
  final from = Rxn<DateTime>();
  final to = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    childId = (args['child_id'] ?? args['child']?['id'] ?? 0) as int;
    childName =
        (args['child_name'] ?? args['child']?['name'] ?? 'Child').toString();

    final now = DateTime.now();
    from.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    to.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    fetch();
  }

  Future<void> fetch() async {
    if (childId == 0) {
      error.value = 'Missing child_id';
      return;
    }
    loading.value = true;
    error.value = null;
    try {
      final list = await repo.attendance(
        childId: childId,
        from: from.value,
        to: to.value,
      );
      items.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void setFrom(DateTime d) {
    from.value = DateTime(d.year, d.month, d.day, 0, 0, 0);
  }

  void setTo(DateTime d) {
    to.value = DateTime(d.year, d.month, d.day, 23, 59, 59);
  }
}
