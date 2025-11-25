import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/core/services/membership_service.dart';

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  Map<String, dynamic>? _membership;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembership();
  }

  Future<void> _loadMembership() async {
    try {
      final res = await const MembershipService().getMembership();
      if (!mounted) return;
      setState(() {
        _membership = res;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _membership = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Membership Card')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_membership == null || _membership!['is_active'] == false) {
      return Scaffold(
        appBar: AppBar(title: const Text('Membership Card')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_membership_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No active membership',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You don’t have an active MotorAmbos membership yet.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/membership'),
                  child: const Text('View Membership Plans'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final m = _membership!;
    final membershipId = (m['membership_id'] as String?) ?? '— — — —';
    final tier = (m['tier'] as String?)?.toUpperCase() ?? 'PREMIUM';

    DateTime? expiry;
    final expiryRaw = m['expiry_date'];
    if (expiryRaw is String) {
      expiry = DateTime.tryParse(expiryRaw);
    } else if (expiryRaw is DateTime) {
      expiry = expiryRaw;
    }
    final expiryText = expiry != null
        ? '${expiry.month.toString().padLeft(2, '0')}/${expiry.year.toString().substring(2)}'
        : '—';

    final user = SupabaseService.client.auth.currentUser;
    final qrPayload = jsonEncode({
      'membership_id': membershipId,
      'user_id': user?.id,
      'tier': tier,
      'exp': expiry?.toIso8601String(),
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Membership Card')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MotorAmbos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$tier MEMBER',
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),

              // QR Code
              QrImageView(
                data: qrPayload,
                size: 200,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 24),
              Text(
                membershipId,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Exp $expiryText',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
