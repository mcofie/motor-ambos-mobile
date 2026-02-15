import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';


import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/widget/skeleton.dart';
import 'package:motor_ambos/src/features/garage/presentation/widgets/ghana_number_plate.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Garage', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(vehiclesProvider);
                await ref.read(vehiclesProvider.future);
              },
              color: theme.colorScheme.onSurface,
              child: vehiclesAsync.when(
                loading: () => const SkeletonList(itemCount: 3, itemHeight: 160),
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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final v = vehicles[index];
                      return _VehiclePassportTile(
                        vehicle: v,
                        onTap: () =>
                            context.pushNamed('vehicle-detail', pathParameters: {'id': v.id}),
                        onDelete: () async {
                          HapticFeedback.heavyImpact();
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove vehicle'),
                              content: Text('Remove "${v.displayLabel}" from your garage?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          ) ?? false;

                          if (!ok) return;
                          await ref.read(vehicleServiceProvider).deleteVehicle(v.id);
                          ref.invalidate(vehiclesProvider);
                        },
                      ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
            ),
          ),

          // Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.extension<MotorAmbosTheme>()!.subtleBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed('garage-add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 24),
                  label: const Text('ADD NEW VEHICLE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehiclePassportTile extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VehiclePassportTile({required this.vehicle, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardText = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMakeBadge(context, vehicle.make),
                if (vehicle.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Text('PRIMARY', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Hero(
              tag: 'label-${vehicle.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  vehicle.displayLabel,
                  style: TextStyle(color: cardText, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (vehicle.plate != null && vehicle.plate!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Hero(
                    tag: 'plate-${vehicle.id}',
                    child: GhanaNumberPlate(plateNumber: vehicle.plate!, height: 60),
                  ),
                ),
              ),
            if (vehicle.year != null && vehicle.year!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                vehicle.year!,
                style: TextStyle(color: cardText.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.nfc_rounded, color: cardText.withValues(alpha: 0.45), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.nfcCardId != null ? 'SECURED' : 'UNLINKED',
                      style: TextStyle(color: cardText.withValues(alpha: 0.45), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDelete();
                  },
                  child: Icon(Icons.remove_circle_outline_rounded, color: cardText.withValues(alpha: 0.45), size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMakeBadge(BuildContext context, String? make) {
    final theme = Theme.of(context);
    final name = (make ?? 'VEHICLE').toUpperCase();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        name,
        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_filled_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 20),
          Text('Your Garage is Empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          const Text('Secure your vehicles with a digital passport', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
