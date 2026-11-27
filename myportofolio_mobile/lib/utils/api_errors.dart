import 'package:myportofolio_mobile/services/api_client.dart';

/// Pesan untuk pengguna dari [ApiException] saat menyimpan, memperbarui,
/// atau menghapus data. Status 401 ditangani langsung oleh pemanggil
/// (menghapus sesi lalu meminta login ulang), bukan lewat fungsi ini.
String apiErrorMessage(ApiException e, {required String action}) {
  switch (e.statusCode) {
    case 400:
      return 'Gagal $action (kode 400).\n${e.message}';
    case 403:
      return 'Gagal $action: hanya pemilik portofolio yang boleh melakukan '
          'ini (kode 403).';
    case 404:
      return 'Gagal $action: data sudah tidak ada di server (kode 404).';
    default:
      return 'Gagal $action (kode ${e.statusCode}).';
  }
}
