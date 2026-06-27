// ─── Vehicle Model ────────────────────────────────────────────────────────────
import 'package:rangrej_fleet/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleModel {
  final String id;
  final String number;
  final String status;
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleModel({
    required this.id,
    required this.number,
    required this.status,
    this.ownerId = '',
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
      ownerId: json['ownerId']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'status': status,
    };
  }

  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      number: number,
      status: status,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
