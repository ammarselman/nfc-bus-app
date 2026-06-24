// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../../../services/nfc_service.dart';
// import '../../../services/offline_queue_service.dart';
// import '../../../data/repositories/driver_repository.dart';

// class DriverScanController extends GetxController {
//   final NfcService nfc;
//   final DriverRepository repo;
//   final OfflineQueueService queue;

//   DriverScanController(this.nfc, this.repo, this.queue);

//   final scanning = false.obs;
//   final lastUid = RxnString();
//   final lastResult = RxnString(); // "IN"/"OUT"/"PENDING"/"ERROR"
//   final syncing = false.obs;

//   Future<void> startOneShotScan() async {
//     if (scanning.value) return;
//     scanning.value = true;
//     lastResult.value = null;

//     try {
//       final uid = await nfc.readUidOnce();
//       if (uid == null) {
//         lastResult.value = 'ERROR: No tag detected';
//         return;
//       }
//       lastUid.value = uid;

//       // جرّب الإرسال الفوري للسيرفر
//       try {
//         final res = await repo.attendanceScan(nfcUid: uid);
//         if (res['ok'] == true) {
//           final ev = (res['event_type'] ?? '').toString().toUpperCase();
//           lastResult.value = ev.isEmpty ? 'IN' : ev; // احتياط
//           HapticFeedback.mediumImpact();
//         } else {
//           // رد ok=false: خزّن Pending
//           await queue.addPending(uid);
//           lastResult.value = 'PENDING';
//           HapticFeedback.lightImpact();
//         }
//       } catch (_) {
//         // فشل شبكي: خزّن Pending
//         await queue.addPending(uid);
//         lastResult.value = 'PENDING';
//         HapticFeedback.lightImpact();
//       }
//     } finally {
//       scanning.value = false;
//     }
//   }

//   Future<void> flushPending() async {
//     if (syncing.value) return;
//     syncing.value = true;
//     try {
//       final sent = await queue.flushAll(repo);
//       lastResult.value = 'SYNCED: $sent';
//       HapticFeedback.selectionClick();
//     } finally {
//       syncing.value = false;
//     }
//   }
// }
import 'package:flutter/material.dart'; // ✅ أضف هذا
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../services/nfc_service.dart';
import '../../../services/offline_queue_service.dart';
import '../../../data/repositories/driver_repository.dart';

class DriverScanController extends GetxController {
  final NfcService nfc;
  final DriverRepository repo;
  final OfflineQueueService queue;

  DriverScanController(this.nfc, this.repo, this.queue);

  final scanning = false.obs;
  final lastUid = RxnString();
  final lastResult = RxnString(); // "IN"/"OUT"/"PENDING"/"ERROR"
  final syncing = false.obs;

  Future<void> startOneShotScan() async {
    if (scanning.value) return;
    scanning.value = true;
    lastResult.value = null;

    try {
      // ✅ أولاً: تأكد أن الجهاز يدعم NFC
      final nfcAvailable = await nfc.isAvailable();
      if (!nfcAvailable) {
        lastResult.value = 'ERROR: NFC not available on this device';

        // Snackbar لطيف بدل الكراش
        Get.snackbar(
          'NFC غير متوفّر',
          'هذا الجهاز لا يدعم NFC أو أنّه غير مفعّل من الإعدادات.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return; // نخرج بدون ما نحاول المسح
      }

      // ✅ الآن نبدأ المسح فعلياً
      final uid = await nfc.readUidOnce();
      if (uid == null) {
        // إمّا ما تم التقاط بطاقة، أو حدث خطأ داخل الخدمة
        lastResult.value = 'ERROR: No tag detected';
        return;
      }

      lastUid.value = uid;

      // جرّب الإرسال الفوري للسيرفر
      try {
        final res = await repo.attendanceScan(nfcUid: uid);
        if (res['ok'] == true) {
          final ev = (res['event_type'] ?? '').toString().toUpperCase();
          lastResult.value = ev.isEmpty ? 'IN' : ev; // احتياط
          HapticFeedback.mediumImpact();
        } else {
          // رد ok=false: خزّن Pending
          await queue.addPending(uid);
          lastResult.value = 'PENDING';
          HapticFeedback.lightImpact();
        }
      } catch (_) {
        // فشل شبكي: خزّن Pending
        await queue.addPending(uid);
        lastResult.value = 'PENDING';
        HapticFeedback.lightImpact();
      }
    } on PlatformException catch (e) {
      // احتياط لو رجع استثناء من النظام
      lastResult.value = 'ERROR: ${e.message ?? 'NFC error'}';
      Get.snackbar(
        'خطأ في NFC',
        e.message ?? 'حدث خطأ غير متوقع أثناء قراءة NFC.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // أي خطأ عام آخر
      lastResult.value = 'ERROR: $e';
    } finally {
      scanning.value = false;
    }
  }

  Future<void> flushPending() async {
    if (syncing.value) return;
    syncing.value = true;
    try {
      final sent = await queue.flushAll(repo);
      lastResult.value = 'SYNCED: $sent';
      HapticFeedback.selectionClick();
    } finally {
      syncing.value = false;
    }
  }
}
