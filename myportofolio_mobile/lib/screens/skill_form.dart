import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class SkillFormPage extends StatefulWidget {
  const SkillFormPage({super.key});

  @override
  State<SkillFormPage> createState() => _SkillFormPageState();
}

class _SkillFormPageState extends State<SkillFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Batas panjang mengikuti model Django (title: max_length=255).
  static const int _maxTitleLength = 255;

  String _title = "";
  String _description = "";
  // Kunci kategori mengikuti SKILL_CHOICES di backend (misalnya 'soft_skill').
  String _category = Skill.categoryLabels.keys.first; // default
  bool _isSubmitting = false;

  // Mengosongkan form sekaligus variabel penampungnya
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _title = "";
      _description = "";
      _category = Skill.categoryLabels.keys.first;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
      final newSkill = Skill(
        title: _title.trim(),
        description: _description.trim(),
        category: _category,
      );
      final created = await apiClient.createSkill(newSkill, token: token);
      if (!mounted) return;

      // 201 Created: tampilkan dialog konfirmasi.
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Skill berhasil ditambahkan!'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${created.title}'),
                  Text('Deskripsi: ${created.description}'),
                  Text('Kategori: ${created.categoryLabel}'),
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
        _showMessage('Gagal menyimpan skill (kode ${e.statusCode}).$detail');
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
        title: const Center(child: Text('Add Skill Form')),
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
              // === Skill Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Skill",
                    labelText: "Nama Skill",
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
                      return "Nama skill tidak boleh kosong!";
                    }
                    if (value.trim().length > _maxTitleLength) {
                      return "Nama skill maksimal $_maxTitleLength karakter!";
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
                    hintText: "Deskripsi Skill",
                    labelText: "Deskripsi Skill",
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
                      return "Deskripsi skill tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category (pilihan sama dengan SKILL_CHOICES di Django) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kategori Skill",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: Skill.categoryLabels.keys.first,
                  items: Skill.categoryLabels.entries
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
