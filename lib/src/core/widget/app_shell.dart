import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Application shell providing the bottom navigation bar
/// with 4 destination tabs and a centre SOS floating action button.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem('/app', CupertinoIcons.house_fill, CupertinoIcons.house, 'Home'),
    _TabItem('/services', CupertinoIcons.wrench_fill, CupertinoIcons.wrench, 'Services'),
    _TabItem('/activity', CupertinoIcons.clock_fill, CupertinoIcons.clock, 'Activity'),
    _TabItem('/profile', CupertinoIcons.person_fill, CupertinoIcons.person, 'Profile'),
  ];

  int _indexForLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return ToastificationWrapper(
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: _FloatingNavBar(
          currentIndex: currentIndex,
          tabs: _tabs,
          onTap: (index) {
            final tab = _tabs[index];
            if (tab.route != location) {
              HapticFeedback.selectionClick();
              context.go(tab.route);
            }
          },
          onSosTap: () {
            HapticFeedback.heavyImpact();
            context.push('/sos');
          },
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;
  final VoidCallback onSosTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
    required this.onSosTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double bottomMargin = bottomPadding > 0 ? bottomPadding + 8 : 20;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomMargin),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Glass Background
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: isDark ? 0.7 : 0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavIcon(tab: tabs[0], isSelected: currentIndex == 0, onTap: () => onTap(0)),
                    _NavIcon(tab: tabs[1], isSelected: currentIndex == 1, onTap: () => onTap(1)),
                    const Spacer(), // Space for SOS FAB
                    _NavIcon(tab: tabs[2], isSelected: currentIndex == 2, onTap: () => onTap(2)),
                    _NavIcon(tab: tabs[3], isSelected: currentIndex == 3, onTap: () => onTap(3)),
                  ],
                ),
              ),
            ),
          ),

          // SOS FAB
          Positioned(
            bottom: 22,
            child: GestureDetector(
              onTap: onSosTap,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final _TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Icon(
                isSelected ? tab.activeIcon : tab.inactiveIcon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final String route;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _TabItem(this.route, this.activeIcon, this.inactiveIcon, this.label);
}
