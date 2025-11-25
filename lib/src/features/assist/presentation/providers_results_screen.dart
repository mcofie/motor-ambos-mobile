import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

class ProvidersResultsScreen extends StatelessWidget {
  const ProvidersResultsScreen({
    super.key,
    required this.issue,
    required this.serviceCode,
    required this.locationLabel,
    required this.providers,
    required this.driverName,
    required this.driverPhone,
    required this.lat,
    required this.lng,
  });

  final String issue;
  final String serviceCode;
  final String locationLabel;
  final List<Map<String, dynamic>> providers;
  final String driverName;
  final String driverPhone;
  final double lat;
  final double lng;

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    // Clean up coordinates for display
    final String coords =
        "${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}";

    return Scaffold(
      backgroundColor: kBgColor,
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: kDarkNavy,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Motor Ambos',
              style: TextStyle(
                color: kDarkNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'NEARBY HELP',
              style: TextStyle(
                color: kSlateText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          // Progress Indicator Pill (Finished state)
          Container(
            margin: const EdgeInsets.only(right: 24),
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: kDarkNavy,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Context Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Providers Found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kDarkNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Near $coords",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kSlateText,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: providers.isEmpty
                ? _EmptyState(issue: issue, onBack: () => context.pop())
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _ProviderCard(
                        provider: providers[index],
                        serviceCode: serviceCode,
                        driverName: driverName,
                        driverPhone: driverPhone,
                        locationLabel: locationLabel,
                        lat: lat,
                        lng: lng,
                      );
                    },
                  ),
          ),
        ],
      ),
      // Floating Refresh Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Logic to refresh would go here (e.g. pop and re-push or Riverpod refresh)
            context.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: kDarkNavy,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Text(
            'Refresh Results',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PROVIDER CARD
// -----------------------------------------------------------------------------

class _ProviderCard extends StatefulWidget {
  const _ProviderCard({
    required this.provider,
    required this.serviceCode,
    required this.driverName,
    required this.driverPhone,
    required this.locationLabel,
    required this.lat,
    required this.lng,
  });

  final Map<String, dynamic> provider;
  final String serviceCode;
  final String driverName;
  final String driverPhone;
  final String locationLabel;
  final double lat;
  final double lng;

  @override
  State<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<_ProviderCard> {
  bool _isExpanded = false;
  bool _isSubmitting = false;

  // Colors
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

  Future<bool> _createRequest(BuildContext context) async {
    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.client
          .schema('motorambos')
          .rpc(
            'create_request',
            params: {
              '_service_code': widget.serviceCode,
              '_driver_name': widget.driverName,
              '_driver_phone': widget.driverPhone,
              '_address_line': widget.locationLabel,
              '_lat': widget.lat,
              '_lng': widget.lng,
            },
          );

      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully!')),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request failed: $e')));
      return false;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleCallPressed() async {
    final provider = widget.provider;
    final name = (provider['name'] ?? 'Provider').toString();
    final phone = (provider['phone']?.toString() ?? '').trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available.')),
      );
      return;
    }

    // Confirm Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Provider'),
        content: Text('We will register your request and dial $name ($phone).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: kDarkNavy),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1. Register Request
    final success = await _createRequest(context);
    if (!success) return;

    // 2. Launch Phone
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final name = (p['name'] ?? 'Provider').toString();
    final rating = (p['rating'] is num) ? (p['rating'] as num).toDouble() : 0.0;
    final distance = (p['distance_km'] is num)
        ? (p['distance_km'] as num).toDouble()
        : 0.0;
    final isVerified = p['is_verified'] == true;

    // Pricing
    final minFee = (p['min_callout_fee'] as num?)?.toDouble();
    final callFee = (p['provider_callout_fee'] as num?)?.toDouble();
    final displayFee = minFee ?? callFee ?? 50.0;
    final coverage = (p['coverage_radius_km'] as num?)?.toInt() ?? 10;

    // Rates
    final rawRates = p['rates'];
    List<Map<String, dynamic>> rates = [];
    if (rawRates is List) {
      rates = rawRates
          .whereType<Map>()
          .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
          .toList()
          .cast<Map<String, dynamic>>();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kSlateText,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kDarkNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4), // Light Green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kSlateText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Badges
            Row(
              children: [
                _InfoBadge(text: 'FEE: GHC${displayFee.toStringAsFixed(0)}'),
                const SizedBox(width: 8),
                _InfoBadge(text: 'RANGE: ${coverage}KM'),
              ],
            ),

            const SizedBox(height: 20),

            // Services List (Accordion)
            if (rates.isNotEmpty)
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  title: Text(
                    '${_isExpanded ? "Hide" : "View"} ${rates.length} services & pricing',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kSlateText,
                    ),
                  ),
                  iconColor: kSlateText,
                  collapsedIconColor: kSlateText,
                  onExpansionChanged: (val) =>
                      setState(() => _isExpanded = val),
                  children: rates.map((r) => _ServiceRow(rate: r)).toList(),
                ),
              ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _handleCallPressed,
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      foregroundColor: kDarkNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _createRequest(context),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isSubmitting ? 'Sending...' : 'Send Info'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: kDarkNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String text;

  const _InfoBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final Map<String, dynamic> rate;

  const _ServiceRow({required this.rate});

  @override
  Widget build(BuildContext context) {
    final name = (rate['name'] ?? 'Service').toString();
    final price = (rate['base_price'] as num?)?.toDouble();
    final priceText = price != null ? "GHC${price.toStringAsFixed(0)}" : "N/A";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          Text(
            priceText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String issue;
  final VoidCallback onBack;

  const _EmptyState({required this.issue, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No providers found for '$issue'",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try increasing your search radius.",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          TextButton(onPressed: onBack, child: const Text("Go Back")),
        ],
      ),
    );
  }
}
