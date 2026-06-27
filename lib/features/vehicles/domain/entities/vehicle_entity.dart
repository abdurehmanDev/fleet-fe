// ─── Vehicle Entity ───────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String id;
  final String number;
  final String status; // ACTIVE, INACTIVE, MAINTENANCE
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleEntity({
    required this.id,
    required this.number,
    required this.status,
    this.ownerId = '',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isMaintenance => status == 'MAINTENANCE';
  bool get isInactive => status == 'INACTIVE';

  @override
  List<Object?> get props => [id, number, status, ownerId];
}
