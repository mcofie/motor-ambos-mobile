import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';

class RequestAssistScreen extends ConsumerStatefulWidget {
  const RequestAssistScreen({super.key, required this.issue});

  final String issue;

  @override
  ConsumerState<RequestAssistScreen> createState() =>
      _RequestAssistScreenState();
}

class _RequestAssistScreenState extends ConsumerState<RequestAssistScreen>
    with SingleTickerProviderStateMixin {
  String? _locationLabel;
  bool _isFinding = false;
  late final AnimationController _pulseController;

  // Track actual GPS position so we know when lat/lng exist
  Position? _position;

  bool get _hasLocation => _position != null;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      LocationPermission finalPerm = permission;

      if (permission == LocationPermission.denied) {
        finalPerm = await Geolocator.requestPermission();
      }

      if (finalPerm == LocationPermission.denied ||
          finalPerm == LocationPermission.deniedForever) {
        setState(() {
          _locationLabel = 'Location permission denied';
          _position = null;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _position = position;
        _locationLabel =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      setState(() {
        _locationLabel = 'Unable to get location';
        _position = null;
      });
    }
  }

  String _mapIssueToServiceCode(String issue) {
    final lower = issue.toLowerCase();

    if (lower.contains('fuel')) return 'fuel';
    if (lower.contains('tow')) return 'tow';
    if (lower.contains('jump')) return 'battery';
    if (lower.contains('batt')) return 'battery';
    if (lower.contains('tyre') || lower.contains('tire')) return 'tire';
    if (lower.contains('oil')) return 'oil';
    if (lower.contains('engine')) return 'rescue';

    // Grid labels:
    // 'Towing', 'Flat tyre', 'Jumpstart', 'Engine', 'Fuel', 'Other'
    switch (issue) {
      case 'Towing':
        return 'tow';
      case 'Flat tyre':
        return 'tire';
      case 'Jumpstart':
        return 'battery';
      case 'Engine':
        return 'rescue';
      case 'Fuel':
        return 'fuel';
      default:
        return 'rescue';
    }
  }

  Future<void> _handleFindProviders() async {
    if (_isFinding) return;
    setState(() => _isFinding = true);

    try {
      // 1. Ensure permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to find providers.'),
          ),
        );
        setState(() => _isFinding = false);
        return;
      }

      // 2. Fresh position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _position = position;
        _locationLabel =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });

      final serviceCode = _mapIssueToServiceCode(widget.issue);

      // 3. Call Postgres function via Supabase
      final res = await SupabaseService.client
          .schema('motorambos')
          .rpc(
            'find_providers_near_with_rates',
            params: {
              'p_lat': position.latitude,
              'p_lng': position.longitude,
              'p_radius_km': 15,
              'p_service_code': serviceCode,
              'p_limit': 10,
            },
          );

      final providers = (res as List<dynamic>).cast<Map<String, dynamic>>();

      if (!mounted) return;

      if (providers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't find providers nearby. Try again later."),
          ),
        );
        setState(() => _isFinding = false);
        return;
      }

      // (Vehicle info is visual-only for now; request is tied to driver + service + location.)
      context.pushNamed(
        'assist-providers',
        extra: {
          'issue': widget.issue,
          'serviceCode': serviceCode,
          'locationLabel': _locationLabel ?? 'Your location',
          'providers': providers,
          // TODO: wire actual driver from profile
          'driverName': 'Maxwell Cofie',
          'driverPhone': '0558509394',
          'lat': position.latitude,
          'lng': position.longitude,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't find providers. Try again.\n$e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isFinding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 🔹 Get vehicles from garage and pick primary
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final List<Vehicle>? vehicles = vehiclesAsync.asData?.value;

    Vehicle? primaryVehicle;
    if (vehicles != null && vehicles.isNotEmpty) {
      try {
        primaryVehicle = vehicles.firstWhere(
          (v) => v.isPrimary,
          orElse: () => vehicles[0],
        );
      } catch (_) {
        primaryVehicle = vehicles[0];
      }
    }

    final vehicleName = primaryVehicle?.displayLabel ?? 'Your vehicle';
    final vehiclePlate = (primaryVehicle?.plate ?? '').trim();

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map background
          Positioned.fill(
            bottom: 280 + kBottomNavigationBarHeight,
            child: _MockMapPreview(controller: _pulseController),
          ),

          // Bottom sheet raised above bottom nav
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: bottomInset + kBottomNavigationBarHeight,
              ),
              child: _RequestSheet(
                issue: widget.issue,
                vehicleName: vehicleName,
                vehiclePlate: vehiclePlate,
                locationLabel: _locationLabel,
                isFinding: _isFinding,
                canFindProviders: _hasLocation,
                onFindProviders: _handleFindProviders,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// REQUEST SHEET
//
class _RequestSheet extends StatelessWidget {
  final String issue;
  final String vehicleName;
  final String vehiclePlate;
  final String? locationLabel;
  final bool isFinding;
  final bool canFindProviders;
  final Future<void> Function() onFindProviders;

  const _RequestSheet({
    required this.issue,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.locationLabel,
    required this.isFinding,
    required this.canFindProviders,
    required this.onFindProviders,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final locText = locationLabel ?? 'Detecting your location…';
    final isEnabled = canFindProviders && !isFinding;

    final vehicleLine = vehiclePlate.isNotEmpty
        ? '$vehicleName • $vehiclePlate'
        : vehicleName;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Confirm Location',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Location card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        locText,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Later: open map picker / manual edit
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  label: 'Issue',
                  value: issue,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
              Expanded(
                child: _DetailItem(
                  label: 'Vehicle',
                  value: vehicleLine,
                  icon: Icons.directions_car_filled,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isEnabled ? onFindProviders : null,
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                foregroundColor: isDark
                    ? colorScheme.onPrimary
                    : colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isFinding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      canFindProviders
                          ? 'Find Providers Nearby'
                          : 'Getting your location…',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// MOCK MAP WIDGET (with injected controller)
//
class _MockMapPreview extends StatelessWidget {
  final AnimationController controller;

  const _MockMapPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final mapBgColor = isDark
        ? const Color(0xFF202020)
        : const Color(0xFFE5E7EB);
    final roadColor = isDark ? const Color(0xFF333333) : Colors.white;

    return Container(
      color: mapBgColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(color: roadColor),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Container(
                width: 100 + (controller.value * 100),
                height: 100 + (controller.value * 100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(
                      1.0 - controller.value,
                    ),
                    width: 2,
                  ),
                  color: colorScheme.primary.withOpacity(
                    0.1 * (1.0 - controller.value),
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isDark
                  ? colorScheme.primary
                  : const Color(0xFF1A1A1A),
              child: Icon(
                Icons.person,
                color: isDark ? colorScheme.onPrimary : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.4);

    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.3, size.height);

    path.moveTo(size.width * 0.8, 0);
    path.lineTo(size.width * 0.6, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}
