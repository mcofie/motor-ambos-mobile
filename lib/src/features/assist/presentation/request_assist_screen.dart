import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/core/services/supabase_service.dart';

class RequestAssistScreen extends ConsumerStatefulWidget {
  const RequestAssistScreen({super.key, required this.issue});

  final String issue;

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

  // Theme Colors
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

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
        desiredAccuracy: LocationAccuracy.high,
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

  Future<void> _handleFindProviders() async {
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
    // 🔁 Get Active Vehicle Logic (Same as Assist Screen)
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? <Vehicle>[];
    Vehicle? activeVehicle;
    if (vehicles.isNotEmpty) {
      activeVehicle = vehicles.firstWhere(
        (v) => v.isPrimary,
        orElse: () => vehicles.first,
      );
    }

    final hasLocation = _position != null;
    final vehicleText = activeVehicle != null
        ? "${activeVehicle.displayLabel} • ${activeVehicle.plate ?? ''}"
        : "No vehicle selected";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
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
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Motor Ambos',
                style: TextStyle(
                  color: kDarkNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'STEP 3: CONFIRM',
                style: const TextStyle(
                  color: kSlateText,
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
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kDarkNavy.withOpacity(0.15),
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Request Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        // Service Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kDarkNavy,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kDarkNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicleText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kSlateText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Edit Button
                        TextButton(
                          onPressed: () => context.pop(), // Go back to edit
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // GPS Coordinates Display
                  if (hasLocation)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4), // Light Green Bg
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location_rounded,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location Detected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _locationLabel ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: kDarkNavy,
                                    fontFamily:
                                        'Courier', // Monospace for coords looks techy
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _fetchLocation,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: kSlateText,
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
                        color: const Color(0xFFFEF2F2), // Light Red
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_disabled_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Location not detected.\nPlease share your location to proceed.',
                              style: TextStyle(
                                color: kDarkNavy,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Location & Action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: hasLocation
                          ? _handleFindProviders
                          : _fetchLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkNavy,
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
    // Light grey map background
    const mapBgColor = Color(0xFFE5E7EB);
    const roadColor = Colors.white;

    return Container(
      color: mapBgColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Draw Roads
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(color: roadColor),
          ),
          // Pulse Animation
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Container(
                width: 80 + (controller.value * 150),
                height: 80 + (controller.value * 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(
                      0xFF0F172A,
                    ).withOpacity(1.0 - controller.value),
                    width: 1,
                  ),
                  color: const Color(
                    0xFF0F172A,
                  ).withOpacity(0.05 * (1.0 - controller.value)),
                ),
              );
            },
          ),
          // User Pin
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A), // Dark Navy Pin
              shape: BoxShape.circle,
              boxShadow: [
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

    // Mock Roads
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
