// ─── Auth Remote Data Source ──────────────────────────────────────────────────
// Handles all remote API calls for auth feature — real API, no mocks
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/auth/data/models/auth_response_model.dart';
import 'package:rangrej_fleet/features/auth/data/models/login_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<UserModel> getMe();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({required String token, required String password});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Silently handle logout errors — user is logging out anyway
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return UserModel.fromJson(data);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'password': password},
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
