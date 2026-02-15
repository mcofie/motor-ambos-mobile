import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

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
    required this.id, required this.tier, required this.memberSince, required this.expiry,
    required this.includedCallsPerYear, required this.callsUsedThisYear,
    required this.estimatedSavings, required this.freeTowRadiusKm, required this.prioritySupport,
  });
}

final membershipProvider = FutureProvider<Membership>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return Membership(
    id: 'MBR-8821-X99', tier: 'Premium', memberSince: DateTime(2023, 1, 15), expiry: DateTime.now().add(const Duration(days: 120)),
    includedCallsPerYear: 5, callsUsedThisYear: 2, estimatedSavings: 1450.00, freeTowRadiusKm: 50, prioritySupport: true,
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
      appBar: AppBar(
        title: const Text('My Membership', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onSurface), onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
      ),
      body: membershipAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (membership) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _PremiumMembershipCard(membership: membership),
                      const SizedBox(height: 32),
                      _sectionTitle('USAGE STATUS'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _UsageTile(membership: membership)),
                          const SizedBox(width: 16),
                          Expanded(child: _SavingsTile(membership: membership)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle('PLAN BENEFITS'),
                      const SizedBox(height: 16),
                      _BenefitRow(icon: Icons.local_shipping_rounded, color: Colors.blue, title: "Free Towing", subtitle: "${membership.freeTowRadiusKm}km radius coverage"),
                      const SizedBox(height: 12),
                      _BenefitRow(icon: Icons.bolt_rounded, color: Colors.orange, title: "Priority Response", subtitle: "Active VIP queueing"),
                      const SizedBox(height: 12),
                      const _BenefitRow(icon: Icons.build_circle_rounded, color: Colors.purple, title: "Labor Discount", subtitle: "15% off at partner garages"),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildRenewButton(theme, motTheme),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2));
  }

  Widget _buildRenewButton(ThemeData theme, MotorAmbosTheme motTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: motTheme.subtleBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('RENEW MEMBERSHIP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }
}

class _PremiumMembershipCard extends StatelessWidget {
  final Membership membership;
  const _PremiumMembershipCard({required this.membership});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 25, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MOTORAMBOS CLUB', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(12)),
                child: const Text('PREMIUM', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(membership.id, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'monospace', letterSpacing: 2)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardInfo(label: 'MEMBER SINCE', value: '${membership.memberSince.year}'),
              _CardInfo(label: 'VALID UNTIL', value: '12/26'),
              const Icon(Icons.nfc_rounded, color: Colors.white24, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String label, value;
  const _CardInfo({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _UsageTile extends StatelessWidget {
  final Membership membership;
  const _UsageTile({required this.membership});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    final left = membership.includedCallsPerYear - membership.callsUsedThisYear;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: motTheme.subtleBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$left', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          const Text('Calls Left', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SavingsTile extends StatelessWidget {
  final Membership membership;
  const _SavingsTile({required this.membership});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: motTheme.subtleBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GHS ${membership.estimatedSavings.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green)),
          const SizedBox(height: 8),
          const Text('Total Saved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _BenefitRow({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: motTheme.subtleBorder)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: motTheme.slateText, fontSize: 12))])),
          const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}