import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../cubits/projects/project_detail_cubit.dart';
import '../../cubits/projects/project_detail_state.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/state_views.dart';
import '../../widgets/task_card.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProjectDetailCubit>()..loadProjectDetail(projectId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
                builder: (context, state) {
                  if (state is ProjectDetailLoading) {
                    return const LoadingView(message: 'Loading project details...');
                  }
                  if (state is ProjectDetailError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<ProjectDetailCubit>().loadProjectDetail(projectId),
                    );
                  }
                  if (state is ProjectDetailSuccess) {
                    return _buildContent(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.taskForm,
            arguments: {'projectId': projectId},
          ),
          icon: const Icon(Icons.add_task),
          label: const Text('Add Task'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectDetailSuccess state) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProjectDetailCubit>().loadProjectDetail(projectId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(state.project.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (state.project.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              state.project.description,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Status Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildStatusGrid(state.statusCounts),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tasks (${state.tasks.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (state.tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No tasks in this project yet.', style: TextStyle(color: AppColors.textSecondaryLight)),
              ),
            )
          else
            ...state.tasks.map(
              (task) => TaskCard(
                task: task,
                onTap: () => Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: task.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid(Map<TaskStatus, int> counts) {
    return Row(
      children: [
        _buildStatusChip('To Do', counts[TaskStatus.todo] ?? 0, AppColors.statusTodo),
        const SizedBox(width: 8),
        _buildStatusChip('In Progress', counts[TaskStatus.inProgress] ?? 0, AppColors.statusInProgress),
        const SizedBox(width: 8),
        _buildStatusChip('Review', counts[TaskStatus.review] ?? 0, AppColors.statusReview),
        const SizedBox(width: 8),
        _buildStatusChip('Done', counts[TaskStatus.done] ?? 0, AppColors.statusDone),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
