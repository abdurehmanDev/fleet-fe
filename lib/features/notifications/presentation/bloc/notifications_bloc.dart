// ─── Notifications BLoC ──────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/notifications/domain/entities/notification_entity.dart';
import 'package:rangrej_fleet/features/notifications/domain/repositories/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDelete);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final (notifications, meta, failure) = await _repository.getNotifications(page: 1, limit: 10);
    if (failure != null) {
      emit(NotificationsError(message: failure.message));
      return;
    }

    final (unreadCount, _) = await _repository.getUnreadCount();

    emit(NotificationsLoaded(
      notifications: notifications,
      meta: meta,
      hasMore: meta?.hasMore ?? false,
      currentPage: 1,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    final cs = state;
    if (cs is! NotificationsLoaded || !cs.hasMore || cs.isLoadingMore) return;

    emit(cs.copyWith(isLoadingMore: true));
    final nextPage = cs.currentPage + 1;

    final (notifications, meta, failure) = await _repository.getNotifications(page: nextPage, limit: 10);
    if (failure != null) {
      emit(cs.copyWith(isLoadingMore: false));
      return;
    }

    emit(NotificationsLoaded(
      notifications: [...cs.notifications, ...notifications],
      meta: meta,
      hasMore: meta?.hasMore ?? false,
      currentPage: nextPage,
      unreadCount: cs.unreadCount,
    ));
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final cs = state;
    if (cs is! NotificationsLoaded) return;

    final (success, failure) = await _repository.markAsRead(event.id);
    if (success) {
      final updated = cs.notifications.map((n) {
        if (n.id == event.id) {
          return NotificationEntity(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final newUnread = cs.unreadCount > 0 ? cs.unreadCount - 1 : 0;
      emit(cs.copyWith(notifications: updated, unreadCount: newUnread));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final cs = state;
    if (cs is! NotificationsLoaded) return;

    final (success, _) = await _repository.markAllAsRead();
    if (success) {
      final updated = cs.notifications.map((n) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      emit(cs.copyWith(notifications: updated, unreadCount: 0));
    }
  }

  Future<void> _onDelete(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    final cs = state;
    if (cs is! NotificationsLoaded) return;

    final target = cs.notifications.firstWhere((n) => n.id == event.id);
    final (success, _) = await _repository.deleteNotification(event.id);
    if (success) {
      final updated = cs.notifications.where((n) => n.id != event.id).toList();
      final newUnread = (!target.isRead && cs.unreadCount > 0) ? cs.unreadCount - 1 : cs.unreadCount;
      emit(cs.copyWith(notifications: updated, unreadCount: newUnread));
    }
  }
}
