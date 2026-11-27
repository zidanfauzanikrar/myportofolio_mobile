import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/api_errors.dart';
import 'package:myportofolio_mobile/utils/format.dart';
import 'package:provider/provider.dart';

/// Halaman detail satu experience. Tanpa drawer agar AppBar menampilkan
/// tombol kembali ke daftar. Tombol edit dan hapus hanya muncul bila
/// pengguna sudah login.
class ExperienceDetailScreen extends StatefulWidget {
  final Experience experience;

  const ExperienceDetailScreen({super.key, required this.experience});

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  bool _isDeleting = false;

  void _edit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExperienceFormPage(experience: widget.experience),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pengalaman?'),
        content: Text(
          '"${widget.experience.title}" akan dihapus permanen dan tidak bisa '
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
    final id = widget.experience.id;
    if (token == null || id == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await apiClient.deleteExperience(id, token: token);
      if (!mounted) return;

      // Buang halaman detail, lalu buka daftar baru yang memuat ulang data
      // dari server agar pengalaman yang dihapus langsung hilang.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const ExperienceListPage(),
        ),
        (route) => route.isFirst,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Pengalaman berhasil dihapus.')),
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
              content: Text(apiErrorMessage(e, action: 'menghapus pengalaman')),
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
    final experience = widget.experience;
    final String? thumbnail = experience.thumbnail;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (isLoggedIn) ...[
            IconButton(
              tooltip: 'Edit pengalaman',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isDeleting ? null : _edit,
            ),
            IconButton(
              tooltip: 'Hapus pengalaman',
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
                // Gambar hanya ditampilkan jika URL thumbnail tidak kosong.
                if (thumbnail != null && thumbnail.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      thumbnail,
                      width: double.infinity,
                      height: 220.0,
                      fit: BoxFit.cover,
                      // Jika gambar gagal dimuat (URL salah atau diblokir CORS).
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                            height: 220.0,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48.0,
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
                Text(
                  experience.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    if (experience.category.isNotEmpty)
                      Chip(label: Text(experience.categoryLabel)),
                    Chip(
                      avatar: Icon(
                        experience.isOngoing
                            ? Icons.timelapse
                            : Icons.check_circle_outline,
                        size: 18.0,
                        color: experience.isOngoing ? Colors.green : null,
                      ),
                      label: Text(
                        experience.isOngoing ? 'Ongoing' : 'Completed',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 18.0),
                    const SizedBox(width: 6.0),
                    Text(experiencePeriod(experience)),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Deskripsi',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(experience.description),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      experience.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6.0),
                    Text('${experience.starCount} star'),
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
