import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/services/membership_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class MembershipConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const MembershipConfirmScreen({super.key, required this.plan});

  @override
  State<MembershipConfirmScreen> createState() => _MembershipConfirmScreenState();
}

class _MembershipConfirmScreenState extends State<MembershipConfirmScreen> {
  bool _loading = false;



  Future<void> _complete() async {
    setState(() => _loading = true);

    // Simulate network delay for better UX feel if needed, or just call service
    try {
      final tier = widget.plan['tier'];
      await MembershipService().enroll(tier);

      if (!mounted) return;
      // Success! Go to card
      context.go('/membership/card');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enrollment failed: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    final p = widget.plan;
    final tier = p['tier'] as String;
    final price = p['price'] as String;
    // Ensure color is handled safely if passed, or default to Navy
    final Color accentColor = (p['color'] is Color) ? p['color'] : motTheme.accent;

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
                      'Confirm Plan',
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

            // 2. Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.verified_rounded, size: 40, color: accentColor),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            tier,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'per year',
                            style: TextStyle(
                              fontSize: 14,
                              color: motTheme.slateText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Divider(height: 1),
                          const SizedBox(height: 32),
                          Text(
                            'You are about to upgrade your MotorAmbos membership. This plan will be active immediately after payment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: motTheme.slateText,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Sticky Bottom Action
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(top: BorderSide(color: motTheme.subtleBorder)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _complete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: motTheme.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Confirm & Pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}