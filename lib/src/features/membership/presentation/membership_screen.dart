import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:motor_ambos/src/features/membership/application/membership_providers.dart';
import 'package:motor_ambos/src/features/membership/domain/membership.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membership = ref.watch(membershipProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MembershipHeader(membership: membership),
            const SizedBox(height: 24),
            _BenefitsSection(membership: membership),
            const SizedBox(height: 24),
            _UsageSection(membership: membership),
            const SizedBox(height: 24),
            _PlanActionsSection(membership: membership),
          ],
        ),
      ),
    );
  }
}

class _MembershipHeader extends StatelessWidget {
  const _MembershipHeader({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final expiryText =
        '${membership.expiry.day.toString().padLeft(2, '0')}/${membership.expiry.month.toString().padLeft(2, '0')}/${membership.expiry.year}';
    final memberSinceText =
        '${membership.memberSince.day.toString().padLeft(2, '0')}/${membership.memberSince.month.toString().padLeft(2, '0')}/${membership.memberSince.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!.copyWith(
          color: cs.onPrimary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${membership.tier} member',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              membership.id,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _HeaderItem(
                    label: 'Member since',
                    value: memberSinceText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeaderItem(
                    label: 'Expires',
                    value: expiryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderItem extends StatelessWidget {
  const _HeaderItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onPrimary.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your benefits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These are the perks included with your ${membership.tier.toLowerCase()} plan.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _BenefitTile(
          icon: Icons.local_shipping_outlined,
          title: 'Free towing',
          subtitle:
          'Up to ${membership.freeTowRadiusKm}km per incident within your coverage area.',
        ),
        const SizedBox(height: 8),
        _BenefitTile(
          icon: Icons.call_outlined,
          title: 'Included roadside calls',
          subtitle:
          '${membership.includedCallsPerYear} assistance calls per year at no extra callout fee.',
        ),
        const SizedBox(height: 8),
        _BenefitTile(
          icon: Icons.price_change_outlined,
          title: 'Member-only rates',
          subtitle:
          'Lower labour and service rates at partner garages & service providers.',
        ),
        const SizedBox(height: 8),
        _BenefitTile(
          icon: Icons.bolt_outlined,
          title: 'Priority response',
          subtitle: membership.prioritySupport
              ? 'Get bumped up in the queue during peak times.'
              : 'Standard response time.',
        ),
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final remainingCalls =
    (membership.includedCallsPerYear - membership.callsUsedThisYear)
        .clamp(0, membership.includedCallsPerYear);

    final usagePercent = membership.includedCallsPerYear == 0
        ? 0.0
        : membership.callsUsedThisYear /
        membership.includedCallsPerYear;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage & savings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Roadside calls this year',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: usagePercent.clamp(0, 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${membership.callsUsedThisYear}/${membership.includedCallsPerYear}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                remainingCalls > 0
                    ? '$remainingCalls included calls remaining this year.'
                    : 'You’ve used all your included calls for this year.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated savings so far',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'GHS ${membership.estimatedSavings.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanActionsSection extends StatelessWidget {
  const _PlanActionsSection({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage your plan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Renew, upgrade, or see your billing history.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {
                  // TODO: renew flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Renewal flow coming soon.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme
                              .colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Renew membership'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: upgrade flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Upgrade options coming soon.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme
                              .colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('View upgrade options'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}