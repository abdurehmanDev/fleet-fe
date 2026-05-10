// ─── Auth Response Model ──────────────────────────────────────────────────────
// Data model for auth API response — maps JSON to domain entity
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

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  // Convert to domain entity
  UserEntity toEntity() => user.toEntity();
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        role: role,
        profilePicture: profilePicture,
      );
}
