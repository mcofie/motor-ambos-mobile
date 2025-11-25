import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider);

    return Scaffold(
      backgroundColor: kBgColor,
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kDarkNavy),
                      onPressed: () => context.canPop() ? context.pop() : context.go('/more'),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'My Membership',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kDarkNavy,
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PLAN PERKS',
                        style: TextStyle(
                          color: kSlateText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BenefitsList(membership: membership),

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
                          backgroundColor: kDarkNavy,
                          foregroundColor: Colors.white,
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
                      child: const Text(
                        "View Billing History",
                        style: TextStyle(
                          color: kSlateText,
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
class _PremiumMembershipCard extends StatelessWidget {
  final Membership membership;

  const _PremiumMembershipCard({required this.membership});

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kDarkNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kDarkNavy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Slate gradient
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
                  const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "MotorAmbos",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  membership.tier.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                membership.id,
                style: const TextStyle(
                  color: Colors.white,
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
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    final remaining = membership.includedCallsPerYear - membership.callsUsedThisYear;
    final percent = remaining / membership.includedCallsPerYear;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: kDarkNavy,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "$remaining",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kDarkNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Calls Left",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kDarkNavy),
          ),
          Text(
            "of ${membership.includedCallsPerYear} included",
            style: const TextStyle(fontSize: 10, color: kSlateText),
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
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 154,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: const Color(0xFFF0FDF4), // Light Green
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.savings_rounded, color: Colors.green, size: 20),
          ),
          const Spacer(),
          const Text(
            "Total Saved",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kSlateText),
          ),
          const SizedBox(height: 4),
          Text(
            "GHS ${membership.estimatedSavings.toInt()}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kDarkNavy,
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
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: color.withOpacity(0.1),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kDarkNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: kSlateText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
        ],
      ),
    );
  }
}