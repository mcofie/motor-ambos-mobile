import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _loading = true;
  String _userName = '';
  String _email = '';
  String? _membershipTier;

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
        _userName = 'Driver';
        _email = '';
        _membershipTier = null;
      });
      return;
    }

    String email = user.email ?? '';
    String nameFromAuth = (user.userMetadata?['full_name'] as String?) ??
        (email.isNotEmpty ? email.split('@').first : 'Driver');

    try {
      final dynamic res = await client
          .schema('motorambos')
          .from('profiles')
          .select('full_name, phone')
          .eq('user_id', user.id)
          .maybeSingle();

      if (res != null) {
        final row = Map<String, dynamic>.from(res as Map);
        final fullName = (row['full_name'] as String?) ?? nameFromAuth;

        setState(() {
          _userName = fullName;
          _email = email;
          _membershipTier = 'MEMBER'; // TODO: Fetch real tier
          _loading = false;
        });
      } else {
        setState(() {
          _userName = nameFromAuth;
          _email = email;
          _membershipTier = 'MEMBER';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = nameFromAuth;
        _email = email;
        _membershipTier = 'MEMBER';
        _loading = false;
      });
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldLogout) return;

    try {
      await SupabaseService.client.auth.signOut();
      if (context.mounted) {
        context.go('/sign-in');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _userName.isNotEmpty ? _userName : 'Driver';
    final displayEmail = _email.isNotEmpty ? _email : 'Add your email in Profile';

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'More',
          style: TextStyle(
            color: kDarkNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // 1. Profile Header
              _ProfileHeader(
                userName: displayName,
                email: displayEmail,
                tier: _membershipTier,
                onEdit: () => context.go('/account'),
                loading: _loading,
              ),

              const SizedBox(height: 32),

              // 2. Settings Groups
              _SettingsGroup(
                title: 'Account & Vehicle',
                children: [
                  _SettingsTile(
                    icon: Icons.card_membership_rounded,
                    iconColor: Colors.purple,
                    title: 'Membership Plan',
                    subtitle: 'View or manage your membership',
                    onTap: () => context.go('/membership'),
                  ),
                  _SettingsTile(
                    icon: Icons.directions_car_filled_rounded,
                    iconColor: Colors.orange,
                    title: 'My Garage',
                    onTap: () => context.go('/garage'),
                  ),
                ],
              ),

              _SettingsGroup(
                title: 'Support & Legal',
                children: [
                  _SettingsTile(
                    icon: Icons.headset_mic_rounded,
                    iconColor: Colors.blue,
                    title: 'Contact Support',
                    onTap: () {}, // TODO: Implement support
                  ),
                  _SettingsTile(
                    icon: Icons.policy_rounded,
                    iconColor: kSlateText,
                    title: 'Legal & Privacy',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: () => _handleSignOut(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFEF2F2), // Light Red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Version 1.0.2 (Build 40)',
                  style: TextStyle(
                    color: kSlateText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom nav
            ]),
          ),
        ],
      ),
    );
  }
}

//
// 1. PROFILE HEADER
//
class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String email;
  final String? tier;
  final VoidCallback onEdit;
  final bool loading;

  const _ProfileHeader({
    required this.userName,
    required this.email,
    required this.tier,
    required this.onEdit,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: loading
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'D',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kDarkNavy,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: kDarkNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: kSlateText,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tier != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kDarkNavy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tier!.toUpperCase(),
                      style: const TextStyle(
                        color: kDarkNavy,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          // Edit Button
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, color: kSlateText, size: 20),
          ),
        ],
      ),
    );
  }
}

//
// 2. SETTINGS GROUP
//
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    const kSlateText = Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: kSlateText,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 20,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// 3. SETTINGS TILE
//
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const kDarkNavy = Color(0xFF0F172A);
    const kSlateText = Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: kDarkNavy,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            color: kSlateText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: kSlateText),
            ],
          ),
        ),
      ),
    );
  }
}