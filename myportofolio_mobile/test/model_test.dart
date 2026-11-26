import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/skill.dart';

void main() {
  test('Skill.fromJson membaca field snake_case dan nilai default', () {
    final skill = Skill.fromJson({
      'id': 'abc',
      'title': 'Dart',
      'description': 'Bahasa pemrograman',
      'category': 'programming_language',
      'category_display': 'Programming Language',
    });

    expect(skill.title, 'Dart');
    expect(skill.categoryLabel, 'Programming Language');
    expect(skill.starCount, 0);
  });

  test('Skill.toJson tidak mengirim field read-only server', () {
    const skill = Skill(
      id: 'abc',
      title: 'Dart',
      description: 'Bahasa pemrograman',
      category: 'programming_language',
    );

    final json = skill.toJson();
    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('star_count'), isFalse);
    expect(json['title'], 'Dart');
  });
}