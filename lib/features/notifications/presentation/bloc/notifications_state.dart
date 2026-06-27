part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final PaginationMeta? meta;
  final bool hasMore;
  final int currentPage;
  final int unreadCount;
  final bool isLoadingMore;

  const NotificationsLoaded({
    required this.notifications,
    this.meta,
    this.hasMore = false,
    this.currentPage = 1,
    this.unreadCount = 0,
    this.isLoadingMore = false,
  });

  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    PaginationMeta? meta,
    bool? hasMore,
    int? currentPage,
    int? unreadCount,
    bool? isLoadingMore,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      meta: meta ?? this.meta,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [notifications, meta, hasMore, currentPage, unreadCount, isLoadingMore];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
