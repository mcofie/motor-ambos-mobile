import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem('/app', CupertinoIcons.house_fill, CupertinoIcons.house, 'Home'),
    _TabItem(
      '/assist',
      CupertinoIcons.exclamationmark_shield_fill,
      CupertinoIcons.exclamationmark_shield,
      'Assist',
    ),
    _TabItem('/garage', CupertinoIcons.car_fill, CupertinoIcons.car_detailed, 'Garage'),
    _TabItem('/membership', CupertinoIcons.creditcard_fill, CupertinoIcons.creditcard, 'Member'),
    _TabItem(
      '/more',
      CupertinoIcons.square_grid_2x2_fill,
      CupertinoIcons.square_grid_2x2,
      'More',
    ),
  ];

  int _indexForLocation(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return ToastificationWrapper(
      child: Scaffold(
      // Setting extendBody to false (default) ensures the body stops
      // right before the bottom navigation bar starts.
      extendBody: false,
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
      ),
    ));
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Calculate safe area + margin
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double bottomMargin = bottomPadding > 0 ? bottomPadding + 10 : 24;

    return Container(
      // This container background ensures the area behind the floating pill
      // matches the scaffold background if it were transparent, but since
      // extendBody is false, this sits in its own slot.
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(24, 10, 24, bottomMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              // Adaptive Glass Color
              color: colorScheme.surface.withValues(alpha: isDark ? 0.75 : 0.85),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              // Subtle border for contrast
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          padding: EdgeInsets.all(isSelected ? 12 : 8),
                          decoration: BoxDecoration(
                            // Active State: Use Primary Container or Inverse Surface
                            color: isSelected
                                ? (isDark
                                      ? colorScheme.primary
                                      : colorScheme.onSurface)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isSelected ? tab.activeIcon : tab.inactiveIcon,
                            // Icon Color Logic
                            color: isSelected
                                ? (isDark
                                      ? colorScheme.onPrimary
                                      : colorScheme.surface)
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
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
