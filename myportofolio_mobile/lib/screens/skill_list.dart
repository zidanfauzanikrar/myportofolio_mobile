import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/services/skill_service.dart';
import 'package:myportofolio_mobile/widgets/error_view.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/skill_card.dart';

class SkillListPage extends StatefulWidget {
  const SkillListPage({super.key});

  @override
  State<SkillListPage> createState() => _SkillListPageState();
}

class _SkillListPageState extends State<SkillListPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Skill>> _futureSkills;

  // Kunci kategori yang dipilih (misalnya 'soft_skill'); null berarti semua.
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _futureSkills = fetchSkills();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Memuat ulang daftar dari API dengan pencarian dan filter yang aktif.
  void _reload() {
    setState(() {
      _futureSkills = fetchSkills(
        title: _searchController.text.trim(),
        category: _selectedCategory,
      );
    });
  }

  Widget _buildCategoryChip({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategory == value,
        onSelected: (_) {
          _selectedCategory = value;
          _reload();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      // Lebar isi dibatasi agar tetap rapi di jendela Chrome yang lebar.
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _reload(),
                  decoration: InputDecoration(
                    hintText: 'Cari judul skill',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _reload();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              // Filter kategori, sesuai pilihan SKILL_CHOICES di backend.
              SizedBox(
                height: 48.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  children: [
                    _buildCategoryChip(label: 'Semua', value: null),
                    for (final entry in Skill.categoryLabels.entries)
                      _buildCategoryChip(
                        label: entry.value,
                        value: entry.key,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Skill>>(
                  future: _futureSkills,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return ErrorView(
                        message: '${snapshot.error}',
                        onRetry: _reload,
                      );
                    }
                    final skills = snapshot.data ?? [];
                    if (skills.isEmpty) {
                      return const Center(child: Text('Belum ada skill.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: skills.length,
                      itemBuilder: (context, index) =>
                          SkillCard(skill: skills[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}