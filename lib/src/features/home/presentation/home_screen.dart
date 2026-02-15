import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/core/providers/profile_provider.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/features/garage/presentation/widgets/ghana_number_plate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);
    final primaryVehicleAsync = ref.watch(primaryVehicleProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(vehiclesProvider);
            await Future.wait([
              ref.read(userProfileProvider.future),
              ref.read(vehiclesProvider.future),
            ]);
          },
          color: theme.colorScheme.onSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userProfileAsync.when(
                  loading: () => const _HeaderSkeleton(),
                  error: (_, __) => _HeaderSection(userName: 'Driver', onProfileTap: () => context.push('/profile')),
                  data: (profile) => _HeaderSection(
                    userName: profile.firstName, 
                    avatarUrl: profile.avatarUrl,
                    onProfileTap: () => context.push('/profile')
                  ),
                ),
                const SizedBox(height: 24),
                
                // --- Smart Contextual Greeting ---
                const _SmartAssistantCard().animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),
                const SizedBox(height: 28),

                primaryVehicleAsync.when(
                  loading: () => const _VehicleCardSkeleton(),
                  error: (_, __) => _PrimaryVehicleCard(
                    vehicle: null,
                    loading: false,
                    onTap: () => context.pushNamed('garage-add'),
                    onAddVehicle: () => context.pushNamed('garage-add'),
                  ),
                  data: (vehicle) => _PrimaryVehicleCard(
                    vehicle: vehicle,
                    loading: false,
                    onTap: () {
                      if (vehicle != null) {
                        context.pushNamed('vehicle-detail', pathParameters: {'id': vehicle.id});
                      } else {
                        context.pushNamed('garage-add');
                      }
                    },
                    onAddVehicle: () => context.pushNamed('garage-add'),
                  ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'QUICK ACCESS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.withValues(alpha: 0.8), letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                const _QuickActionsGrid().animate().fade(duration: 600.ms, delay: 150.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                const _EmergencyActionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmartAssistantCard extends StatelessWidget {
  const _SmartAssistantCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Safe travel, Max!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                Text('Road conditions are clear today.', style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text('28°C', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: theme.colorScheme.onSurface)),
          const SizedBox(width: 4),
          const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16),
        ],
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 14, color: Colors.white10),
            const SizedBox(height: 8),
            Container(width: 180, height: 32, color: Colors.white10),
          ],
        ),
        Container(width: 52, height: 52, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle)),
      ],
    );
  }
}

class _VehicleCardSkeleton extends StatelessWidget {
  const _VehicleCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback onProfileTap;

  const _HeaderSection({required this.userName, this.avatarUrl, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms, begin: 0.3, end: 1.0),
                const SizedBox(width: 8),
                Text(
                  'READY TO ROLL',
                  style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2),
            ),
          ],
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: motTheme.subtleBorder, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 5))],
              image: avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: avatarUrl == null
                ? Text(initial, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface))
                : null,
          ),
        ),
      ],
    );
  }
}

class _PrimaryVehicleCard extends StatelessWidget {
  final Vehicle? vehicle;
  final bool loading;
  final VoidCallback onTap;
  final VoidCallback onAddVehicle;

  const _PrimaryVehicleCard({required this.vehicle, required this.loading, required this.onTap, required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    const cardBg = Color(0xFF0F172A);

    if (loading) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)),
      );
    }

    if (vehicle == null) {
      return GestureDetector(
        onTap: onAddVehicle,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: motTheme.subtleBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.add_rounded, size: 30, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text('Register Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text('Unlock digital documents & rescue', style: TextStyle(fontSize: 12, color: motTheme.slateText, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    final v = vehicle!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 30, offset: const Offset(0, 15))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Top-right Glow Decor
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_rounded, color: Colors.blueAccent, size: 12),
                              const SizedBox(width: 6),
                              Text('PROTECTED', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                        Icon(Icons.more_horiz_rounded, color: Colors.white.withValues(alpha: 0.45)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Hero(
                      tag: 'label-${v.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          v.displayLabel, 
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.8)
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (v.plate != null && v.plate!.isNotEmpty)
                      Hero(
                        tag: 'plate-${v.id}',
                        child: GhanaNumberPlate(plateNumber: v.plate!, height: 74),
                      ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatItem(label: 'MAKE', value: v.make ?? '---'),
                          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.12)),
                          _StatItem(label: 'YEAR', value: v.year ?? '---'),
                          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.12)),
                          _StatItem(
                            label: 'HEALTH', 
                            value: '${v.healthScore.toInt()}%', 
                            valueColor: v.healthScore > 80 ? Colors.green : (v.healthScore > 50 ? Colors.orangeAccent : Colors.redAccent)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _QuickAction(icon: Icons.garage_rounded, label: 'My Garage', color: Colors.blueAccent, onTap: () => context.go('/garage')),
        _QuickAction(icon: Icons.history_edu_rounded, label: 'History', color: Colors.purpleAccent, onTap: () => context.go('/activity')),
        _QuickAction(icon: Icons.vignette_rounded, label: 'Club Shop', color: Colors.orangeAccent, onTap: () => context.go('/membership')),
        _QuickAction(icon: Icons.support_agent_rounded, label: 'Support', color: Colors.tealAccent, onTap: () => context.go('/assist')),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: motTheme.subtleBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, fontSize: 14, letterSpacing: -0.2)),
          ],
        ),
      ),
    );
  }
}

class _EmergencyActionCard extends StatelessWidget {
  const _EmergencyActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFC2410C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.45), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/sos'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EMERGENCY SOS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                      const SizedBox(height: 10),
                      const Text('Request Rescue', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
                      const SizedBox(height: 6),
                      Text('Towing, Fuel & Mechanical Rescue', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 30)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
