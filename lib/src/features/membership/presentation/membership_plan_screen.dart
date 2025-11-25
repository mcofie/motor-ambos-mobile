import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MembershipPlansScreen extends StatelessWidget {
  const MembershipPlansScreen({super.key});

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'tier': 'BASIC',
        'price': 'GHS 199',
        'period': '/year',
        'features': ['2 calls per year', 'Standard Support', '10km Towing Radius'],
        'color': const Color(0xFF3B82F6), // Blue-500
        'recommended': false,
      },
      {
        'tier': 'STANDARD',
        'price': 'GHS 349',
        'period': '/year',
        'features': ['4 calls per year', 'Priority Support', '25km Towing Radius', 'Battery Jumpstart'],
        'color': const Color(0xFFF59E0B), // Amber-500
        'recommended': true,
      },
      {
        'tier': 'PREMIUM',
        'price': 'GHS 499',
        'period': '/year',
        'features': ['Unlimited calls', 'VIP Fastest Response', 'Nationwide Coverage', 'All Services Included'],
        'color': const Color(0xFF8B5CF6), // Violet-500
        'recommended': false,
      },
    ];

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
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Choose a Plan',
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

            // 2. Plans List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, i) {
                  final p = plans[i];
                  return _PlanCard(
                    tier: p['tier'] as String,
                    price: p['price'] as String,
                    period: p['period'] as String,
                    features: p['features'] as List<String>,
                    color: p['color'] as Color,
                    isRecommended: p['recommended'] as bool,
                    onTap: () => context.push('/membership/confirm', extra: p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String tier;
  final String price;
  final String period;
  final List<String> features;
  final Color color;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PlanCard({
    required this.tier,
    required this.price,
    required this.period,
    required this.features,
    required this.color,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Stack(
      children: [
        Container(
          margin: isRecommended ? const EdgeInsets.only(top: 12) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isRecommended
                ? Border.all(color: color, width: 2)
                : Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tier,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (isRecommended)
                        // Spacer to avoid overlap with the "Best Value" badge
                          const SizedBox(height: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: kDarkNavy,
                          ),
                        ),
                        Text(
                          period,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kSlateText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 24),
                    ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF334155), // Slate-700
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: isRecommended ? color : kDarkNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Select Plan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Recommended Badge
        if (isRecommended)
          Positioned(
            top: 0,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}