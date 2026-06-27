// ─── Driver Remote Data Source ────────────────────────────────────────────────
// Handles all remote API calls for drivers feature
// ─────────────────────────────────────────────────────────────────────────────

import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';

abstract class DriverRemoteDataSource {
  Future<(List<DriverModel>, PaginationMeta)> getDrivers({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<List<DriverModel>> searchDrivers(String query);
  Future<DriverModel> getDriverById(String id);
  Future<DriverModel> createDriver({required String name, required String mobile});
  Future<DriverModel> updateDriver(String id, {String? name, String? mobile});
  Future<void> deleteDriver(String id);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient _apiClient;

  const DriverRemoteDataSourceImpl(this._apiClient);

  @override
  Future<(List<DriverModel>, PaginationMeta)> getDrivers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiEndpoints.drivers,
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      final meta = response.data['meta'] as Map<String, dynamic>? ?? {};

      final drivers = data
          .map((json) => DriverModel.fromJson(json as Map<String, dynamic>))
          .toList();
      final pagination = PaginationMeta.fromJson(meta);

      return (drivers, pagination);
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<DriverModel>> searchDrivers(String query) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.driversSearch,
        queryParameters: {'q': query},
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => DriverModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<DriverModel> getDriverById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverById(id));
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return DriverModel.fromJson(data);
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<DriverModel> createDriver({
    required String name,
    required String mobile,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.drivers,
        data: {'name': name, 'mobile': mobile},
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return DriverModel.fromJson(data);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<DriverModel> updateDriver(String id, {String? name, String? mobile}) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (mobile != null) payload['mobile'] = mobile;

      final response = await _apiClient.patch(
        ApiEndpoints.driverById(id),
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return DriverModel.fromJson(data);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteDriver(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.driverById(id));
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
