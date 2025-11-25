import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save vehicle: $e')));

        print('$e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit vehicle' : 'Add vehicle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Basic details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nickname (optional)',
                    hintText: 'Eg. Daily Driver, Wife’s Car',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _makeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Make',
                    hintText: 'Toyota, Hyundai, Kia…',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _modelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'Corolla, Tucson, Picanto…',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _yearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    hintText: '2015',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _plateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Number plate',
                    hintText: 'GR 1234-21',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Plate is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SwitchListTile(
                  value: _isPrimary,
                  onChanged: (value) {
                    setState(() => _isPrimary = value);
                  },
                  title: const Text('Set as primary vehicle'),
                  subtitle: const Text(
                    'This will be the default car used for assistance requests.',
                  ),
                  activeColor: cs.primary,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Save changes' : 'Add vehicle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
