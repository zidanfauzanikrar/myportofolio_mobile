import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/format.dart';

/// Halaman detail satu experience. Tanpa drawer agar AppBar menampilkan
/// tombol kembali ke daftar.
class ExperienceDetailScreen extends StatelessWidget {
  final Experience experience;

  const ExperienceDetailScreen({super.key, required this.experience});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String? thumbnail = experience.thumbnail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar hanya ditampilkan jika URL thumbnail tidak kosong.
                if (thumbnail != null && thumbnail.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      thumbnail,
                      width: double.infinity,
                      height: 220.0,
                      fit: BoxFit.cover,
                      // Jika gambar gagal dimuat (URL salah atau diblokir CORS).
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                        height: 220.0,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
                Text(
                  experience.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
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
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 18.0),
                    const SizedBox(width: 6.0),
                    Text(experiencePeriod(experience)),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Deskripsi',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(experience.description),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      experience.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6.0),
                    Text('${experience.starCount} star'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}