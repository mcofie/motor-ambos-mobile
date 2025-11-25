import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Garage')),

      // 👇 move FAB up so it sits above the bottom nav from AppShell
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            context.pushNamed('garage-add'); // existing route
          },
          icon: const Icon(Icons.add),
          label: const Text('Add vehicle'),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vehiclesProvider);
          await ref.read(vehiclesProvider.future);
        },
        child: vehiclesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Failed to load vehicles: $e',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
                children: [
                  Icon(
                    Icons.directions_car_filled_rounded,
                    size: 64,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No vehicles yet',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Add your car to get faster assistance and membership perks.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return _VehicleTile(
                  vehicle: v,
                  onTap: () {
                    // Edit: pass vehicle via extra
                    context.pushNamed('garage-add', extra: v);
                  },
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
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Remove'),
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
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            vehicle.displayLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vehicle.isPrimary) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (vehicle.plate != null &&
                            vehicle.plate!.trim().isNotEmpty)
                          vehicle.plate,
                        if (vehicle.year != null &&
                            vehicle.year!.trim().isNotEmpty)
                          '• ${vehicle.year}',
                      ].whereType<String>().join('  '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
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
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!vehicle.isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Text('Set as primary'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
