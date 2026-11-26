import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/skill_list.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Di mode gelap, warna kartu digelapkan 40% agar tidak menyilaukan.
    final Color cardColor = isDark
        ? Color.lerp(item.color, Colors.black, 0.4)!
        : item.color;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () async {
          // Ambil dulu objek yang dibutuhkan sebelum ada await.
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final auth = context.read<AuthState>();

          // Menampilkan SnackBar dengan pesan interaktif.
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!"),
              ),
            );

          if (item.name == "Lihat Skill") {
            // Publik: tidak perlu login.
            navigator.push(
              MaterialPageRoute(builder: (context) => const SkillListPage()),
            );
          } else if (item.name == "Lihat Pengalaman") {
            // Publik: tidak perlu login.
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const ExperienceListPage(),
              ),
            );
          } else if (item.name == "Tambah Skill") {
            // Dilindungi: wajib login.
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn) return;
            navigator.push(
              MaterialPageRoute(builder: (context) => const SkillFormPage()),
            );
          } else if (item.name == "Tambah Pengalaman") {
            // Dilindungi: wajib login.
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn) return;
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const ExperienceFormPage(),
              ),
            );
          } else if (item.name == "Logout") {
            if (auth.isLoggedIn) {
              await auth.logout();
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Berhasil logout.')),
                );
            } else {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Kamu belum login.')),
                );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
