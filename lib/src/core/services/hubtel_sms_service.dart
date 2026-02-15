// lib/src/core/services/hubtel_sms_service.dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:motor_ambos/src/core/config/env.dart';

/// Service for sending & verifying OTP codes via Hubtel SMS API.
///
/// Flow:
///   1. Call [sendOtp] with the user's phone number → a 6-digit code is
///      generated, stored in memory, and sent via Hubtel.
///   2. Call [verifyOtp] with the same phone number and the code the user
///      entered → returns `true` if it matches and hasn't expired.
///   3. Optionally call [resendOtp] to generate & send a fresh code.
class HubtelSmsService {
  HubtelSmsService._();
  static final HubtelSmsService instance = HubtelSmsService._();

  // ── Hubtel SMS API ────────────────────────────────────────────────────
  static const _baseUrl = 'https://smsc.hubtel.com/v1/messages/send';

  /// In-memory OTP store: phone → { code, expiresAt }
  final Map<String, _OtpEntry> _otpStore = {};

  /// OTP validity window
  static const _otpTtl = Duration(minutes: 5);

  // ── Public API ────────────────────────────────────────────────────────

  /// Generate a 6-digit OTP and send it to [phoneNumber] via Hubtel.
  ///
  /// [phoneNumber] should be in international format, e.g. "+233200000000".
  /// Throws [HubtelSmsException] if the SMS could not be sent.
  Future<void> sendOtp(String phoneNumber) async {
    final code = _generateCode();
    _otpStore[phoneNumber] = _OtpEntry(
      code: code,
      expiresAt: DateTime.now().add(_otpTtl),
    );

    await _sendSms(
      to: phoneNumber,
      message: 'Your MotorAmbos verification code is: $code. '
          'It expires in 5 minutes.',
    );

    debugPrint('[HubtelSmsService] OTP sent to $phoneNumber');
  }

  /// Verify the OTP [code] for the given [phoneNumber].
  ///
  /// Returns `true` only if the code matches and hasn't expired.
  bool verifyOtp(String phoneNumber, String code) {
    final entry = _otpStore[phoneNumber];
    if (entry == null) return false;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _otpStore.remove(phoneNumber);
      return false;
    }
    if (entry.code != code) return false;

    // Verified — remove so it can't be reused
    _otpStore.remove(phoneNumber);
    return true;
  }

  /// Resend a fresh OTP (invalidates the previous one).
  Future<void> resendOtp(String phoneNumber) => sendOtp(phoneNumber);

  // ── Internals ─────────────────────────────────────────────────────────

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  Future<void> _sendSms({
    required String to,
    required String message,
  }) async {
    // Basic Auth: base64(clientId:clientSecret)
    final credentials = base64Encode(
      utf8.encode('${Env.hubtelClientId}:${Env.hubtelClientSecret}'),
    );

    final http.Response response;

    try {
      response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'From': Env.hubtelSenderId,
          'To': to,
          'Content': message,
        }),
      );
    } catch (e) {
      debugPrint('[HubtelSmsService] Network error: $e');
      throw HubtelSmsException(
        'Network error — check your internet connection.',
      );
    }

    debugPrint('[HubtelSmsService] Response ${response.statusCode}: '
        '${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Try to extract a message from the response body
      String detail = 'SMS delivery failed (${response.statusCode}).';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          detail = body['message'] as String;
        } else if (body is Map && body.containsKey('Message')) {
          detail = body['Message'] as String;
        }
      } catch (_) {
        // body isn't JSON — use the raw status
      }
      throw HubtelSmsException(detail);
    }
  }
}

/// Exception thrown when an SMS could not be sent via Hubtel.
class HubtelSmsException implements Exception {
  final String message;
  const HubtelSmsException(this.message);

  @override
  String toString() => 'HubtelSmsException: $message';
}

class _OtpEntry {
  final String code;
  final DateTime expiresAt;
  const _OtpEntry({required this.code, required this.expiresAt});
}
