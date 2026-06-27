// ─── Auth Repository Contract ─────────────────────────────────────────────────
// Abstract interface — domain layer defines the contract, data layer implements it
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Returns (UserEntity, null) on success, (null, Failure) on error
  Future<(UserEntity?, Failure?)> login({
    required String email,
    required String password,
  });

  /// Returns (true, null) on success, (false, Failure) on error
  Future<(bool, Failure?)> logout();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get current authenticated user from API
  Future<(UserEntity?, Failure?)> getMe();

  /// Forgot password
  Future<(bool, Failure?)> forgotPassword(String email);

  /// Change password
  Future<(bool, Failure?)> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
