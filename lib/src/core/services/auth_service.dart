// lib/src/core/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple wrapper around Supabase auth for MotorAmbos
class AuthService {
  AuthService();

  final SupabaseClient _client = Supabase.instance.client;

  // ── Email auth ──────────────────────────────────────────────────────

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

  // ── Phone / OTP auth ────────────────────────────────────────────────

  /// Sign in (or sign up) with phone number using Supabase phone OTP.
  ///
  /// After calling this, Supabase will issue an OTP to the phone number.
  /// Then call [verifyPhoneOtp] with the code the user received.
  Future<void> signInWithPhone(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Verify the OTP code that Supabase sent to [phone].
  ///
  /// On success a session is created and the user is logged in.
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final resp = await _client.auth.verifyOTP(
      phone: phone,
      token: code,
      type: OtpType.sms,
    );
    return resp;
  }

  // ── OAuth ───────────────────────────────────────────────────────────

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

  // ── General ─────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Update the current user's metadata (e.g. full_name after phone login).
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    await _client.auth.updateUser(UserAttributes(data: data));
  }

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
}

/// Global instance you can import everywhere
final authService = AuthService();