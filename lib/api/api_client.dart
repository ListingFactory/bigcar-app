import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/listing.dart';

class ApiClient {
  // iOS 시뮬레이터는 mac의 localhost와 동일. 실기기는 mac IP 사용.
  static const String baseUrl = 'http://localhost:8080/api/v1';

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String? t) async {
    _token = t;
    final prefs = await SharedPreferences.getInstance();
    if (t == null) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', t);
    }
  }

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ===== Home / Listings =====
  Future<Map<String, dynamic>> home() async {
    final r = await http.get(Uri.parse('$baseUrl/home'), headers: _headers);
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  Future<List<Listing>> listings({Map<String, dynamic>? params}) async {
    final uri = Uri.parse('$baseUrl/listings').replace(
      queryParameters: params?.map((k, v) => MapEntry(k, v.toString())),
    );
    final r = await http.get(uri, headers: _headers);
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    return ((j['data'] as List?) ?? []).map((e) => Listing.fromJson(e)).toList();
  }

  Future<Listing> listing(String slug) async {
    final r = await http.get(Uri.parse('$baseUrl/listings/$slug'), headers: _headers);
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    return Listing.fromJson(j['data'] ?? j);
  }

  Future<List<CategoryModel>> categories() async {
    final r = await http.get(Uri.parse('$baseUrl/categories'), headers: _headers);
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    return ((j['data'] as List?) ?? []).map((e) => CategoryModel.fromJson(e)).toList();
  }

  // ===== Auth =====
  Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password, 'device_name': 'flutter-ios'}),
    );
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode == 200 && j['token'] != null) {
      await setToken(j['token']);
      return j;
    }
    throw j['message'] ?? '로그인 실패';
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, {String? phone, String accountType = 'member'}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone_e164': phone,
        'account_type': accountType,
        'device_name': 'flutter-ios',
      }),
    );
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode == 201 && j['token'] != null) {
      await setToken(j['token']);
      return j;
    }
    throw j['message'] ?? '회원가입 실패';
  }

  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _headers);
    } catch (_) {}
    await setToken(null);
  }

  Future<Map<String, dynamic>?> me() async {
    if (_token == null) return null;
    final r = await http.get(Uri.parse('$baseUrl/me'), headers: _headers);
    if (r.statusCode != 200) return null;
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  Future<bool> sendInquiry(String slug, {required String name, required String phone, String? email, required String message}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/listings/$slug/inquiry'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        'message': message,
      }),
    );
    return r.statusCode == 201;
  }

  bool get isAuthenticated => _token != null;
}

// Singleton
final apiClient = ApiClient();
