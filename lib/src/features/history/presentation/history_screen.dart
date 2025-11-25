import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

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
        res = await client
            .schema('motorambos')
            .from('requests')
            .select()
            .eq('created_by', user.id)
            .order('created_at', ascending: false);
      } catch (_) {
        res = await client
            .schema('motorambos')
            .from('requests')
            .select()
            .order('created_at', ascending: false);
      }

      final list = (res as List).cast<dynamic>().map((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList();

      if (mounted) {
        setState(() {
          _requests = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load requests.';
        });
      }
    }
  }

  String _mapServiceCodeToLabel(String? code) {
    switch (code) {
      case 'tow': return 'Towing';
      case 'fuel': return 'Fuel Delivery';
      case 'tire': return 'Tire Change';
      case 'battery': return 'Jumpstart';
      case 'oil': return 'Oil Change';
      case 'rescue': return 'Rescue';
      default: return 'Assistance';
    }
  }

  IconData _mapServiceCodeToIcon(String? code) {
    switch (code) {
      case 'tow': return Icons.local_shipping_rounded;
      case 'fuel': return Icons.local_gas_station_rounded;
      case 'tire': return Icons.tire_repair_rounded;
      case 'battery': return Icons.bolt_rounded;
      case 'oil': return Icons.oil_barrel_rounded;
      case 'rescue': return Icons.warning_amber_rounded;
      default: return Icons.support_agent_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'in_progress': return kDarkNavy;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDateTime(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = createdAt is DateTime ? createdAt : DateTime.parse(createdAt.toString()).toLocal();
      final now = DateTime.now();
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      if (isToday) return 'Today, $time';
      return '${dt.day}/${dt.month}/${dt.year} • $time';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kDarkNavy),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            color: kDarkNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        color: kDarkNavy,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: kDarkNavy))
            : _error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kSlateText),
                ),
                TextButton(onPressed: _loadRequests, child: const Text('Retry')),
              ],
            ),
          ),
        )
            : _requests.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kDarkNavy.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded, size: 40, color: kSlateText),
              ),
              const SizedBox(height: 24),
              const Text(
                'No requests yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDarkNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your assistance history will appear here.',
                style: TextStyle(color: kSlateText),
              ),
            ],
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final r = _requests[index];
            final serviceCode = (r['service_code'] ?? r['service_id'])?.toString();
            final status = (r['status'] ?? 'pending').toString();
            final date = r['created_at'];
            final address = (r['address_line'] ?? 'Unknown location').toString();

            final statusColor = _statusColor(status);
            final icon = _mapServiceCodeToIcon(serviceCode);
            final title = _mapServiceCodeToLabel(serviceCode);

            return Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: kDarkNavy, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kDarkNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateTime(date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: kSlateText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (address.isNotEmpty && address != 'Unknown location') ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: kSlateText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kSlateText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}