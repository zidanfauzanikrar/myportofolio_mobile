import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Halaman detail satu skill. Tanpa drawer agar AppBar menampilkan
/// tombol kembali ke daftar.
class SkillDetailScreen extends StatelessWidget {
  final Skill skill;

  const SkillDetailScreen({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Detail'),
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
                Text(
                  skill.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                if (skill.category.isNotEmpty)
                  Chip(label: Text(skill.categoryLabel)),
                const SizedBox(height: 16.0),
                Text(
                  'Deskripsi',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(skill.description),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      skill.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6.0),
                    Text('${skill.starCount} star'),
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
