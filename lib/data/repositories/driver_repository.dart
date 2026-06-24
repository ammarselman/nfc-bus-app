import '../../core/http/api_client.dart';
import '../../core/http/api_paths.dart';

class DriverRepository {
  final ApiClient api;
  DriverRepository(this.api);

  /// إرسال UID إلى السيرفر
  /// يتوقّع رد مثل:
  /// { "ok":true, "event_type":"in"|"out", "student":{"id":..,"name":".."}, "time":"..." }
  Future<Map<String, dynamic>> attendanceScan({
    required String nfcUid,
  }) async {
    final res = await api.post(ApiPath.driverAttendanceScan, body: {
      'nfc_uid': nfcUid,
    });
    return res;
  }

  /// يعيد قائمة الطلاب على متن الحافلة الآن
  /// متوقَّع من PHP:
  /// { "ok": true, "data": [ { "id": 77, "name": "Ali", "grade": "3A", "boarded_at": "2025-09-24T07:21:10Z" }, ... ] }
  Future<List<Map<String, dynamic>>> onboardList() async {
    final res = await api.get(ApiPath.driverOnboard);
    if (res['ok'] == true) {
      final list = (res['data'] ?? []) as List;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception(
        res['message']?.toString() ?? 'Failed to load onboard list');
  }

  /// يجلب حالة الرحلة والعداد من السيرفر (اقتراح تنسيق)
  /// رد متوقَّع:
  /// { "ok": true, "trip": { "active": true, "onboard_count": 12 } }
  Future<Map<String, dynamic>> tripCurrent() async {
    final res = await api.get(ApiPath.driverTripCurrent);
    if (res['ok'] == true) return (res['trip'] ?? {}) as Map<String, dynamic>;
    throw Exception(res['message']?.toString() ?? 'Failed to load trip status');
  }

  /// إرسال نقطة موقع الحافلة
  /// متوقع من السيرفر { "ok": true }
  Future<Map<String, dynamic>> sendLocation({
    required double lat,
    required double lng,
    double? speed, // م/ث
    DateTime? time,
  }) async {
    final res = await api.post(ApiPath.driverLocation, body: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      if (speed != null) 'speed': speed,
      if (time != null) 'time': time.toUtc().toIso8601String(),
    });
    return res;
  }

  /// إنشاء بلاغ من السائق
  /// توقّع من السيرفر: { "ok": true, "id": 123 }
  Future<Map<String, dynamic>> createIncident({
    required String type, // delay | breakdown | accident | other
    String? note,
    DateTime? time,
  }) async {
    final res = await api.post(ApiPath.driverIncident, body: {
      'type': type,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return res;
  }
}
