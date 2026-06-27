// ─── Vehicle Remote Data Source ───────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/vehicles/data/models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<(List<VehicleModel>, PaginationMeta)> getVehicles({
    int page = 1,
    int limit = 10,
    String? status,
  });
  Future<List<VehicleModel>> searchVehicles(String query);
  Future<VehicleModel> getVehicleById(String id);
  Future<VehicleModel> createVehicle({required String number, String status = 'ACTIVE'});
  Future<VehicleModel> updateVehicle(String id, {String? number, String? status});
  Future<void> updateVehicleStatus(String id, String status);
  Future<void> deleteVehicle(String id);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient _apiClient;
  const VehicleRemoteDataSourceImpl(this._apiClient);

  @override
  Future<(List<VehicleModel>, PaginationMeta)> getVehicles({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _apiClient.get(ApiEndpoints.vehicles, queryParameters: queryParams);
      final data = response.data['data'] as List<dynamic>? ?? [];
      final meta = response.data['meta'] as Map<String, dynamic>? ?? {};

      return (
        data.map((json) => VehicleModel.fromJson(json as Map<String, dynamic>)).toList(),
        PaginationMeta.fromJson(meta),
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.vehiclesSearch, queryParameters: {'q': query});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => VehicleModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.vehicleById(id));
      return VehicleModel.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is NotFoundException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleModel> createVehicle({required String number, String status = 'ACTIVE'}) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.vehicles, data: {'number': number, 'status': status});
      return VehicleModel.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle(String id, {String? number, String? status}) async {
    try {
      final payload = <String, dynamic>{};
      if (number != null) payload['number'] = number;
      if (status != null) payload['status'] = status;
      final response = await _apiClient.patch(ApiEndpoints.vehicleById(id), data: payload);
      return VehicleModel.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateVehicleStatus(String id, String status) async {
    try {
      await _apiClient.patch(ApiEndpoints.vehicleStatus(id), data: {'status': status});
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.vehicleById(id));
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
