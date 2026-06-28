// ─── Dashboard Repository Contract ────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/dashboard/data/models/dashboard_summary_model.dart';

abstract class DashboardRepository {
  Future<(DashboardSummaryModel?, Failure?)> getDashboardSummary({DateTime? date, bool forceRefresh = false});
  Future<(WeeklyOverviewModel?, Failure?)> getWeeklyOverview({bool forceRefresh = false});
  Future<(List<Map<String, dynamic>>?, Failure?)> getCompanyAnalyticsTrend({bool forceRefresh = false});
  Future<(List<Map<String, dynamic>>?, Failure?)> getDriverEarningsTrend({bool forceRefresh = false});
}
