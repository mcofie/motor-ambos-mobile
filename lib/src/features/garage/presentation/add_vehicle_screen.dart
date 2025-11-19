import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/vehicle_providers.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  bool _isPrimary = false;

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final year = int.tryParse(_yearController.text.trim()) ?? 0;

    ref.read(vehicleListProvider.notifier).addVehicle(
      name: _nameController.text.trim(),
      plate: _plateController.text.trim().toUpperCase(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      isPrimary: _isPrimary,
    );

    Navigator.of(context).pop(); // go back to Garage
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Tell us a bit about your car.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle name',
                  hintText: 'e.g. Daily runner, Mum\'s car',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name for this vehicle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Number plate',
                  hintText: 'e.g. GR 1234-24',
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the number plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                        hintText: 'e.g. Toyota',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        hintText: 'e.g. Corolla',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  hintText: 'e.g. 2019',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the year';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1980 || year > 2100) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Set as primary vehicle'),
                subtitle: const Text(
                  'We’ll default to this car when you request assistance.',
                ),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() {
                    _isPrimary = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _submit(context),
                  child: const Text('Save vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}