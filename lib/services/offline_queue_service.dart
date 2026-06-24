import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/driver_repository.dart';

class OfflineQueueService extends GetxService {
  static const _kKey = 'pending_scans';

  Future<void> addPending(String nfcUid) async {
    final prefs = await SharedPreferences.getInstance();
    final list =
        (jsonDecode(prefs.getString(_kKey) ?? '[]') as List).cast<String>();
    list.add(nfcUid);
    await prefs.setString(_kKey, jsonEncode(list));
  }

  Future<List<String>> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final list =
        (jsonDecode(prefs.getString(_kKey) ?? '[]') as List).cast<String>();
    return list;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }

  /// يحاول إرسال جميع الـ UID المتراكمة إلى السيرفر
  Future<int> flushAll(DriverRepository repo) async {
    final prefs = await SharedPreferences.getInstance();
    final list =
        (jsonDecode(prefs.getString(_kKey) ?? '[]') as List).cast<String>();
    int sent = 0;
    final remain = <String>[];

    for (final uid in list) {
      try {
        final res = await repo.attendanceScan(nfcUid: uid);
        if (res['ok'] == true) {
          sent++;
        } else {
          remain.add(uid); // اتركه لمحاولة لاحقة
        }
      } catch (_) {
        remain.add(uid);
      }
    }

    await prefs.setString(_kKey, jsonEncode(remain));
    return sent;
  }
}
