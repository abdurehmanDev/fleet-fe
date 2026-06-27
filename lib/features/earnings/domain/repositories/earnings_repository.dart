// ─── Earnings Repository Contract ──────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/company_earning_entity.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/weekly_earning_entity.dart';

abstract class EarningsRepository {
  // Driver earnings
  Future<(WeeklyEarningEntity?, Failure?)> getDriverEarningForWeek(String driverId, DateTime date);
  Future<(WeeklyEarningEntity?, Failure?)> saveDriverEarning(WeeklyEarningEntity entity);
  Future<(WeeklyEarningEntity?, Failure?)> updateDriverEarning(String id, WeeklyEarningEntity entity);

  // Company earnings
  Future<(CompanyEarningEntity?, Failure?)> getCompanyEarningForWeek(DateTime date);
  Future<(CompanyEarningEntity?, Failure?)> saveCompanyEarning(CompanyEarningEntity entity);
  
  // Weekly total summaries
  Future<(Map<String, dynamic>?, Failure?)> getWeekPayoutSummary(DateTime date);
}
