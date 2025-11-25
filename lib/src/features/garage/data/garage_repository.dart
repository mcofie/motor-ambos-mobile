import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/vehicle.dart';

// 1. Repository Provider
final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepository(Supabase.instance.client);
});

// 2. Data Stream (This is what the UI watches)
final garageListProvider = StreamProvider<List<Vehicle>>((ref) {
  final repo = ref.watch(garageRepositoryProvider);
  return repo.watchMyVehicles();
});

class GarageRepository {
  final SupabaseClient _client;

  GarageRepository(this._client);

  Stream<List<Vehicle>> watchMyVehicles() {
    return _client
        .from('vehicles')
        .stream(primaryKey: ['id'])
        .order('is_primary', ascending: false)
        .map((data) => data.map((json) => Vehicle.fromJson(json)).toList());
  }

  Future<void> addVehicle({
    required String name,
    required String plate,
    required String make,
    required String model,
    required int year,
    required bool isPrimary,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // If making this primary, un-primary all others first
    if (isPrimary) {
      await _client
          .from('vehicles')
          .update({'is_primary': false})
          .eq('user_id', user.id);
    }

    await _client.from('vehicles').insert({
      'user_id': user.id,
      'name': name,
      'plate': plate,
      'make': make,
      'model': model,
      'year': year,
      'is_primary': isPrimary,
    });
  }

  Future<void> setPrimaryVehicle(String vehicleId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // 1. Set all to false
    await _client
        .from('vehicles')
        .update({'is_primary': false})
        .eq('user_id', user.id);

    // 2. Set chosen one to true
    await _client
        .from('vehicles')
        .update({'is_primary': true})
        .eq('id', vehicleId);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _client.from('vehicles').delete().eq('id', vehicleId);
  }
}
