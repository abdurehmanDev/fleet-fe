// ─── Analytics Repository Implementation ──────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:rangrej_fleet/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const AnalyticsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<(List<Map<String, dynamic>>?, Failure?)> getCompanyAnalytics({int weeks = 4}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final data = await remoteDataSource.getCompanyAnalytics(weeks: weeks);
      return (data, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } on UnauthorizedException {
      return (null, const UnauthorizedFailure(message: 'Session expired'));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Map<String, dynamic>>?, Failure?)> getDriverAnalytics(String driverId) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final data = await remoteDataSource.getDriverAnalytics(driverId);
      return (data, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getAnalyticsOverview() async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final data = await remoteDataSource.getAnalyticsOverview();
      return (data, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }
}
