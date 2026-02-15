import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final String? make;
  final String? model;
  final String? year;
  final String? plate;
  final String? color;
  final bool isPrimary;
  final String? nfcCardId;
  final String? nfcSerialNumber;
  
  // Doc fields (Roadworthy)
  final String? roadworthyDocUrl;
  final DateTime? roadworthyExpiry;
  
  // Doc fields (Insurance)
  final String? insuranceProvider;
  final String? insuranceStickerNo;
  final DateTime? insuranceStartDate;
  final DateTime? insuranceEndDate;

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
    this.color,
    this.isPrimary = false,
    this.nfcCardId,
    this.nfcSerialNumber,
    this.roadworthyDocUrl,
    this.roadworthyExpiry,
    this.insuranceProvider,
    this.insuranceStickerNo,
    this.insuranceStartDate,
    this.insuranceEndDate,
  });

  double get healthScore {
    double score = 100;
    final now = DateTime.now();

    // Roadworthy penalty
    if (roadworthyExpiry != null) {
      if (roadworthyExpiry!.isBefore(now)) {
        score -= 40;
      } else if (roadworthyExpiry!.isBefore(now.add(const Duration(days: 30)))) {
        score -= 20;
      }
    } else {
      score -= 10; // Penalty for missing data
    }

    // Insurance penalty
    if (insuranceEndDate != null) {
      if (insuranceEndDate!.isBefore(now)) {
        score -= 40;
      } else if (insuranceEndDate!.isBefore(now.add(const Duration(days: 30)))) {
        score -= 20;
      }
    } else {
      score -= 10; // Penalty for missing data
    }

    return score.clamp(0, 100);
  }

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
      color: json['color'] as String?,
      isPrimary: (json['is_primary'] as bool?) ?? false,
      nfcCardId: json['nfc_card_id'] as String?,
      nfcSerialNumber: json['nfc_serial_number'] as String?,
      roadworthyDocUrl: json['roadworthy_doc_url'] as String?,
      roadworthyExpiry: json['roadworthy_expiry'] != null
          ? DateTime.tryParse(json['roadworthy_expiry'].toString())
          : null,
      insuranceProvider: json['insurance_provider'] as String?,
      insuranceStickerNo: json['insurance_sticker_no'] as String?,
      insuranceStartDate: json['insurance_start_date'] != null
          ? DateTime.tryParse(json['insurance_start_date'].toString())
          : null,
      insuranceEndDate: json['insurance_end_date'] != null
          ? DateTime.tryParse(json['insurance_end_date'].toString())
          : null,
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
      'color': color,
      'is_primary': isPrimary,
      'nfc_card_id': nfcCardId,
      'nfc_serial_number': nfcSerialNumber,
      'roadworthy_doc_url': roadworthyDocUrl,
      'roadworthy_expiry': roadworthyExpiry?.toIso8601String(),
      'insurance_provider': insuranceProvider,
      'insurance_sticker_no': insuranceStickerNo,
      'insurance_start_date': insuranceStartDate?.toIso8601String(),
      'insurance_end_date': insuranceEndDate?.toIso8601String(),
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
    String? color,
    bool? isPrimary,
    String? nfcCardId,
    String? nfcSerialNumber,
    String? roadworthyDocUrl,
    DateTime? roadworthyExpiry,
    String? insuranceProvider,
    String? insuranceStickerNo,
    DateTime? insuranceStartDate,
    DateTime? insuranceEndDate,
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
      color: color ?? this.color,
      isPrimary: isPrimary ?? this.isPrimary,
      nfcCardId: nfcCardId ?? this.nfcCardId,
      nfcSerialNumber: nfcSerialNumber ?? this.nfcSerialNumber,
      roadworthyDocUrl: roadworthyDocUrl ?? this.roadworthyDocUrl,
      roadworthyExpiry: roadworthyExpiry ?? this.roadworthyExpiry,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceStickerNo: insuranceStickerNo ?? this.insuranceStickerNo,
      insuranceStartDate: insuranceStartDate ?? this.insuranceStartDate,
      insuranceEndDate: insuranceEndDate ?? this.insuranceEndDate,
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
        color,
        isPrimary,
        nfcCardId,
        nfcSerialNumber,
        roadworthyDocUrl,
        roadworthyExpiry,
        insuranceProvider,
        insuranceStickerNo,
        insuranceStartDate,
        insuranceEndDate,
        createdAt,
      ];
}
