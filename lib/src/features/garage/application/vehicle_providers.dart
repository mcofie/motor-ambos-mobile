import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vehicle.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

class VehicleListNotifier extends StateNotifier<List<Vehicle>> {
  VehicleListNotifier()
      : super([
    Vehicle(
      id: _uuid.v4(),
      name: 'Toyota Corolla',
      plate: 'GR 1234-24',
      make: 'Toyota',
      model: 'Corolla',
      year: 2019,
      isPrimary: true,
    ),
  ]);

  void addVehicle({
    required String name,
    required String plate,
    required String make,
    required String model,
    required int year,
    bool isPrimary = false,
  }) {
    final updated = isPrimary
        ? state.map((v) => v.copyWith(isPrimary: false)).toList()
        : List<Vehicle>.from(state);

    updated.add(
      Vehicle(
        id: _uuid.v4(),
        name: name,
        plate: plate,
        make: make,
        model: model,
        year: year,
        isPrimary: isPrimary,
      ),
    );

    state = updated;
  }

  void setPrimary(String id) {
    state = [
      for (final v in state)
        v.copyWith(isPrimary: v.id == id),
    ];
  }
}

final vehicleListProvider =
StateNotifierProvider<VehicleListNotifier, List<Vehicle>>(
      (ref) => VehicleListNotifier(),
);