// ─── Vehicle Repository Implementation ────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import 'package:rangrej_fleet/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:rangrej_fleet/features/vehicles/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const VehicleRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<(List<VehicleEntity>, PaginationMeta?, Failure?)> getVehicles({int page = 1, int limit = 10, String? status, bool forceRefresh = false}) async {
    if (!await networkInfo.isConnected) return (<VehicleEntity>[], null, const NetworkFailure(message: 'No internet connection'));
    try {
      final (models, meta) = await remoteDataSource.getVehicles(page: page, limit: limit, status: status, forceRefresh: forceRefresh);
      return (models.map((m) => m.toEntity()).toList(), meta, null);
    } on ServerException catch (e) {
      return (<VehicleEntity>[], null, ServerFailure(message: e.message));
    } on UnauthorizedException {
      return (<VehicleEntity>[], null, const UnauthorizedFailure(message: 'Session expired'));
    } catch (e) {
      return (<VehicleEntity>[], null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<VehicleEntity>?, Failure?)> searchVehicles(String query) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final models = await remoteDataSource.searchVehicles(query);
      return (models.map((m) => m.toEntity()).toList(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(VehicleEntity?, Failure?)> getVehicleById(String id) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = await remoteDataSource.getVehicleById(id);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(VehicleEntity?, Failure?)> createVehicle({required String number, String status = 'ACTIVE'}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = await remoteDataSource.createVehicle(number: number, status: status);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(VehicleEntity?, Failure?)> updateVehicle(String id, {String? number, String? status}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = await remoteDataSource.updateVehicle(id, number: number, status: status);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> updateVehicleStatus(String id, String status) async {
    if (!await networkInfo.isConnected) return (false, const NetworkFailure(message: 'No internet connection'));
    try {
      await remoteDataSource.updateVehicleStatus(id, status);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteVehicle(String id) async {
    if (!await networkInfo.isConnected) return (false, const NetworkFailure(message: 'No internet connection'));
    try {
      await remoteDataSource.deleteVehicle(id);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }
}
