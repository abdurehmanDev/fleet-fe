// ─── Driver Entity ────────────────────────────────────────────────────────────
// Pure domain entity for Driver
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.mobile,
    this.ownerId = '',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, mobile, ownerId];
}
