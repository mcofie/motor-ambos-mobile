import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart'; // 👈 Real 3D Viewer

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/core/utils/toast_utils.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _plateCtrl;
  bool _isPrimary = false;
  bool _isSaving = false;

  // Car Type Selection
  int _selectedTypeIndex = 0;
  final List<Map<String, dynamic>> _carTypes = [
    {'label': 'Sedan', 'icon': Icons.directions_car_filled_rounded},
    {'label': 'SUV', 'icon': Icons.airport_shuttle_rounded},
    {'label': 'Truck', 'icon': Icons.local_shipping_rounded},
    {'label': 'Bike', 'icon': Icons.two_wheeler_rounded},
  ];



  bool get isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _makeCtrl = TextEditingController(text: v?.make ?? '');
    _modelCtrl = TextEditingController(text: v?.model ?? '');
    _yearCtrl = TextEditingController(text: v?.year ?? '');
    _plateCtrl = TextEditingController(text: v?.plate ?? '');
    _isPrimary = v?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final service = ref.read(vehicleServiceProvider);

    try {
      if (isEdit) {
        await service.updateVehicle(
          id: widget.vehicle!.id,
          name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          make: _makeCtrl.text.trim().isEmpty ? null : _makeCtrl.text.trim(),
          model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
          year: _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
          plate: _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
          isPrimary: _isPrimary,
        );
      } else {
        await service.createVehicle(
          name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          make: _makeCtrl.text.trim().isEmpty ? null : _makeCtrl.text.trim(),
          model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
          year: _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
          plate: _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
          isPrimary: _isPrimary,
        );
      }

      ref.invalidate(vehiclesProvider);
      if (mounted) {
        context.pop();
        HapticFeedback.mediumImpact();
        ToastUtils.showSuccess(context, title: isEdit ? 'Vehicle Updated' : 'Vehicle Added');
      }
    } catch (e) {
      if (mounted) {
      if (mounted) {
        ToastUtils.showError(context, title: 'Failed to save vehicle', description: e.toString());
      }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
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
        title: Column(
          children: [
            Text(
              'Motor Ambos',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEdit ? 'EDIT VEHICLE' : 'ADD VEHICLE',
              style: TextStyle(
                color: motTheme.slateText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. INTERACTIVE 3D SHOWROOM ---
                    _buildInteractiveShowroom(),

                    // --- 2. Car Type Selector ---
                    _buildTypeSelector(),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Form Fields ---
                          _InputLabel(label: 'MAKE'),
                          const SizedBox(height: 8),
                          _StyledTextField(
                            controller: _makeCtrl,
                            hint: 'Toyota',
                          ),

                          const SizedBox(height: 20),

                          _InputLabel(label: 'MODEL'),
                          const SizedBox(height: 8),
                          _StyledTextField(
                            controller: _modelCtrl,
                            hint: 'Corolla',
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _InputLabel(label: 'YEAR'),
                                    const SizedBox(height: 8),
                                    _StyledTextField(
                                      controller: _yearCtrl,
                                      hint: '2019',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _InputLabel(label: 'LICENSE PLATE'),
                                    const SizedBox(height: 8),
                                    _StyledTextField(
                                      controller: _plateCtrl,
                                      hint: 'GR-5522-23',
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _InputLabel(label: 'NICKNAME (OPTIONAL)'),
                          const SizedBox(height: 8),
                          _StyledTextField(
                            controller: _nameCtrl,
                            hint: 'e.g. Daily Driver',
                          ),

                          const SizedBox(height: 24),

                          // --- Primary Toggle ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: motTheme.subtleBorder,
                              ),
                            ),
                            child: SwitchListTile.adaptive(
                              value: _isPrimary,
                              activeTrackColor: theme.colorScheme.onSurface,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Set as Primary Vehicle',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Default for assistance requests',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: motTheme.slateText,
                                ),
                              ),
                              onChanged: (val) =>
                                  setState(() => _isPrimary = val),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Sticky Bottom Button ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(color: motTheme.subtleBorder),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? 'Save Changes' : 'Add Vehicle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveShowroom() {
    // 🔴 UPDATED URL: Switched to "ToyCar" which is reliably hosted in the 'main' branch
    const String carModelUrl =
        'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/main/2.0/ToyCar/glTF-Binary/ToyCar.glb';

    return Container(
      height: 260,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Theme.of(context).colorScheme.onSurface],
                ),
              ),
            ),

            // Background Grid (Tech effect)
            Positioned.fill(
              child: CustomPaint(painter: _GridBackgroundPainter()),
            ),

            // 3D Model Viewer
            ModelViewer(
              src: carModelUrl,
              alt: "A 3D model of a car",
              ar: true,
              // Enable AR for supported devices
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.transparent,
              disableZoom: false,
            ),

            // Overlay Text
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.view_in_ar_rounded,
                      color: Colors.blueAccent,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'INTERACTIVE 3D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _carTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = _carTypes[index];
          final isSelected = _selectedTypeIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTypeIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).extension<MotorAmbosTheme>()!.slateText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).extension<MotorAmbosTheme>()!.slateText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAINTERS & WIDGETS
// -----------------------------------------------------------------------------

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const double step = 40.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InputLabel extends StatelessWidget {
  final String label;

  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).extension<MotorAmbosTheme>()!.slateText, // Slate-400
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<MotorAmbosTheme>()!.inputBg, // Slate-100
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
