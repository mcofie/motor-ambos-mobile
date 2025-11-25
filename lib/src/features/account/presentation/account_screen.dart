import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String? role;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    this.role,
  });

  UserProfile copyWith({String? name, String? phone, String? role}) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email,
      role: role ?? this.role,
    );
  }

  factory UserProfile.fromDb(
      Map<String, dynamic> row, {
        required String fallbackEmail,
        required String fallbackPhone,
      }) {
    return UserProfile(
      name: (row['full_name'] as String?) ?? fallbackEmail.split('@').first,
      phone: (row['phone'] as String?) ?? fallbackPhone,
      email: fallbackEmail,
      role: row['role'] as String?,
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _hasChanges = false;
  bool _loading = true;
  bool _isSaving = false;
  UserProfile? _profile;

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _loadProfile();
  }

  void _onFieldChanged() {
    if (!_loading && _profile != null) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final dynamic res = await client
          .schema('motorambos')
          .from('profiles')
          .select('user_id, full_name, role, phone')
          .eq('user_id', user.id)
          .maybeSingle();

      Map<String, dynamic>? row = res == null
          ? null
          : Map<String, dynamic>.from(res as Map);

      if (row == null) {
        final insert = {
          'user_id': user.id,
          'full_name': (user.userMetadata?['full_name'] as String?) ?? (user.email?.split('@').first ?? 'Driver'),
          'phone': user.phone ?? '',
        };

        final dynamic insertRes = await client
            .schema('motorambos')
            .from('profiles')
            .insert(insert)
            .select()
            .single();

        row = Map<String, dynamic>.from(insertRes as Map);
      }

      final profile = UserProfile.fromDb(
        row,
        fallbackEmail: user.email ?? '',
        fallbackPhone: user.phone ?? (row['phone'] as String? ?? ''),
      );

      setState(() {
        _profile = profile;
        _nameController.text = profile.name;
        _phoneController.text = profile.phone;
        _loading = false;
        _hasChanges = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _saveChanges() async {
    if (_profile == null) return;

    setState(() => _isSaving = true);
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    final updated = _profile!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      await client
          .schema('motorambos')
          .from('profiles')
          .update({
        'full_name': updated.name,
        'phone': updated.phone,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _profile = updated;
          _hasChanges = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Scaffold(
        backgroundColor: kBgColor,
        body: Center(child: CircularProgressIndicator(color: kDarkNavy)),
      );
    }

    return Scaffold(
      backgroundColor: kBgColor,
      // Custom Header
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kDarkNavy),
            onPressed: () => context.canPop() ? context.pop() : context.go('/more'),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: kDarkNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF1F5F9), // Light Slate
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: kDarkNavy,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: kDarkNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Inputs
                  _InputLabel(label: "FULL NAME"),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'Your full name',
                  ),

                  const SizedBox(height: 24),

                  _InputLabel(label: "PHONE NUMBER"),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _phoneController,
                    icon: Icons.phone_iphone_rounded,
                    hint: '+233 20 000 0000',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  _InputLabel(label: "EMAIL ADDRESS"),
                  const SizedBox(height: 8),
                  _ReadOnlyField(
                    value: _profile!.email,
                    icon: Icons.email_outlined,
                  ),
                ],
              ),
            ),
          ),

          // Sticky Save Button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_hasChanges && !_isSaving) ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkNavy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// UI HELPERS
//

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8), // Slate-400
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A), // Dark Navy
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;

  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}