import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/services/membership_service.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firstName = 'Driver';

  Map<String, dynamic>? _membership;
  bool _loadingMembership = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadMembership();
  }

  Future<void> _loadUserName() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) {
      setState(() {
        _firstName = 'Driver';
      });
      return;
    }

    final email = user.email ?? '';
    final metadataName = user.userMetadata?['full_name'] as String?;
    String fallbackName =
        metadataName ?? (email.isNotEmpty ? email.split('@').first : 'Driver');

    try {
      final dynamic res = await client
          .schema('motorambos')
          .from('profiles')
          .select('full_name')
          .eq('user_id', user.id)
          .maybeSingle();

      String displayName = fallbackName;

      if (res != null) {
        final row = Map<String, dynamic>.from(res as Map);
        final fullName = row['full_name'] as String?;
        if (fullName != null && fullName.trim().isNotEmpty) {
          displayName = fullName;
        }
      }

      final parts = displayName.trim().split(RegExp(r'\s+'));
      final first = parts.isNotEmpty ? parts.first : displayName;

      if (!mounted) return;
      setState(() {
        _firstName = first;
      });
    } catch (_) {
      final parts = fallbackName.trim().split(RegExp(r'\s+'));
      final first = parts.isNotEmpty ? parts.first : fallbackName;
      if (!mounted) return;
      setState(() {
        _firstName = first;
      });
    }
  }

  Future<void> _loadMembership() async {
    try {
      final service = MembershipService();
      final res = await service.getMembership();
      if (!mounted) return;
      setState(() {
        _membership = res; // null means no membership yet
        _loadingMembership = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _membership = null;
        _loadingMembership = false;
      });
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasMembership =
        !_loadingMembership &&
        _membership != null &&
        (_membership!['is_active'] != false);

    // Safely derive membership info
    String cardTier = 'PREMIUM';
    String membershipId = '— — — —';
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));
    int callsUsed = 0;
    double savings = 0.0;

    if (hasMembership) {
      final m = _membership!;
      cardTier = (m['tier'] as String?)?.toUpperCase() ?? 'PREMIUM';
      membershipId = (m['membership_id'] as String?) ?? '— — — —';

      final rawExpiry = m['expiry_date'];
      if (rawExpiry is String) {
        expiryDate = DateTime.tryParse(rawExpiry) ?? expiryDate;
      } else if (rawExpiry is DateTime) {
        expiryDate = rawExpiry;
      }

      callsUsed = (m['calls_used'] as int?) ?? 0;
      if (m['savings'] is num) {
        savings = (m['savings'] as num).toDouble();
      } else if (m['savings'] != null) {
        savings = double.tryParse(m['savings'].toString()) ?? 0.0;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with real user name
              _HeaderSection(userName: _firstName, greeting: _greeting()),

              const SizedBox(height: 24),

              // 2. Membership Card + Glass CTA overlay
              Stack(
                children: [
                  _MembershipCard(
                    tier: cardTier,
                    membershipId: membershipId,
                    expiryDate: expiryDate,
                    callsUsedThisYear: callsUsed,
                    estimatedSavings: savings,
                  ),

                  // Loading overlay (fade)
                  if (_loadingMembership)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (!hasMembership)
                    // Glassmorphic "Become a Member" overlay
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.35),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Become a MotorAmbos Member',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enjoy towing, rescue, fuel delivery and more — with one tap when you need help.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () => context.go('/membership'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Membership Plans',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. Emergency SOS
              _EmergencyAssistanceButton(onTap: () => context.go('/assist')),

              const SizedBox(height: 28),

              // 4. Section Title
              Text(
                'Manage Vehicle',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // 5. Grid
              const _ServicesGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 1. HEADER
//
class _HeaderSection extends StatelessWidget {
  final String userName;
  final String greeting;

  const _HeaderSection({
    required this.userName,
    this.greeting = 'Good Morning,',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.surfaceContainer,
                child: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//
// 2. PREMIUM MEMBERSHIP CARD
//
class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.tier,
    required this.membershipId,
    required this.expiryDate,
    required this.callsUsedThisYear,
    required this.estimatedSavings,
  });

  final String tier;
  final String membershipId;
  final DateTime expiryDate;
  final int callsUsedThisYear;
  final double estimatedSavings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expiryText =
        '${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year.toString().substring(2)}';

    final cardBgColor = const Color(0xFF1E1E1E);
    final cardTextColor = Colors.white;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardBgColor, Colors.black],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_moon,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MotorAmbos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cardTextColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(
                      tier.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Stats Row
              IntrinsicHeight(
                child: Row(
                  children: [
                    _StatItem(label: 'Calls Used', value: '$callsUsedThisYear'),
                    VerticalDivider(
                      color: Colors.white.withOpacity(0.1),
                      width: 30,
                    ),
                    _StatItem(
                      label: 'Savings',
                      value: 'GHS ${estimatedSavings.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membershipId,
                        style: TextStyle(
                          color: cardTextColor,
                          fontFamily: 'Courier',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Exp $expiryText',
                        style: TextStyle(
                          color: cardTextColor.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => context.push('/membership/card'),
                    icon: const Icon(Icons.qr_code_2_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: -30,
          top: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
      ],
    );
  }
}

//
// 3. EMERGENCY BUTTON
//
class _EmergencyAssistanceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EmergencyAssistanceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.errorContainer.withOpacity(0.4),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.error.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sos_rounded,
                  color: colorScheme.onError,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Assistance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flat tire, battery, towing',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 4. SERVICES GRID
//
class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _GridItem(
        icon: Icons.calendar_month_rounded,
        label: 'Book Service',
        accentColor: Colors.blue,
        onTap: () => context.go('/assist'),
      ),
      _GridItem(
        icon: Icons.directions_car_filled_rounded,
        label: 'My Garage',
        accentColor: Colors.orange,
        onTap: () => context.go('/garage'),
      ),
      _GridItem(
        icon: Icons.card_membership_rounded,
        label: 'Membership',
        accentColor: Colors.purple,
        onTap: () => context.go('/membership'),
      ),
      _GridItem(
        icon: Icons.history_rounded,
        label: 'History',
        accentColor: Colors.teal,
        onTap: () => context.go('/history'),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark
        ? accentColor.withOpacity(0.8)
        : Color.lerp(accentColor, Colors.black, 0.3) ?? accentColor;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: activeColor, size: 22),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
