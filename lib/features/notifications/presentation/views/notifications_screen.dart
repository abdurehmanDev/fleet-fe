import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/notifications/domain/entities/notification_entity.dart';
import 'package:rangrej_fleet/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(const LoadNotifications()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsBloc>().add(const LoadMoreNotifications());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SUCCESS':
        return AppColors.success;
      case 'WARNING':
        return AppColors.warning;
      case 'ERROR':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SUCCESS':
        return Icons.check_circle_outline;
      case 'WARNING':
        return Icons.warning_amber_outlined;
      case 'ERROR':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(const MarkAllNotificationsAsRead());
                  },
                  child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return _buildShimmerList();
          }

          if (state is NotificationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NotificationsBloc>().add(const LoadNotifications()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const AppEmptyWidget(
                message: 'No notifications yet',
                icon: Icons.notifications_none,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationsBloc>().add(const LoadNotifications());
                await context.read<NotificationsBloc>().stream.firstWhere(
                      (s) => s is NotificationsLoaded || s is NotificationsError,
                    );
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppDimensions.lg),
                itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppDimensions.lg),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = state.notifications[index];
                  return _buildNotificationCard(item);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity item) {
    final typeColor = _getTypeColor(item.type);
    final icon = _getTypeIcon(item.type);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<NotificationsBloc>().add(DeleteNotification(item.id));
      },
      child: GestureDetector(
        onTap: () {
          if (!item.isRead) {
            context.read<NotificationsBloc>().add(MarkNotificationAsRead(item.id));
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: AppCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: typeColor, size: 22),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(item.createdAt),
                        style: AppTextStyles.caption.copyWith(color: AppColors.grey400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.lg),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
