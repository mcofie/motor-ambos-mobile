import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

/// Cached user profile data, shared across Home, Account, and other screens.
class UserProfileData {
  final String fullName;
  final String firstName;
  final String phone;
  final String email;
  final String? role;
  final String? avatarUrl;

  const UserProfileData({
    required this.fullName,
    required this.firstName,
    required this.phone,
    required this.email,
    this.role,
    this.avatarUrl,
  });

  UserProfileData copyWith({String? fullName, String? phone, String? role, String? avatarUrl}) {
    final newName = fullName ?? this.fullName;
    final parts = newName.trim().split(RegExp(r'\s+'));
    return UserProfileData(
      fullName: newName,
      firstName: parts.isNotEmpty ? parts.first : newName,
      phone: phone ?? this.phone,
      email: email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// Single source of truth for the current user's profile.
///
/// - `keepAlive`: stays cached until explicitly invalidated.
/// - Invalidate after profile edits: `ref.invalidate(userProfileProvider)`.
final userProfileProvider = FutureProvider<UserProfileData>((ref) async {
  // Keep in memory across navigations
  ref.keepAlive();

  final client = SupabaseService.client;
  final user = client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final email = user.email ?? '';
  final metadataName = user.userMetadata?['full_name'] as String?;
  final fallbackName = metadataName ?? (email.isNotEmpty ? email.split('@').first : 'Driver');

  Map<String, dynamic>? row;

  try {
    final res = await client
        .schema('motorambos')
        .from('profiles')
        .select('full_name, role, phone, avatar_url')
        .eq('user_id', user.id)
        .maybeSingle();

    if (res != null) {
      row = Map<String, dynamic>.from(res as Map);
    }
  } catch (_) {
    // DB might not have profiles table yet — fall back gracefully
  }

  // Auto-create profile row if missing
  if (row == null) {
    try {
      final insert = {
        'user_id': user.id,
        'full_name': fallbackName,
        'phone': user.phone ?? '',
      };
      final insertRes = await client
          .schema('motorambos')
          .from('profiles')
          .insert(insert)
          .select()
          .single();
      row = Map<String, dynamic>.from(insertRes as Map);
    } catch (_) {
      // If insert fails too, use fallback data
    }
  }

  final displayName = (row?['full_name'] as String?)?.isNotEmpty == true
      ? row!['full_name'] as String
      : fallbackName;
  final parts = displayName.trim().split(RegExp(r'\s+'));

  return UserProfileData(
    fullName: displayName,
    firstName: parts.isNotEmpty ? parts.first : displayName,
    phone: (row?['phone'] as String?) ?? user.phone ?? '',
    email: email,
    role: row?['role'] as String?,
    avatarUrl: row?['avatar_url'] as String?,
  );
});
