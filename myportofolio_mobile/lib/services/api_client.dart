import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: query);
  }

  // ---------------------------------------------------------------------------
  // Skill  (/api/v1/skills/)
  // ---------------------------------------------------------------------------

  /// Daftar skill. GET bersifat publik; mendukung filter `title` dan `category`.
  Future<List<Skill>> getSkills({String? title, String? category}) async {
    final response = await _client.get(
      _uri('/api/v1/skills/', {
        if (title != null && title.isNotEmpty) 'title': title,
        if (category != null && category.isNotEmpty) 'category': category,
      }),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    return _decodeList(response)
        .map((item) => Skill.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Skill> createSkill(Skill skill, {required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/skills/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(skill.toJson()),
    );
    _ensureSuccess(response);

    return Skill.fromJson(_decodeObject(response));
  }

  // ---------------------------------------------------------------------------
  // Experience  (/api/v1/experience/)
  // ---------------------------------------------------------------------------

  /// Daftar experience. GET bersifat publik; mendukung filter `title` dan
  /// `category`.
  Future<List<Experience>> getExperiences({
    String? title,
    String? category,
  }) async {
    final response = await _client.get(
      _uri('/api/v1/experience/', {
        if (title != null && title.isNotEmpty) 'title': title,
        if (category != null && category.isNotEmpty) 'category': category,
      }),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    return _decodeList(response)
        .map((item) => Experience.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/experience/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(experience.toJson()),
    );
    _ensureSuccess(response);

    return Experience.fromJson(_decodeObject(response));
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// Menukar username dan password dengan token.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    return _decodeObject(response)['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      },
    );
    _ensureSuccess(response);
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, _bodyText(response));
  }

  // bodyBytes didecode sebagai UTF-8 agar karakter non-ASCII tidak rusak
  // (response.body memakai Latin-1 bila server tidak menyertakan charset).
  String _bodyText(http.Response response) =>
      utf8.decode(response.bodyBytes, allowMalformed: true);

  Map<String, dynamic> _decodeObject(http.Response response) =>
      jsonDecode(_bodyText(response)) as Map<String, dynamic>;

  // Mendukung respons array langsung maupun berpaginasi ({"results": [...]}).
  List<dynamic> _decodeList(http.Response response) {
    final decoded = jsonDecode(_bodyText(response));
    if (decoded is List) {
      return decoded;
    }
    return (decoded as Map<String, dynamic>)['results'] as List<dynamic>;
  }
}