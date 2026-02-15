import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/utils/toast_utils.dart';
import 'package:motor_ambos/src/core/widget/skeleton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String _userName = '';
  String _email = '';
  String? _phone;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    String email = user.email ?? '';
    String nameFromAuth = (user.userMetadata?['full_name'] as String?) ?? (email.isNotEmpty ? email.split('@').first : 'Driver');

    try {
      final dynamic res = await client.schema('motorambos').from('profiles').select('full_name, phone').eq('user_id', user.id).maybeSingle();

      if (mounted) {
        setState(() {
          _userName = (res != null && res['full_name'] != null) ? res['full_name'] : nameFromAuth;
          _email = email;
          _phone = (res != null) ? res['phone'] : null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSignOut() async {
    HapticFeedback.heavyImpact();
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    try {
      await SupabaseService.client.auth.signOut();
      if (mounted) context.go('/phone-login');
    } catch (e) {
      if (mounted) ToastUtils.showError(context, title: 'Sign out failed', description: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
        child: Column(
          children: [
            _buildProfileCard(theme, motTheme),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Account Settings',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  color: Colors.blueAccent,
                  title: 'Personal Info',
                  onTap: () => context.push('/account'),
                ),
                _SettingsTile(
                  icon: Icons.directions_car_filled_outlined,
                  color: Colors.orangeAccent,
                  title: 'Garage Management',
                  onTap: () => context.go('/garage'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'App Settings',
              children: [
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  color: Colors.purpleAccent,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.security_rounded,
                  color: Colors.green,
                  title: 'Privacy & Security',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildSignOutButton(theme),
            const SizedBox(height: 24),
            Text('Version 1.0.2 (Build 40)', style: TextStyle(color: motTheme.slateText, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, MotorAmbosTheme motTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: motTheme.inputBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: _loading
                ? const Skeleton(width: 70, height: 70, radius: 35)
                : Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'D', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading) const Skeleton(width: 140, height: 20, radius: 4) else Text(_userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                if (_loading) const Skeleton(width: 180, height: 14, radius: 4) else ...[
                  Text(_email, style: TextStyle(fontSize: 13, color: motTheme.slateText, fontWeight: FontWeight.w500)),
                  if (_phone != null && _phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(_phone!, style: TextStyle(fontSize: 12, color: motTheme.slateText.withValues(alpha: 0.9), fontWeight: FontWeight.w400)),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSignOutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _handleSignOut,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
          foregroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: motTheme.slateText.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}