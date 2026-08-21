import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../cubits/notifications/notification_cubit.dart';
import '../../cubits/notifications/notification_state.dart';
import '../../widgets/state_views.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const LoadingView(message: 'Loading notifications...');
        }

        if (state is NotificationError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<NotificationCubit>().loadNotifications(userId),
          );
        }

        if (state is NotificationEmpty) {
          return const EmptyView(
            title: 'No Notifications',
            subtitle: 'You are all caught up! New assignment notifications will appear here.',
            icon: Icons.notifications_none_rounded,
          );
        }

        if (state is NotificationSuccess) {
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().loadNotifications(userId),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                return Card(
                  color: notif.read ? null : AppColors.primaryLight.withValues(alpha: 0.3),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notif.read ? Colors.grey.withValues(alpha: 0.1) : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_ind_rounded,
                        color: notif.read ? Colors.grey : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormatter.formatRelative(notif.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ),
                    trailing: notif.read
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () {
                      if (!notif.read) {
                        context.read<NotificationCubit>().markAsRead(notif.id, userId);
                      }
                      if (notif.taskId.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.taskDetail,
                          arguments: notif.taskId,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
