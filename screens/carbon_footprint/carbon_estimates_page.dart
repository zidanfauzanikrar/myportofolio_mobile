import 'package:flutter/material.dart';

import 'carbon_module_widgets.dart';

class CarbonEstimatesPage extends StatelessWidget {
  const CarbonEstimatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CarbonPageScaffold(
      title: 'Estimates',
      subtitle: 'Kelola estimasi emisi untuk pakaian milik pengguna.',
      endpoint: 'GET/POST /api/carbon/estimates/ · GET/PATCH/DELETE /api/carbon/estimates/<id>/',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            Chip(label: Text('Search item')),
            Chip(label: Text('Filter material')),
            Chip(label: Text('Sort')),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daftar estimasi'),
                      SizedBox(height: 4),
                      Text(
                        'Daftar pakaian dan nilai CO₂e akan dimuat dari API.',
                      ),
                    ],
                  ),
                ),
                Icon(Icons.list_alt_outlined, size: 30),
              ],
            ),
          ),
        ),
        const CarbonPlaceholderPanel(
          icon: Icons.inventory_2_outlined,
          title: 'Belum ada data yang ditampilkan',
          description:
              'Tahap UI berikutnya: item card, detail estimasi, form tambah/edit, '
              'preview emisi, dan konfirmasi hapus.',
        ),
        const SizedBox(height: 12),
        const Text('Endpoint pendukung'),
        const SizedBox(height: 8),
        const CarbonEndpointLabel(
          endpoint: 'GET /api/carbon/options/',
        ),
        const SizedBox(height: 8),
        const CarbonEndpointLabel(
          endpoint: 'POST /api/carbon/estimates/preview/',
        ),
      ],
    );
  }
}
