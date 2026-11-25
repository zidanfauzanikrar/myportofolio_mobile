import 'package:flutter/material.dart';

import 'carbon_module_widgets.dart';

class CarbonFactorsPage extends StatelessWidget {
  const CarbonFactorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CarbonPageScaffold(
      title: 'Factors',
      subtitle: 'Pengaturan faktor emisi dan berat default kategori pakaian.',
      endpoint: 'GET/PUT /api/carbon/analyzer/factors/ · POST /api/carbon/analyzer/factors/reset/',
      children: [
        Text('Faktor emisi per material'),
        SizedBox(height: 8),
        CarbonPlaceholderPanel(
          icon: Icons.layers_outlined,
          title: 'Material factors',
          description:
              'Nilai Cotton, Polyester, Wool, dan Silk akan dimuat dari backend. '
              'Perubahan nilai dilakukan melalui request PUT.',
        ),
        SizedBox(height: 16),
        Text('Berat default per kategori'),
        SizedBox(height: 8),
        CarbonPlaceholderPanel(
          icon: Icons.checkroom_outlined,
          title: 'Category weights',
          description:
              'Berat default T-shirt, Shirt, Dress, Sweater, Jeans, dan Jacket '
              'akan dimuat dari backend.',
        ),
        SizedBox(height: 16),
        CarbonPlaceholderPanel(
          icon: Icons.restart_alt_outlined,
          title: 'Reset factors',
          description:
              'Aksi reset faktor ke nilai bawaan dan opsi menghitung ulang '
              'estimasi offline akan dihubungkan setelah integrasi API.',
        ),
      ],
    );
  }
}
