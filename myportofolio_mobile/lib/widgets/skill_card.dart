import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Kartu satu skill: judul, kategori, deskripsi, dan jumlah star.
/// Isi parameter [onTap] untuk membuka halaman detail.
class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onTap;

  const SkillCard({super.key, required this.skill, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
