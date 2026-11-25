import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';

/// Kartu satu experience: thumbnail, judul, kategori, status, periode,
/// deskripsi, dan jumlah star.
class ExperienceCard extends StatelessWidget {
  final Experience experience;

  const ExperienceCard({super.key, required this.experience});

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  // Contoh: "3 Mar 2025 - Sekarang" atau "3 Mar 2025 - 1 Jun 2025".
  String get _period {
    final start = experience.startedAt;
    final end = experience.endedAt;
    final startText = start == null ? '-' : _formatDate(start);
    final endText = end == null ? 'Sekarang' : _formatDate(end);
    return '$startText - $endText';
  }

  @override
  Widget build(BuildContext context) {
    final String? thumbnail = experience.thumbnail;

    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thumbnail != null && thumbnail.isNotEmpty)
            Image.network(
              thumbnail,
              height: 160.0,
              width: double.infinity,
              fit: BoxFit.cover,
              // Jika gambar gagal dimuat (URL salah atau diblokir CORS di web).
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 160.0,
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 40.0),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    if (experience.category.isNotEmpty)
                      Chip(label: Text(experience.categoryLabel)),
                    Chip(
                      avatar: Icon(
                        experience.isOngoing
                            ? Icons.timelapse
                            : Icons.check_circle_outline,
                        size: 18.0,
                        color: experience.isOngoing ? Colors.green : null,
                      ),
                      label: Text(
                        experience.isOngoing ? 'Ongoing' : 'Completed',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16.0),
                    const SizedBox(width: 6.0),
                    Text(_period),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  experience.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      experience.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text('${experience.starCount}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}