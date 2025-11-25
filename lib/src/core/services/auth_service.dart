// lib/src/core/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple wrapper around Supabase auth for MotorAmbos
class AuthService {
  AuthService();

  final SupabaseClient _client = Supabase.instance.client;

  /// Email/password sign-up
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    final resp = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return resp;
  }

  /// Email/password sign-in
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final resp = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return resp;
  }

  /// Google OAuth sign-in
  ///
  /// On mobile, make sure your redirect URL is configured in Supabase & app.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      // You can pass redirectTo here if needed:
      // redirectTo: 'io.motorambos.app://login-callback',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
}

/// Global instance you can import everywhere
final authService = AuthService();