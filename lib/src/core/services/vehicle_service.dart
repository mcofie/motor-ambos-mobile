import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/models/service_history.dart';

class VehicleService {
  final SupabaseClient _client;

  VehicleService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  Future<String?> _currentUserId() async {
    final user = _client.auth.currentUser;
    return user?.id;
  }

  Future<Vehicle?> getVehicleById(String id) async {
    final res = await _client
        .schema('motorambos')
        .from('vehicles')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (res == null) return null;
    return Vehicle.fromJson(res);
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

    return (res as List)
        .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> createVehicle({
    String? name,
    String? make,
    String? model,
    String? year,
    String? plate,
    String? color,
    bool isPrimary = false,
    String? insuranceProvider,
    String? insuranceStickerNo,
    DateTime? insuranceStartDate,
    DateTime? insuranceEndDate,
    DateTime? roadworthyExpiry,
  }) async {
    final userId = await _currentUserId();
    if (userId == null) throw Exception('Not authenticated');

    if (isPrimary) {
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
      'color': color,
      'is_primary': isPrimary,
      'insurance_provider': insuranceProvider,
      'insurance_sticker_no': insuranceStickerNo,
      'insurance_start_date': insuranceStartDate?.toIso8601String(),
      'insurance_end_date': insuranceEndDate?.toIso8601String(),
      'roadworthy_expiry': roadworthyExpiry?.toIso8601String(),
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
    String? color,
    bool? isPrimary,
    String? nfcCardId,
    String? nfcSerialNumber,
    String? roadworthyDocUrl,
    DateTime? roadworthyExpiry,
    String? insuranceProvider,
    String? insuranceStickerNo,
    DateTime? insuranceStartDate,
    DateTime? insuranceEndDate,
  }) async {
    final userId = await _currentUserId();
    if (userId == null) throw Exception('Not authenticated');

    final update = <String, dynamic>{};

    if (name != null) update['name'] = name;
    if (make != null) update['make'] = make;
    if (model != null) update['model'] = model;
    if (year != null) update['year'] = year;
    if (plate != null) update['plate'] = plate;
    if (color != null) update['color'] = color;
    if (nfcCardId != null) update['nfc_card_id'] = nfcCardId;
    if (nfcSerialNumber != null) update['nfc_serial_number'] = nfcSerialNumber;
    if (roadworthyDocUrl != null) update['roadworthy_doc_url'] = roadworthyDocUrl;
    if (roadworthyExpiry != null) update['roadworthy_expiry'] = roadworthyExpiry.toIso8601String();
    if (insuranceProvider != null) update['insurance_provider'] = insuranceProvider;
    if (insuranceStickerNo != null) update['insurance_sticker_no'] = insuranceStickerNo;
    if (insuranceStartDate != null) update['insurance_start_date'] = insuranceStartDate.toIso8601String();
    if (insuranceEndDate != null) update['insurance_end_date'] = insuranceEndDate.toIso8601String();

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

  // --- Service History ---

  Future<List<ServiceHistory>> getServiceHistory(String vehicleId) async {
    final res = await _client
        .schema('motorambos')
        .from('service_history')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('service_date', ascending: false);

    return (res as List)
        .map((json) => ServiceHistory.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
