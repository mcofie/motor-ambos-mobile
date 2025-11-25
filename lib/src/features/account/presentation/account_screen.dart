import 'package:flutter/material.dart';
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

class AppColors {
  static const Color brandPrimary = Color(0xFF00E676);
  static const Color brandAccent = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF2F2F7);
  static const Color inputFill = Colors.white;
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
  UserProfile? _profile;

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
      // No generic type on select(); cast the result afterwards
      final dynamic res = await client
          .schema('motorambos')
          .from('profiles')
          .select('user_id, full_name, role, phone')
          .eq('user_id', user.id)
          .maybeSingle();

      Map<String, dynamic>? row = res == null
          ? null
          : Map<String, dynamic>.from(res as Map);

      // Create a row if it doesn't exist
      if (row == null) {
        final insert = {
          'user_id': user.id,
          'full_name':
              (user.userMetadata?['full_name'] as String?) ??
              (user.email?.split('@').first ?? 'Driver'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _saveChanges() async {
    if (_profile == null) return;

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

      setState(() {
        _profile = updated;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Avatar (purely cosmetic)
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.brandAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ACCOUNT DETAILS (only the required inputs)
          const _SectionHeader(title: "ACCOUNT DETAILS"),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ProfileTextField(
                  label: "Full Name",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                const Divider(height: 1, indent: 56),
                _ProfileTextField(
                  label: "Phone Number",
                  controller: _phoneController,
                  icon: Icons.phone_iphone,
                  hint: "+233 20 000 0000",
                  keyboardType: TextInputType.phone,
                ),
                const Divider(height: 1, indent: 56),
                _ReadOnlyField(
                  label: "Email",
                  value: profile.email,
                  icon: Icons.email_outlined,
                  isVerified: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), // space for FAB
        ],
      ),

      // Save FAB – only when something changed
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              onPressed: _saveChanges,
              backgroundColor: AppColors.brandAccent,
              icon: const Icon(Icons.check, color: AppColors.brandPrimary),
              label: const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

//
// UI HELPERS
//

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 4, bottom: 8),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isVerified;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: AppColors.brandPrimary,
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
