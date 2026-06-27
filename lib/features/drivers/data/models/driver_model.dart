// ─── Driver Model ─────────────────────────────────────────────────────────────
// Data layer model with JSON serialization
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';

class DriverModel {
  final String id;
  final String name;
  final String mobile;
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DriverModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.ownerId = '',
    this.createdAt,
    this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
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
      'name': name,
      'mobile': mobile,
    };
  }

  DriverEntity toEntity() {
    return DriverEntity(
      id: id,
      name: name,
      mobile: mobile,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Pagination metadata from API
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  bool get hasMore => page < totalPages;
}
