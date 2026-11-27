import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Experience yang disinkronkan dengan Django REST Framework API
/// (endpoint: /api/v1/experience/).
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    this.category = 'full-time',
    this.categoryDisplay = '',
    this.thumbnail,
    this.endedAt,
    this.id,
    this.startedAt,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// Pilihan kategori di backend (kunci -> label), sesuai EXPERIENCE_CHOICES.
  static const Map<String, String> categoryLabels = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  // Field read-only dari server tidak ikut dikirim saat POST/PUT/PATCH.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  @JsonKey(defaultValue: 'full-time')
  final String category;

  /// Label kategori dari server (`category_display`), hanya untuk dibaca.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  /// URL gambar (opsional, boleh kosong di backend).
  final String? thumbnail;

  /// Diisi otomatis server saat data dibuat (auto_now_add).
  @JsonKey(includeToJson: false)
  final DateTime? startedAt;

  /// Null berarti pengalaman masih berlangsung.
  final DateTime? endedAt;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  /// Masih berlangsung bila belum ada tanggal selesai. Dihitung di sini
  /// dengan aturan yang sama seperti `is_ongoing` yang dikirim server.
  bool get isOngoing => endedAt == null || endedAt!.isAfter(DateTime.now());

  /// Label yang ramah dibaca, misalnya `part-time` menjadi `Part-Time`.
  /// Memakai `category_display` dari server, dengan cadangan peta lokal.
  String get categoryLabel => categoryDisplay.isNotEmpty
      ? categoryDisplay
      : (categoryLabels[category] ?? category);

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}
