import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/skill_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/api_errors.dart';
import 'package:provider/provider.dart';

/// Halaman detail satu skill. Tanpa drawer agar AppBar menampilkan
/// tombol kembali ke daftar. Tombol edit dan hapus hanya muncul bila
/// pengguna sudah login.
class SkillDetailScreen extends StatefulWidget {
  final Skill skill;

  const SkillDetailScreen({super.key, required this.skill});

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  bool _isDeleting = false;

  void _edit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillFormPage(skill: widget.skill),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus skill?'),
        content: Text(
          '"${widget.skill.title}" akan dihapus permanen dan tidak bisa '
          'dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);
    final token = auth.token;
    final id = widget.skill.id;
    if (token == null || id == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await apiClient.deleteSkill(id, token: token);
      if (!mounted) return;

      // Buang halaman detail, lalu buka daftar baru yang memuat ulang data
      // dari server agar skill yang dihapus langsung hilang.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (context) => const SkillListPage()),
        (route) => route.isFirst,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Skill berhasil dihapus.')),
        );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token tidak berlaku lagi: keluar dari sesi.
        await auth.logout();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Sesi berakhir. Silakan login kembali.'),
            ),
          );
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(apiErrorMessage(e, action: 'menghapus skill')),
            ),
          );
      }
    } catch (_) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final skill = widget.skill;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (isLoggedIn) ...[
            IconButton(
              tooltip: 'Edit skill',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isDeleting ? null : _edit,
            ),
            IconButton(
              tooltip: 'Hapus skill',
              icon: const Icon(Icons.delete_outline),
              onPressed: _isDeleting ? null : _confirmDelete,
            ),
          ],
        ],
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
