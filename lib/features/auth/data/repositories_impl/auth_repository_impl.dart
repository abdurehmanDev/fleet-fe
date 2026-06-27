// ─── Auth Repository Implementation ──────────────────────────────────────────
// Implements the domain AuthRepository contract — real API, no mocks
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
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return (null, const NetworkFailure(message: 'No internet connection. Please check your network.'));
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
    } catch (_) {
      await secureStorage.clearAll(); // Clear locally even if API fails
      return (true, null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await secureStorage.isAuthenticated();
  }

  @override
  Future<(UserEntity?, Failure?)> getMe() async {
    try {
      final user = await remoteDataSource.getMe();
      final entity = UserEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
      );
      return (entity, null);
    } on UnauthorizedException {
      return (null, const UnauthorizedFailure(message: 'Session expired'));
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }
}
