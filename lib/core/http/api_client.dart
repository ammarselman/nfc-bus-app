import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class ApiClient {
  final http.Client _client;

  String? _authToken; // سيُملأ من SharedPreferences عند الحاجة

  final Map<String, String> defaultHeaders;

  ApiClient({
    http.Client? client,
    Map<String, String>? defaultHeaders,
  })  : _client = client ?? http.Client(),
        defaultHeaders = defaultHeaders ??
            {
              'Accept': 'application/json',
            };

  // حمّل التوكن كسولاً من SharedPreferences مرة واحدة
  static const _kToken = 'token';
  Future<void> _ensureAuthLoaded() async {
    if (_authToken == null || _authToken!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_kToken); // <-- يستعيد التوكن
      print('[ApiClient] loaded token from prefs = $_authToken');
    }
  }

  void setAuthToken(String? token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  Map<String, String> _headers([Map<String, String>? extra]) {
    // اطبع هنا للتشخيص
    print('[_headers] _authToken=$_authToken');
    return {
      ...defaultHeaders,
      if (_authToken != null && _authToken!.isNotEmpty)
        'Authorization': 'Bearer $_authToken',
      if (extra != null) ...extra,
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${AppConfig.baseUrl}$path'); // استخدم baseUrl
    print(uri);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: query.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    await _ensureAuthLoaded(); // <-- مهم
    final merged = _headers(headers);
    print("REQUEST HEADERS (POST) => $merged");
    final res = await _client.post(
      _uri(path),
      headers: merged,
      body: body?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    print(res.body);
    return _parseResponse(res);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? jsonBody,
    Map<String, String>? headers,
  }) async {
    await _ensureAuthLoaded(); // <-- مهم
    final merged = _headers({
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    });
    // print("REQUEST HEADERS (POST JSON) => $merged");
    final res = await _client.post(
      _uri(path),
      headers: merged,
      body: json.encode(jsonBody ?? {}),
    );
    return _parseResponse(res);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    await _ensureAuthLoaded(); // <-- مهم
    final merged = _headers(headers);
    print("REQUEST HEADERS (GET) => $merged");
    final res = await _client.get(
      _uri(path, query),
      headers: merged,
    );
    return _parseResponse(res);
  }

  Map<String, dynamic> _parseResponse(http.Response res) {
    final code = res.statusCode;
    Map<String, dynamic> bodyMap = {};
    try {
      bodyMap = json.decode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON (HTTP $code): ${res.body}');
    }
    if (code >= 200 && code < 300) return bodyMap;

    if (code == 401) {
      throw Exception(bodyMap['message']?.toString() ?? 'Unauthorized (401)');
    }
    if (code == 422) {
      final errors = bodyMap['errors'];
      if (errors is Map) {
        final firsts = errors.entries
            .map((e) => '${e.key}: ${(e.value as List).first}')
            .join(' | ');
        throw Exception(firsts.isNotEmpty ? firsts : 'Validation error (422)');
      }
      throw Exception(
          bodyMap['message']?.toString() ?? 'Unprocessable Entity (422)');
    }
    if (code == 419) {
      throw Exception(bodyMap['message']?.toString() ?? 'Page expired (419)');
    }

    final msg = bodyMap['message']?.toString() ?? 'HTTP $code';
    throw Exception(msg);
  }
}
