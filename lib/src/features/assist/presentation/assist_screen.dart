import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class AssistScreen extends ConsumerStatefulWidget {
  const AssistScreen({super.key});

  @override
  ConsumerState<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends ConsumerState<AssistScreen> {
  int _modeIndex = 0; // 0 = Emergency, 1 = Services
  String _selectedIssue = 'Towing'; // Default selection

  /// Vehicle explicitly chosen in this screen (via bottom sheet).
  /// If null, we fall back to primary/first vehicle.
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    final isEmergency = _modeIndex == 0;

    // 🔁 Vehicles from Riverpod
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? <Vehicle>[];

    // 🏎 Pick primary vehicle logic
    Vehicle? primaryVehicle;
    if (vehicles.isNotEmpty) {
      primaryVehicle = vehicles.firstWhere(
        (v) => v.isPrimary,
        orElse: () => vehicles.first,
      );
    }

    // Effective vehicle = user-selected (via sheet) OR primary fallback
    final Vehicle? effectiveVehicle = _selectedVehicle ?? primaryVehicle;

    final vehiclesLoading = vehiclesAsync.isLoading;
    final vehiclesError = vehiclesAsync.hasError ? vehiclesAsync.error : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header (Matches Home Screen Vibe)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assistance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: motTheme.subtleBorder),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _ModernToggle(
                selectedIndex: _modeIndex,
                onChanged: (index) => setState(() => _modeIndex = index),
              ),
            ),

            // 3. Main Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isEmergency
                    ? _EmergencyBody(
                        selectedIssue: _selectedIssue,
                        onIssueSelected: (val) =>
                            setState(() => _selectedIssue = val),
                        activeVehicle: effectiveVehicle,
                        vehiclesLoading: vehiclesLoading,
                        vehiclesError: vehiclesError,
                        onChangeVehicle: vehicles.isNotEmpty
                            ? () => _showVehiclePicker(vehicles)
                            : null,
                      )
                    : const _ServicesBody(),
              ),
            ),

            // 4. Sticky Bottom Bar (Only for Emergency)
            if (isEmergency)
              _StickyBottomBar(
                selectedIssue: _selectedIssue,
                hasVehicle: effectiveVehicle != null,
                onContinue: effectiveVehicle == null
                    ? null
                    : () {
                        final summary = {
                          'label': effectiveVehicle.displayLabel,
                          'plate': effectiveVehicle.plate,
                          'year': effectiveVehicle.year,
                        };

                        context.push(
                          '/assist/request',
                          extra: {
                            'issue': _selectedIssue,
                            'vehicleId': effectiveVehicle.id,
                            'vehicleSummary': summary,
                          },
                        );
                      },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVehiclePicker(List<Vehicle> vehicles) async {
    final selected = await showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(context);
        final motTheme = theme.extension<MotorAmbosTheme>()!;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: motTheme.subtleBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose vehicle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select the vehicle that needs help.',
                    style: TextStyle(fontSize: 13, color: motTheme.slateText),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final v = vehicles[index];
                      final title = v.displayLabel;
                      final subtitle =
                          "${v.plate ?? 'No Plate'} • ${v.year ?? 'Year N/A'}";

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(ctx, v),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: motTheme.subtleBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: motTheme.inputBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: motTheme.slateText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() => _selectedVehicle = selected);
    }
  }
}

// -----------------------------------------------------------------------------
// 1. CUSTOM TOGGLE
// -----------------------------------------------------------------------------
class _ModernToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ModernToggle({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'Emergency',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _ToggleItem(
            label: 'Services',
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
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? theme.colorScheme.surface : motTheme.slateText,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. EMERGENCY BODY
// -----------------------------------------------------------------------------
class _EmergencyBody extends StatelessWidget {
  final String selectedIssue;
  final ValueChanged<String> onIssueSelected;
  final Vehicle? activeVehicle;
  final bool vehiclesLoading;
  final Object? vehiclesError;
  final VoidCallback? onChangeVehicle;

  const _EmergencyBody({
    required this.selectedIssue,
    required this.onIssueSelected,
    required this.activeVehicle,
    required this.vehiclesLoading,
    required this.vehiclesError,
    required this.onChangeVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    final issues = [
      {
        'id': 'Battery',
        'sub': 'Jumpstart / Replace',
        'icon': Icons.battery_charging_full_rounded,
      },
      {
        'id': 'Flat Tyre',
        'sub': 'Change / Pump',
        'icon': Icons.tire_repair_rounded,
      },
      {
        'id': 'Engine Oil',
        'sub': 'Top-up / Leak',
        'icon': Icons.oil_barrel_rounded,
      },
      {'id': 'Towing', 'sub': 'Move Vehicle', 'icon': Icons.toys_rounded},
      {
        'id': 'Rescue',
        'sub': 'Stuck / Accident',
        'icon': Icons.warning_amber_rounded,
      },
      {
        'id': 'Fuel',
        'sub': 'Out of gas',
        'icon': Icons.local_gas_station_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the service you need right now.',
            style: TextStyle(fontSize: 14, color: motTheme.slateText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: issues.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final item = issues[index];
              final id = item['id'] as String;
              final isSelected = selectedIssue == id;

              return _IssueCard(
                label: id,
                subLabel: item['sub'] as String,
                icon: item['icon'] as IconData,
                isSelected: isSelected,
                isAlert: id == 'Rescue',
                onTap: () => onIssueSelected(id),
              );
            },
          ),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'For Vehicle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _ActiveVehicleCard(
            vehicle: activeVehicle,
            isLoading: vehiclesLoading,
            error: vehiclesError,
            onChangeVehicle: onChangeVehicle,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final bool isSelected;
  final bool isAlert;
  final VoidCallback onTap;

  const _IssueCard({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.isSelected,
    this.isAlert = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    final bgColor = isSelected ? theme.colorScheme.onSurface : theme.cardColor;
    final mainTextColor = isSelected ? theme.colorScheme.surface : theme.colorScheme.onSurface;
    final subTextColor = isSelected ? theme.colorScheme.surface.withValues(alpha: 0.7) : motTheme.slateText;

    Color iconBg;
    Color iconColor;

    if (isSelected) {
      iconBg = theme.colorScheme.surface.withValues(alpha: 0.15);
      iconColor = theme.colorScheme.surface;
    } else if (isAlert) {
      iconBg = theme.colorScheme.errorContainer;
      iconColor = theme.colorScheme.error;
    } else {
      iconBg = motTheme.inputBg;
      iconColor = theme.colorScheme.onSurfaceVariant;
    }

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: motTheme.subtleBorder),
      ),
      elevation: isSelected ? 8 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. VEHICLE CARD
// -----------------------------------------------------------------------------
class _ActiveVehicleCard extends StatelessWidget {
  final Vehicle? vehicle;
  final bool isLoading;
  final Object? error;
  final VoidCallback? onChangeVehicle;

  const _ActiveVehicleCard({
    required this.vehicle,
    required this.isLoading,
    required this.error,
    required this.onChangeVehicle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator.adaptive(),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2)),
        ),
        child: Text(
          'Failed to load vehicle.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (vehicle == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).extension<MotorAmbosTheme>()!.inputBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 16),
            const Text(
              "Add a vehicle to continue",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/garage'),
              child: const Text("Add"),
            ),
          ],
        ),
      );
    }

    // Active Vehicle Display
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<MotorAmbosTheme>()!.inputBg, // Light Slate
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle!.displayLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${vehicle!.plate ?? 'No Plate'} • ${vehicle!.year ?? 'Year N/A'}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).extension<MotorAmbosTheme>()!.slateText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChangeVehicle ?? () => context.go('/garage'),
            child: const Text(
              "Change",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. STICKY BOTTOM BAR
// -----------------------------------------------------------------------------
class _StickyBottomBar extends StatelessWidget {
  final String selectedIssue;
  final bool hasVehicle;
  final VoidCallback? onContinue;

  const _StickyBottomBar({
    required this.selectedIssue,
    required this.hasVehicle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasVehicle ? onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onSurface, // Dark Navy
            foregroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue to Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. SERVICES BODY (unchanged)
// -----------------------------------------------------------------------------
class _ServicesBody extends StatelessWidget {
  const _ServicesBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    final services = [
      {
        'title': 'Car Wash',
        'desc': 'Interior & Exterior',
        'icon': Icons.local_car_wash_rounded,
      },
      {
        'title': 'Oil Change',
        'desc': 'Synthetic & Standard',
        'icon': Icons.oil_barrel_rounded,
      },
      {
        'title': 'Diagnostics',
        'desc': 'Check engine light',
        'icon': Icons.monitor_heart_rounded,
      },
      {
        'title': 'Detailing',
        'desc': 'Deep clean & polish',
        'icon': Icons.cleaning_services_rounded,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final s = services[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: motTheme.subtleBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: motTheme.inputBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(s['icon'] as IconData, color: theme.colorScheme.onSurface, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['desc'] as String,
                      style: TextStyle(color: motTheme.slateText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
