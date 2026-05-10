// ─── User Entity ──────────────────────────────────────────────────────────────
// Pure domain entity — no JSON, no dependencies on data layer
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isDriver => role.toLowerCase() == 'driver';

  @override
  List<Object?> get props => [id, name, email, role, profilePicture];
}
