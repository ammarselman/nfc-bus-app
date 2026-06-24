// // lib/modules/driver/map/driver_map_controller.dart
// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../../data/repositories/driver_repository.dart';
// import '../../../services/location_service.dart';

// class DriverMapController extends GetxController {
//   final DriverRepository repo;
//   final LocationService loc;
//   DriverMapController(this.repo, this.loc);

//   final hasPermission = false.obs;
//   GoogleMapController? mapCtrl;
//   final sending = false.obs;
//   final lastSendOk = RxnBool();
//   final lastError = RxnString();

//   final current = Rxn<Position>();
//   StreamSubscription<Position>? _sub;
//   Timer? _throttle;

//   @override
//   void onInit() {
//     super.onInit();
//     _init();
//   }

//   void onMapCreated(GoogleMapController c) {
//     mapCtrl = c;
//   }

//   Future<void> _init() async {
//     hasPermission.value = await loc.ensurePermission();
//     if (!hasPermission.value) return;
//     // جلب أول نقطة
//     current.value = await loc.getCurrent();
//     // الاستماع لتحديثات الموقع
//     _sub = loc.startListening(onData: (p) {
//       current.value = p;
//       mapCtrl?.animateCamera(
//         CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude)),
//       );
//       _scheduleSend(p); // نرسل بشكل مهدود
//     });
//   }

//   void _scheduleSend(Position p) {
//     // أرسل كل ~15 ثانية أو عند حركة ملموسة
//     _throttle?.cancel();
//     _throttle = Timer(const Duration(seconds: 15), () => _send(p));
//   }

//   Future<void> manualSend() async {
//     final p = current.value;
//     if (p == null) return;
//     await _send(p, manual: true);
//   }

//   Future<void> _send(Position p, {bool manual = false}) async {
//     if (sending.value) return;
//     sending.value = true;
//     try {
//       await repo.sendLocation(
//         lat: p.latitude,
//         lng: p.longitude,
//         speed: p.speed, // m/s
//         time: DateTime.now(),
//       );
//       lastSendOk.value = true;
//       lastError.value = null;
//     } catch (e) {
//       lastSendOk.value = false;
//       lastError.value = e.toString();
//     } finally {
//       sending.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     _throttle?.cancel();
//     _sub?.cancel();
//     loc.stop();
//     super.onClose();
//   }
// }
import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart'; // جديد
import 'package:latlong2/latlong.dart'; // جديد
import '../../../data/repositories/driver_repository.dart';
import '../../../services/location_service.dart';

class DriverMapController extends GetxController {
  final DriverRepository repo;
  final LocationService loc;
  DriverMapController(this.repo, this.loc);

  // ========= flutter_map =========
  final mapController = MapController(); // جديد

  final hasPermission = false.obs;
  final sending = false.obs;
  final lastSendOk = RxnBool();
  final lastError = RxnString();

  final current = Rxn<Position>();
  StreamSubscription<Position>? _sub;
  Timer? _throttle;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    hasPermission.value = await loc.ensurePermission();
    if (!hasPermission.value) return;

    // أول نقطة
    current.value = await loc.getCurrent();
    final p0 = current.value;
    if (p0 != null) {
      try {
        mapController.move(
            LatLng(p0.latitude, p0.longitude), 16); // حرّك الكاميرا
      } catch (_) {}
    }

    // الاستماع لتحديثات الموقع
    _sub = loc.startListening(onData: (p) {
      current.value = p;
      // حرّك الكاميرا مع كل تحديث (أو قللها إن أردت)
      try {
        mapController.move(LatLng(p.latitude, p.longitude), 16);
      } catch (_) {}
      _scheduleSend(p); // إرسال مهدود
    });
  }

  void _scheduleSend(Position p) {
    _throttle?.cancel();
    _throttle = Timer(const Duration(seconds: 15), () => _send(p));
  }

  Future<void> manualSend() async {
    final p = current.value;
    if (p == null) return;
    await _send(p, manual: true);
  }

  Future<void> _send(Position p, {bool manual = false}) async {
    if (sending.value) return;
    sending.value = true;
    try {
      await repo.sendLocation(
        lat: p.latitude,
        lng: p.longitude,
        speed: p.speed,
        time: DateTime.now(),
      );
      lastSendOk.value = true;
      lastError.value = null;
    } catch (e) {
      lastSendOk.value = false;
      lastError.value = e.toString();
    } finally {
      sending.value = false;
    }
  }

  @override
  void onClose() {
    _throttle?.cancel();
    _sub?.cancel();
    loc.stop();
    super.onClose();
  }
}
