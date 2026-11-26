import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/theme_controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    // MultiProvider membungkus aplikasi dan menyediakan objek yang dipakai
    // berulang oleh banyak widget, seperti ApiClient dan status autentikasi.
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthState(apiClient)),
      ],
      // MaterialApp dibangun ulang setiap mode tema berubah (Dark Mode).
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'MyPortfolio',
            themeMode: mode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}
