import 'package:material_ui/material_ui.dart';

/// Tampilan saat data gagal dimuat dari server, dengan tombol coba lagi.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48.0),
            const SizedBox(height: 12.0),
            const Text(
              'Gagal memuat data dari server.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12.0),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
