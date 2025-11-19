import 'package:flutter/material.dart';

class RequestAssistScreen extends StatelessWidget {
  const RequestAssistScreen({
    super.key,
    required this.issue,
  });

  final String issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: later – pull selected vehicle & location from state
    const vehicleName = 'Toyota Corolla';
    const vehiclePlate = 'GR 1234-24';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary card
            _SummaryCard(
              issue: issue,
              vehicleName: vehicleName,
              vehiclePlate: vehiclePlate,
            ),
            const SizedBox(height: 16),

            // Location card
            _LocationCard(),

            const Spacer(),

            // Bottom CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // Later: call Supabase RPC to find providers
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Next: search nearby providers via Supabase.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Search nearby providers'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We’ll show you verified providers within your coverage radius and membership benefits.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.issue,
    required this.vehicleName,
    required this.vehiclePlate,
  });

  final String issue;
  final String vehicleName;
  final String vehiclePlate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.directions_car_filled_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$vehicleName • $vehiclePlate',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.08),
              child: Icon(
                Icons.my_location_outlined,
                color: colorScheme.primary,
              ),
            ),
            title: const Text('Use my current GPS location'),
            subtitle: Text(
              'We’ll ask for permission to access your location.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              // TODO: integrate location plugin later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'GPS location request coming soon.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.edit_location_alt_outlined,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Set location on map'),
            subtitle: Text(
              'Tap and drag a pin to where your vehicle is.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              // Later: navigate to a map picker screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Map picker screen coming soon.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}