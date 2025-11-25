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

  // --- LOGIC SECTION ---

  Future<void> _loadUserName() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _firstName = 'Driver');
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

      // Extract First Name
      final parts = displayName.trim().split(RegExp(r'\s+'));
      if (mounted)
        setState(
          () => _firstName = parts.isNotEmpty ? parts.first : displayName,
        );
    } catch (_) {
      final parts = fallbackName.trim().split(RegExp(r'\s+'));
      if (mounted)
        setState(
          () => _firstName = parts.isNotEmpty ? parts.first : fallbackName,
        );
    }
  }

  Future<void> _loadMembership() async {
    try {
      final service = MembershipService();
      final res = await service.getMembership();
      if (mounted) {
        setState(() {
          _membership = res;
          _loadingMembership = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _membership = null;
          _loadingMembership = false;
        });
      }
    }
  }

  // --- UI BUILD SECTION ---

  @override
  Widget build(BuildContext context) {
    // 1. Data Parsing
    final hasMembership =
        !_loadingMembership &&
        _membership != null &&
        (_membership!['is_active'] != false);

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

    // 2. Theme Colors
    const kBgColor = Color(0xFFF8FAFC); // Very light grey/blue
    const kDarkNavy = Color(0xFF0F172A); // The dark text/button color

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (Enhanced)
              _HeaderSection(
                userName: _firstName,
                onProfileTap: () => context.go('/more'), // Navigate to profile
              ),

              const SizedBox(height: 24),

              // MEMBERSHIP CARD
              Stack(
                children: [
                  _MembershipCard(
                    tier: cardTier,
                    membershipId: membershipId,
                    expiryDate: expiryDate,
                    callsUsedThisYear: callsUsed,
                    estimatedSavings: savings,
                  ),

                  // Loading Overlay
                  if (_loadingMembership)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          color: Colors.white.withOpacity(0.5),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kDarkNavy,
                          ),
                        ),
                      ),
                    )
                  else if (!hasMembership)
                    // Glassmorphic "Join" Overlay
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                          child: Container(
                            color: kDarkNavy.withOpacity(0.85),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Upgrade to Member',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get free towing & priority rescue',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/membership'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: kDarkNavy,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      'View Plans',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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

              // BOLD ACTION POINT
              const _EmergencyActionCard(),

              const SizedBox(height: 32),

              // MANAGE SECTION
              const Text(
                'Account & Vehicle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDarkNavy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Utility Grid
              const _UtilityGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SUB-COMPONENTS
// -----------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  final String userName;
  final VoidCallback onProfileTap;

  const _HeaderSection({required this.userName, required this.onProfileTap});

  // Determine greeting based on time of day
  (String, IconData, Color) _getGreetingData() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return ('Good Morning', Icons.wb_sunny_rounded, Colors.orange);
    } else if (hour < 17) {
      return ('Good Afternoon', Icons.wb_cloudy_rounded, Colors.orange);
    } else {
      return ('Good Evening', Icons.nights_stay_rounded, Colors.indigoAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (greetingText, greetingIcon, iconColor) = _getGreetingData();
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(greetingIcon, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    greetingText,
                    style: const TextStyle(
                      color: Color(0xFF64748B), // Slate 500
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  color: Color(0xFF0F172A), // Slate 900
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Profile Avatar Button
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                // Notification/Active Badge
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      // Red for alert, or Green for status
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final String tier;
  final String membershipId;
  final DateTime expiryDate;
  final int callsUsedThisYear;
  final double estimatedSavings;

  const _MembershipCard({
    required this.tier,
    required this.membershipId,
    required this.expiryDate,
    required this.callsUsedThisYear,
    required this.estimatedSavings,
  });

  @override
  Widget build(BuildContext context) {
    final expiryText =
        '${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year.toString().substring(2)}';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Navy Solid
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MotorAmbos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tier,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              _CardStat(value: '$callsUsedThisYear', label: 'Calls Used'),
              Container(
                height: 32,
                width: 1,
                color: Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _CardStat(
                value: 'GHS ${estimatedSavings.toStringAsFixed(0)}',
                label: 'Saved',
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membershipId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exp $expiryText',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.nfc, color: Colors.white30, size: 32),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String value;
  final String label;

  const _CardStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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

class _EmergencyActionCard extends StatelessWidget {
  const _EmergencyActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)], // Red gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/assist'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          '24/7 SUPPORT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Request Help',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Towing, Battery, Fuel & More',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFEF4444),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UtilityGrid extends StatelessWidget {
  const _UtilityGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _UtilityCard(
            icon: Icons.directions_car_filled_rounded,
            label: 'My Garage',
            onTap: () => context.go('/garage'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _UtilityCard(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => context.go('/history'),
          ),
        ),
      ],
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UtilityCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF334155)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
