import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:motor_ambos/src/features/account/application/account_providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _nameController = TextEditingController();
  final _homeLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController.text = profile.name;
    _homeLocationController.text = profile.homeLocation ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _homeLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + basic info
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                cs.primaryContainer.withOpacity(0.9),
                child: Text(
                  profile.name.isNotEmpty
                      ? profile.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style:
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.phone,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Personal details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full name',
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (value) {
              ref
                  .read(userProfileProvider.notifier)
                  .updateName(value.trim());
            },
            onChanged: (value) {
              // You could debounce in a real app
            },
          ),
          const SizedBox(height: 12),

          TextField(
            enabled: false, // read-only for now
            decoration: InputDecoration(
              labelText: 'Phone number',
              helperText: 'Managed via login & verification',
              helperStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            controller:
            TextEditingController(text: profile.phone),
          ),
          const SizedBox(height: 12),

          TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Email',
              helperText:
              'We\'ll use this for receipts and important updates.',
              helperStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            controller:
            TextEditingController(text: profile.email),
          ),
          const SizedBox(height: 24),

          Text(
            'Home area (optional)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _homeLocationController,
            decoration: const InputDecoration(
              labelText: 'Neighbourhood / area',
              hintText: 'e.g. East Legon, Spintex, Dzorwulu',
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (value) {
              ref
                  .read(userProfileProvider.notifier)
                  .updateHomeLocation(
                value.trim().isEmpty ? null : value.trim(),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text(
              'Job updates, reminders, and important alerts.',
            ),
            value: profile.pushNotificationsEnabled,
            onChanged: (value) {
              ref
                  .read(userProfileProvider.notifier)
                  .setPushNotificationsEnabled(value);
              // TODO: later wire to actual push settings
            },
          ),
          SwitchListTile(
            title: const Text('News & offers'),
            subtitle: const Text(
              'Occasional product updates and member-only deals.',
            ),
            value: profile.marketingOptIn,
            onChanged: (value) {
              ref
                  .read(userProfileProvider.notifier)
                  .setMarketingOptIn(value);
            },
          ),

          const SizedBox(height: 24),
          Text(
            'Security',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.lock_reset_outlined,
              color: cs.primary,
            ),
            title: const Text('Change password'),
            subtitle: const Text(
              'You’ll manage this via your login method.',
            ),
            onTap: () {
              // Later: open auth-related flow
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password / login management will be handled when auth is connected.',
                    style:
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme
                          .colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.logout_outlined,
              color: cs.error,
            ),
            title: const Text('Sign out'),
            subtitle: const Text(
              'You will be signed out from this device.',
            ),
            onTap: () {
              // Later: call Supabase auth signOut
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sign out will be wired to Supabase auth later.',
                    style:
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme
                          .colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}