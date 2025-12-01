import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/widget/skeleton.dart';

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
      // 1. Get user profile to find phone number
      String? userPhone;
      try {
        final profileRes = await client
            .schema('motorambos')
            .from('profiles')
            .select('phone')
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (profileRes != null) {
          userPhone = profileRes['phone'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching profile: $e');
      }

      // 2. Fetch requests (without join first, to be safe)
      dynamic res;
      if (userPhone != null && userPhone.isNotEmpty) {
        res = await client
            .schema('motorambos')
            .from('requests')
            .select() // Fetch raw data first
            .eq('driver_phone', userPhone)
            .order('created_at', ascending: false);
      } else {
        res = await client
            .schema('motorambos')
            .from('requests')
            .select()
            .eq('created_by', user.id)
            .order('created_at', ascending: false);
      }

      final list = (res as List).cast<dynamic>().map((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList();

      // 3. Manually fetch provider details
      final providerIds = list
          .map((r) => r['provider_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      Map<String, String> providerNames = {};
      if (providerIds.isNotEmpty) {
        try {
          final providersRes = await client
              .schema('motorambos')
              .from('providers')
              .select('id, display_name')
              .filter('id', 'in', providerIds);
          
          for (final p in (providersRes as List)) {
            providerNames[p['id']] = p['display_name'] as String;
          }
        } catch (e) {
          debugPrint('Error fetching providers: $e');
        }
      }

      // 4. Merge provider names into requests
      for (var r in list) {
        final pid = r['provider_id'];
        if (pid != null && providerNames.containsKey(pid)) {
          r['provider'] = {'display_name': providerNames[pid]};
        }
      }

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
          _error = 'Failed to load requests: $e';
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

  Color _statusColor(String status, Color defaultColor) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'in_progress': return defaultColor;
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
      final day = dt.day;
      final suffix = (day >= 11 && day <= 13) || (day % 10 == 0) || (day % 10 >= 4)
          ? 'th'
          : (day % 10 == 1)
              ? 'st'
              : (day % 10 == 2)
                  ? 'nd'
                  : 'rd';
      
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dt.month - 1];
      
      return '$day$suffix $month ${dt.year} • $time';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: theme.colorScheme.onSurface),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        color: theme.colorScheme.onSurface,
        child: _isLoading
            ? const SkeletonList(itemCount: 6, itemHeight: 120)
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
                  style: TextStyle(color: motTheme.slateText),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history_rounded, size: 40, color: motTheme.slateText),
              ),
              const SizedBox(height: 24),
              Text(
                'No requests yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your assistance history will appear here.',
                style: TextStyle(color: motTheme.slateText),
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
            
            // Extract new details
            final providerData = r['provider'] as Map<String, dynamic>?;
            final providerName = providerData?['display_name'] as String?;
            
            final detailsRaw = r['details'];
            Map<String, dynamic>? details;
            if (detailsRaw is String) {
              try {
                details = jsonDecode(detailsRaw) as Map<String, dynamic>;
              } catch (_) {}
            } else if (detailsRaw is Map) {
              details = Map<String, dynamic>.from(detailsRaw);
            }
            final vehicleInfo = details != null 
                ? '${details['vehicle_make'] ?? ''} ${details['vehicle_model'] ?? ''} ${details['vehicle_plate'] ?? ''}'.trim()
                : null;
            
            final cost = r['cost'] ?? r['price']; // Assuming cost/price field exists or is in details
            final displayCost = cost != null ? 'GHS $cost' : null;

            final statusColor = _statusColor(status, theme.colorScheme.onSurface);
            final icon = _mapServiceCodeToIcon(serviceCode);
            final title = _mapServiceCodeToLabel(serviceCode);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: motTheme.subtleBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                          color: motTheme.inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateTime(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: motTheme.slateText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
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
                    Divider(height: 1, color: motTheme.subtleBorder),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: motTheme.slateText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 13,
                              color: motTheme.slateText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Provider & Vehicle Details
                  if (providerName != null || (vehicleInfo != null && vehicleInfo.isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (providerName != null) ...[
                          Icon(Icons.business_rounded, size: 16, color: motTheme.slateText),
                          const SizedBox(width: 6),
                          Text(
                            providerName,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (vehicleInfo != null && vehicleInfo.isNotEmpty) ...[
                          Icon(Icons.directions_car_rounded, size: 16, color: motTheme.slateText),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              vehicleInfo,
                              style: TextStyle(
                                fontSize: 13,
                                color: motTheme.slateText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Cost (if available)
                  if (displayCost != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        displayCost,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}