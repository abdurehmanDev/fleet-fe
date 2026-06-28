// ─── Driver Repository Implementation ─────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/features/drivers/data/datasources/driver_remote_datasource.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';
import 'package:rangrej_fleet/features/drivers/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const DriverRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<(List<DriverEntity>, PaginationMeta?, Failure?)> getDrivers({
    int page = 1,
    int limit = 10,
    String? search,
    bool forceRefresh = false,
  }) async {
    if (!await networkInfo.isConnected) {
      return (<DriverEntity>[], null, const NetworkFailure(message: 'No internet connection'));
    }
    try {
      final (models, meta) = await remoteDataSource.getDrivers(
        page: page,
        limit: limit,
        search: search,
        forceRefresh: forceRefresh,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return (entities, meta, null);
    } on ServerException catch (e) {
      return (<DriverEntity>[], null, ServerFailure(message: e.message));
    } on UnauthorizedException {
      return (<DriverEntity>[], null, const UnauthorizedFailure(message: 'Session expired'));
    } catch (e) {
      return (<DriverEntity>[], null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<DriverEntity>?, Failure?)> searchDrivers(String query) async {
    if (!await networkInfo.isConnected) {
      return (null, const NetworkFailure(message: 'No internet connection'));
    }
    try {
      final models = await remoteDataSource.searchDrivers(query);
      return (models.map((m) => m.toEntity()).toList(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(DriverEntity?, Failure?)> getDriverById(String id) async {
    if (!await networkInfo.isConnected) {
      return (null, const NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await remoteDataSource.getDriverById(id);
      return (model.toEntity(), null);
    } on NotFoundException catch (e) {
      return (null, ServerFailure(message: e.message));
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(DriverEntity?, Failure?)> createDriver({
    required String name,
    required String mobile,
  }) async {
    if (!await networkInfo.isConnected) {
      return (null, const NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await remoteDataSource.createDriver(name: name, mobile: mobile);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(DriverEntity?, Failure?)> updateDriver(
    String id, {
    String? name,
    String? mobile,
  }) async {
    if (!await networkInfo.isConnected) {
      return (null, const NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await remoteDataSource.updateDriver(id, name: name, mobile: mobile);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteDriver(String id) async {
    if (!await networkInfo.isConnected) {
      return (false, const NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteDriver(id);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }
}
