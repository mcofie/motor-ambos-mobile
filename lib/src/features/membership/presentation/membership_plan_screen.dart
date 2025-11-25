import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MembershipPlansScreen extends StatelessWidget {
  const MembershipPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'tier': 'BASIC',
        'price': 'GHS 199/year',
        'features': ['2 calls/year', 'Basic Support'],
        'color': Colors.blue,
      },
      {
        'tier': 'STANDARD',
        'price': 'GHS 349/year',
        'features': ['4 calls/year', 'Priority Support'],
        'color': Colors.orange,
      },
      {
        'tier': 'PREMIUM',
        'price': 'GHS 499/year',
        'features': ['Unlimited calls', 'Fastest Response', 'Full Coverage'],
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Membership"), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final p = plans[i];
          return _PlanCard(
            tier: p['tier'] as String,
            price: p['price'] as String,
            features: p['features'] as List<String>,
            color: p['color'] as Color,
            onTap: () => context.push('/membership/confirm', extra: p),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String tier;
  final String price;
  final List<String> features;
  final Color color;
  final VoidCallback onTap;

  const _PlanCard({
    required this.tier,
    required this.price,
    required this.features,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tier,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              for (final f in features)
                Row(
                  children: [
                    Icon(Icons.check, color: color, size: 18),
                    const SizedBox(width: 6),
                    Text(f, style: const TextStyle(fontSize: 13)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
