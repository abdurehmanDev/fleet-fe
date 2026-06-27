// ─── Analytics Repository Contract ────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';

abstract class AnalyticsRepository {
  Future<(List<Map<String, dynamic>>?, Failure?)> getCompanyAnalytics({int weeks = 4});
  Future<(List<Map<String, dynamic>>?, Failure?)> getDriverAnalytics(String driverId);
  Future<(Map<String, dynamic>?, Failure?)> getAnalyticsOverview();
}
