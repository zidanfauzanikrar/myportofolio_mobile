import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/api_errors.dart';
import 'package:myportofolio_mobile/utils/format.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key, this.experience});

  /// Bila diisi, form berjalan dalam mode edit (PATCH) untuk experience ini.
  final Experience? experience;

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

  bool get _isEditing => widget.experience != null;

  // Kategori awal: milik experience yang diedit, atau default model.
  String get _initialCategory {
    final category = widget.experience?.category;
    return category != null && Experience.categoryLabels.containsKey(category)
        ? category
        : _defaultCategory;
  }

  @override
  void initState() {
    super.initState();
    final experience = widget.experience;
    if (experience != null) {
      _title = experience.title;
      _description = experience.description;
      _thumbnail = experience.thumbnail ?? '';
      _endedAt = experience.endedAt;
      final endedAt = experience.endedAt;
      if (endedAt != null) {
        _endDateController.text = formatDate(endedAt);
      }
    }
    _category = _initialCategory;
  }

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

    final editId = widget.experience?.id;
    if (_isEditing && editId == null) {
      _showMessage(
        'Pengalaman ini belum punya ID dari server, tidak bisa diedit.',
      );
      return;
    }

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
      final created = _isEditing
          ? await apiClient.updateExperience(
              editId!,
              newExperience,
              token: token,
            )
          : await apiClient.createExperience(newExperience, token: token);
      if (!mounted) return;

      // Sukses (201 untuk tambah, 200 untuk edit): tampilkan dialog konfirmasi.
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              _isEditing
                  ? 'Pengalaman berhasil diperbarui!'
                  : 'Pengalaman berhasil ditambahkan!',
            ),
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
      final listRoute = MaterialPageRoute<void>(
        builder: (context) => const ExperienceListPage(),
      );
      if (_isEditing) {
        // Buang halaman edit dan detail (datanya sudah usang), sisakan halaman
        // awal, lalu buka daftar baru yang memuat ulang data dari server.
        Navigator.pushAndRemoveUntil(
          context,
          listRoute,
          (route) => route.isFirst,
        );
      } else {
        Navigator.pushReplacement(context, listRoute);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token tidak berlaku lagi: keluar, lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showMessage('Sesi berakhir. Silakan login kembali.');
        await ensureLoggedIn(context);
      } else {
        _showMessage(
          apiErrorMessage(
            e,
            action: _isEditing
                ? 'memperbarui pengalaman'
                : 'menyimpan pengalaman',
          ),
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
        title: _isEditing
            ? const Text('Edit Experience Form')
            : const Center(child: Text('Add Experience Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // Mode edit tanpa drawer agar AppBar menampilkan tombol kembali.
      drawer: _isEditing ? null : const LeftDrawer(),
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
                  initialValue: widget.experience?.title,
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
                  initialValue: widget.experience?.description,
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
                  initialValue: _initialCategory,
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
                  initialValue: widget.experience?.thumbnail,
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
