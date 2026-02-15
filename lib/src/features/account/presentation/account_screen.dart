import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:motor_ambos/src/core/providers/profile_provider.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/utils/toast_utils.dart';


class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _hasChanges = false;
  bool _isSaving = false;
  bool _isUploading = false;
  UserProfileData? _currentData;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (_currentData == null) return;
    final nameChanged = _nameController.text.trim() != _currentData!.fullName;
    final phoneChanged = _phoneController.text.trim() != _currentData!.phone;
    if (_hasChanges != (nameChanged || phoneChanged)) setState(() => _hasChanges = nameChanged || phoneChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (picked == null) return;
    await _uploadAvatar(File(picked.path));
  }

  Future<void> _uploadAvatar(File file) async {
    setState(() => _isUploading = true);
    final client = SupabaseService.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final ext = file.path.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      await client.storage.from('avatars').upload(fileName, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
      final publicUrl = client.storage.from('avatars').getPublicUrl(fileName);
      await client.schema('motorambos').from('profiles').update({'avatar_url': publicUrl, 'updated_at': DateTime.now().toIso8601String()}).eq('user_id', user.id);

      ref.invalidate(userProfileProvider);
      if (mounted) ToastUtils.showSuccess(context, title: 'Photo Updated');
    } catch (e) {
      if (mounted) ToastUtils.showError(context, title: 'Upload Failed', description: e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_currentData == null) return;
    setState(() => _isSaving = true);
    
    final client = SupabaseService.client;
    final user = client.auth.currentUser;
    if (user == null) { setState(() => _isSaving = false); return; }

    try {
      await client.schema('motorambos').from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String()
      }).eq('user_id', user.id);
      
      ref.invalidate(userProfileProvider);
      if (mounted) {
        setState(() { _hasChanges = false; _isSaving = false; });
        HapticFeedback.mediumImpact();
        ToastUtils.showSuccess(context, title: 'Profile Updated');
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) { setState(() => _isSaving = false); ToastUtils.showError(context, title: 'Update Failed', description: e.toString()); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    profileAsync.whenData((data) {
      if (_currentData != data && !_hasChanges) {
        _currentData = data;
        _nameController.text = data.fullName;
        _phoneController.text = data.phone;
      }
    });

    if (profileAsync.isLoading && _currentData == null) {
      return Scaffold(backgroundColor: theme.scaffoldBackgroundColor, body: const Center(child: CircularProgressIndicator()));
    }
    
    final profile = _currentData;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0)),
        centerTitle: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onSurface), onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(profile),
                  const SizedBox(height: 40),
                  
                  _sectionHeader('PERSONAL INFORMATION'),
                  const SizedBox(height: 16),
                  _buildGroupedInputs([
                    _buildInputItem(label: 'FULL NAME', controller: _nameController, icon: Icons.person_rounded),
                    _buildInputItem(label: 'PHONE NUMBER', controller: _phoneController, icon: Icons.phone_iphone_rounded, kbType: TextInputType.phone),
                  ]),
                  
                  const SizedBox(height: 32),
                  _sectionHeader('ACCOUNT SECURITY'),
                  const SizedBox(height: 16),
                  _buildGroupedInputs([
                    _buildReadOnlyItem(label: 'EMAIL ADDRESS', value: profile.email, icon: Icons.alternate_email_rounded),
                  ]),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          _buildSaveButton(theme, motTheme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileData profile) {
    final initial = profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'U';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 3),
                    image: profile.avatarUrl != null ? DecorationImage(image: CachedNetworkImageProvider(profile.avatarUrl!), fit: BoxFit.cover) : null,
                  ),
                  alignment: Alignment.center,
                  child: profile.avatarUrl == null ? Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)) : null,
                ),
                if (_isUploading) const Positioned.fill(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(8)),
                  child: Text(profile.role ?? 'PREMIUM MEMBER', style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5));
  }

  Widget _buildGroupedInputs(List<Widget> items) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildInputItem({required String label, required TextEditingController controller, required IconData icon, TextInputType? kbType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.withValues(alpha: 0.9)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
                TextField(
                  controller: controller,
                  keyboardType: kbType,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyItem({required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.withValues(alpha: 0.45)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, MotorAmbosTheme motTheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.paddingOf(context).bottom + 20),
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, border: Border(top: BorderSide(color: motTheme.subtleBorder))),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: _hasChanges ? const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]) : null,
            boxShadow: _hasChanges ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.45), blurRadius: 15, offset: const Offset(0, 8))] : null,
          ),
          child: ElevatedButton(
            onPressed: (_hasChanges && !_isSaving) ? _saveChanges : null,
            style: ElevatedButton.styleFrom(backgroundColor: _hasChanges ? Colors.transparent : theme.disabledColor, foregroundColor: Colors.white, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            child: _isSaving ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('UPDATE PROFILE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          ),
        ),
      ),
    );
  }
}