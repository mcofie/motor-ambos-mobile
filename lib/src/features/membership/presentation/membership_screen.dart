import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final membershipProvider = Provider<Membership>((ref) {
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
    final membership = ref.watch(membershipProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Membership',
          style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold
          ),
        ),
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. The Premium Card
            _PremiumMembershipCard(membership: membership),

            const SizedBox(height: 24),

            // 2. Usage Dashboard (Visual Data)
            Row(
              children: [
                Expanded(child: _UsageCircle(membership: membership)),
                const SizedBox(width: 16),
                Expanded(child: _SavingsCard(membership: membership)),
              ],
            ),

            const SizedBox(height: 32),

            // 3. Benefits List
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Plan Perks',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BenefitsList(membership: membership),

            const SizedBox(height: 32),

            // 4. Action Buttons
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary, // Brand Green
                  foregroundColor: colorScheme.onPrimary, // Black Text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Renew Membership",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "View Billing History",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
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
class _PremiumMembershipCard extends StatelessWidget {
  final Membership membership;

  const _PremiumMembershipCard({required this.membership});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // We enforce a Dark Card look even in Light mode for "Premium" feel
    const cardBgColor = Color(0xFF1E1E1E);
    const cardTextColor = Colors.white;

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          // Background Texture
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "MotorAmbos",
                    style: TextStyle(
                      color: cardTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      membership.tier.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onPrimary,
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
                      color: cardTextColor.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membership.id,
                    style: const TextStyle(
                      color: cardTextColor,
                      fontFamily: 'Courier',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
                    value:
                    "${membership.expiry.month}/${membership.expiry.year.toString().substring(2)}",
                  ),
                ],
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
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
    final colorScheme = Theme.of(context).colorScheme;

    final remaining =
        membership.includedCallsPerYear - membership.callsUsedThisYear;
    final percent = remaining / membership.includedCallsPerYear;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Theme-aware background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  strokeWidth: 8,
                  backgroundColor: colorScheme.outlineVariant.withOpacity(0.3),
                  color: colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "$remaining",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Calls Left",
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            "of ${membership.includedCallsPerYear} included",
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 154,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Theme-aware background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.savings_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            "Total Saved",
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            "GHS ${membership.estimatedSavings.toInt()}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
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
          subtitle: membership.prioritySupport
              ? "Active VIP queueing"
              : "Standard",
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adjust accent colors for visibility in dark mode
    final displayColor = isDark ? color.withOpacity(0.9) : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Theme-aware background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: displayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: displayColor, size: 24),
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
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: colorScheme.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}