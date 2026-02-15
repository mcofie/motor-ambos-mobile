import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/services/hubtel_sms_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerifyPage extends StatefulWidget {
  /// The phone number the OTP was sent to (in +233 format).
  final String phoneNumber;

  const OtpVerifyPage({super.key, required this.phoneNumber});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _errorText;
  String? _successText;

  // ── Resend cooldown ───────────────────────────────────────────────────
  int _resendCooldown = 60; // seconds
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) timer.cancel();
    });
  }

  String get _enteredCode =>
      _controllers.map((c) => c.text).join();

  Future<void> _onVerify() async {
    final code = _enteredCode;

    if (code.length < 6) {
      setState(() => _errorText = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
      _successText = null;
    });

    try {
      // 1. Verify the OTP code via Hubtel (in-memory check)
      final isValid =
          HubtelSmsService.instance.verifyOtp(widget.phoneNumber, code);

      if (!isValid) {
        setState(
            () => _errorText = 'Invalid or expired code. Please try again.');
        return;
      }

      // 2. OTP verified → create / retrieve a Supabase session.
      //
      //    Since Supabase phone auth requires Twilio, we use a deterministic
      //    email + password derived from the phone number. This keeps it
      //    simple and works without any Supabase SMS provider config.
      final supabase = Supabase.instance.client;
      final phoneDigits = widget.phoneNumber.replaceAll('+', '');
      final syntheticEmail = '$phoneDigits@phone.motorambos.app';
      final syntheticPassword = 'ma_phone_$phoneDigits';

      bool signedIn = false;

      // Try to sign in first (returning user)
      try {
        await supabase.auth.signInWithPassword(
          email: syntheticEmail,
          password: syntheticPassword,
        );
        signedIn = true;
      } on AuthException {
        // User doesn't exist yet — sign them up
        signedIn = false;
      }

      if (!signedIn) {
        // Sign up — the data map stores the real phone number
        final signUpResp = await supabase.auth.signUp(
          email: syntheticEmail,
          password: syntheticPassword,
          data: {
            'phone': widget.phoneNumber,
            'full_name': '',
          },
        );

        // If Supabase has email confirmation enabled, signUp won't auto-login.
        // In that case, try signing in immediately after.
        if (signUpResp.session == null) {
          try {
            await supabase.auth.signInWithPassword(
              email: syntheticEmail,
              password: syntheticPassword,
            );
          } catch (_) {
            // If sign-in still fails, the email-confirm requirement blocks us.
            // Show a helpful error.
            if (mounted) {
              setState(() => _errorText =
                  'Account created but auto‑login failed. Please contact support.');
            }
            return;
          }
        }
      }

      if (!mounted) return;

      setState(() => _successText = 'Verified! Redirecting…');
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) context.go('/app');
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (e) {
      setState(
          () => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onResend() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _loading = true;
      _errorText = null;
      _successText = null;
    });

    try {
      await HubtelSmsService.instance.resendOtp(widget.phoneNumber);

      if (!mounted) return;

      setState(() => _successText = 'A new code has been sent.');
      _startCooldown();
      // Clear fields
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } on HubtelSmsException catch (e) {
      if (mounted) {
        setState(() => _errorText = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = 'Failed to resend: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Handle text change in an OTP field — auto-advance to next.
  void _onOtpFieldChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all filled
    if (_enteredCode.length == 6) {
      _onVerify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    // Mask phone for display: +233241234567 → +233 ** *** 4567
    final masked = widget.phoneNumber.length >= 4
        ? '${widget.phoneNumber.substring(0, 4)} ** *** ${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}'
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.onSurface,
                            theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack)
                      .fade(duration: 400.ms),

                  const SizedBox(height: 24),

                  Text(
                    'Verify Your Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Enter the 6-digit code sent to\n$masked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: motTheme.slateText,
                      height: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 36),

                  // ── Error / Success banners ─────────────────────────
                  if (_errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).shake(hz: 2, duration: 400.ms),
                    const SizedBox(height: 20),
                  ],
                  if (_successText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: motTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: motTheme.success.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: motTheme.success, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _successText!,
                              style: TextStyle(
                                color: motTheme.success,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 20),
                  ],

                  // ── OTP code boxes ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 48,
                        height: 56,
                        margin: EdgeInsets.only(
                          left: i == 0 ? 0 : (i == 3 ? 16 : 8),
                        ),
                        decoration: BoxDecoration(
                          color: motTheme.inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _controllers[i].text.isNotEmpty
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          enabled: !_loading,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => _onOtpFieldChanged(v, i),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: 400.ms,
                              delay: (400 + i * 60).ms)
                          .slideY(begin: 0.15, end: 0);
                    }),
                  ),

                  const SizedBox(height: 36),

                  // ── Verify button ───────────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_user_rounded,
                                    size: 20),
                                const SizedBox(width: 10),
                                const Text(
                                  'Verify & Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Resend row ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          color: motTheme.slateText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: (_loading || _resendCooldown > 0)
                            ? null
                            : _onResend,
                        child: Text(
                          _resendCooldown > 0
                              ? 'Resend in ${_resendCooldown}s'
                              : 'Resend',
                          style: TextStyle(
                            color: _resendCooldown > 0
                                ? motTheme.slateText
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
