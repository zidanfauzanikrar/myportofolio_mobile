import 'package:material_ui/material_ui.dart';

/// Menyimpan mode tema aplikasi (terang atau gelap).
/// Dibaca oleh MaterialApp dan diubah lewat switch di drawer.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);
