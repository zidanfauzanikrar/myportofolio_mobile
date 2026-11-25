import 'package:flutter/material.dart';

import 'carbon_analyzer_page.dart';
import 'carbon_estimates_page.dart';
import 'carbon_factors_page.dart';
import 'carbon_module_widgets.dart';
import 'carbon_numbers_page.dart';

/// Landing page kerangka Modul Carbon Footprint.
/// Belum melakukan request ke backend; halaman ini untuk tracking progress UI.
class CarbonFootprintHomePage extends StatelessWidget {
  const CarbonFootprintHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Carbon Footprint')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xffdce2d0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MODULE 03 · SUSTAINABILITY',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Carbon footprint tracker',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pantau estimasi emisi dari pakaian, kelola data, dan lihat '
                  'analisis keberlanjutan.',
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Status integrasi API',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '0 / 4 fitur',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 0),
                const SizedBox(height: 8),
                const Text(
                  'Kerangka halaman tersedia. Koneksi API dan pengujian belum dimulai.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Fitur modul', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          CarbonSectionCard(
            title: 'Numbers',
            description: 'Ringkasan emisi untuk item pakaian yang dipilih.',
            icon: Icons.analytics_outlined,
            endpoint: 'GET /api/carbon/numbers/',
            onTap: () => _open(context, const CarbonNumbersPage()),
          ),
          CarbonSectionCard(
            title: 'Estimates',
            description: 'Daftar, tambah, ubah, dan hapus estimasi karbon.',
            icon: Icons.checkroom_outlined,
            endpoint: 'GET/POST /api/carbon/estimates/',
            onTap: () => _open(context, const CarbonEstimatesPage()),
          ),
          CarbonSectionCard(
            title: 'Analyzer',
            description: 'Analisis agregat emisi dengan filter material, kategori, dan sumber.',
            icon: Icons.analytics_outlined,
            endpoint: 'GET /api/carbon/analyzer/analysis/',
            accessLabel: 'Analyzer / Superuser',
            onTap: () => _open(context, const CarbonAnalyzerPage()),
          ),
          CarbonSectionCard(
            title: 'Factors',
            description: 'Pengelolaan faktor emisi material dan berat kategori.',
            icon: Icons.tune_outlined,
            endpoint: 'GET/PUT /api/carbon/analyzer/factors/',
            accessLabel: 'Analyzer / Superuser',
            onTap: () => _open(context, const CarbonFactorsPage()),
          ),
          const SizedBox(height: 12),
          const CarbonPlaceholderPanel(
            icon: Icons.info_outline,
            title: 'Tahap berikutnya',
            description:
                'Hubungkan setiap halaman ke endpoint Django, lalu tambahkan '
                'loading state, error handling, dan pengujian role.',
          ),
        ],
      ),
    );
  }
}
