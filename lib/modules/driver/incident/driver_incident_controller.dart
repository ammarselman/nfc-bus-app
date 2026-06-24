import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../../services/incident_queue_service.dart';

class DriverIncidentController extends GetxController {
  final DriverRepository repo;
  final IncidentQueueService queue;
  DriverIncidentController(this.repo, this.queue);

  final loading = false.obs;
  final syncing = false.obs;

  // الحقول
  final type = 'delay'.obs; // delay | breakdown | accident | other
  final note = ''.obs;

  // إحصاء الـ pending
  final pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshPendingCount();
  }

  Future<void> refreshPendingCount() async {
    final list = await queue.loadPending();
    pendingCount.value = list.length;
  }

  Future<void> submit() async {
    if (loading.value) return;
    loading.value = true;
    try {
      // حاول إرسال مباشر
      final res = await repo.createIncident(
        type: type.value,
        note: note.value.trim().isEmpty ? null : note.value.trim(),
        time: DateTime.now(),
      );
      if (res['ok'] == true) {
        Get.snackbar('Incident', 'Sent successfully ✅',
            snackPosition: SnackPosition.BOTTOM);
        note.value = '';
      } else {
        // خزّن Offline
        await queue.addPending(type: type.value, note: note.value);
        await refreshPendingCount();
        Get.snackbar('Incident', 'Saved offline (will sync later)',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      // فشل شبكي: خزّن Offline
      await queue.addPending(type: type.value, note: note.value);
      await refreshPendingCount();
      Get.snackbar('Incident', 'Saved offline (will sync later)',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  Future<void> syncPending() async {
    if (syncing.value) return;
    syncing.value = true;
    try {
      final sent = await queue.flushAll(repo);
      await refreshPendingCount();
      Get.snackbar('Incident', 'Synced $sent pending',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      syncing.value = false;
    }
  }
}
