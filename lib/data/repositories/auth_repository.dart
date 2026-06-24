import '../../core/http/api_client.dart';
import '../../core/http/api_paths.dart';

/// مستودع المصادقة: يجمع استدعاءات Auth في مكان واحد.
/// ملاحظة: حسب كلامك لا يوجد Token، والسيرفر يعيد بيانات المستخدم ضمن الرد.
class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  /// تسجيل الدخول:
  /// يرسل email/password كـ Form إلى PHP
  /// نتوقع رد بالشكل:
  ///{ "ok": true, "user": { "id":1, "name":"...", "role":"driver|parent", ... } }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await api.post(ApiPath.login, body: {
      'email': email,
      'password': password,
    });
    return res;
  }
}
