import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  String? selectedIssue;
  bool isRequesting = false;
  bool isActive = false;

  void _handleIssueTap(String label) {
    setState(() {
      selectedIssue = label;
      isRequesting = true;
    });

    // Simulate network request
    Future.delayed(2.seconds, () {
      if (mounted) {
        setState(() {
          isRequesting = false;
          isActive = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface, size: 28),
                onPressed: () => context.pop(),
              ),
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  ).animate(onPlay: (c) => c.repeat()).fade(duration: 500.ms, begin: 0.3, end: 1.0),
                  const SizedBox(width: 8),
                  Text(isActive ? 'RESCUE ACTIVE' : 'Emergency SOS', 
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            children: [
              if (!isActive && !isRequesting) ...[
                const SizedBox(height: 24),
                // Pulsing SOS icon
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.white),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.06, 1.06), duration: 1200.ms, curve: Curves.easeInOut),

                const SizedBox(height: 28),
                Text('Need Help?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Select your issue type to request\nimmediate roadside assistance.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: motTheme.slateText, height: 1.5)),

                const SizedBox(height: 32),
                // Issue type grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12, crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _IssueChip(icon: Icons.tire_repair_rounded, label: 'Flat Tyre', onTap: () => _handleIssueTap('Flat Tyre')),
                    _IssueChip(icon: Icons.battery_0_bar_rounded, label: 'Dead Battery', onTap: () => _handleIssueTap('Dead Battery')),
                    _IssueChip(icon: Icons.thermostat_rounded, label: 'Overheating', onTap: () => _handleIssueTap('Overheating')),
                    _IssueChip(icon: Icons.car_crash_rounded, label: 'Accident', onTap: () => _handleIssueTap('Accident')),
                  ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.12, end: 0),
                ),
              ] else if (isRequesting) ...[
                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 6),
                      const SizedBox(height: 32),
                      Text('Requesting Rescue...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 12),
                      Text('Connecting you to the nearest provider for $selectedIssue', textAlign: TextAlign.center, style: TextStyle(color: motTheme.slateText)),
                    ],
                  ),
                ).animate().fade().scale(begin: const Offset(0.9, 0.9)),
              ] else ...[
                // ACTIVE STATE
                const SizedBox(height: 20),
                _RescueTracker(theme: theme, motTheme: motTheme, issue: selectedIssue ?? 'Emergency'),
                const SizedBox(height: 32),
                _ProviderCard(theme: theme, motTheme: motTheme),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.9)),
                      foregroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('CANCEL REQUEST', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IssueChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IssueChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFFEF4444)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RescueTracker extends StatelessWidget {
  final ThemeData theme;
  final MotorAmbosTheme motTheme;
  final String issue;

  const _RescueTracker({required this.theme, required this.motTheme, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(issue.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('RESCUE ACTIVE', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.share_location_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Provider is on the way', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Approx. 2.1km away • 6 mins', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
            ],
          ),
          const SizedBox(height: 24),
          // Animated Tracker Bar
          Stack(
            children: [
              Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2))),
              Container(
                height: 4, width: 240,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyanAccent]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.white24),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ThemeData theme;
  final MotorAmbosTheme motTheme;

  const _ProviderCard({required this.theme, required this.motTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: motTheme.subtleBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.15), child: const Icon(Icons.person, color: Colors.grey)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kofi Mensah', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Expert Mechanic • 4.9 ★', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.blueAccent)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.message_rounded, color: Colors.blueAccent)),
            ],
          ),
        ],
      ),
    );
  }
}
