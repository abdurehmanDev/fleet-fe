// ─── Dashboard Remote Data Source ─────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/dashboard/data/models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getDashboardSummary({String? dateStr});
  Future<WeeklyOverviewModel> getWeeklyOverview();
  Future<List<Map<String, dynamic>>> getCompanyAnalyticsTrend();
  Future<List<Map<String, dynamic>>> getDriverEarningsTrend();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;
  const DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DashboardSummaryModel> getDashboardSummary({String? dateStr}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.dashboardSummary,
        queryParameters: dateStr != null ? {'date': dateStr} : null,
      );
      return DashboardSummaryModel.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WeeklyOverviewModel> getWeeklyOverview() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardWeeklyOverview);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return WeeklyOverviewModel.fromJson(data);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCompanyAnalyticsTrend() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.companyEarningsAnalytics,
        queryParameters: {'weeks': 4},
      );
      final dataMap = response.data['data'] as Map<String, dynamic>? ?? {};
      final barChart = dataMap['barChart'] as List<dynamic>? ?? [];
      return barChart.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDriverEarningsTrend() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weeklyEarningsAnalytics);
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
