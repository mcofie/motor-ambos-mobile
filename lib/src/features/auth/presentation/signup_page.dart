import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motor_ambos/src/core/services/auth_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorText;




  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      // Route to App or Sign In depending on verification flow
      // Assuming direct login or auto-login after signup:
      context.go('/app');
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = 'Something went wrong. Please try again.');
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
                  // 1. Header
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
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
                    'Join MotorAmbos to get roadside\nassistance anywhere, anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: motTheme.slateText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. Error Box
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
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
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
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Inputs
                  _InputLabel(label: 'FULL NAME'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _nameController,
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    enabled: !_loading,
                  ),

                  const SizedBox(height: 20),

                  _InputLabel(label: 'PHONE NUMBER'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _phoneController,
                    hint: '+233 20 000 0000',
                    icon: Icons.phone_iphone_rounded,
                    keyboardType: TextInputType.phone,
                    enabled: !_loading,
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 32),

                  // 4. Primary Action
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: motTheme.slateText),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => context.go('/sign-in'),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
// UI HELPERS
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
