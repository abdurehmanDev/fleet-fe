// ─── Notifications Remote Data Source ─────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<(List<NotificationModel>, PaginationMeta)> getNotifications({int page = 1, int limit = 10});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;
  const NotificationsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<(List<NotificationModel>, PaginationMeta)> getNotifications({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      final meta = response.data['meta'] as Map<String, dynamic>? ?? {};

      return (
        data.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList(),
        PaginationMeta.fromJson(meta),
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.notificationsUnreadCount);
      return response.data['data']?['count'] as int? ?? 0;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.patch(ApiEndpoints.notificationRead(id));
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch(ApiEndpoints.notificationsReadAll);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.notificationById(id));
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
