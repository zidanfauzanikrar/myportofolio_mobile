import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Mengambil daftar skill dari API. GET bersifat publik (tanpa login).
/// Mendukung filter `?title=` dan `?category=` seperti di backend.
Future<List<Skill>> fetchSkills({String? title, String? category}) async {
  final params = <String, String>{
    if (title != null && title.isNotEmpty) 'title': title,
    if (category != null && category.isNotEmpty) 'category': category,
  };
  final uri = Uri.parse('$apiBaseUrl/api/v1/skills/')
      .replace(queryParameters: params.isEmpty ? null : params);

  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception('Gagal memuat skill (kode ${response.statusCode})');
  }

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  // Mendukung respons array langsung maupun berpaginasi ({"results": [...]}).
  final List<dynamic> data = decoded is List
      ? decoded
      : (decoded as Map<String, dynamic>)['results'] as List<dynamic>;
  return data
      .map((item) => Skill.fromJson(item as Map<String, dynamic>))
      .toList();
}