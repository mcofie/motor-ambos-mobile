import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Later: dynamic data from Supabase / Riverpod
    const userName = 'Max';
    const membershipTier = 'Premium';
    const membershipId = 'MBR-2048-001';
    final expiryDate = DateTime.now().add(const Duration(days: 142));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Hi, $userName 👋',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your MotorAmbos membership is active.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Membership card
          _MembershipCard(
            tier: membershipTier,
            membershipId: membershipId,
            expiryDate: expiryDate,
            callsUsedThisYear: 3,
            estimatedSavings: 420.0,
          ),
          const SizedBox(height: 28),

          // Quick actions header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'For your most common tasks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const _QuickActionsGrid(),
        ],
      ),
    );
  }
}

//
// MEMBERSHIP CARD
//
class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.tier,
    required this.membershipId,
    required this.expiryDate,
    required this.callsUsedThisYear,
    required this.estimatedSavings,
  });

  final String tier;
  final String membershipId;
  final DateTime expiryDate;
  final int callsUsedThisYear;
  final double estimatedSavings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final expiryText =
        '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandAccent, // BLACK background
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: brand + tier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MotorAmbos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.brandPrimary,      // PRIMARY GREEN
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.brandPrimary.withOpacity(0.7),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  tier.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Membership ID
          Text(
            'Membership ID',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            membershipId,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Row of stats
          Row(
            children: [
              Expanded(
                child: _CardStat(
                  label: 'Calls used',
                  value: '$callsUsedThisYear',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardStat(
                  label: 'Saved this year',
                  value: 'GHS ${estimatedSavings.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expiry + button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expiry text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expires',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    expiryText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Button to full screen card
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor:
                  AppColors.brandPrimary.withOpacity(0.16),
                  foregroundColor: AppColors.brandPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                onPressed: () {
                  context.push('/membership/card');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_2, size: 18),
                    SizedBox(width: 6),
                    Text('Show full card'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label;
  final String value;

  const _CardStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

//
// QUICK ACTIONS
//
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = [
      _QuickActionItem(
        icon: Icons.bolt_outlined,
        label: 'Request assistance',
        description: 'Get help right now',
        onTap: () => context.go('/assist'),
      ),
      _QuickActionItem(
        icon: Icons.calendar_month_outlined,
        label: 'Book a service',
        description: 'Plan ahead for your car',
        onTap: () => context.go('/assist'),
      ),
      _QuickActionItem(
        icon: Icons.directions_car_filled_outlined,
        label: 'Add a vehicle',
        description: 'Save a car to your garage',
        onTap: () => context.go('/garage'),
      ),
      _QuickActionItem(
        icon: Icons.card_membership_outlined,
        label: 'View membership',
        description: 'See your plan & perks',
        onTap: () => context.go('/membership'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,        // TWO COLUMNS
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.7,    // Wide pill style
        ),
        itemBuilder: (context, index) {
          return _QuickActionTile(item: items[index], theme: theme);
        },
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionItem item;
  final ThemeData theme;

  const _QuickActionTile({
    required this.item,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: item.onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 0.9,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // Icon bubble
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(width: 10),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.chevron_right,
              size: 18,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}