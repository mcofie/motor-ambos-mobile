import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/membership.dart';

final membershipProvider = Provider<Membership>((ref) {
  // TODO: Replace this with data from Supabase later
  final now = DateTime.now();

  return Membership(
    id: 'MBR-2048-001',
    tier: 'Premium',
    expiry: DateTime(now.year + 1, now.month, now.day),
    memberSince: DateTime(2024, 3, 12),
    callsUsedThisYear: 3,
    includedCallsPerYear: 6,
    estimatedSavings: 420.0,
    freeTowRadiusKm: 20,
    prioritySupport: true,
  );
});