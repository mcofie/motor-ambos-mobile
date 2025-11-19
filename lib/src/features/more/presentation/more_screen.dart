import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // TODO: later – pull from auth/profile
    const userName = 'Max';
    const phone = '+233 20 000 0000';
    const email = 'max@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                  cs.primaryContainer.withOpacity(0.9),
                  child: Text(
                    userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleMedium?.copyWith(
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
                        userName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style:
                        theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        email,
                        style:
                        theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    context.go('/account');
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Account & membership',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: cs.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.card_membership_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Membership & benefits'),
                  subtitle: const Text(
                    'View your plan, perks, and usage.',
                  ),
                  onTap: () {
                    context.go('/membership');
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.receipt_long_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Billing & payments'),
                  subtitle: const Text(
                    'Invoices, receipts, and history (coming soon).',
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Billing history coming soon.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Support & feedback',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: cs.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.support_agent_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Contact support'),
                  subtitle: const Text(
                    'Chat, call, or email the MotorAmbos team.',
                  ),
                  onTap: () {
                    // TODO: support screen or deep link
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Support options coming soon.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.chat_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Give feedback'),
                  subtitle: const Text(
                    'Tell us what’s working and what can improve.',
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Feedback form coming soon.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Grow MotorAmbos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: cs.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.group_add_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Refer a friend'),
                  subtitle: const Text(
                    'Share MotorAmbos and earn rewards.',
                  ),
                  onTap: () {
                    // TODO: referral deep link generation
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Referral program coming soon.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.star_rate_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Rate the app'),
                  subtitle: const Text(
                    'Leave a rating in the app store.',
                  ),
                  onTap: () {
                    // TODO: link to store
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Store rating link coming soon.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: cs.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: cs.primary,
                  ),
                  title: const Text('About MotorAmbos'),
                  subtitle: const Text(
                    'Version 0.1.0 • Made for drivers in Africa.',
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Terms & privacy'),
                  subtitle: const Text(
                    'Review how we handle your data.',
                  ),
                  onTap: () {
                    // TODO: open webview / browser
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Legal docs coming soon.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}