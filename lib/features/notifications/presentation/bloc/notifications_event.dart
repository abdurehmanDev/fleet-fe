part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

class LoadMoreNotifications extends NotificationsEvent {
  const LoadMoreNotifications();
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String id;
  const MarkNotificationAsRead(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationsEvent {
  final String id;
  const DeleteNotification(this.id);
  @override
  List<Object?> get props => [id];
}
