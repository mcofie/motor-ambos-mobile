import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class RequestAssistScreen extends ConsumerStatefulWidget {
  const RequestAssistScreen({
    super.key,
    required this.issue,
    this.vehicleId,
    this.vehicleSummary,
  });

  final String issue;

  /// Optional: vehicle explicitly selected on the Assist screen
  final String? vehicleId;

  /// Optional: summary info passed from Assist screen
  /// Example: { 'label': 'Toyota Corolla', 'plate': 'GR-1234-24', 'year': '2020' }
  final Map<String, dynamic>? vehicleSummary;

  @override
  ConsumerState<RequestAssistScreen> createState() =>
      _RequestAssistScreenState();
}

class _RequestAssistScreenState extends ConsumerState<RequestAssistScreen>
    with SingleTickerProviderStateMixin {
  // User Data (Fetched silently)
  String _driverName = '';
  String _driverPhone = '';

  // Location & Animation
  String? _locationLabel;
  Position? _position;
  bool _isGettingLocation = false;
  bool _isFindingProviders = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _prefillUserData();
    _fetchLocation(silent: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _prefillUserData() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _driverName = user.userMetadata?['full_name'] ?? '';
        _driverPhone = user.phone ?? '';
      });
    }
  }

  Future<void> _fetchLocation({bool silent = false}) async {
    if (_isGettingLocation) return;
    if (!silent) setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        setState(() {
          _position = position;
          _locationLabel =
              '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        });
      }
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (!silent && mounted) setState(() => _isGettingLocation = false);
    }
  }

  String _mapIssueToServiceCode(String issue) {
    final lower = issue.toLowerCase();
    if (lower.contains('fuel')) return 'fuel';
    if (lower.contains('tow')) return 'tow';
    if (lower.contains('battery')) return 'battery';
    if (lower.contains('tyre') || lower.contains('tire')) return 'tire';
    if (lower.contains('oil')) return 'oil';
    return 'rescue';
  }

  Future<void> _handleFindProviders({
    required Vehicle? activeVehicle,
    required Map<String, dynamic>? effectiveVehicleSummary,
  }) async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your location first.')),
      );
      return;
    }

    setState(() => _isFindingProviders = true);

    try {
      final serviceCode = _mapIssueToServiceCode(widget.issue);

      final res = await SupabaseService.client
          .schema('motorambos')
          .rpc(
            'find_providers_near_with_rates',
            params: {
              'p_lat': _position!.latitude,
              'p_lng': _position!.longitude,
              'p_radius_km': 15,
              'p_service_code': serviceCode,
              'p_limit': 10,
            },
          );

      final providers = (res as List<dynamic>).cast<Map<String, dynamic>>();

      if (!mounted) return;

      if (providers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No providers found nearby.")),
        );
        return;
      }

      context.pushNamed(
        'assist-providers',
        extra: {
          'issue': widget.issue,
          'serviceCode': serviceCode,
          'locationLabel': _locationLabel ?? 'Current Location',
          'providers': providers,
          'driverName': _driverName,
          'driverPhone': _driverPhone,
          'lat': _position!.latitude,
          'lng': _position!.longitude,
          // 🚗 Vehicle context
          'vehicleId': widget.vehicleId ?? activeVehicle?.id,
          'vehicleSummary': effectiveVehicleSummary,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isFindingProviders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    // 🔁 Vehicles from Riverpod (used as fallback if no vehicle was passed)
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? <Vehicle>[];

    Vehicle? primaryVehicle;
    if (vehicles.isNotEmpty) {
      primaryVehicle = vehicles.firstWhere(
        (v) => v.isPrimary,
        orElse: () => vehicles.first,
      );
    }

    // Find explicit vehicle by id if provided
    Vehicle? explicitVehicle;
    if (widget.vehicleId != null && vehicles.isNotEmpty) {
      try {
        explicitVehicle = vehicles.firstWhere((v) => v.id == widget.vehicleId);
      } catch (_) {
        explicitVehicle = null;
      }
    }

    final Vehicle? activeVehicle = explicitVehicle ?? primaryVehicle;

    // Build effective vehicle summary for display & passing along
    Map<String, dynamic>? effectiveVehicleSummary;
    if (widget.vehicleSummary != null) {
      effectiveVehicleSummary = widget.vehicleSummary;
    } else if (activeVehicle != null) {
      effectiveVehicleSummary = {
        'label': activeVehicle.displayLabel,
        'plate': activeVehicle.plate,
        'year': activeVehicle.year,
      };
    }

    final hasLocation = _position != null;

    final vehicleText = (() {
      if (effectiveVehicleSummary != null) {
        final label = effectiveVehicleSummary['label']?.toString() ?? '';
        final plate = effectiveVehicleSummary['plate']?.toString() ?? '';
        if (label.isEmpty && plate.isEmpty) {
          return "No vehicle selected";
        }
        return plate.isEmpty ? label : "$label • $plate";
      }

      if (activeVehicle != null) {
        return "${activeVehicle.displayLabel} • ${activeVehicle.plate ?? ''}";
      }

      return "No vehicle selected";
    })();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Motor Ambos',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'STEP 3: CONFIRM',
                style: TextStyle(
                  color: motTheme.slateText,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Map Background
          Positioned.fill(
            bottom: 300, // Leave room for bottom sheet so map is visible
            child: _MockMapPreview(controller: _pulseController),
          ),

          // 2. Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: motTheme.subtleBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Request Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: motTheme.inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: motTheme.subtleBorder),
                    ),
                    child: Row(
                      children: [
                        // Service Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.build_circle_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.issue,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicleText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: motTheme.slateText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Edit Button (go back to Assist)
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // GPS / Location Display
                  if (hasLocation)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: motTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: motTheme.success.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            color: motTheme.success,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location Detected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: motTheme.success,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _locationLabel ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _fetchLocation,
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: motTheme.slateText,
                            ),
                            tooltip: 'Update Location',
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_disabled_rounded,
                            color: theme.colorScheme.error,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Location not detected.\nPlease share your location to proceed.',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: hasLocation
                          ? () => _handleFindProviders(
                        activeVehicle: activeVehicle,
                        effectiveVehicleSummary: effectiveVehicleSummary,
                      )
                          : _fetchLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: motTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isFindingProviders || _isGettingLocation
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasLocation
                                ? Icons.search
                                : Icons.near_me_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            hasLocation
                                ? 'Find Providers Nearby'
                                : 'Share Location',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SUB-COMPONENTS
// -----------------------------------------------------------------------------

class _MockMapPreview extends StatelessWidget {
  final AnimationController controller;

  const _MockMapPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    
    // Use theme colors for map background
    final mapBgColor = theme.brightness == Brightness.dark 
        ? const Color(0xFF1E293B) // Slate-800 for dark mode
        : const Color(0xFFE5E7EB); // Slate-200 for light mode
        
    final roadColor = theme.cardColor;

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
                width: 80 + (controller.value * 150),
                height: 80 + (controller.value * 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: motTheme.accent.withValues(alpha: 1.0 - controller.value),
                    width: 1,
                  ),
                  color: motTheme.accent.withValues(alpha: 0.05 * (1.0 - controller.value)),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: motTheme.accent,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.navigation, color: Colors.white, size: 24),
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
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(-50, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.35,
      size.width + 50,
      size.height * 0.6,
    );

    path.moveTo(size.width * 0.3, -50);
    path.lineTo(size.width * 0.4, size.height + 50);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
