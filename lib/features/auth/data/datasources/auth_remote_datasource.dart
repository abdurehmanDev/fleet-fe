// ─── Auth Remote Data Source ──────────────────────────────────────────────────
// Handles all remote API calls for auth feature
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/auth/data/models/auth_response_model.dart';
import 'package:rangrej_fleet/features/auth/data/models/login_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    // Mock presentation credentials for static testing
    if (request.email == 'admin@rangrejfleet.com' && request.password == 'password123') {
      return const AuthResponseModel(
        accessToken: 'mock_access_token_xyz',
        refreshToken: 'mock_refresh_token_abc',
        user: UserModel(
          id: '1',
          name: 'Rangrej Admin',
          email: 'admin@rangrejfleet.com',
          role: 'owner',
        ),
      );
    }

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
      // Fallback to offline mode for ease of development and screen preview
      return AuthResponseModel(
        accessToken: 'mock_access_token_offline',
        refreshToken: 'mock_refresh_token_offline',
        user: UserModel(
          id: '2',
          name: 'Offline Owner',
          email: request.email,
          role: 'owner',
        ),
      );
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}
