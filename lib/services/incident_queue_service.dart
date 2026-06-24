import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/driver_repository.dart';

class IncidentQueueService extends GetxService {
  static const _kKey = 'pending_incidents';

  Future<void> addPending({
    required String type,
    String? note,
    DateTime? time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (jsonDecode(prefs.getString(_kKey) ?? '[]') as List)
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    list.add({
      'type': type,
      if (note != null) 'note': note,
      'time': (time ?? DateTime.now()).toUtc().toIso8601String(),
    });

    await prefs.setString(_kKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return list;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }

  /// يحاول إرسال كل البلاغات المتراكمة
  Future<int> flushAll(DriverRepository repo) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (jsonDecode(prefs.getString(_kKey) ?? '[]') as List)
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    int sent = 0;
    final remain = <Map<String, dynamic>>[];

    for (final it in list) {
      try {
        final res = await repo.createIncident(
          type: (it['type'] ?? '').toString(),
          note: it['note']?.toString(),
          time: DateTime.tryParse((it['time'] ?? '').toString()),
        );
        if (res['ok'] == true) {
          sent++;
        } else {
          remain.add(it);
        }
      } catch (_) {
        remain.add(it);
      }
    }

    await prefs.setString(_kKey, jsonEncode(remain));
    return sent;
  }
}
