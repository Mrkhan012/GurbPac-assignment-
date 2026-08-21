import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../cubits/projects/project_list_cubit.dart';
import '../../cubits/tasks/task_list_cubit.dart';
import '../../cubits/tasks/task_list_state.dart';
import '../../widgets/task_card.dart';
import '../../widgets/user_avatar.dart';

class HomeDashboardView extends StatelessWidget {
  final User user;

  const HomeDashboardView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (user.orgId != null) {
          context.read<ProjectListCubit>().loadProjects(user.orgId!);
          context.read<TaskListCubit>().loadTasks(orgId: user.orgId);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context),
            const SizedBox(height: 20),
            _buildMetricsOverview(context),
            const SizedBox(height: 24),
            _buildRecentTasksSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          UserAvatar(name: user.name, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isAdmin ? AppColors.accent : AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.isAdmin ? 'ORG ADMIN' : 'MEMBER',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.orgId == 'org_a1b2c3' ? 'Nimbus Digital' : 'Harborlight Studios',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(BuildContext context) {
    return BlocBuilder<TaskListCubit, TaskListState>(
      builder: (context, taskState) {
        int total = 0;
        int completed = 0;
        int inProgress = 0;
        int urgent = 0;

        if (taskState is TaskListSuccess) {
          total = taskState.tasks.length;
          completed = taskState.tasks.where((t) => t.status == TaskStatus.done).length;
          inProgress = taskState.tasks.where((t) => t.status == TaskStatus.inProgress).length;
          urgent = taskState.tasks.where((t) => t.priority == TaskPriority.urgent).length;
        }

        return Column(
          children: [
            Row(
              children: [
                _buildStatCard('Total Tasks', '$total', Icons.assignment_outlined, AppColors.primary),
                const SizedBox(width: 12),
                _buildStatCard('In Progress', '$inProgress', Icons.timelapse_rounded, AppColors.secondary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Completed', '$completed', Icons.check_circle_outline_rounded, AppColors.success),
                const SizedBox(width: 12),
                _buildStatCard('Urgent', '$urgent', Icons.warning_amber_rounded, AppColors.error),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.tasks),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<TaskListCubit, TaskListState>(
          builder: (context, state) {
            if (state is TaskListSuccess) {
              final recent = state.tasks.take(4).toList();
              return Column(
                children: recent.map((t) {
                  final assignee = state.orgMembers.where((m) => m.id == t.assigneeId).firstOrNull;
                  return TaskCard(
                    task: t,
                    assignee: assignee,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: t.id),
                  );
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
