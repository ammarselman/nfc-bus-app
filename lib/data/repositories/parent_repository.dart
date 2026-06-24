import '../../core/http/api_client.dart';
import '../../core/http/api_paths.dart';

class ParentRepository {
  final ApiClient api;
  ParentRepository(this.api);

  /// يعيد قائمة الأطفال المرتبطين بالحساب، مع الحالة الحالية لكل طفل
  /// مثال رد متوقّع:
  /// { "ok": true, "data": [
  ///   { "id": 10, "name": "Ali",  "grade": "3A", "on_bus": true,  "last_event": { "type":"in","time":"2025-09-24T07:05:00Z" } },
  ///   { "id": 11, "name": "Sara", "grade": "2B", "on_bus": false, "last_event": { "type":"out","time":"2025-09-24T14:02:00Z" } }
  /// ]}
  Future<List<Map<String, dynamic>>> children() async {
    final res = await api.get(ApiPath.parentChild);
    if (res['ok'] == true) {
      final list = (res['data'] ?? []) as List;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception(res['message']?.toString() ?? 'Failed to load children');
  }

  /// يعيد موقع حافلة الطفل
  /// مثال رد: { "ok": true, "bus": { "id":5, "lat": 21.485, "lng": 39.192, "updated_at": "2025-09-25T12:01:20Z" } }
  Future<Map<String, dynamic>?> busLocation({required int childId}) async {
    final res =
        await api.get(ApiPath.parentBusLocation, query: {'child_id': childId});
    if (res['ok'] == true) {
      final bus = res['bus'];
      if (bus is Map<String, dynamic>) return bus;
      return null;
    }
    throw Exception(
        res['message']?.toString() ?? 'Failed to load bus location');
  }

  Future<({List<Map<String, dynamic>> items, bool hasMore})> notifications({
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await api.get(
      ApiPath.parentNotifications,
      query: {'page': page, 'per_page': perPage},
    );

    if (res['ok'] == true) {
      final list = (res['data'] as List?) ?? const [];
      final items =
          list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      final hasMore = items.length == perPage; // ← لا يوجد meta
      return (items: items, hasMore: hasMore);
    }
    throw Exception(
        res['message']?.toString() ?? 'Failed to load notifications');
  }

  /// سجل حضور الطفل ضمن مدى تاريخ
  /// مثال رد:
  /// { "ok": true, "data": [
  ///   { "type":"in","time":"2025-09-24T07:05:00Z","bus":"BUS-5","by":"Driver Ali" },
  ///   { "type":"out","time":"2025-09-24T14:02:00Z","bus":"BUS-5","by":"Driver Ali" }
  /// ]}
  Future<List<Map<String, dynamic>>> attendance({
    required int childId,
    DateTime? from, // inclusive
    DateTime? to, // inclusive
    int? page, // اختياري لو عملت تقسيم صفحات
  }) async {
    final query = {
      'child_id': childId,
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
      if (page != null) 'page': page,
    };
    final res = await api.get(ApiPath.parentAttendance, query: query);
    if (res['ok'] == true) {
      final list = (res['data'] ?? []) as List;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception(res['message']?.toString() ?? 'Failed to load attendance');
  }
}
