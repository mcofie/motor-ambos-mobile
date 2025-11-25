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
  String? _membershipTier; // e.g. 'PREMIUM' or null

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
    String nameFromAuth =
        (user.userMetadata?['full_name'] as String?) ??
            (email.isNotEmpty ? email.split('@').first : 'Driver');

    try {
      // Load profile row if it exists
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
          // TODO: wire real membership tier from memberships table
          _membershipTier = 'MEMBER';
          _loading = false;
        });
      } else {
        // No profile row – fall back to auth
        setState(() {
          _userName = nameFromAuth;
          _email = email;
          _membershipTier = 'MEMBER';
          _loading = false;
        });
      }
    } catch (e) {
      // On error, still show something
      setState(() {
        _userName = nameFromAuth;
        _email = email;
        _membershipTier = 'MEMBER';
        _loading = false;
      });
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

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
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    ) ??
        false;

    if (!shouldLogout) return;

    try {
      await SupabaseService.client.auth.signOut();
      if (context.mounted) {
        context.go('/sign-in');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayName = _userName.isNotEmpty ? _userName : 'Driver';
    final displayEmail =
    _email.isNotEmpty ? _email : 'Add your email in Profile';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. Theme-Aware Sliver App Bar
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                userName: displayName,
                email: displayEmail,
                tier: _membershipTier,
                onEdit: () => context.go('/account'),
                loading: _loading,
              ),
            ),
          ),

          // 2. Settings Groups
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              _SettingsGroup(
                title: 'Account',
                children: [
                  _SettingsTile(
                    icon: Icons.card_membership_rounded,
                    iconColor: Colors.purple,
                    title: 'Membership Plan',
                    subtitle: 'View or manage your membership',
                    onTap: () => context.go('/membership'),
                  ),
                  _SettingsTile(
                    icon: Icons.directions_car_rounded,
                    iconColor: Colors.orange,
                    title: 'My Garage',
                    onTap: () => context.go('/garage'),
                  ),
                ],
              ),

              _SettingsGroup(
                title: 'Support',
                children: [
                  _SettingsTile(
                    icon: Icons.headset_mic_rounded,
                    iconColor: colorScheme.primary,
                    title: 'Contact Support',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.chat_bubble_rounded,
                    iconColor: Colors.teal,
                    title: 'Give Feedback',
                    onTap: () {},
                  ),
                ],
              ),

              _SettingsGroup(
                title: 'More',
                children: [
                  _SettingsTile(
                    icon: Icons.card_giftcard_rounded,
                    iconColor: Colors.pink,
                    title: 'Refer a Friend',
                    subtitle: 'Get GHS 50 credit',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.policy_rounded,
                    iconColor: colorScheme.outline,
                    title: 'Legal & Privacy',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: () => _handleSignOut(context),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                    colorScheme.errorContainer.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Version 1.0.2 (Build 40)',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? colorScheme.surface : const Color(0xFF1A1A1A);
    final textColor = isDark ? colorScheme.onSurface : Colors.white;
    final subTextColor = isDark ? colorScheme.onSurfaceVariant : Colors.white70;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: loading
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (tier != null && tier!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                            colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          tier!.toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Edit Button
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.settings_outlined, color: textColor),
              ),
            ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
                      indent: 56,
                      color: colorScheme.outlineVariant.withOpacity(0.2),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final displayIconColor = isDark ? iconColor.withOpacity(0.9) : iconColor;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: displayIconColor.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: displayIconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}