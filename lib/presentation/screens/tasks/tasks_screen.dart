import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/tasks/task_list_cubit.dart';
import '../../cubits/tasks/task_list_state.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/state_views.dart';
import '../../widgets/task_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    final orgId = authState.user.orgId ?? 'org_a1b2c3';

    return BlocBuilder<TaskListCubit, TaskListState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildSearchAndFilterBar(context, state),
            Expanded(child: _buildTaskListContent(context, state, orgId)),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context, TaskListState state) {
    final hasFilters = (state is TaskListSuccess && state.hasActiveFilters) ||
        (state is TaskListEmpty && state.hasActiveFilters);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => context.read<TaskListCubit>().setFilter(search: val),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: Badge(
              isLabelVisible: hasFilters,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: () => _openFilterSheet(context, state),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context, TaskListState state) {
    if (state is! TaskListSuccess) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterSheet(
        initialStatus: state.statusFilter,
        initialPriority: state.priorityFilter,
        initialAssignee: state.assigneeFilter,
        orgMembers: state.orgMembers,
        onApply: (s, p, a) {
          context.read<TaskListCubit>().setFilter(
                status: s,
                clearStatus: s == null,
                priority: p,
                clearPriority: p == null,
                assigneeId: a,
                clearAssignee: a == null,
              );
        },
        onClear: () => context.read<TaskListCubit>().clearAllFilters(),
      ),
    );
  }

  Widget _buildTaskListContent(BuildContext context, TaskListState state, String orgId) {
    if (state is TaskListLoading) {
      return const LoadingView(message: 'Loading tasks...');
    }

    if (state is TaskListError) {
      return ErrorView(
        message: state.message,
        onRetry: () => context.read<TaskListCubit>().loadTasks(orgId: orgId),
      );
    }

    if (state is TaskListEmpty) {
      return EmptyView(
        title: 'No Tasks Found',
        subtitle: state.hasActiveFilters
            ? 'Try changing or clearing your filters.'
            : 'Get started by creating a new task.',
        action: state.hasActiveFilters
            ? OutlinedButton(
                onPressed: () => context.read<TaskListCubit>().clearAllFilters(),
                child: const Text('Clear Filters'),
              )
            : null,
      );
    }

    if (state is TaskListSuccess) {
      return RefreshIndicator(
        onRefresh: () => context.read<TaskListCubit>().loadTasks(orgId: orgId, retainFilters: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.tasks.length,
          itemBuilder: (context, index) {
            final task = state.tasks[index];
            final assignee = state.orgMembers.where((m) => m.id == task.assigneeId).firstOrNull;

            return TaskCard(
              task: task,
              assignee: assignee,
              onTap: () => Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: task.id),
              onStatusChanged: (newStatus) {
                context.read<TaskListCubit>().updateTaskStatus(task.id, newStatus);
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
