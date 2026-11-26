import 'package:myportofolio_mobile/models/experience.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Contoh: `3 Mar 2025` (dalam zona waktu perangkat).
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// Contoh: `3 Mar 2025 - Sekarang` atau `3 Mar 2025 - 1 Jun 2025`.
String experiencePeriod(Experience experience) {
  final start = experience.startedAt;
  final end = experience.endedAt;
  final startText = start == null ? '-' : formatDate(start);
  final endText = end == null ? 'Sekarang' : formatDate(end);
  return '$startText - $endText';
}
