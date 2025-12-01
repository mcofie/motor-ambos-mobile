class Vehicle {
  final String id;
  final String name;
  final String make;
  final String model;
  final int year; // Changed to int to match SQL
  final String plate;
  final bool isPrimary;

  Vehicle({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    this.isPrimary = false,
  });

  // Factory to convert JSON from Supabase to Dart Object
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'My Car',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 2020,
      plate: json['plate'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Vehicle copyWith({
    String? id,
    String? name,
    String? make,
    String? model,
    int? year,
    String? plate,
    bool? isPrimary,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
