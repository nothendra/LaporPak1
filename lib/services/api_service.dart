import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Resolve base URL dynamically; allow override via --dart-define=API_BASE_URL
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty)
      return fromEnv.endsWith('/api') ? fromEnv : '$fromEnv/api';

    // Defaults per platform
    if (kIsWeb) {
      // Expect same origin proxy or explicit define
      return '/api';
    }
    // For emulators/simulators
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android)) {
      return 'http://10.0.2.2:8000/api';
    }
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS)) {
      return 'http://localhost:8000/api';
    }
    // Fallback to localhost; for physical devices, pass API_BASE_URL via dart-define
    return 'http://127.0.0.1:8000/api';
  }

  // Headers for API requests
  static Map<String, String> _headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (body.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) return {};
      throw Exception('Empty response (status $statusCode)');
    }

    try {
      final decoded = json.decode(body);
      if (statusCode >= 200 && statusCode < 300) return decoded;
      final message =
          decoded is Map<String, dynamic>
              ? (decoded['message'] ?? decoded['error'] ?? 'Request failed')
              : 'Request failed';
      throw Exception(message);
    } catch (_) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'raw': body};
      }
      final snippet = body.length > 160 ? body.substring(0, 160) : body;
      throw Exception('Unexpected response (status $statusCode): $snippet');
    }
  }

  static Future<http.Response> _safeGet(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    _logRequest('GET', uri.toString());
    return await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _safePost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    _logRequest('POST', uri.toString());
    return await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _safePut(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    _logRequest('PUT', uri.toString());
    return await http
        .put(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  static void _logRequest(String method, String url) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[API] $method $url');
    }
  }

  // Register a new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _safePost(
      Uri.parse('$baseUrl/register'),
      headers: _headers(),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role':
            role.toLowerCase(), // Convert to lowercase to match backend expectations
      }),
    );

    return _handleResponse(response);
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _safePost(
      Uri.parse('$baseUrl/login'),
      headers: _headers(),
      body: json.encode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  // Logout user
  static Future<Map<String, dynamic>> logout(String token) async {
    final response = await _safePost(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  // Helper to get base host (without /api) for media URLs
  static String get baseHost {
    final uri = Uri.parse(baseUrl);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }

  // ===================== Aduan (Reports) =====================

  // Simple health check
  static Future<Map<String, dynamic>> ping() async {
    final res = await _safeGet(Uri.parse(baseUrl));
    return _handleResponse(res);
  }

  // Create Aduan (multipart for photo)
  static Future<Map<String, dynamic>> createAduan({
    required String token,
    required String judul,
    required String deskripsi,
    required String tanggal, // format YYYY-MM-DD
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/aduan');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['tanggal'] = tanggal;

    if (foto != null) {
      final fileStream = http.ByteStream(foto.openRead());
      final length = await foto.length();
      final multipartFile = http.MultipartFile(
        'foto',
        fileStream,
        length,
        filename: foto.path.split('/').last.split('\\').last,
      );
      request.files.add(multipartFile);
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  // Get Aduan list for warga (optionally filter by status 1,2,3)
  static Future<Map<String, dynamic>> getWargaAduan({
    required String token,
    int? status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/warga/aduan${status != null ? '?status=$status' : ''}',
    );
    final response = await _safeGet(uri, headers: _headers(token: token));
    return _handleResponse(response);
  }

  // Get all Aduan (RT/Admin)
  static Future<Map<String, dynamic>> getAllAduan({
    required String token,
    int? status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/aduan${status != null ? '?status=$status' : ''}',
    );
    final response = await _safeGet(uri, headers: _headers(token: token));
    return _handleResponse(response);
  }

  // Get detail Aduan
  static Future<Map<String, dynamic>> getAduanDetail({
    required String token,
    required int id,
  }) async {
    final response = await _safeGet(
      Uri.parse('$baseUrl/aduan/$id'),
      headers: _headers(token: token),
    );
    return _handleResponse(response);
  }

  // RT: send recommendation
  static Future<Map<String, dynamic>> sendRecommendation({
    required String token,
    required int aduanId,
    required int recommendedStatus, // 1,2,3
    String? notes,
  }) async {
    final response = await _safePost(
      Uri.parse('$baseUrl/aduan/$aduanId/recommend'),
      headers: _headers(token: token),
      body: json.encode({
        'recommended_status': recommendedStatus,
        if (notes != null) 'notes': notes,
      }),
    );
    return _handleResponse(response);
  }

  // Admin: list recommendations
  static Future<Map<String, dynamic>> getRecommendations({
    required String token,
    String status = 'pending', // pending|approved|rejected
  }) async {
    final response = await _safeGet(
      Uri.parse('$baseUrl/admin/recommendations?status=$status'),
      headers: _headers(token: token),
    );
    return _handleResponse(response);
  }

  // Admin: handle recommendation (approve/reject)
  static Future<Map<String, dynamic>> handleRecommendation({
    required String token,
    required int recommendationId,
    required String action, // approve|reject
    String? adminNotes,
  }) async {
    final response = await _safePost(
      Uri.parse('$baseUrl/admin/recommendations/$recommendationId/handle'),
      headers: _headers(token: token),
      body: json.encode({
        'action': action,
        if (adminNotes != null) 'admin_notes': adminNotes,
      }),
    );
    return _handleResponse(response);
  }

  // Admin: update aduan status directly
  static Future<Map<String, dynamic>> updateAduanStatus({
    required String token,
    required int aduanId,
    required int status, // 1,2,3
  }) async {
    final response = await _safePut(
      Uri.parse('$baseUrl/aduan/$aduanId/status'),
      headers: _headers(token: token),
      body: json.encode({'status': status}),
    );
    return _handleResponse(response);
  }
}
