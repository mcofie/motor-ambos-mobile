import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final String? make;
  final String? model;
  final String? year;
  final String? plate;
  final bool isPrimary;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.name,
    this.make,
    this.model,
    this.year,
    this.plate,
    this.isPrimary = false,
  });

  String get displayLabel {
    if (name != null && name!.trim().isNotEmpty) return name!;
    final parts = [
      if (make != null && make!.isNotEmpty) make,
      if (model != null && model!.isNotEmpty) model,
      if (year != null && year!.isNotEmpty) year,
    ].whereType<String>().toList();

    if (parts.isNotEmpty) return parts.join(' ');
    if (plate != null && plate!.isNotEmpty) return plate!;
    return 'Vehicle';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      plate: json['plate'] as String?,
      isPrimary: (json['is_primary'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'plate': plate,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? name,
    String? make,
    String? model,
    String? year,
    String? plate,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    make,
    model,
    year,
    plate,
    isPrimary,
    createdAt,
  ];
}
