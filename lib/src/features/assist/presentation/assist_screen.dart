import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';

class AssistScreen extends ConsumerStatefulWidget {
  const AssistScreen({super.key});

  @override
  ConsumerState<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends ConsumerState<AssistScreen> {
  int _modeIndex = 0; // 0 = Emergency, 1 = Services
  String _selectedIssue = 'Towing';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEmergency = _modeIndex == 0;

    // 🔁 Vehicles from Riverpod
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? <Vehicle>[];

    // 🏎 Pick primary vehicle (fallback to first if none)
    Vehicle? activeVehicle;
    for (final v in vehicles) {
      if (v.isPrimary) {
        activeVehicle = v;
        break;
      }
    }
    activeVehicle ??= vehicles.isNotEmpty ? vehicles.first : null;

    final vehiclesLoading = vehiclesAsync.isLoading;
    final vehiclesError = vehiclesAsync.hasError ? vehiclesAsync.error : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        centerTitle: true,
        title: Text(
          'Assistance',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Top Section: Toggle & Context
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _ModernToggle(
                  selectedIndex: _modeIndex,
                  onChanged: (index) => setState(() => _modeIndex = index),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isEmergency
                        ? 'What issue are you facing?'
                        : 'Schedule vehicle maintenance',
                    key: ValueKey(isEmergency),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 2. Scrollable Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isEmergency
                  ? _EmergencyBody(
                selectedIssue: _selectedIssue,
                onIssueSelected: (val) =>
                    setState(() => _selectedIssue = val),
                activeVehicle: activeVehicle,
                vehiclesLoading: vehiclesLoading,
                vehiclesError: vehiclesError,
              )
                  : const _ServicesBody(),
            ),
          ),

          // 3. Bottom Sticky Action Bar (Only for Emergency)
          if (isEmergency)
            _StickyBottomBar(
              selectedIssue: _selectedIssue,
              hasVehicle: activeVehicle != null,
            ),
        ],
      ),
    );
  }
}

//
// CUSTOM TOGGLE
//
class _ModernToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ModernToggle({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Theme-aware grey
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'Emergency',
            icon: Icons.warning_amber_rounded,
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _ToggleItem(
            label: 'Services',
            icon: Icons.calendar_month_rounded,
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// EMERGENCY BODY
//
class _EmergencyBody extends StatelessWidget {
  final String selectedIssue;
  final ValueChanged<String> onIssueSelected;

  final Vehicle? activeVehicle;
  final bool vehiclesLoading;
  final Object? vehiclesError;

  const _EmergencyBody({
    required this.selectedIssue,
    required this.onIssueSelected,
    required this.activeVehicle,
    required this.vehiclesLoading,
    required this.vehiclesError,
  });

  @override
  Widget build(BuildContext context) {
    final issues = [
      {'id': 'Towing', 'icon': Icons.local_shipping_outlined},
      {'id': 'Flat tyre', 'icon': Icons.tire_repair},
      {'id': 'Jumpstart', 'icon': Icons.bolt_outlined},
      {'id': 'Engine', 'icon': Icons.build_circle_outlined},
      {'id': 'Fuel', 'icon': Icons.local_gas_station_outlined},
      {'id': 'Other', 'icon': Icons.support_agent},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: issues.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final item = issues[index];
              final isSelected = selectedIssue == item['id'];
              return _IssueCard(
                label: item['id'] as String,
                icon: item['icon'] as IconData,
                isSelected: isSelected,
                onTap: () => onIssueSelected(item['id'] as String),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'For Vehicle',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // 🔧 Active vehicle card wired to real data
          _ActiveVehicleCard(
            vehicle: activeVehicle,
            isLoading: vehiclesLoading,
            error: vehiclesError,
          ),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Logic: Selected card uses "Secondary" (Brand Black), text is "OnSecondary"
    final bgColor =
    isSelected ? colorScheme.secondary : colorScheme.surfaceContainer;
    final iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.7);
    final textColor =
    isSelected ? colorScheme.onSecondary : colorScheme.onSurface;
    final borderColor = isSelected ? colorScheme.secondary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveVehicleCard extends StatelessWidget {
  final Vehicle? vehicle;
  final bool isLoading;
  final Object? error;

  const _ActiveVehicleCard({
    required this.vehicle,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      // Skeleton shimmer-ish state
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.onSecondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBar(colorScheme.onSecondary, width: 140),
                  const SizedBox(height: 8),
                  _skeletonBar(
                    colorScheme.onSecondary.withOpacity(0.6),
                    width: 100,
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load vehicles',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/garage'),
            child: const Text('Open Garage'),
          ),
        ],
      );
    }

    // ✅ Fix: copy to local var for promotion
    final v = vehicle;
    if (v == null) {
      // No vehicle configured
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car_filled_outlined,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No vehicle selected.\nAdd a car to your garage to request assistance faster.',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/garage'),
              child: Text(
                'Add',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ Vehicle is present -> show primary / active vehicle
    final label = v.displayLabel;
    final plate = v.plate?.trim();
    final year = v.year?.trim();
    final secondaryLine = [
      if (plate != null && plate.isNotEmpty) plate,
      if (year != null && year.isNotEmpty) '• $year',
      if (v.isPrimary) '• Primary',
    ].join('  ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary, // Brand Accent (Black)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car_filled,
              color: colorScheme.onSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (secondaryLine.isNotEmpty)
                  Text(
                    secondaryLine,
                    style: TextStyle(
                      color: colorScheme.onSecondary.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/garage'),
            child: Text(
              'Change',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBar(Color color, {double width = 120, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

//
// STICKY BOTTOM BAR
//
class _StickyBottomBar extends StatelessWidget {
  final String selectedIssue;
  final bool hasVehicle;

  const _StickyBottomBar({
    required this.selectedIssue,
    required this.hasVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: hasVehicle
              ? () {
            context.push(
              '/assist/request',
              extra: {
                'issue': selectedIssue,
              },
            );
          }
              : null, // disable if no vehicle
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.my_location_sharp, size: 20),
              SizedBox(width: 10),
              Text(
                'Confirm Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// SERVICES BODY
//
class _ServicesBody extends StatelessWidget {
  const _ServicesBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final services = [
      {
        'title': 'Car Wash',
        'desc': 'Interior & Exterior',
        'icon': Icons.local_car_wash
      },
      {
        'title': 'Oil Change',
        'desc': 'Synthetic & Standard',
        'icon': Icons.oil_barrel
      },
      {
        'title': 'Diagnostics',
        'desc': 'Check engine light',
        'icon': Icons.monitor_heart
      },
      {
        'title': 'Detailing',
        'desc': 'Deep clean & polish',
        'icon': Icons.cleaning_services
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final s = services[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border:
            Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child:
                Icon(s['icon'] as IconData, color: colorScheme.onSurface),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      s['desc'] as String,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}