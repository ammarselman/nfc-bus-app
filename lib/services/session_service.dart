import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/http/api_client.dart';

class SessionService extends GetxService {
  static const _kUser = 'user';
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kToken = 'token';

  final isLoggedIn = false.obs;
  final role = RxnString();
  final user = Rxn<Map<String, dynamic>>();
  final token = RxnString();

  ApiClient? _api;

  Future<SessionService> init({ApiClient? api}) async {
    _api = api;
    await loadSession();
    // حقن التوكن في ApiClient إن وُجد
    if (_api != null && (token.value ?? '').isNotEmpty) {
      _api!.setAuthToken(token.value);
    }
    return this;
  }

  Future<void> saveSession(
    Map<String, dynamic> userData, {
    required String tokenValue,
  }) async {
    // فحوصات مبكرة
    if (tokenValue.trim().isEmpty) {
      throw Exception('Token is empty');
    }

    // Debug مهم
    // تجاهلها بعد ما تتأكد
    print('[SessionService] saving token: $tokenValue');

    final prefs = await SharedPreferences.getInstance();

    // خزّن القيم
    await prefs.setString(_kUser, jsonEncode(userData));
    await prefs.setString(_kToken, tokenValue);
    await prefs.setBool(_kIsLoggedIn, true);

    // حدّث الحالة داخل الذاكرة
    user.value = userData;
    role.value = (userData['role'] ?? '').toString();
    token.value = tokenValue;
    isLoggedIn.value = true;

    // حقن التوكن في ApiClient
    _api?.setAuthToken(tokenValue);

    // تأكيد فوري بالقراءة مرّة ثانية (للتشخيص)
    final check = prefs.getString(_kToken);
    if (check == null || check.isEmpty) {
      throw Exception('Token save failed: read-back returned null/empty');
    }
    print('[SessionService] token read-back ok: $check');
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final ok = prefs.getBool(_kIsLoggedIn) ?? false;
    isLoggedIn.value = ok;

    if (!ok) {
      user.value = null;
      role.value = null;
      token.value = null;
      return;
    }

    final raw = prefs.getString(_kUser);
    final savedToken = prefs.getString(_kToken);

    if (raw == null || savedToken == null || savedToken.isEmpty) {
      await clear();
      return;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      user.value = map;
      role.value = (map['role'] ?? '').toString();
      token.value = savedToken;
    } catch (e) {
      // لو البيانات تالفة، امسح الجلسة
      await clear();
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUser);
    await prefs.remove(_kToken);
    await prefs.remove(_kIsLoggedIn);

    user.value = null;
    role.value = null;
    token.value = null;
    isLoggedIn.value = false;

    _api?.clearAuthToken();
  }

  void attachApi(ApiClient api) {
    _api = api;
    if ((token.value ?? '').isNotEmpty) {
      _api!.setAuthToken(token.value);
    }
  }
}
