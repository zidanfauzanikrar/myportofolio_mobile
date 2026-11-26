import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/skill_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/error_view.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/skill_card.dart';
import 'package:provider/provider.dart';

class SkillListPage extends StatefulWidget {
  const SkillListPage({super.key});

  @override
  State<SkillListPage> createState() => _SkillListPageState();
}

class _SkillListPageState extends State<SkillListPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Skill>> _skillsFuture;

  // Kunci kategori yang dipilih (misalnya 'soft_skill'); null berarti semua.
  String? _selectedCategory;

  // Memanggil API dengan pencarian dan filter yang sedang aktif.
  Future<List<Skill>> _fetch() => context.read<ApiClient>().getSkills(
    title: _searchController.text.trim(),
    category: _selectedCategory,
  );

  @override
  void initState() {
    super.initState();
    // Future dibuat sekali di initState, bukan di build(), agar permintaan
    // HTTP tidak terkirim ulang setiap widget dibangun ulang.
    _skillsFuture = _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final future = _fetch();
    setState(() {
      _skillsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
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
                      _buildCategoryChip(label: entry.value, value: entry.key),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Skill>>(
                  future: _skillsFuture,
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

                    final skills = snapshot.data ?? const <Skill>[];

                    // Daftar kosong: pull-to-refresh tetap berfungsi.
                    if (skills.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _reload,
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: const Center(
                                    child: Text('Belum ada skill.'),
                                  ),
                                ),
                              ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8.0),
                        itemCount: skills.length,
                        itemBuilder: (context, index) {
                          final skill = skills[index];
                          return SkillCard(
                            skill: skill,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SkillDetailScreen(skill: skill),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
