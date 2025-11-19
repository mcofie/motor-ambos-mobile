import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssistScreen extends StatefulWidget {
  const AssistScreen({super.key});

  @override
  State<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends State<AssistScreen> {
  int _modeIndex = 0; // 0 = Emergency, 1 = Services
  String _selectedIssue = 'Towing';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmergency = _modeIndex == 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'How can we help today?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEmergency
                  ? 'Select the kind of roadside issue you’re facing.'
                  : 'Book a convenient service for your car.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Mode toggle
            _AssistModeToggle(
              selectedIndex: _modeIndex,
              onChanged: (index) {
                setState(() {
                  _modeIndex = index;
                });
              },
            ),
            const SizedBox(height: 16),

            if (isEmergency)
              _EmergencyAssistSection(
                selectedIssue: _selectedIssue,
                onIssueSelected: (issue) {
                  setState(() {
                    _selectedIssue = issue;
                  });
                },
              )
            else
              const _ServiceBookingSection(),
          ],
        ),
      ),
    );
  }
}

class _AssistModeToggle extends StatelessWidget {
  const _AssistModeToggle({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final labels = ['Emergency', 'Services'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmergencyAssistSection extends StatelessWidget {
  const _EmergencyAssistSection({
    required this.selectedIssue,
    required this.onIssueSelected,
  });

  final String selectedIssue;
  final ValueChanged<String> onIssueSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final issues = <_EmergencyIssue>[
      _EmergencyIssue(
        key: 'Towing',
        icon: Icons.local_shipping_outlined,
        label: 'Towing',
      ),
      _EmergencyIssue(
        key: 'Flat tyre',
        icon: Icons.tire_repair,
        label: 'Flat tyre',
      ),
      _EmergencyIssue(
        key: 'Jumpstart',
        icon: Icons.bolt_outlined,
        label: 'Jumpstart',
      ),
      _EmergencyIssue(
        key: 'Engine trouble',
        icon: Icons.build_outlined,
        label: 'Engine\ntrouble',
      ),
      _EmergencyIssue(
        key: 'Battery',
        icon: Icons.battery_charging_full_outlined,
        label: 'Battery',
      ),
      _EmergencyIssue(
        key: 'Other',
        icon: Icons.more_horiz,
        label: 'Other',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What seems to be the problem?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Issues grid
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: issues.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final issue = issues[index];
            final isSelected = selectedIssue == issue.key;
            return _EmergencyIssueTile(
              issue: issue,
              isSelected: isSelected,
              onTap: () => onIssueSelected(issue.key),
            );
          },
        ),
        const SizedBox(height: 20),

        Text(
          'Selected vehicle',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        const _SelectedVehicleCard(),

        const SizedBox(height: 20),

        FilledButton.icon(
          onPressed: () {
            context.push(
              '/assist/request',
              extra: {
                'issue': selectedIssue,
              },
            );
          },
          icon: const Icon(Icons.my_location_outlined),
          label: const Text('Confirm location & continue'),
        ),
        const SizedBox(height: 8),
        Text(
          'We’ll use your GPS to find the closest verified provider for this issue.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmergencyIssue {
  final String key;
  final IconData icon;
  final String label;

  const _EmergencyIssue({
    required this.key,
    required this.icon,
    required this.label,
  });
}

class _EmergencyIssueTile extends StatelessWidget {
  const _EmergencyIssueTile({
    required this.issue,
    required this.isSelected,
    required this.onTap,
  });

  final _EmergencyIssue issue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withOpacity(0.7),
            width: isSelected ? 1.3 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              issue.icon,
              size: 26,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              issue.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedVehicleCard extends StatelessWidget {
  const _SelectedVehicleCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Replace with actual selected vehicle state (from Garage / profile)
    const vehicleName = 'Toyota Corolla';
    const vehiclePlate = 'GR 1234-24';
    const vehicleTag = 'Primary car';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Later: open vehicle picker & garage
        context.go('/garage');
      },
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_filled_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicleName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehiclePlate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      vehicleTag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceBookingSection extends StatelessWidget {
  const _ServiceBookingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final services = <_ServiceItem>[
      const _ServiceItem(
        title: 'Car wash',
        subtitle: 'Basic, premium, or full interior & exterior.',
        icon: Icons.local_car_wash_outlined,
      ),
      const _ServiceItem(
        title: 'Oil change',
        subtitle: 'Keep your engine healthy with regular oil changes.',
        icon: Icons.oil_barrel_outlined,
      ),
      const _ServiceItem(
        title: 'Fuel delivery',
        subtitle: 'Ran low? We’ll top you up where you are.',
        icon: Icons.local_gas_station_outlined,
      ),
      const _ServiceItem(
        title: 'Battery service',
        subtitle: 'Jumpstart or full replacement when needed.',
        icon: Icons.battery_full_outlined,
      ),
      const _ServiceItem(
        title: 'Tyre service',
        subtitle: 'Puncture repairs, swaps, or alignment (where available).',
        icon: Icons.tire_repair,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book a service',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Perfect for planned maintenance or convenience services.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final service = services[index];
            return _ServiceCard(service: service);
          },
        ),
      ],
    );
  }
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final _ServiceItem service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Later: push to /assist/service/:id -> choose vehicle, time, location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking flow for "${service.title}" coming soon.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                service.icon,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'From GHS —', // TODO: pricing from Supabase
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                // Same as card tap for now
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking flow for "${service.title}" coming soon.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}