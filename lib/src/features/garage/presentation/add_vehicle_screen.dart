import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
  late final TextEditingController _colorCtrl;
  
  // Insurance
  late final TextEditingController _insProviderCtrl;
  late final TextEditingController _insStickerNoCtrl;
  DateTime? _insStart;
  DateTime? _insEnd;
  
  // Roadworthy
  DateTime? _rwExpiry;

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
    _colorCtrl = TextEditingController(text: v?.color ?? '');
    
    _insProviderCtrl = TextEditingController(text: v?.insuranceProvider ?? '');
    _insStickerNoCtrl = TextEditingController(text: v?.insuranceStickerNo ?? '');
    _insStart = v?.insuranceStartDate;
    _insEnd = v?.insuranceEndDate;
    _rwExpiry = v?.roadworthyExpiry;
    
    _isPrimary = v?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    _insProviderCtrl.dispose();
    _insStickerNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String type) async {
    // Dismiss keyboard first to avoid layout conflicts
    FocusScope.of(context).unfocus();
    
    final now = DateTime.now();
    final initialDate = switch (type) {
      'ins_start' => _insStart ?? now,
      'ins_end' => _insEnd ?? now.add(const Duration(days: 365)),
      'rw_expiry' => _rwExpiry ?? now.add(const Duration(days: 365)),
      _ => now,
    };

    DateTime tempDate = initialDate;
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true, // Prevents overflow by allowing flexible height
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SELECT DATE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(100)),
                        child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
              // Picker
              Container(
                height: 200,
                color: theme.cardColor,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2040),
                  use24hFormat: true,
                  dateOrder: DatePickerDateOrder.dmy,
                  backgroundColor: theme.cardColor,
                  onDateTimeChanged: (val) => tempDate = val,
                ),
              ),
            ],
          ),
        );
      },
    );

    setState(() {
      if (type == 'ins_start') _insStart = tempDate;
      if (type == 'ins_end') _insEnd = tempDate;
      if (type == 'rw_expiry') _rwExpiry = tempDate;
    });
  }

  Future<void> _showYearPicker() async {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;
    final years = List.generate(40, (i) => (currentYear - i).toString());

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('SELECT YEAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
              const SizedBox(height: 20),
              SizedBox(
                height: 260,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: years.length,
                  itemBuilder: (context, i) => InkWell(
                    onTap: () {
                      setState(() => _yearCtrl.text = years[i]);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _yearCtrl.text == years[i] ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(years[i], style: TextStyle(fontWeight: FontWeight.w900, color: _yearCtrl.text == years[i] ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final service = ref.read(vehicleServiceProvider);

    try {
      if (isEdit) {
        await service.updateVehicle(
          id: widget.vehicle!.id,
          name: _nameCtrl.text.trim(),
          make: _makeCtrl.text.trim().toUpperCase(),
          model: _modelCtrl.text.trim().toUpperCase(),
          year: _yearCtrl.text.trim(),
          plate: _plateCtrl.text.trim().toUpperCase(),
          color: _colorCtrl.text.trim().toUpperCase(),
          isPrimary: _isPrimary,
          insuranceProvider: _insProviderCtrl.text.trim().toUpperCase(),
          insuranceStickerNo: _insStickerNoCtrl.text.trim().toUpperCase(),
          insuranceStartDate: _insStart,
          insuranceEndDate: _insEnd,
          roadworthyExpiry: _rwExpiry,
        );
      } else {
        await service.createVehicle(
          name: _nameCtrl.text.trim(),
          make: _makeCtrl.text.trim().toUpperCase(),
          model: _modelCtrl.text.trim().toUpperCase(),
          year: _yearCtrl.text.trim(),
          plate: _plateCtrl.text.trim().toUpperCase(),
          color: _colorCtrl.text.trim().toUpperCase(),
          isPrimary: _isPrimary,
          insuranceProvider: _insProviderCtrl.text.trim().toUpperCase(),
          insuranceStickerNo: _insStickerNoCtrl.text.trim().toUpperCase(),
          insuranceStartDate: _insStart,
          insuranceEndDate: _insEnd,
          roadworthyExpiry: _rwExpiry,
        );
      }

      ref.invalidate(vehiclesProvider);
      if (widget.vehicle != null) {
        ref.invalidate(vehicleDetailProvider(widget.vehicle!.id));
      }
      
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.pop();
        ToastUtils.showSuccess(context, title: isEdit ? 'Vehicle Updated' : 'Vehicle Added');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, title: 'Check Database Connection', description: 'Ensure all fields are correctly formatted.');
        debugPrint('SAVE ERROR: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    final df = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? 'Update Passport' : 'New Vehicle',
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    
                    _FormCard(
                      title: 'IDENTIFICATION',
                      icon: Icons.badge_rounded,
                      children: [
                        _StyledTextField(
                          label: 'MAKE',
                          controller: _makeCtrl,
                          hint: 'TOYOTA',
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _QuickMakeSelector(
                          onSelected: (make) {
                            setState(() => _makeCtrl.text = make);
                          },
                        ),
                        const SizedBox(height: 16),
                        _StyledTextField(
                          label: 'MODEL',
                          controller: _modelCtrl,
                          hint: 'COROLLA',
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _YearSelector(
                                label: 'YEAR',
                                year: _yearCtrl.text,
                                onTap: _showYearPicker,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _ColorPicker(
                          selectedColor: _colorCtrl.text,
                          onColorSelected: (color) {
                            setState(() => _colorCtrl.text = color);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _FormCard(
                      title: 'REGISTRATION',
                      icon: Icons.app_registration_rounded,
                      children: [
                        _StyledTextField(
                          label: 'PLATE NUMBER',
                          controller: _plateCtrl,
                          hint: 'GR-1234-24',
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _StyledTextField(label: 'NICKNAME (OPTIONAL)', controller: _nameCtrl, hint: 'My Daily Driver', textCapitalization: TextCapitalization.words),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _FormCard(
                      title: 'INSURANCE STICKER',
                      icon: Icons.shield_rounded,
                      children: [
                        _StyledTextField(label: 'PROVIDER', controller: _insProviderCtrl, hint: 'SIC INSURANCE', textCapitalization: TextCapitalization.characters),
                        const SizedBox(height: 12),
                        _QuickInsuranceSelector(
                          onSelected: (provider) {
                            setState(() => _insProviderCtrl.text = provider);
                          },
                        ),
                        const SizedBox(height: 16),
                        _StyledTextField(label: 'STICKER NUMBER', controller: _insStickerNoCtrl, hint: 'STSIC208...', textCapitalization: TextCapitalization.characters),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DateSelector(
                                label: 'START DATE',
                                date: _insStart,
                                onTap: () => _pickDate('ins_start'),
                                df: df,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateSelector(
                                label: 'END DATE',
                                date: _insEnd,
                                onTap: () => _pickDate('ins_end'),
                                df: df,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _FormCard(
                      title: 'ROADWORTHINESS',
                      icon: Icons.verified_rounded,
                      children: [
                        _DateSelector(
                          label: 'EXPIRATION DATE',
                          date: _rwExpiry,
                          onTap: () => _pickDate('rw_expiry'),
                          df: df,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildPrimaryToggle(theme, motTheme),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomAction(theme, motTheme),
        ],
      ),
    );
  }

  Widget _buildPrimaryToggle(ThemeData theme, MotorAmbosTheme motTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: motTheme.subtleBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.star_rounded, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Primary Vehicle', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, fontSize: 15)),
                Text('Default for all SOS requests', style: TextStyle(color: motTheme.slateText, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isPrimary,
            onChanged: (v) => setState(() => _isPrimary = v),
            activeTrackColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(ThemeData theme, MotorAmbosTheme motTheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: motTheme.subtleBorder)),
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'SAVE CHANGES' : 'CREATE PASSPORT', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.label,
    required this.controller,
    required this.hint,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textCapitalization: textCapitalization,
          style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.45), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: motTheme.inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1)),
            errorStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final DateFormat df;

  const _DateSelector({required this.label, this.date, required this.onTap, required this.df});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: motTheme.inputBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? df.format(date!).toUpperCase() : 'SELECT DATE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: date != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Icon(Icons.calendar_month_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _YearSelector extends StatelessWidget {
  final String label;
  final String year;
  final VoidCallback onTap;

  const _YearSelector({required this.label, required this.year, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: motTheme.inputBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    year.isNotEmpty ? year : 'SELECT YEAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: year.isNotEmpty ? theme.colorScheme.onSurface : Colors.grey.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Icon(Icons.expand_more_rounded, size: 20, color: Colors.grey.withValues(alpha: 0.9)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String selectedColor;
  final Function(String) onColorSelected;

  const _ColorPicker({required this.selectedColor, required this.onColorSelected});

  static const List<Map<String, dynamic>> colors = [
    {'name': 'BLACK', 'color': Colors.black},
    {'name': 'WHITE', 'color': Color(0xFFF8F9FA)},
    {'name': 'SILVER', 'color': Color(0xFFC0C0C0)},
    {'name': 'ASH', 'color': Color(0xFF555555)},
    {'name': 'GRAY', 'color': Color(0xFF6B7280)},
    {'name': 'BLUE', 'color': Color(0xFF1E3A8A)},
    {'name': 'NAVY', 'color': Color(0xFF1E1B4B)},
    {'name': 'RED', 'color': Color(0xFFB91C1C)},
    {'name': 'MAROON', 'color': Color(0xFF450A0A)},
    {'name': 'BURGUNDY', 'color': Color(0xFF7F1D1D)},
    {'name': 'ORANGE', 'color': Color(0xFFEA580C)},
    {'name': 'YELLOW', 'color': Color(0xFFCA8A04)},
    {'name': 'GOLD', 'color': Color(0xFFD4AF37)},
    {'name': 'GREEN', 'color': Color(0xFF065F46)},
    {'name': 'TEAL', 'color': Color(0xFF0F766E)},
    {'name': 'CYAN', 'color': Color(0xFF0891B2)},
    {'name': 'BROWN', 'color': Color(0xFF78350F)},
    {'name': 'PURPLE', 'color': Color(0xFF581C87)},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VEHICLE COLOR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, i) {
              final isSelected = selectedColor == colors[i]['name'];
              return GestureDetector(
                onTap: () => onColorSelected(colors[i]['name']),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors[i]['color'],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.45),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4))] : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        colors[i]['name'],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? theme.colorScheme.primary : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
class _QuickMakeSelector extends StatelessWidget {
  final Function(String) onSelected;

  const _QuickMakeSelector({required this.onSelected});

  static const List<String> makes = ['TOYOTA', 'HONDA', 'MERCEDES', 'BMW', 'HYUNDAI', 'KIA', 'NISSAN', 'MAZDA', 'FORD'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: makes.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => onSelected(makes[i]),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
              ),
              child: Text(
                makes[i],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.8), letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _QuickInsuranceSelector extends StatelessWidget {
  final Function(String) onSelected;

  const _QuickInsuranceSelector({required this.onSelected});

  static const List<String> providers = [
    'ENTERPRISE',
    'SIC INSURANCE',
    'HOLLARD GHANA',
    'STAR ASSURANCE',
    'VANGUARD ASSURANCE',
    'DONEWELL INSURANCE',
    'GLICO GENERAL',
    'SERENE INSURANCE',
    'PHOENIX INSURANCE',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: providers.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => onSelected(providers[i]),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
              ),
              child: Text(
                providers[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
