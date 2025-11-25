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
  String _selectedIssue = 'Towing'; // Default selection

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const kBgColor = Color(0xFFF8FAFC); // Slate-50
    const kDarkNavy = Color(0xFF0F172A); // Slate-900

    final isEmergency = _modeIndex == 0;

    // 🔁 Vehicles from Riverpod
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? <Vehicle>[];

    // 🏎 Pick primary vehicle logic
    Vehicle? activeVehicle;
    if (vehicles.isNotEmpty) {
      activeVehicle = vehicles.firstWhere(
        (v) => v.isPrimary,
        orElse: () => vehicles.first,
      );
    }

    final vehiclesLoading = vehiclesAsync.isLoading;
    final vehiclesError = vehiclesAsync.hasError ? vehiclesAsync.error : null;

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header (Matches Home Screen Vibe)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assistance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kDarkNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // Optional: Profile Icon or Notification Icon could go here
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: kDarkNavy,
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
                        activeVehicle: activeVehicle,
                        vehiclesLoading: vehiclesLoading,
                        vehiclesError: vehiclesError,
                      )
                    : const _ServicesBody(),
              ),
            ),

            // 4. Sticky Bottom Bar (Only for Emergency)
            if (isEmergency)
              _StickyBottomBar(
                selectedIssue: _selectedIssue,
                hasVehicle: activeVehicle != null,
              ),
          ],
        ),
      ),
    );
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? kDarkNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? Colors.white : kSlateText,
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

  const _EmergencyBody({
    required this.selectedIssue,
    required this.onIssueSelected,
    required this.activeVehicle,
    required this.vehiclesLoading,
    required this.vehiclesError,
  });

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

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
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kDarkNavy,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the service you need right now.',
            style: TextStyle(fontSize: 14, color: kSlateText),
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
                color: kDarkNavy,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _ActiveVehicleCard(
            vehicle: activeVehicle,
            isLoading: vehiclesLoading,
            error: vehiclesError,
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
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    final bgColor = isSelected ? kDarkNavy : Colors.white;
    final mainTextColor = isSelected ? Colors.white : kDarkNavy;
    final subTextColor = isSelected ? Colors.white70 : kSlateText;

    Color iconBg;
    Color iconColor;

    if (isSelected) {
      iconBg = Colors.white.withOpacity(0.15);
      iconColor = Colors.white;
    } else if (isAlert) {
      iconBg = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFEF4444);
    } else {
      iconBg = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF334155);
    }

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      elevation: isSelected ? 8 : 0,
      shadowColor: kDarkNavy.withOpacity(0.2),
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

  const _ActiveVehicleCard({
    required this.vehicle,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
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
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: const Text(
          'Failed to load vehicle.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (vehicle == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF0F172A)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: const Color(0xFFF1F5F9), // Light Slate
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFF0F172A),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${vehicle!.plate ?? 'No Plate'} • ${vehicle!.year ?? 'Year N/A'}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/garage'),
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

  const _StickyBottomBar({
    required this.selectedIssue,
    required this.hasVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasVehicle
              ? () => context.push(
                  '/assist/request',
                  extra: {'issue': selectedIssue},
                )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A), // Dark Navy
            foregroundColor: Colors.white,
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
// 5. SERVICES BODY (RESTORED)
// -----------------------------------------------------------------------------
class _ServicesBody extends StatelessWidget {
  const _ServicesBody();

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Leading icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(s['icon'] as IconData, color: kDarkNavy, size: 20),
              ),
              const SizedBox(width: 16),

              // Title + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['desc'] as String,
                      style: TextStyle(color: kSlateText, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // "Coming soon" pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kDarkNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kDarkNavy,
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
