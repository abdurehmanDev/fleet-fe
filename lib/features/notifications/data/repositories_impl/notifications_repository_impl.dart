// ─── Notifications Repository Implementation ──────────────────────────────────
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:rangrej_fleet/features/notifications/domain/entities/notification_entity.dart';
import 'package:rangrej_fleet/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const NotificationsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<(List<NotificationEntity>, PaginationMeta?, Failure?)> getNotifications({int page = 1, int limit = 10}) async {
    if (!await networkInfo.isConnected) return (<NotificationEntity>[], null, const NetworkFailure(message: 'No internet connection'));
    try {
      final (models, meta) = await remoteDataSource.getNotifications(page: page, limit: limit);
      return (models.map((m) => m.toEntity()).toList(), meta, null);
    } on ServerException catch (e) {
      return (<NotificationEntity>[], null, ServerFailure(message: e.message));
    } on UnauthorizedException {
      return (<NotificationEntity>[], null, const UnauthorizedFailure(message: 'Session expired'));
    } catch (e) {
      return (<NotificationEntity>[], null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(int, Failure?)> getUnreadCount() async {
    if (!await networkInfo.isConnected) return (0, const NetworkFailure(message: 'No internet connection'));
    try {
      final count = await remoteDataSource.getUnreadCount();
      return (count, null);
    } on ServerException catch (e) {
      return (0, ServerFailure(message: e.message));
    } catch (e) {
      return (0, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> markAsRead(String id) async {
    if (!await networkInfo.isConnected) return (false, const NetworkFailure(message: 'No internet connection'));
    try {
      await remoteDataSource.markAsRead(id);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> markAllAsRead() async {
    if (!await networkInfo.isConnected) return (false, const NetworkFailure(message: 'No internet connection'));
    try {
      await remoteDataSource.markAllAsRead();
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteNotification(String id) async {
    if (!await networkInfo.isConnected) return (false, const NetworkFailure(message: 'No internet connection'));
    try {
      await remoteDataSource.deleteNotification(id);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(message: e.toString()));
    }
  }
}
