import 'dart:ui';
import 'package:flutter/material.dart';

class MembershipCardScreen extends StatelessWidget {
  const MembershipCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Replace these with real data from Supabase / Riverpod
    const userName = 'Max';
    const membershipTier = 'Premium';
    const membershipId = 'MBR-2048-001';
    final expiryDate = DateTime.now().add(const Duration(days: 142));

    final expiryText =
        '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Membership card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Big card
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Subtle blur overlay
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            color: Colors.black.withOpacity(0.10),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: brand + tier
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'MotorAmbos',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: colorScheme.onPrimary
                                            .withOpacity(0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      membershipTier.toUpperCase(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.1,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // Member name
                              Text(
                                userName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member since 2024', // TODO: dynamic
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(
                                    0.85,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Membership ID + expiry
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Membership ID',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colorScheme.onPrimary
                                                  .withOpacity(0.85),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        membershipId,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Expires',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colorScheme.onPrimary
                                                  .withOpacity(0.85),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        expiryText,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // QR placeholder
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.qr_code_2, size: 48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Info + actions under card
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Show this card at partner garages, car wash bays, or during roadside assistance to verify your membership and unlock benefits.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    // TODO: Integrate Add to Wallet / Passbook later
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Save to my wallet (coming soon)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
