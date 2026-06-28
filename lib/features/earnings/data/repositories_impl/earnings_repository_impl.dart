// ─── Earnings Repository Implementation ────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/features/earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:rangrej_fleet/features/earnings/data/models/company_earning_model.dart';
import 'package:rangrej_fleet/features/earnings/data/models/weekly_earning_model.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/company_earning_entity.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/weekly_earning_entity.dart';
import 'package:rangrej_fleet/features/earnings/domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const EarningsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  String _formatDate(DateTime date) => date.toIso8601String().substring(0, 10);

  @override
  Future<(WeeklyEarningEntity?, Failure?)> getDriverEarningForWeek(String driverId, DateTime date) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = await remoteDataSource.getDriverEarningForWeek(driverId, _formatDate(date));
      return (model?.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } on UnauthorizedException {
      return (null, const UnauthorizedFailure(message: 'Session expired'));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(WeeklyEarningEntity?, Failure?)> saveDriverEarning(WeeklyEarningEntity entity) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = WeeklyEarningModel(
        id: entity.id,
        driverId: entity.driverId,
        amount: entity.amount,
        weekStart: entity.weekStart,
        weekEnd: entity.weekEnd,
        trips: entity.trips,
        status: entity.status,
        notes: entity.notes,
        weeklyEarning: entity.weeklyEarning,
        cash: entity.cash,
        tax: entity.tax,
        toll: entity.toll,
        rent: entity.rent,
        uberSubscription: entity.uberSubscription,
        adjustment: entity.adjustment,
        other: entity.other,
      );
      final savedModel = await remoteDataSource.saveDriverEarning(model);
      return (savedModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(WeeklyEarningEntity?, Failure?)> updateDriverEarning(String id, WeeklyEarningEntity entity) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = WeeklyEarningModel(
        id: entity.id,
        driverId: entity.driverId,
        amount: entity.amount,
        weekStart: entity.weekStart,
        weekEnd: entity.weekEnd,
        trips: entity.trips,
        status: entity.status,
        notes: entity.notes,
        weeklyEarning: entity.weeklyEarning,
        cash: entity.cash,
        tax: entity.tax,
        toll: entity.toll,
        rent: entity.rent,
        uberSubscription: entity.uberSubscription,
        adjustment: entity.adjustment,
        other: entity.other,
      );
      final updatedModel = await remoteDataSource.updateDriverEarning(id, model);
      return (updatedModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(CompanyEarningEntity?, Failure?)> getCompanyEarningForWeek(DateTime date, {bool forceRefresh = false}) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = await remoteDataSource.getCompanyEarningForWeek(_formatDate(date), forceRefresh: forceRefresh);
      return (model?.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(CompanyEarningEntity?, Failure?)> saveCompanyEarning(CompanyEarningEntity entity) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final model = CompanyEarningModel(
        id: entity.id,
        grossRevenue: entity.grossRevenue,
        totalDriverPayouts: entity.totalDriverPayouts,
        operatingCosts: entity.operatingCosts,
        ownerShare: entity.ownerShare,
        weekStart: entity.weekStart,
        weekEnd: entity.weekEnd,
      );
      final savedModel = await remoteDataSource.saveCompanyEarning(model);
      return (savedModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getWeekPayoutSummary(DateTime date) async {
    if (!await networkInfo.isConnected) return (null, const NetworkFailure(message: 'No internet connection'));
    try {
      final summary = await remoteDataSource.getWeekPayoutSummary(_formatDate(date));
      return (summary, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }
}
