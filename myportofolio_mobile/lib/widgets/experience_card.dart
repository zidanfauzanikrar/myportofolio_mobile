import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/format.dart';

/// Kartu satu experience: thumbnail, judul, kategori, status, periode,
/// deskripsi, dan jumlah star.
/// Isi parameter [onTap] untuk membuka halaman detail.
class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final VoidCallback? onTap;

  const ExperienceCard({super.key, required this.experience, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String? thumbnail = experience.thumbnail;

    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
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
                      Text(experiencePeriod(experience)),
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
      ),
    );
  }
}
