// ─── User Entity ──────────────────────────────────────────────────────────────
// Pure domain entity — no JSON, no dependencies on data layer
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  bool get isOwner => role.toUpperCase() == 'OWNER';
  bool get isManager => role.toUpperCase() == 'MANAGER';

  @override
  List<Object?> get props => [id, name, email, role, isActive];
}
