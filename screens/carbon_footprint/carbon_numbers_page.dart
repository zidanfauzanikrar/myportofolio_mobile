import 'package:flutter/material.dart';

import 'carbon_module_widgets.dart';

class CarbonNumbersPage extends StatelessWidget {
  const CarbonNumbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CarbonPageScaffold(
      title: 'Numbers',
      subtitle: 'Ringkasan dampak karbon dari satu item pakaian.',
      endpoint: 'GET /api/carbon/numbers/?item=<id>',
      children: [
        Text('Ringkasan'),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CarbonMetricPlaceholder(
                label: 'Total emisi',
                icon: Icons.cloud_outlined,
                unit: 'kg CO₂e',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: CarbonMetricPlaceholder(
                label: 'Sustainability score',
                icon: Icons.eco_outlined,
                unit: '/ 100',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CarbonMetricPlaceholder(
                label: 'Cost per wear',
                icon: Icons.payments_outlined,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: CarbonMetricPlaceholder(
                label: 'Estimated wears',
                icon: Icons.repeat_outlined,
                unit: 'kali',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        CarbonPlaceholderPanel(
          icon: Icons.insights_outlined,
          title: 'Statistik item akan ditampilkan di sini',
          description:
              'Data item, emisi CO₂e, jumlah pemakaian, cost per wear, dan skor '
              'akan diambil dari respons endpoint Numbers.',
        ),
      ],
    );
  }
}
