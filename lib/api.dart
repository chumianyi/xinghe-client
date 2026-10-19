import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 星河软件站 API 客户端
class Api {
  static const String base = "http://103.236.99.177:24512/iosipa";
  static String? token;
  static Map<String, dynamic>? me;

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> loadToken() async {
    final p = await _prefs;
    token = p.getString('token');
  }

  static Future<void> setToken(String? t) async {
    token = t;
    final p = await _prefs;
    if (t == null) {
      await p.remove('token');
      me = null;
    } else {
      await p.setString('token', t);
    }
  }

  static Uri _u(String path, Map<String, String>? q) {
    final params = <String, String>{};
    if (q != null) params.addAll(q);
    if (token != null && !params.containsKey('token')) {
      params['token'] = token!;
    }
    return Uri.parse('$base$path').replace(queryParameters: params);
  }

  static Future<Map<String, dynamic>> get(String path,
      [Map<String, String>? q]) async {
    try {
      final r = await http.get(_u(path, q)).timeout(const Duration(seconds: 15));
      return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'msg': '网络连接失败：$e'};
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {bool sendToken = true}) async {
    try {
      final q = <String, String>{};
      if (sendToken && token != null) q['token'] = token!;
      final r = await http
          .post(
            _u(path, q.isEmpty ? null : q),
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'msg': '网络连接失败：$e'};
    }
  }

  // ---- 用户系统 ----
  static Future<Map<String, dynamic>> sendCode(String email) =>
      post('/api/send_code', {'email': email}, sendToken: false);

  static Future<Map<String, dynamic>> register(
          String email, String code, String password) =>
      post('/api/register',
          {'email': email, 'code': code, 'password': password},
          sendToken: false);

  static Future<Map<String, dynamic>> login(String email, String password) =>
      post('/api/login', {'email': email, 'password': password},
          sendToken: false);

  static Future<Map<String, dynamic>> fetchMe() async {
    final r = await get('/api/me');
    if (r['ok'] == true) me = r;
    return r;
  }

  static Future<Map<String, dynamic>> updateProfile(
          {String? name, String? bio}) =>
      post('/api/update_profile', {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
      });

  // ---- APP 商店 ----
  static Future<Map<String, dynamic>> fetchApps() => get('/api/apps');
  static Future<Map<String, dynamic>> fetchRanking() => get('/api/ranking');

  static Future<Map<String, dynamic>> submitApp(Map<String, dynamic> body) =>
      post('/api/submit_app', body);

  static Future<Map<String, dynamic>> download(String appId) =>
      get('/api/download', {'app_id': appId});

  // ---- 评论 ----
  static Future<Map<String, dynamic>> fetchComments(String appId) =>
      get('/api/comments', {'app_id': appId});

  static Future<Map<String, dynamic>> comment(
          String appId, String content, int rating) =>
      post('/api/comment',
          {'app_id': appId, 'content': content, 'rating': rating});

  // ---- 金币 / 消息 ----
  static Future<Map<String, dynamic>> checkin() => get('/api/checkin');
  static Future<Map<String, dynamic>> fetchMessages() => get('/api/messages');

  // ---- 管理后台 ----
  static Future<Map<String, dynamic>> adminLogin(
          String username, String password) =>
      post('/api/admin/login', {'username': username, 'password': password},
          sendToken: false);
  static Future<Map<String, dynamic>> adminPending() => get('/api/admin/pending');
  static Future<Map<String, dynamic>> adminStats() => get('/api/admin/stats');
  static Future<Map<String, dynamic>> adminApprove(String id) =>
      post('/api/admin/approve', {'submission_id': id});
  static Future<Map<String, dynamic>> adminReject(String id) =>
      post('/api/admin/reject', {'submission_id': id});
}
