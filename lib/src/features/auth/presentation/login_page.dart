import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motor_ambos/src/core/services/auth_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorText;




  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorText = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.go('/app');
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onGoogleLogin() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await authService.signInWithGoogle();
      // Router handles redirect via auth state listener
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = 'Google sign-in failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Brand Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your vehicle and\nrequest roadside assistance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: motTheme.slateText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 2. Error Message
                  if (_errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer, // Light Red
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: TextStyle(color: theme.colorScheme.error, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Inputs
                  _InputLabel(label: 'EMAIL ADDRESS'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _emailController,
                    hint: 'hello@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_loading,
                  ),

                  const SizedBox(height: 20),

                  _InputLabel(label: 'PASSWORD'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    enabled: !_loading,
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : () {}, // Implement Forgot Password
                      style: TextButton.styleFrom(foregroundColor: motTheme.slateText),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Primary Action
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onEmailLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Social Login
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _onGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: theme.cardColor,
                      ),
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                        height: 24,
                        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 6. Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: motTheme.slateText),
                      ),
                      TextButton(
                        onPressed: _loading ? null : () => context.push('/sign-up'),
                        child: Text(
                          'Create one',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
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

// -----------------------------------------------------------------------------
// UI HELPERS (Consistent with Add Vehicle / Request Screens)
// -----------------------------------------------------------------------------

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).extension<MotorAmbosTheme>()!.slateText, // Slate-400
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<MotorAmbosTheme>()!.inputBg, // Slate-100
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface, // Dark Navy
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}