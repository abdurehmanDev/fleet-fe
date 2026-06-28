// ─── Analytics Repository Contract ────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';

abstract class AnalyticsRepository {
  Future<(List<Map<String, dynamic>>?, Failure?)> getCompanyAnalytics({int weeks = 4, bool forceRefresh = false});
  Future<(List<Map<String, dynamic>>?, Failure?)> getDriverAnalytics(String driverId, {bool forceRefresh = false});
  Future<(Map<String, dynamic>?, Failure?)> getAnalyticsOverview({bool forceRefresh = false});
}
