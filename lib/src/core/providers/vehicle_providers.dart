import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/models/service_history.dart';
import 'package:motor_ambos/src/core/services/vehicle_service.dart';

/// Singleton service — no need to recreate on every use.
final vehicleServiceProvider = Provider<VehicleService>((ref) {
  return VehicleService();
});

/// Cached vehicle list. Stays alive until explicitly invalidated
/// (e.g. after add/edit/delete).
///
/// Invalidate: `ref.invalidate(vehiclesProvider)`
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  ref.keepAlive();
  final service = ref.read(vehicleServiceProvider);
  return service.getVehicles();
});

/// Cached single‑vehicle lookup. Stays alive per vehicle ID.
///
/// Invalidate: `ref.invalidate(vehicleDetailProvider(id))`
final vehicleDetailProvider = FutureProvider.family<Vehicle?, String>((ref, id) async {
  ref.keepAlive();

  // Optimistic Cache: Check if we already have this vehicle in the loaded list
  // Only use cache if the list is stable (not loading/refreshing) to avoid stale data during edits
  final vehiclesState = ref.read(vehiclesProvider);
  if (vehiclesState.hasValue && !vehiclesState.isLoading && !vehiclesState.isRefreshing) {
    try {
      final cached = vehiclesState.value!.firstWhere((v) => v.id == id);
      return cached;
    } catch (_) {
      // Not found, proceed to fetch
    }
  }

  final service = ref.read(vehicleServiceProvider);
  return service.getVehicleById(id);
});

/// Cached service history per vehicle. Stays alive per vehicle ID.
///
/// Invalidate: `ref.invalidate(serviceHistoryProvider(vehicleId))`
final serviceHistoryProvider = FutureProvider.family<List<ServiceHistory>, String>((ref, vehicleId) async {
  ref.keepAlive();
  final service = ref.read(vehicleServiceProvider);
  return service.getServiceHistory(vehicleId);
});

/// Convenience: the user's primary vehicle (derived from the cached list).
/// No extra DB call — reads from vehiclesProvider.
final primaryVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  if (vehicles.isEmpty) return null;
  try {
    return vehicles.firstWhere((v) => v.isPrimary);
  } catch (_) {
    return vehicles.first;
  }
});
