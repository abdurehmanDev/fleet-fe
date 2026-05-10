// ─── Auth Repository Implementation ──────────────────────────────────────────
// Implements the domain AuthRepository contract; handles errors and maps to failures
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/core/storage/secure_storage_service.dart';
import 'package:rangrej_fleet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rangrej_fleet/features/auth/data/models/login_request_model.dart';
import 'package:rangrej_fleet/features/auth/domain/entities/user_entity.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SecureStorageService secureStorage;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.secureStorage,
  });

  @override
  Future<(UserEntity?, Failure?)> login({
    required String email,
    required String password,
  }) async {
    // Bypass connection check for mock admin to allow seamless login in static testing
    if (email == 'admin@rangrejfleet.com' && password == 'password123') {
      try {
        final response = await remoteDataSource.login(
          LoginRequestModel(email: email, password: password),
        );
        return (response.toEntity(), null);
      } catch (e) {
        return (null, UnknownFailure(message: e.toString()));
      }
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      // Allow fallback login even if fully offline
      try {
        final response = await remoteDataSource.login(
          LoginRequestModel(email: email, password: password),
        );
        return (response.toEntity(), null);
      } catch (e) {
        return (null, const NetworkFailure(message: 'Network connection is unavailable'));
      }
    }

    try {
      final response = await remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      // Persist tokens
      await secureStorage.saveAccessToken(response.accessToken);
      await secureStorage.saveRefreshToken(response.refreshToken);
      await secureStorage.saveUserData(jsonEncode({
        'id': response.user.id,
        'name': response.user.name,
        'email': response.user.email,
        'role': response.user.role,
      }));

      return (response.toEntity(), null);
    } on UnauthorizedException catch (e) {
      return (null, UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return (null, NetworkFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> logout() async {
    try {
      await remoteDataSource.logout();
      await secureStorage.clearAll();
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      await secureStorage.clearAll(); // Clear locally even if API fails
      return (true, null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await secureStorage.isAuthenticated();
  }
}
