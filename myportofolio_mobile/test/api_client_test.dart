import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const _baseUrl = 'http://api.test';

const _skillJson = {
  'id': '11111111-1111-1111-1111-111111111111',
  'title': 'Dart',
  'description': 'Bahasa pemrograman',
  'category': 'programming_language',
  'category_display': 'Programming Language',
  'star_count': 2,
  'is_starred': true,
};

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Membuat [ApiClient] dengan [MockClient] dan menyimpan request terakhir.
ApiClient _client(
  http.Response Function(http.Request request) handler, {
  List<http.Request>? log,
}) {
  return ApiClient(
    baseUrl: _baseUrl,
    client: MockClient((request) async {
      log?.add(request);
      return handler(request);
    }),
  );
}

void main() {
  group('GET (publik)', () {
    test(
      'getSkills memakai query filter dan tanpa header Authorization',
      () async {
        final log = <http.Request>[];
        final api = _client((_) => _json([_skillJson]), log: log);

        final skills = await api.getSkills(title: 'da', category: 'soft_skill');

        expect(skills, hasLength(1));
        expect(skills.single.title, 'Dart');
        expect(skills.single.starCount, 2);
        expect(skills.single.isStarred, isTrue);

        final request = log.single;
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/skills/');
        expect(request.url.queryParameters, {
          'title': 'da',
          'category': 'soft_skill',
        });
        expect(request.headers.containsKey('Authorization'), isFalse);
      },
    );

    test('getSkills mendukung respons berpaginasi (results)', () async {
      final api = _client(
        (_) => _json({
          'count': 1,
          'results': [_skillJson],
        }),
      );

      final skills = await api.getSkills();

      expect(skills.single.title, 'Dart');
    });

    test(
      'getExperiences membaca ended_at null sebagai masih berlangsung',
      () async {
        final api = _client(
          (_) => _json([
            {
              'id': '22222222-2222-2222-2222-222222222222',
              'title': 'Asisten Lab',
              'description': 'Membantu praktikum',
              'category': 'part-time',
              'started_at': '2025-03-03T00:00:00Z',
              'ended_at': null,
            },
          ]),
        );

        final experiences = await api.getExperiences();

        expect(experiences.single.isOngoing, isTrue);
        expect(experiences.single.startedAt, isNotNull);
      },
    );
  });

  group('POST (terautentikasi)', () {
    test('createSkill mengirim token dan body tanpa field read-only', () async {
      final log = <http.Request>[];
      final api = _client((_) => _json(_skillJson, 201), log: log);

      final created = await api.createSkill(
        const Skill(
          title: 'Dart',
          description: 'Bahasa pemrograman',
          category: 'programming_language',
        ),
        token: 'abc123',
      );

      expect(created.id, _skillJson['id']);

      final request = log.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/skills/');
      expect(request.headers['Authorization'], 'Token abc123');
      expect(request.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(request.body), {
        'title': 'Dart',
        'description': 'Bahasa pemrograman',
        'category': 'programming_language',
      });
    });
  });

  group('PATCH (terautentikasi)', () {
    test('updateSkill mengirim PATCH ke /skills/<id>/ dengan token', () async {
      final log = <http.Request>[];
      final api = _client(
        (_) => _json({..._skillJson, 'title': 'Dart 3'}),
        log: log,
      );

      final updated = await api.updateSkill(
        _skillJson['id']! as String,
        const Skill(
          title: 'Dart 3',
          description: 'Bahasa pemrograman',
          category: 'programming_language',
        ),
        token: 'abc123',
      );

      expect(updated.title, 'Dart 3');

      final request = log.single;
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/v1/skills/${_skillJson['id']}/');
      expect(request.headers['Authorization'], 'Token abc123');
      expect(jsonDecode(request.body)['title'], 'Dart 3');
    });

    test(
      'updateExperience mengirim ended_at null saat tanggal dikosongkan',
      () async {
        final log = <http.Request>[];
        final api = _client(
          (_) => _json({
            'id': '22222222-2222-2222-2222-222222222222',
            'title': 'Asisten Lab',
            'description': 'Membantu praktikum',
            'category': 'part-time',
            'ended_at': null,
          }),
          log: log,
        );

        final updated = await api.updateExperience(
          '22222222-2222-2222-2222-222222222222',
          const Experience(
            title: 'Asisten Lab',
            description: 'Membantu praktikum',
            category: 'part-time',
          ),
          token: 'abc123',
        );

        expect(updated.isOngoing, isTrue);

        final request = log.single;
        expect(request.method, 'PATCH');
        expect(
          request.url.path,
          '/api/v1/experience/22222222-2222-2222-2222-222222222222/',
        );
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body.containsKey('ended_at'), isTrue);
        expect(body['ended_at'], isNull);
      },
    );
  });

  group('DELETE (terautentikasi)', () {
    test('deleteSkill mengirim DELETE dengan token dan menerima 204', () async {
      final log = <http.Request>[];
      final api = _client((_) => http.Response('', 204), log: log);

      await api.deleteSkill(_skillJson['id']! as String, token: 'abc123');

      final request = log.single;
      expect(request.method, 'DELETE');
      expect(request.url.path, '/api/v1/skills/${_skillJson['id']}/');
      expect(request.headers['Authorization'], 'Token abc123');
    });

    test('deleteExperience memakai endpoint experience', () async {
      final log = <http.Request>[];
      final api = _client((_) => http.Response('', 204), log: log);

      await api.deleteExperience(
        '22222222-2222-2222-2222-222222222222',
        token: 'abc123',
      );

      expect(log.single.method, 'DELETE');
      expect(
        log.single.url.path,
        '/api/v1/experience/22222222-2222-2222-2222-222222222222/',
      );
    });
  });

  group('Penanganan error', () {
    for (final status in [401, 403, 404]) {
      test('status $status dilempar sebagai ApiException', () async {
        final api = _client((_) => _json({'detail': 'ditolak'}, status));

        await expectLater(
          api.deleteSkill('x', token: 't'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', status)
                .having((e) => e.message, 'message', contains('ditolak')),
          ),
        );
      });
    }

    test('updateSkill menerus 400 beserta isi pesan validasi', () async {
      final api = _client(
        (_) => _json({
          'title': ['Field ini tidak boleh kosong.'],
        }, 400),
      );

      await expectLater(
        api.updateSkill(
          'x',
          const Skill(title: '', description: 'd', category: 'soft_skill'),
          token: 't',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                contains('tidak boleh kosong'),
              ),
        ),
      );
    });
  });
}
