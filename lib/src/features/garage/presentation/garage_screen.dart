import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header (Consistent with other screens)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: kDarkNavy,
                      ),
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'My Garage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kDarkNavy,
                      ),
                    ),
                  ),
                  // Spacer to balance the back button width
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // 2. Vehicle List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(vehiclesProvider);
                  await ref.read(vehiclesProvider.future);
                },
                color: kDarkNavy,
                child: vehiclesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: kDarkNavy),
                  ),
                  error: (e, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Failed to load vehicles.\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return _EmptyGarageView(
                        onAdd: () => context.pushNamed('garage-add'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        return _VehicleTile(
                          vehicle: v,
                          onTap: () =>
                              context.pushNamed('garage-add', extra: v),
                          onDelete: () async {
                            final ok =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Remove vehicle'),
                                    content: Text(
                                      'Remove "${v.displayLabel}" from your garage?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (!ok) return;

                            final service = ref.read(vehicleServiceProvider);
                            await service.deleteVehicle(v.id);
                            ref.invalidate(vehiclesProvider);
                          },
                          onSetPrimary: () async {
                            final service = ref.read(vehicleServiceProvider);
                            await service.setPrimaryVehicle(v.id);
                            ref.invalidate(vehiclesProvider);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // 3. Sticky "Add Vehicle" Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed('garage-add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 24),
                  label: const Text(
                    'Add New Vehicle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class _VehicleTile extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSetPrimary;

  const _VehicleTile({
    required this.vehicle,
    this.onTap,
    this.onDelete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    // Colors
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Light Slate
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: kDarkNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              vehicle.displayLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kDarkNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vehicle.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: kDarkNavy.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkNavy,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (vehicle.plate != null &&
                              vehicle.plate!.trim().isNotEmpty)
                            vehicle.plate,
                          if (vehicle.year != null &&
                              vehicle.year!.trim().isNotEmpty)
                            vehicle.year,
                        ].whereType<String>().join(' • '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: kSlateText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: kSlateText),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'primary' && onSetPrimary != null) {
                      onSetPrimary!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    } else if (value == 'edit' && onTap != null) {
                      onTap!();
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18, color: kSlateText),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!vehicle.isPrimary)
                      const PopupMenuItem(
                        value: 'primary',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: kSlateText,
                            ),
                            SizedBox(width: 12),
                            Text('Set as Primary'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text('Remove', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyGarageView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyGarageView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kDarkNavy.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                size: 48,
                color: kDarkNavy,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No vehicles yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kDarkNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your car to get faster assistance and access membership perks.',
              style: TextStyle(fontSize: 14, color: kSlateText, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
