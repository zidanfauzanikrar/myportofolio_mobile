import 'package:flutter/material.dart';

import 'carbon_module_widgets.dart';

class CarbonAnalyzerPage extends StatelessWidget {
  const CarbonAnalyzerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CarbonPageScaffold(
      title: 'Analyzer',
      subtitle: 'Analisis gabungan secara anonim dari seluruh estimasi pengguna.',
      endpoint: 'GET /api/carbon/analyzer/analysis/?material=&category=&source=',
      children: [
        Text('Filter analisis'),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Material')),
            Chip(label: Text('Category')),
            Chip(label: Text('Source')),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CarbonMetricPlaceholder(
                label: 'Total estimates',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: CarbonMetricPlaceholder(
                label: 'Average CO₂e',
                icon: Icons.cloud_outlined,
                unit: 'kg CO₂e',
              ),
            ),
          ],
        ),
        CarbonPlaceholderPanel(
          icon: Icons.bar_chart_outlined,
          title: 'Grafik berdasarkan material',
          description: 'Visualisasi rata-rata emisi per material akan dibuat di tahap UI berikutnya.',
        ),
        SizedBox(height: 12),
        CarbonPlaceholderPanel(
          icon: Icons.pie_chart_outline,
          title: 'Grafik berdasarkan kategori',
          description: 'Visualisasi distribusi emisi dan ringkasan sumber data akan ditampilkan di sini.',
        ),
        SizedBox(height: 12),
        CarbonPlaceholderPanel(
          icon: Icons.leaderboard_outlined,
          title: 'Top estimasi',
          description: 'Tabel ringkasan estimasi teratas tanpa menampilkan identitas pengguna.',
        ),
      ],
    );
  }
}
