import 'package:motor_ambos/src/core/services/supabase_service.dart';

/// Simple service to read the user's membership.
///
/// Table assumed: motorambos.memberships
/// Columns used: user_id, membership_id, tier, status, started_at, expiry_date,
///               calls_used, savings
class MembershipService {
  const MembershipService();

  Future<Map<String, dynamic>?> getMembership() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) return null;

    final dynamic res = await client
        .schema('motorambos')
        .from('memberships')
        .select(
          'membership_id, tier, status, started_at, expiry_date, calls_used, savings',
        )
        .eq('user_id', user.id)
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (res == null) return null;

    final row = Map<String, dynamic>.from(res as Map);

    // Compute "is_active" on the Dart side
    final status = (row['status'] as String?)?.toLowerCase();
    final now = DateTime.now();

    DateTime? expiry;
    final expiryRaw = row['expiry_date'];
    if (expiryRaw is String) {
      expiry = DateTime.tryParse(expiryRaw);
    } else if (expiryRaw is DateTime) {
      expiry = expiryRaw;
    }

    final bool isActive =
        status == 'active' && (expiry == null || !expiry.isBefore(now));

    row['is_active'] = isActive;

    return row;
  }

  Future<void> enroll(String tier) async {
    // TODO: Implement actual enrollment logic
    await Future.delayed(const Duration(seconds: 1));
  }
}
