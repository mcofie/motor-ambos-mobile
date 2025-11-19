import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem('/app', Icons.home_outlined, 'Home'),
    _TabItem('/assist', Icons.electric_car_outlined, 'Assist'),
    _TabItem('/garage', Icons.garage_outlined, 'Garage'),
    _TabItem('/membership', Icons.card_membership_outlined, 'Member'),
    _TabItem('/more', Icons.more_horiz, 'More'),
  ];

  int _indexForLocation(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final tab = _tabs[index];
          if (tab.route != location) {
            context.go(tab.route);
          }
        },
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _TabItem {
  final String route;
  final IconData icon;
  final String label;

  const _TabItem(this.route, this.icon, this.label);
}
