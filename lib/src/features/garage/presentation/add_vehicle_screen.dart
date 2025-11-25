import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/models/vehicle.dart';
import 'package:motor_ambos/src/core/providers/vehicle_providers.dart';

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

  bool get isEdit => widget.vehicle != null;

  // Theme Colors
  static const kBgColor = Color(0xFFF8FAFC);
  static const kDarkNavy = Color(0xFF0F172A);
  static const kSlateText = Color(0xFF64748B);

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
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save vehicle: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      // Custom Header
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
            Text(
              isEdit ? 'EDIT VEHICLE' : 'ADD VEHICLE',
              style: const TextStyle(
                color: kSlateText,
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kDarkNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help the provider identify your car.',
                      style: TextStyle(
                        fontSize: 14,
                        color: kSlateText,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Form Fields ---
                    _InputLabel(label: 'MAKE'),
                    const SizedBox(height: 8),
                    _StyledTextField(controller: _makeCtrl, hint: 'Toyota'),

                    const SizedBox(height: 24),

                    _InputLabel(label: 'MODEL'),
                    const SizedBox(height: 8),
                    _StyledTextField(controller: _modelCtrl, hint: 'Corolla'),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InputLabel(label: 'YEAR'),
                              const SizedBox(height: 8),
                              _StyledTextField(controller: _yearCtrl, hint: '2019', keyboardType: TextInputType.number),
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
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _InputLabel(label: 'NICKNAME (OPTIONAL)'),
                    const SizedBox(height: 8),
                    _StyledTextField(controller: _nameCtrl, hint: 'e.g. Daily Driver'),

                    const SizedBox(height: 32),

                    // --- Primary Toggle ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.15)),
                      ),
                      child: SwitchListTile.adaptive(
                        value: _isPrimary,
                        activeColor: kDarkNavy,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Set as Primary Vehicle',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kDarkNavy,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Default for assistance requests',
                          style: TextStyle(fontSize: 12, color: kSlateText),
                        ),
                        onChanged: (val) => setState(() => _isPrimary = val),
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
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                  isEdit ? 'Save Changes' : 'Add Vehicle',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8), // Slate-400
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
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A), // Dark Navy
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}