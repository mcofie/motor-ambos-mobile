import 'package:flutter/material.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'You must be signed in to view history.';
      });
      return;
    }

    try {
      dynamic res;

      try {
        // ✅ Most likely: requests table with driver_id
        res = await client
            .schema('motorambos')
            .from('requests')
            .select()
            .eq('driver_id', user.id)
            .order('created_at', ascending: false);
      } catch (_) {
        // Fallback: get all (in case column name differs — you can tighten later)
        res = await client
            .schema('motorambos')
            .from('requests')
            .select()
            .order('created_at', ascending: false);
      }

      final list = (res as List).cast<dynamic>().map((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList();

      setState(() {
        _requests = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load requests: $e';
      });
    }
  }

  String _mapServiceCodeToLabel(String? code) {
    switch (code) {
      case 'tow':
        return 'Towing';
      case 'fuel':
        return 'Fuel Delivery';
      case 'tire':
        return 'Tire / Wheel';
      case 'battery':
        return 'Battery Jump/Replace';
      case 'oil':
        return 'Oil Change';
      case 'rescue':
        return 'Rescue';
      default:
        return 'Assistance';
    }
  }

  IconData _mapServiceCodeToIcon(String? code) {
    switch (code) {
      case 'tow':
        return Icons.local_shipping_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'tire':
        return Icons.tire_repair_rounded;
      case 'battery':
        return Icons.bolt_rounded;
      case 'oil':
        return Icons.oil_barrel_rounded;
      case 'rescue':
        return Icons.build_circle_rounded;
      default:
        return Icons.support_agent_rounded;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'pending':
        return cs.outline;
      case 'accepted':
      case 'ongoing':
        return cs.primary;
      case 'completed':
        return cs.tertiary;
      case 'cancelled':
      case 'failed':
        return cs.error;
      default:
        return cs.outline;
    }
  }

  String _formatDateTime(dynamic createdAt) {
    if (createdAt == null) return 'Unknown time';
    try {
      final dt = createdAt is DateTime
          ? createdAt
          : DateTime.parse(createdAt.toString()).toLocal();
      final now = DateTime.now();
      final isToday =
          dt.year == now.year && dt.month == now.month && dt.day == now.day;

      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      if (isToday) return 'Today • $time';

      final date =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)}';

      return '$date • $time';
    } catch (_) {
      return createdAt.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('History'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.error,
                      ),
                    ),
                  ),
                ],
              )
            : _requests.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No requests yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Your assistance requests will appear here once you start using MotorAmbos.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = _requests[index];

                  final serviceCode = (r['service_code'] ?? r['_service_code'])
                      ?.toString();
                  final serviceLabel = _mapServiceCodeToLabel(serviceCode);

                  final address = (r['address_line'] ?? '').toString().trim();
                  final status = (r['status'] ?? 'Pending').toString();
                  final createdAt = r['created_at'];
                  final providerName = (r['provider_name'] ?? '')
                      .toString()
                      .trim();

                  final lat = (r['lat'] as num?)?.toDouble();
                  final lng = (r['lng'] as num?)?.toDouble();

                  final statusChipColor = _statusColor(context, status);

                  return Material(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: icon + service + status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _mapServiceCodeToIcon(serviceCode),
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      serviceLabel,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(createdAt),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusChipColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  status[0].toUpperCase() +
                                      status.substring(1).toLowerCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: statusChipColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Address
                          if (address.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (lat != null && lng != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '($lat, $lng)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],

                          if (providerName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Provider: $providerName',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
