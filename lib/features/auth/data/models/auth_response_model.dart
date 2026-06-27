// ─── Auth Response Model ──────────────────────────────────────────────────────
// Maps backend /auth/login response to app domain
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/features/auth/domain/entities/user_entity.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  /// Parse from real API response structure:
  /// { "success": true, "data": { "user": {...}, "accessToken": "...", "refreshToken": "..." } }
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AuthResponseModel(
      accessToken: data['accessToken'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
    };
  }
}
