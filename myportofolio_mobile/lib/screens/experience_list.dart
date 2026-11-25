import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/experience_service.dart';
import 'package:myportofolio_mobile/widgets/error_view.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceListPage extends StatefulWidget {
  const ExperienceListPage({super.key});

  @override
  State<ExperienceListPage> createState() => _ExperienceListPageState();
}

class _ExperienceListPageState extends State<ExperienceListPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Experience>> _futureExperiences;

  // Kunci kategori yang dipilih (misalnya 'internship'); null berarti semua.
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _futureExperiences = fetchExperiences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Memuat ulang daftar dari API dengan pencarian dan filter yang aktif.
  void _reload() {
    setState(() {
      _futureExperiences = fetchExperiences(
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
        title: const Text('Experience'),
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
                    hintText: 'Cari judul pengalaman',
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
              // Filter kategori, sesuai pilihan EXPERIENCE_CHOICES di backend.
              SizedBox(
                height: 48.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  children: [
                    _buildCategoryChip(label: 'Semua', value: null),
                    for (final entry in Experience.categoryLabels.entries)
                      _buildCategoryChip(
                        label: entry.value,
                        value: entry.key,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Experience>>(
                  future: _futureExperiences,
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
                    final experiences = snapshot.data ?? [];
                    if (experiences.isEmpty) {
                      return const Center(
                        child: Text('Belum ada pengalaman.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: experiences.length,
                      itemBuilder: (context, index) =>
                          ItemCard(experiences[index] as ItemHomepage),
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