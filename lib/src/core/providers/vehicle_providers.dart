import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/services/vehicle_service.dart';

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  return VehicleService();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final service = ref.read(vehicleServiceProvider);
  return service.getVehicles();
});
