// ─── Dashboard Repository Implementation ──────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:rangrej_fleet/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:rangrej_fleet/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const DashboardRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<(DashboardSummaryModel?, Failure?)> getDashboardSummary({DateTime? date, bool forceRefresh = false}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final dateStr = date?.toIso8601String().substring(0, 10);
      final result = await remoteDataSource.getDashboardSummary(dateStr: dateStr, forceRefresh: forceRefresh);
      return (result, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } on UnauthorizedException {
      return (null, const UnauthorizedFailure(message: 'Session expired'));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(WeeklyOverviewModel?, Failure?)> getWeeklyOverview({bool forceRefresh = false}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final result = await remoteDataSource.getWeeklyOverview(forceRefresh: forceRefresh);
      return (result, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Map<String, dynamic>>?, Failure?)> getCompanyAnalyticsTrend({bool forceRefresh = false}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final result = await remoteDataSource.getCompanyAnalyticsTrend(forceRefresh: forceRefresh);
      return (result, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Map<String, dynamic>>?, Failure?)> getDriverEarningsTrend({bool forceRefresh = false}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final result = await remoteDataSource.getDriverEarningsTrend(forceRefresh: forceRefresh);
      return (result, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }
}
