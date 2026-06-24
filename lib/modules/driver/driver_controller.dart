import 'dart:async';
import 'package:get/get.dart';
import '../../data/repositories/driver_repository.dart';
import '../../services/offline_queue_service.dart';

class DriverController extends GetxController {
  final DriverRepository repo = Get.find<DriverRepository>();
  final OfflineQueueService queue = Get.find<OfflineQueueService>();

  // حالة الرحلة والعداد
  final tripActive = false.obs;
  final onboardCount = 0.obs;

  // معلومات واجهة
  final loading = false.obs;
  final lastUpdated = Rxn<DateTime>();
  final pendingCount = 0.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 20), (_) => refreshDashboard());
  }

  Future<void> refreshDashboard() async {
    loading.value = true;
    try {
      // نجرب واجهة trip/current أولاً
      final trip = await repo.tripCurrent();
      tripActive.value = (trip['active'] ?? false) == true;

      // إن لم يعُد السيرفر onboard_count، نكمل بواجهة onboard
      final countFromTrip = (trip['onboard_count'] ?? -1) as int;
      if (countFromTrip >= 0) {
        onboardCount.value = countFromTrip;
      } else {
        final list = await repo.onboardList();
        onboardCount.value = list.length;
      }

      // حدّث عدد الـ Pending من التخزين المحلي
      final pend = await queue.loadPending();
      pendingCount.value = pend.length;

      lastUpdated.value = DateTime.now();
    } catch (_) {
      // لا نرمي الخطأ للمستخدم هنا؛ نُبقي القيم السابقة
    } finally {
      loading.value = false;
    }
  }
}
