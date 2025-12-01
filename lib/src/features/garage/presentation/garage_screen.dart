import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';


import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/widget/skeleton.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header (Consistent with other screens)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Garage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
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
                color: theme.colorScheme.onSurface,
                child: vehiclesAsync.when(
                  loading: () => const SkeletonList(itemCount: 3, itemHeight: 140),
                  error: (e, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Failed to load vehicles.\n$e',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
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
                            HapticFeedback.heavyImpact();
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
                        ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
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
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(color: theme.extension<MotorAmbosTheme>()!.subtleBorder),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed('garage-add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface,
                    foregroundColor: theme.colorScheme.surface,
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
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                    color: motTheme.inputBg, // Light Slate
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: theme.colorScheme.onSurface,
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
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
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
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
                        style: TextStyle(
                          fontSize: 13,
                          color: motTheme.slateText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: motTheme.slateText),
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18, color: motTheme.slateText),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!vehicle.isPrimary)
                      PopupMenuItem(
                        value: 'primary',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: motTheme.slateText,
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
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 48,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No vehicles yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your car to get faster assistance and access membership perks.',
              style: TextStyle(fontSize: 14, color: motTheme.slateText, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
