// ─── Login UseCase ────────────────────────────────────────────────────────────
// Business logic for login — sits between BLoC and Repository
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/auth/domain/entities/user_entity.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Executes the login use case
  /// Returns [UserEntity] on success, [Failure] on error
  Future<(UserEntity?, Failure?)> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email: email, password: password);
  }
}
