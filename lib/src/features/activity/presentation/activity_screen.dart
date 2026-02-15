import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

/// Vehicle history timeline – service logs, fuel entries, document renewals.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Premium AppBar/Header ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                            ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms, begin: 0.3, end: 1.0),
                            const SizedBox(width: 8),
                            Text(
                              'LIVE FEED',
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Activity',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1.2),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(Icons.filter_list_rounded, color: theme.colorScheme.onSurface, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Category Filters ---
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: const EdgeInsets.only(top: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(label: 'All', isSelected: true),
                    _FilterChip(label: 'Service'),
                    _FilterChip(label: 'Fuel'),
                    _FilterChip(label: 'Rescue'),
                    _FilterChip(label: 'Insurance'),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
            ),

            // --- Timeline Empty State or Feed ---
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sophisticated layered icon decor
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
                          
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              size: 36,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms).scale(curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      Text(
                        'The Story Begins',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Every rescue request, fuel refill and\nservice check will be logged here in your\nvehicle\'s digital history.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: motTheme.slateText,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      
                      const SizedBox(height: 40),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('ADD ACTIVITY LOG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.onSurface.withValues(alpha: 0.15)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? theme.colorScheme.surface : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
