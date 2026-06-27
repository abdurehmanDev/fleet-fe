// ─── Dashboard Repository Contract ────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/dashboard/data/models/dashboard_summary_model.dart';

abstract class DashboardRepository {
  Future<(DashboardSummaryModel?, Failure?)> getDashboardSummary({DateTime? date});
  Future<(WeeklyOverviewModel?, Failure?)> getWeeklyOverview();
  Future<(List<Map<String, dynamic>>?, Failure?)> getCompanyAnalyticsTrend();
  Future<(List<Map<String, dynamic>>?, Failure?)> getDriverEarningsTrend();
}
