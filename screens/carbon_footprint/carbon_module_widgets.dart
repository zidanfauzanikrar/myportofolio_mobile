import 'package:flutter/material.dart';

class CarbonStatusChip extends StatelessWidget {
  const CarbonStatusChip({
    super.key,
    this.label = 'Kerangka UI',
    this.icon = Icons.construction_outlined,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class CarbonEndpointLabel extends StatelessWidget {
  const CarbonEndpointLabel({super.key, required this.endpoint});

  final String endpoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.api_outlined, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              endpoint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarbonPlaceholderPanel extends StatelessWidget {
  const CarbonPlaceholderPanel({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.pending_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class CarbonSectionCard extends StatelessWidget {
  const CarbonSectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.endpoint,
    required this.onTap,
    this.accessLabel = 'User',
  });

  final String title;
  final String description;
  final IconData icon;
  final String endpoint;
  final String accessLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(icon, color: scheme.onSecondaryContainer),
                  ),
                  const Spacer(),
                  CarbonStatusChip(),
                ],
              ),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: scheme.primary),
                  const SizedBox(width: 5),
                  Text(accessLabel, style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                endpoint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarbonMetricPlaceholder extends StatelessWidget {
  const CarbonMetricPlaceholder({
    super.key,
    required this.label,
    required this.icon,
    this.unit,
  });

  final String label;
  final IconData icon;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 12),
            Text('--', style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            if (unit != null)
              Text(unit!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class CarbonPageScaffold extends StatelessWidget {
  const CarbonPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.endpoint,
    required this.children,
  });

  final String title;
  final String subtitle;
  final String endpoint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const CarbonStatusChip(label: 'API belum disambungkan'),
          const SizedBox(height: 14),
          CarbonEndpointLabel(endpoint: endpoint),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
