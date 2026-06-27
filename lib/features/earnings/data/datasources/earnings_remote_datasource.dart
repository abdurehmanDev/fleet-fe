// ─── Earnings Remote Data Source ──────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/earnings/data/models/company_earning_model.dart';
import 'package:rangrej_fleet/features/earnings/data/models/weekly_earning_model.dart';

abstract class EarningsRemoteDataSource {
  // Driver weekly earnings CRUD
  Future<WeeklyEarningModel?> getDriverEarningForWeek(String driverId, String dateStr);
  Future<WeeklyEarningModel> saveDriverEarning(WeeklyEarningModel model);
  Future<WeeklyEarningModel> updateDriverEarning(String id, WeeklyEarningModel model);

  // Company weekly earnings
  Future<CompanyEarningModel?> getCompanyEarningForWeek(String dateStr);
  Future<CompanyEarningModel> saveCompanyEarning(CompanyEarningModel model);
  
  // Total payouts/trips/ops cost for a given week
  Future<Map<String, dynamic>> getWeekPayoutSummary(String dateStr);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final ApiClient _apiClient;
  const EarningsRemoteDataSourceImpl(this._apiClient);

  Map<String, dynamic> _safeCast(dynamic map) {
    if (map is Map) {
      return Map<String, dynamic>.from(map);
    }
    return {};
  }

  @override
  Future<WeeklyEarningModel?> getDriverEarningForWeek(String driverId, String dateStr) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.weeklyEarningsByDriver(driverId),
      );
      
      final dynamic rawData = response.data;
      List<dynamic> listData = [];

      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map) {
        final inner = rawData['data'];
        if (inner is List) {
          listData = inner;
        } else if (inner is Map) {
          return WeeklyEarningModel.fromJson(_safeCast(inner));
        }
      }

      // Match chronological weekStartDate up to YYYY-MM-DD
      final targetDateOnly = dateStr.substring(0, 10);
      final match = listData.firstWhere(
        (item) {
          if (item is Map) {
            final itemDate = item['weekStartDate']?.toString() ?? '';
            return itemDate.startsWith(targetDateOnly);
          }
          return false;
        },
        orElse: () => null,
      );

      if (match == null) return null;
      return WeeklyEarningModel.fromJson(_safeCast(match));
    } on NotFoundException {
      return null;
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WeeklyEarningModel> saveDriverEarning(WeeklyEarningModel model) async {
    try {
      final payload = {
        'driver_id': model.driverId,
        'total_amount': model.amount,
        'week_start_date': model.weekStart.toIso8601String().substring(0, 10),
        'week_end_date': model.weekEnd.toIso8601String().substring(0, 10),
        'trips': model.trips,
        'status': model.status,
        'notes': model.notes,
        'weekly_earning': model.weeklyEarning,
        'cash': model.cash,
        'tax': model.tax,
        'toll': model.toll,
        'rent': model.rent,
        'uber_subscription': model.uberSubscription,
        'adjustment': model.adjustment,
        'other': model.other,
      };
      
      final response = await _apiClient.post(ApiEndpoints.weeklyEarnings, data: payload);
      final dynamic rawData = response.data;
      final mapData = rawData is Map ? _safeCast(rawData['data']) : <String, dynamic>{};
      return WeeklyEarningModel.fromJson(mapData);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WeeklyEarningModel> updateDriverEarning(String id, WeeklyEarningModel model) async {
    try {
      final payload = {
        'driver_id': model.driverId,
        'total_amount': model.amount,
        'week_start_date': model.weekStart.toIso8601String().substring(0, 10),
        'week_end_date': model.weekEnd.toIso8601String().substring(0, 10),
        'trips': model.trips,
        'status': model.status,
        'notes': model.notes,
        'weekly_earning': model.weeklyEarning,
        'cash': model.cash,
        'tax': model.tax,
        'toll': model.toll,
        'rent': model.rent,
        'uber_subscription': model.uberSubscription,
        'adjustment': model.adjustment,
        'other': model.other,
      };

      final response = await _apiClient.patch(ApiEndpoints.weeklyEarningsById(id), data: payload);
      final dynamic rawData = response.data;
      final mapData = rawData is Map ? _safeCast(rawData['data']) : <String, dynamic>{};
      return WeeklyEarningModel.fromJson(mapData);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CompanyEarningModel?> getCompanyEarningForWeek(String dateStr) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.companyEarningsWeek, queryParameters: {'date': dateStr});
      final dynamic rawData = response.data;
      if (rawData is Map) {
        final inner = rawData['data'];
        if (inner is Map) {
          return CompanyEarningModel.fromJson(_safeCast(inner));
        }
      }
      return null;
    } on NotFoundException {
      return null;
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CompanyEarningModel> saveCompanyEarning(CompanyEarningModel model) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.companyEarnings, data: model.toJson());
      final dynamic rawData = response.data;
      final mapData = rawData is Map ? _safeCast(rawData['data']) : <String, dynamic>{};
      return CompanyEarningModel.fromJson(mapData);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getWeekPayoutSummary(String dateStr) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weeklyEarningsWeek, queryParameters: {'date': dateStr});
      final dynamic rawData = response.data;
      if (rawData is Map) {
        return _safeCast(rawData['data']);
      }
      return {};
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
