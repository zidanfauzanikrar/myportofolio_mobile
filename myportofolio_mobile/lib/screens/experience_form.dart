import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/format.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _endDateController = TextEditingController();

  // Batas panjang mengikuti model Django (title: max_length=255).
  static const int _maxTitleLength = 255;
  // Default kategori sama dengan default di model Django.
  static const String _defaultCategory = 'full-time';

  String _title = "";
  String _description = "";
  // Kunci kategori mengikuti EXPERIENCE_CHOICES di backend.
  String _category = _defaultCategory;
  String _thumbnail = "";
  DateTime? _endedAt; // null = masih berlangsung
  bool _isSubmitting = false;

  @override
  void dispose() {
    _endDateController.dispose();
    super.dispose();
  }

  // Mengosongkan form sekaligus variabel penampungnya
  void _resetForm() {
    _formKey.currentState!.reset();
    _endDateController.clear();
    setState(() {
      _title = "";
      _description = "";
      _category = _defaultCategory;
      _thumbnail = "";
      _endedAt = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _endedAt = picked;
      _endDateController.text = formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    // Pastikan sudah login; jika belum, buka LoginScreen.
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();
    final token = auth.token;
    if (token == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final thumbnail = _thumbnail.trim();
      final newExperience = Experience(
        title: _title.trim(),
        description: _description.trim(),
        category: _category,
        thumbnail: thumbnail.isEmpty ? null : thumbnail,
        endedAt: _endedAt,
      );
      final created = await apiClient.createExperience(
        newExperience,
        token: token,
      );
      if (!mounted) return;

      // 201 Created: tampilkan dialog konfirmasi.
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pengalaman berhasil ditambahkan!'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${created.title}'),
                  Text('Deskripsi: ${created.description}'),
                  Text('Kategori: ${created.categoryLabel}'),
                  Text('Periode: ${experiencePeriod(created)}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      _resetForm();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ExperienceListPage()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token tidak berlaku lagi: keluar, lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showMessage('Sesi berakhir. Silakan login kembali.');
        await ensureLoggedIn(context);
      } else {
        final detail = e.statusCode == 400 ? '\n${e.message}' : '';
        _showMessage(
          'Gagal menyimpan pengalaman (kode ${e.statusCode}).$detail',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Pengalaman",
                    labelText: "Nama Pengalaman",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama pengalaman tidak boleh kosong!";
                    }
                    if (value.trim().length > _maxTitleLength) {
                      return "Nama pengalaman maksimal $_maxTitleLength karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Deskripsi Pengalaman",
                    labelText: "Deskripsi Pengalaman",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Deskripsi pengalaman tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category (pilihan sama dengan EXPERIENCE_CHOICES) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kategori Pengalaman",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _defaultCategory,
                  items: Experience.categoryLabels.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Thumbnail URL (opsional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: "https://contoh.com/gambar.jpg",
                    labelText: "URL Thumbnail (opsional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _thumbnail = value;
                    });
                  },
                  validator: (String? value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null; // opsional
                    final uri = Uri.tryParse(text);
                    final valid =
                        uri != null &&
                        uri.hasAuthority &&
                        (uri.scheme == 'http' || uri.scheme == 'https');
                    return valid
                        ? null
                        : "URL harus diawali http:// atau https://";
                  },
                ),
              ),

              // === Tanggal Selesai (opsional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  onTap: _pickEndDate,
                  decoration: InputDecoration(
                    hintText: "Kosongkan jika masih berlangsung",
                    labelText: "Tanggal Selesai (opsional)",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _endedAt = null;
                          _endDateController.clear();
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(_isSubmitting ? 'Menyimpan...' : 'Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
