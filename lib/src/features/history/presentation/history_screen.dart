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
    if (!mounted) return;
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
      String? userPhone;
      try {
        final profileRes = await client.schema('motorambos').from('profiles').select('phone').eq('user_id', user.id).maybeSingle();
        if (profileRes != null) userPhone = profileRes['phone'] as String?;
      } catch (e) {
        debugPrint('Error fetching profile: $e');
      }

      dynamic res;
      if (userPhone != null && userPhone.isNotEmpty) {
        res = await client.schema('motorambos').from('requests').select().eq('driver_phone', userPhone).order('created_at', ascending: false);
      } else {
        res = await client.schema('motorambos').from('requests').select().eq('created_by', user.id).order('created_at', ascending: false);
      }

      final list = (res as List).cast<dynamic>().map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final providerIds = list.map((r) => r['provider_id']).where((id) => id != null).toSet().toList();
      Map<String, String> providerNames = {};
      if (providerIds.isNotEmpty) {
        try {
          final providersRes = await client.schema('motorambos').from('providers').select('id, display_name').filter('id', 'in', providerIds);
          for (final p in (providersRes as List)) {
            providerNames[p['id']] = p['display_name'] as String;
          }
        } catch (e) { debugPrint('Error fetching providers: $e'); }
      }

      for (var r in list) {
        final pid = r['provider_id'];
        if (pid != null && providerNames.containsKey(pid)) r['provider'] = {'display_name': providerNames[pid]};
      }

      if (mounted) setState(() { _requests = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = 'Failed to load requests: $e'; });
    }
  }

  String _mapServiceCodeToLabel(String? code) {
    switch (code) {
      case 'tow': return 'Towing';
      case 'fuel': return 'Fuel Delivery';
      case 'tire': return 'Tire Change';
      case 'battery': return 'Jumpstart';
      case 'oil': return 'Oil Change';
      case 'rescue': return 'Rescue Area';
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
      case 'pending': return Colors.orangeAccent;
      case 'accepted': return Colors.blueAccent;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.redAccent;
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
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $time';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onSurface), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        color: theme.colorScheme.primary,
        child: _isLoading ? const SkeletonList(itemCount: 6, itemHeight: 120) : _error != null ? _buildError(motTheme) : _requests.isEmpty ? _buildEmpty(theme, motTheme) : ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: _requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildHistoryCard(_requests[index], theme, motTheme),
        ),
      ),
    );
  }

  Widget _buildError(MotorAmbosTheme motTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: motTheme.slateText, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextButton(onPressed: _loadRequests, child: const Text('Retry Connection', style: TextStyle(fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, MotorAmbosTheme motTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.history_rounded, size: 36, color: motTheme.slateText.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 24),
          const Text('No Past Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Your assistance requests will appear here.', style: TextStyle(color: motTheme.slateText, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> r, ThemeData theme, MotorAmbosTheme motTheme) {
    final serviceCode = (r['service_code'] ?? r['service_id'])?.toString();
    final status = (r['status'] ?? 'pending').toString();
    final date = r['created_at'];
    final address = (r['address_line'] ?? 'Unknown location').toString();
    final providerName = (r['provider'] as Map<String, dynamic>?)?['display_name'] as String?;
    
    final icon = _mapServiceCodeToIcon(serviceCode);
    final title = _mapServiceCodeToLabel(serviceCode);
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: theme.colorScheme.onSurface, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Text(_formatDateTime(date), style: TextStyle(color: motTheme.slateText, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)),
              ),
            ],
          ),
          if (address != 'Unknown location') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: motTheme.slateText.withValues(alpha: 0.9)),
                const SizedBox(width: 8),
                Expanded(child: Text(address, style: TextStyle(fontSize: 12, color: motTheme.slateText, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
          if (providerName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 14, color: Colors.blueAccent.withValues(alpha: 0.9)),
                const SizedBox(width: 8),
                Text(providerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}