// ─── Analytics Remote Data Source ─────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';

abstract class AnalyticsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getCompanyAnalytics({int weeks = 4, bool forceRefresh = false});
  Future<List<Map<String, dynamic>>> getDriverAnalytics(String driverId, {bool forceRefresh = false});
  Future<Map<String, dynamic>> getAnalyticsOverview({bool forceRefresh = false});
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient _apiClient;
  const AnalyticsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<Map<String, dynamic>>> getCompanyAnalytics({int weeks = 4, bool forceRefresh = false}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.companyEarningsAnalytics,
        queryParameters: {'weeks': weeks},
        forceRefresh: forceRefresh,
      );
      final dataMap = response.data['data'] as Map<String, dynamic>? ?? {};
      final barChart = dataMap['barChart'] as List<dynamic>? ?? [];
      return barChart.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDriverAnalytics(String driverId, {bool forceRefresh = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverAnalytics(driverId), forceRefresh: forceRefresh);
      final dataMap = response.data['data'] as Map<String, dynamic>? ?? {};
      final trend = dataMap['trend'] as List<dynamic>? ?? [];
      return trend.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getAnalyticsOverview({bool forceRefresh = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.analyticsOverview, forceRefresh: forceRefresh);
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      try {
        final summaryResponse = await _apiClient.get(ApiEndpoints.dashboardSummary, forceRefresh: forceRefresh);
        return summaryResponse.data['data'] as Map<String, dynamic>? ?? {};
      } catch (_) {
        rethrow;
      }
    }
  }
}
