import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';

class VehicleService {
  final SupabaseClient _client;

  VehicleService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  Future<String?> _currentUserId() async {
    final user = _client.auth.currentUser;
    return user?.id;
  }

  Future<List<Vehicle>> getVehicles() async {
    final userId = await _currentUserId();
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final res = await _client
        .schema('motorambos')
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('is_primary', ascending: false)
        .order('created_at', ascending: false);

    return (res as List<dynamic>)
        .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> createVehicle({
    String? name,
    String? make,
    String? model,
    String? year,
    String? plate,
    bool isPrimary = false,
  }) async {
    final userId = await _currentUserId();
    if (userId == null) throw Exception('Not authenticated');

    if (isPrimary) {
      // Unset existing primary vehicles for this user
      await _client
          .schema('motorambos')
          .from('vehicles')
          .update({'is_primary': false})
          .eq('user_id', userId);
    }

    final insert = {
      'user_id': userId,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'plate': plate,
      'is_primary': isPrimary,
    };

    final res = await _client
        .schema('motorambos')
        .from('vehicles')
        .insert(insert)
        .select()
        .single();

    return Vehicle.fromJson(res);
  }

  Future<Vehicle> updateVehicle({
    required String id,
    String? name,
    String? make,
    String? model,
    String? year,
    String? plate,
    bool? isPrimary,
  }) async {
    final userId = await _currentUserId();
    if (userId == null) throw Exception('Not authenticated');

    final update = <String, dynamic>{};

    if (name != null) update['name'] = name;
    if (make != null) update['make'] = make;
    if (model != null) update['model'] = model;
    if (year != null) update['year'] = year;
    if (plate != null) update['plate'] = plate;

    if (isPrimary != null && isPrimary) {
      await _client
          .schema('motorambos')
          .from('vehicles')
          .update({'is_primary': false})
          .eq('user_id', userId);
      update['is_primary'] = true;
    } else if (isPrimary != null && !isPrimary) {
      update['is_primary'] = false;
    }

    final res = await _client
        .schema('motorambos')
        .from('vehicles')
        .update(update)
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return Vehicle.fromJson(res);
  }

  Future<void> deleteVehicle(String id) async {
    final userId = await _currentUserId();
    if (userId == null) throw Exception('Not authenticated');

    await _client
        .schema('motorambos')
        .from('vehicles')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> setPrimaryVehicle(String id) async {
    final userId = await _currentUserId();
    if (userId == null) throw Exception('Not authenticated');

    await _client
        .schema('motorambos')
        .from('vehicles')
        .update({'is_primary': false})
        .eq('user_id', userId);

    await _client
        .schema('motorambos')
        .from('vehicles')
        .update({'is_primary': true})
        .eq('id', id)
        .eq('user_id', userId);
  }
}
