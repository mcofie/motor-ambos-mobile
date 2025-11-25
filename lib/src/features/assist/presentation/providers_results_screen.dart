import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:motor_ambos/src/core/services/supabase_service.dart';

/// Nearby providers results page
///
/// Pass in:
/// - [issue] (e.g. "Towing")
/// - [serviceCode] (e.g. "tow", "fuel", "battery", "rescue", "oil", "tire")
/// - [locationLabel] (human-readable address/location string)
/// - [providers] (List<Map<String, dynamic>> from RPC)
/// - [driverName], [driverPhone] (for create_request)
/// - [lat], [lng] (driver location used for create_request)
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

  @override
  Widget build(BuildContext context) {
    // You can tweak this to show radius + coords if you want
    final String contextLocation = "Within 15km • $lat, $lng";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light greyish background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motor Ambos',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'NEARBY HELP',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Black pill indicator from screenshot
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header: "Nearby Help" + Context Info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Nearby Help',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Text(
                  contextLocation,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Provider List
          Expanded(
            child: providers.isEmpty
                ? _EmptyState(issue: issue, onChangeIssue: () => context.pop())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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

          // Bottom Refresh Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: OutlinedButton(
              onPressed: () {
                // TODO: re-run search here if you want
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[200]!),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              child: const Text(
                'Refresh Results',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROVIDER CARD
// ─────────────────────────────────────────────

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

  Future<bool> _createRequest(BuildContext context) async {
    setState(() => _isSubmitting = true);
    try {
      final client = SupabaseService.client;

      await client
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
        const SnackBar(content: Text('Your request has been registered.')),
      );

      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register request. Please try again.\n$e'),
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleCallPressed(BuildContext context) async {
    final provider = widget.provider;
    final name = (provider['name'] ?? 'this provider').toString();
    final phoneRaw = provider['phone']?.toString() ?? '';
    final phone = phoneRaw.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This provider does not have a phone number on file.'),
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Call provider'),
            content: Text(
              'We’ll register your request and call $name on your behalf at $phone.\n\nDo you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Okay'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final ok = await _createRequest(context);
    if (!ok || !mounted) return;

    // Now place the actual phone call
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone dialer for $phone')),
      );
    }
  }

  Future<void> _handleSendInfoPressed(BuildContext context) async {
    final ok = await _createRequest(context);
    if (!ok || !mounted) return;

    // Optionally you can change this message – request toast already shown in _createRequest
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('We’ve shared your details with the provider.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    // Data parsing
    final name = (provider['name'] ?? 'Unknown Provider').toString();
    final rating = (provider['rating'] is num)
        ? (provider['rating'] as num).toDouble()
        : 0.0;
    final distanceKm = (provider['distance_km'] is num)
        ? (provider['distance_km'] as num).toDouble()
        : 0.3; // Default for mock
    final isVerified = provider['is_verified'] == true;

    final minCallout = (provider['min_callout_fee'] as num?)?.toDouble();
    final providerCallout = (provider['provider_callout_fee'] as num?)
        ?.toDouble();
    final displayFee = minCallout ?? providerCallout ?? 50.0; // Fallback

    final coverage = (provider['coverage_radius_km'] as num?)?.toInt() ?? 10;

    // Services Parsing
    final rawRates = provider['rates'];
    List<Map<String, dynamic>> rates = [];
    if (rawRates is List) {
      rates = rawRates
          .whereType<Map>()
          .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
          .toList()
          .cast<Map<String, dynamic>>();
    }

    final isBusy = _isSubmitting;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP ROW: Avatar, Info, Map Icon ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A6B87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Rating
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
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Rating Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F6EB), // Light green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rate_rounded,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "•  ${distanceKm.toStringAsFixed(1)} km away",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Map Icon Button (placeholder)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- BADGES ROW (Fee, Range) ---
            Row(
              children: [
                _InfoBadge(text: "FEE: GHC${displayFee.toStringAsFixed(0)}"),
                const SizedBox(width: 8),
                _InfoBadge(text: "RANGE: ${coverage}KM"),
              ],
            ),

            const SizedBox(height: 16),

            // --- SERVICES LIST (Accordion)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                onExpansionChanged: (expanded) {
                  setState(() => _isExpanded = expanded);
                },
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text(
                  "${_isExpanded ? 'Hide' : 'View'} ${rates.length} services & pricing",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                iconColor: Colors.grey[600],
                collapsedIconColor: Colors.grey[600],
                children: rates.map((rate) {
                  return _ServiceRow(rate: rate);
                }).toList(),
              ),
            ),

            // --- ACTION BUTTONS ---
            Row(
              children: [
                // Call Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => _handleCallPressed(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.black,
                    ),
                    icon: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.phone_outlined, size: 20),
                    label: Text(
                      isBusy ? 'Please wait' : 'Call',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send Info Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => _handleSendInfoPressed(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isBusy ? 'Sending…' : 'Send Info',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

// ─────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  final String text;

  const _InfoBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5A6B87),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            priceText,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String issue;
  final VoidCallback onChangeIssue;

  const _EmptyState({required this.issue, required this.onChangeIssue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No Providers Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: onChangeIssue, child: const Text("Go Back")),
        ],
      ),
    );
  }
}
