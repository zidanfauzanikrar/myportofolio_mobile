import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Kartu yang menampilkan satu skill: judul, kategori, deskripsi, dan jumlah star.
class SkillCard extends StatelessWidget {
  final Skill skill;

  const SkillCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    skill.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (skill.category.isNotEmpty)
                  Chip(label: Text(skill.categoryLabel)),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              skill.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  skill.isStarred ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20.0,
                ),
                const SizedBox(width: 4.0),
                Text('${skill.starCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}