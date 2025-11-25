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

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

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
                      'Digital Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kDarkNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance spacer
                ],
              ),
            ),

            // 2. Body Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: kDarkNavy))
                  : _membership == null || _membership!['is_active'] == false
                  ? _buildEmptyState()
                  : _buildActiveCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kDarkNavy.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_membership_rounded, size: 48, color: kDarkNavy),
            ),
            const SizedBox(height: 24),
            const Text(
              'No active membership',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kDarkNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don’t have an active MotorAmbos membership yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: kSlateText, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/membership'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'View Membership Plans',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard() {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // --- The Visual Card ---
          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kDarkNavy,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: kDarkNavy.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Slate-800 to Slate-900
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'MotorAmbos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tier,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membershipId,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires $expiryText',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- QR Code Section ---
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrPayload,
                  size: 200,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Scan to Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kDarkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Show this code to your service provider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: kSlateText,
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