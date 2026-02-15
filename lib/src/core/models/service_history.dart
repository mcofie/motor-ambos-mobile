import 'package:equatable/equatable.dart';

class ServiceHistory extends Equatable {
  final String id;
  final String vehicleId;
  final DateTime serviceDate;
  final String description;
  final String? providerName;
  final int? mileage;
  final double? cost;
  final bool isVerified;
  final String? documentUrl;
  final DateTime createdAt;

  const ServiceHistory({
    required this.id,
    required this.vehicleId,
    required this.serviceDate,
    required this.description,
    required this.createdAt,
    this.providerName,
    this.mileage,
    this.cost,
    this.isVerified = false,
    this.documentUrl,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      serviceDate: DateTime.tryParse(json['service_date']?.toString() ?? '') ?? DateTime.now(),
      description: json['description'] as String,
      providerName: json['provider_name'] as String?,
      mileage: json['mileage'] as int?,
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) : null,
      isVerified: (json['is_verified'] as bool?) ?? false,
      documentUrl: json['document_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        serviceDate,
        description,
        providerName,
        mileage,
        cost,
        isVerified,
        documentUrl,
        createdAt,
      ];
}
