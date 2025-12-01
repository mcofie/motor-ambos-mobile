import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/widget/skeleton.dart';

// MOCKING DOMAIN & PROVIDER
class Membership {
  final String id;
  final String tier;
  final DateTime memberSince;
  final DateTime expiry;
  final int includedCallsPerYear;
  final int callsUsedThisYear;
  final double estimatedSavings;
  final int freeTowRadiusKm;
  final bool prioritySupport;

  Membership({
    required this.id,
    required this.tier,
    required this.memberSince,
    required this.expiry,
    required this.includedCallsPerYear,
    required this.callsUsedThisYear,
    required this.estimatedSavings,
    required this.freeTowRadiusKm,
    required this.prioritySupport,
  });
}

final membershipProvider = FutureProvider<Membership>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));
  return Membership(
    id: 'MBR-8821-X99',
    tier: 'Premium',
    memberSince: DateTime(2023, 1, 15),
    expiry: DateTime.now().add(const Duration(days: 120)),
    includedCallsPerYear: 5,
    callsUsedThisYear: 2,
    estimatedSavings: 1450.00,
    freeTowRadiusKm: 50,
    prioritySupport: true,
  );
});

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(membershipProvider);
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: theme.colorScheme.onSurface),
                      onPressed: () => context.canPop() ? context.pop() : context.go('/more'),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'My Membership',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance
                ],
              ),
            ),

            // 2. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    membershipAsync.when(
                      loading: () => const SkeletonCard(height: 200),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (membership) {
                        return Column(
                          children: [
                            // The Premium Card
                            _PremiumMembershipCard(membership: membership),

                            const SizedBox(height: 24),

                            // Usage Dashboard
                            Row(
                              children: [
                                Expanded(child: _UsageCircle(membership: membership)),
                                const SizedBox(width: 16),
                                Expanded(child: _SavingsCard(membership: membership)),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Benefits List
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'PLAN PERKS',
                                style: TextStyle(
                                  color: motTheme.slateText,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _BenefitsList(membership: membership),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement renewal flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: motTheme.accent,
                          foregroundColor: theme.colorScheme.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Renew Membership",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "View Billing History",
                        style: TextStyle(
                          color: motTheme.slateText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// 1. PREMIUM CARD WIDGET
//
//
// 1. PREMIUM CARD WIDGET
//
class _PremiumMembershipCard extends StatelessWidget {
  final Membership membership;

  const _PremiumMembershipCard({required this.membership});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: motTheme.accent, // Fallback if gradient fails, but gradient covers it
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: motTheme.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            motTheme.accent.withValues(alpha: 0.8),
            motTheme.accent,
          ], 
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: theme.colorScheme.onPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "MotorAmbos",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  membership.tier.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          // ID
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MEMBERSHIP ID",
                style: TextStyle(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                membership.id,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardFooterItem(
                label: "SINCE",
                value: "${membership.memberSince.year}",
              ),
              _CardFooterItem(
                label: "EXPIRES",
                value: "${membership.expiry.month.toString().padLeft(2, '0')}/${membership.expiry.year.toString().substring(2)}",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardFooterItem extends StatelessWidget {
  final String label;
  final String value;

  const _CardFooterItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

//
// 2. DASHBOARD WIDGETS
//
class _UsageCircle extends StatelessWidget {
  final Membership membership;

  const _UsageCircle({required this.membership});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    final remaining = membership.includedCallsPerYear - membership.callsUsedThisYear;
    final percent = remaining / membership.includedCallsPerYear;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: motTheme.inputBg,
                  color: motTheme.accent,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "$remaining",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Calls Left",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          Text(
            "of ${membership.includedCallsPerYear} included",
            style: TextStyle(fontSize: 10, color: motTheme.slateText),
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final Membership membership;

  const _SavingsCard({required this.membership});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 154,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: motTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.savings_rounded, color: motTheme.success, size: 20),
          ),
          const Spacer(),
          Text(
            "Total Saved",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: motTheme.slateText),
          ),
          const SizedBox(height: 4),
          Text(
            "GHS ${membership.estimatedSavings.toInt()}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

//
// 3. BENEFITS LIST
//
class _BenefitsList extends StatelessWidget {
  final Membership membership;

  const _BenefitsList({required this.membership});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BenefitRow(
          icon: Icons.local_shipping_rounded,
          color: Colors.blue,
          title: "Free Towing",
          subtitle: "${membership.freeTowRadiusKm}km radius coverage",
        ),
        const SizedBox(height: 16),
        _BenefitRow(
          icon: Icons.bolt_rounded,
          color: Colors.orange,
          title: "Priority Response",
          subtitle: membership.prioritySupport ? "Active VIP queueing" : "Standard",
        ),
        const SizedBox(height: 16),
        const _BenefitRow(
          icon: Icons.build_circle_rounded,
          color: Colors.purple,
          title: "Labor Discount",
          subtitle: "15% off at partner garages",
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: motTheme.slateText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: motTheme.success, size: 18),
        ],
      ),
    );
  }
}