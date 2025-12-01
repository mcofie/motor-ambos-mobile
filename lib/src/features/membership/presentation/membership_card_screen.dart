import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/core/services/membership_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

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
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Digital Card',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
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
                  ? Center(child: CircularProgressIndicator(color: motTheme.accent))
                  : _membership == null || _membership!['is_active'] == false
                  ? _buildEmptyState(theme, motTheme)
                  : _buildActiveCard(theme, motTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, MotorAmbosTheme motTheme) {
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
                color: motTheme.accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.card_membership_rounded, size: 48, color: motTheme.accent),
            ),
            const SizedBox(height: 24),
            Text(
              'No active membership',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'You don’t have an active MotorAmbos membership yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: motTheme.slateText, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/membership'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: motTheme.accent,
                  foregroundColor: theme.colorScheme.surface,
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

  Widget _buildActiveCard(ThemeData theme, MotorAmbosTheme motTheme) {
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
              color: motTheme.accent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: motTheme.accent.withValues(alpha: 0.4),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: theme.colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'MotorAmbos',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tier,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
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
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires $expiryText',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
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
              border: Border.all(color: motTheme.subtleBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
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
                Text(
                  'Scan to Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show this code to your service provider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: motTheme.slateText,
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