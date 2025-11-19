class Vehicle {
  final String id;
  final String name;
  final String plate;
  final String make;
  final String model;
  final int year;
  final bool isPrimary;

  const Vehicle({
    required this.id,
    required this.name,
    required this.plate,
    required this.make,
    required this.model,
    required this.year,
    this.isPrimary = false,
  });

  Vehicle copyWith({
    String? id,
    String? name,
    String? plate,
    String? make,
    String? model,
    int? year,
    bool? isPrimary,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}