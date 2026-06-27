// ─── Notifications Repository Contract ─────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<(List<NotificationEntity>, PaginationMeta?, Failure?)> getNotifications({int page = 1, int limit = 10});
  Future<(int, Failure?)> getUnreadCount();
  Future<(bool, Failure?)> markAsRead(String id);
  Future<(bool, Failure?)> markAllAsRead();
  Future<(bool, Failure?)> deleteNotification(String id);
}
