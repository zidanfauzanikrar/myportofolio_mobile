import 'package:json_annotation/json_annotation.dart';

part 'skill.g.dart';

/// Skill yang disinkronkan dengan Django REST Framework API
/// (endpoint: /api/v1/skills/).
@JsonSerializable(fieldRename: FieldRename.snake)
class Skill {
  const Skill({
    required this.title,
    required this.description,
    required this.category,
    this.categoryDisplay = '',
    this.id,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

  /// Pilihan kategori di backend (kunci -> label), sesuai SKILL_CHOICES.
  static const Map<String, String> categoryLabels = {
    'language': 'Language',
    'programming_language': 'Programming Language',
    'soft_skill': 'Soft-skill',
    'hard_skill': 'Hard-skill',
  };

  // Field read-only dari server tidak ikut dikirim saat POST/PUT/PATCH.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  @JsonKey(defaultValue: '')
  final String category;

  /// Label kategori dari server (`category_display`), hanya untuk dibaca.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  /// Label yang ramah dibaca, misalnya `soft_skill` menjadi `Soft-skill`.
  /// Memakai `category_display` dari server, dengan cadangan peta lokal.
  String get categoryLabel => categoryDisplay.isNotEmpty
      ? categoryDisplay
      : (categoryLabels[category] ?? category);

  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
