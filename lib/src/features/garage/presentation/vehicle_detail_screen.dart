import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/core/providers/profile_provider.dart';
// ignore: unused_import
import 'package:motor_ambos/src/core/widget/skeleton.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Docs, 2: History

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicleAsync = ref.watch(vehicleDetailProvider(widget.vehicleId));
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Vehicle Details', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          vehicleAsync.whenOrNull(
              data: (v) => IconButton(
                    icon: Icon(Icons.edit_note_rounded, color: theme.colorScheme.onSurface),
                    onPressed: () => context.pushNamed('garage-add', extra: v),
                  )) ??
              const SizedBox(),
          const SizedBox(width: 8),
        ],
      ),
      body: vehicleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('Vehicle not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. Top Segmented Control (Mock)
                _SegmentedControl(
                  selectedIndex: _selectedTab,
                  onChanged: (i) => setState(() => _selectedTab = i),
                ),
                const SizedBox(height: 24),

                if (_selectedTab == 0) ...[
                  // 2. Health Score Card
                  _HealthScoreCard(vehicle: vehicle),
                  const SizedBox(height: 24),

                  // 3. Owner Card
                  userAsync.when(
                    data: (user) => _OwnerCard(user: user),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // 4. Specs Grid
                  _SpecsGrid(vehicle: vehicle),
                  const SizedBox(height: 24),

                  // 5. VIN Check
                  _VinCheckCard(vehicle: vehicle),
                  const SizedBox(height: 24),

                  // 6. Next Service Prediction
                  const _NextServiceCard(),
                ] else if (_selectedTab == 1) ...[
                  // Docs Tab Placeholder
                  _DocsTab(vehicle: vehicle),
                ] else ...[
                  // History Tab Placeholder
                  _HistoryTab(vehicleId: vehicle.id),
                ],
                
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS ---

class _SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer, // Theme-aware background
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _buildTab(context, 'OVERVIEW', 0),
          _buildTab(context, 'DOCS', 1),
          _buildTab(context, 'HISTORY', 2),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent, // Brand Green for selected
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  final Vehicle vehicle;
  const _HealthScoreCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = vehicle.healthScore.toInt();
    // Assuming low score is bad (Red), high is good (Green)
    final isHealthy = score > 70;
    final healthColor = isHealthy ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH SCORE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: healthColor, height: 1.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/100',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Based on insurance, valid\nroadworthy, and service\nregularity.',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: healthColor.withValues(alpha: 0.2), width: 8),
                ),
                child: Icon(Icons.monitor_heart_outlined, color: healthColor, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final UserProfileData user;
  const _OwnerCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)), // Green-ish tint
            child: const Icon(Icons.person_outline_rounded, color: Color(0xFF163300)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OWNER',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 4),
                Text(
                  user.fullName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.colorScheme.outline)),
            child: const Text('ACTIVE MEMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final Vehicle vehicle;
  const _SpecsGrid({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SpecCard(label: 'COLOR', value: vehicle.color ?? 'N/A')),
            const SizedBox(width: 16),
            Expanded(child: _SpecCard(label: 'ENGINE', value: '${vehicle.make} ${vehicle.model}')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SpecCard(label: 'TRANSMISSION', value: vehicle.year ?? 'N/A')), // Mapping year to transmission slot as requested mock
            const SizedBox(width: 16),
            Expanded(child: _SpecCard(label: 'DRIVE', value: vehicle.plate ?? 'N/A')), // Mapping plate to drive slot as requested mock
          ],
        ),
      ],
    );
  }
}

class _SpecCard extends StatelessWidget {
  final String label;
  final String value;
  const _SpecCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      height: 100,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _VinCheckCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VinCheckCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use part of ID as fake VIN
    final vinSuffix = vehicle.id.length > 4 ? vehicle.id.substring(vehicle.id.length - 4) : '0000';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIN CHECK',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Dots
              _buildDots(theme),
              const SizedBox(width: 16),
              _buildDots(theme),
              const SizedBox(width: 16),
              _buildDots(theme),
              const Spacer(),
              Text(
                vinSuffix,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Monospace', color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDots(ThemeData theme) {
    return Row(
      children: List.generate(4, (i) => Container(
        width: 4, height: 4,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          shape: BoxShape.circle,
        ),
      )),
    );
  }
}

class _NextServiceCard extends StatelessWidget {
  const _NextServiceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: const Icon(Icons.show_chart_rounded, color: Colors.blueAccent),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATED NEXT SERVICE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Not enough data',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse existing widgets for Docs/History tabs
class _DocsTab extends StatelessWidget {
  final Vehicle vehicle;
  const _DocsTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DocCard(
          title: 'DIGITAL PASSPORT',
          icon: Icons.nfc_rounded,
          iconColor: Colors.blueAccent,
          child: _PassportContent(vehicle: vehicle),
        ),
        const SizedBox(height: 16),
        _DocCard(
          title: 'ROADWORTHINESS',
          icon: Icons.verified_user_rounded,
          iconColor: Colors.teal,
          child: _RoadworthyContent(vehicle: vehicle),
        ),
        const SizedBox(height: 16),
        _DocCard(
          title: 'INSURANCE STICKER',
          icon: Icons.security_rounded,
          iconColor: Colors.purple,
          child: _InsuranceContent(vehicle: vehicle),
        ),
      ],
    );
  }
}

class _DocCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _DocCard({required this.title, required this.icon, required this.iconColor, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _PassportContent extends StatelessWidget {
  final Vehicle vehicle;
  const _PassportContent({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLinked = vehicle.nfcCardId != null;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLinked ? 'SECURELY LINKED' : 'UNLINKED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isLinked ? const Color(0xFF16A34A) : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLinked ? 'Card ID: ${vehicle.nfcCardId}' : 'Tap to link NFC Card',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        if (!isLinked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
            child: Text('LINK NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
          ),
      ],
    );
  }
}

class _RoadworthyContent extends StatelessWidget {
  final Vehicle vehicle;
  const _RoadworthyContent({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiry = vehicle.roadworthyExpiry;
    
    if (expiry == null) {
      return Center(
        child: Text('No Roadworthy Data', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
      );
    }

    final df = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();
    final daysLeft = expiry.difference(now).inDays;
    final isExpired = daysLeft < 0;
    
    Color statusColor = const Color(0xFF16A34A);
    String statusText = '$daysLeft DAYS LEFT';
    
    if (isExpired) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'EXPIRED';
    } else if (daysLeft < 30) {
      statusColor = Colors.orange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EXPIRY DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
            const SizedBox(height: 4),
            Text(df.format(expiry), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: statusColor)),
        ),
      ],
    );
  }
}

class _InsuranceContent extends StatelessWidget {
  final Vehicle vehicle;
  const _InsuranceContent({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = vehicle.insuranceProvider;
    
    if (provider == null || provider.isEmpty) {
       return Center(
        child: Text('No Insurance Data', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PROVIDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
            Text('STICKER NO.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(provider, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
            Text(vehicle.insuranceStickerNo ?? '---', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final String vehicleId;
  const _HistoryTab({required this.vehicleId});
  @override
  Widget build(BuildContext context) {
     return Center(child: Text('Service History Timeline', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
  }
}
