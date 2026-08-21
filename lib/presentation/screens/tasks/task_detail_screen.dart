import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/tasks/task_detail_cubit.dart';
import '../../cubits/tasks/task_detail_state.dart';
import '../../cubits/tasks/task_list_cubit.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is Authenticated ? authState.user : null;
    final orgId = currentUser?.orgId ?? 'org_a1b2c3';

    return BlocProvider(
      create: (context) => sl<TaskDetailCubit>()..loadTaskDetail(taskId, orgId),
      child: BlocConsumer<TaskDetailCubit, TaskDetailState>(
        listener: (context, state) {
          if (state is TaskDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Task Details'),
              actions: [
                if (state is TaskDetailSuccess)
                  PopupMenuButton<String>(
                    onSelected: (val) async {
                      if (val == 'edit') {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.taskForm,
                          arguments: {'task': state.task, 'orgId': orgId},
                        );
                      } else if (val == 'delete') {
                        final confirm = await ConfirmationDialog.show(
                          context,
                          title: 'Delete Task',
                          content: 'Are you sure you want to delete "${state.task.title}"?',
                          isDestructive: true,
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<TaskDetailCubit>().deleteTask();
                          if (context.mounted) {
                            context.read<TaskListCubit>().loadTasks(orgId: orgId);
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
              ],
            ),
            body: Column(
              children: [
                const OfflineBanner(),
                Expanded(child: _buildBody(context, state, currentUser, orgId)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskDetailState state, User? currentUser, String orgId) {
    if (state is TaskDetailLoading) return const LoadingView(message: 'Loading task...');
    if (state is TaskDetailError && state.message.contains('not found')) {
      return ErrorView(message: state.message);
    }
    if (state is TaskDetailSuccess) {
      return _TaskDetailContent(state: state, currentUser: currentUser, orgId: orgId);
    }
    return const SizedBox.shrink();
  }
}

class _TaskDetailContent extends StatefulWidget {
  final TaskDetailSuccess state;
  final User? currentUser;
  final String orgId;

  const _TaskDetailContent({required this.state, required this.currentUser, required this.orgId});

  @override
  State<_TaskDetailContent> createState() => _TaskDetailContentState();
}

class _TaskDetailContentState extends State<_TaskDetailContent> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.state.task;
    final assignee = widget.state.assignee;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(task.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            StatusBadge(status: task.status),
            const SizedBox(width: 8),
            PriorityBadge(priority: task.priority),
          ],
        ),
        const SizedBox(height: 16),
        if (task.description.isNotEmpty) ...[
          const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(task.description, style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
        ],
        _buildInfoCard(task, assignee),
        const SizedBox(height: 24),
        _buildStatusChanger(),
        const SizedBox(height: 24),
        _buildCommentsSection(),
      ],
    );
  }

  Widget _buildInfoCard(TaskItem task, User? assignee) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Assignee', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                InkWell(
                  onTap: _showAssigneePicker,
                  child: Row(
                    children: [
                      if (assignee != null) ...[
                        UserAvatar(name: assignee.name, size: 22),
                        const SizedBox(width: 6),
                        Text(assignee.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ] else
                        const Text('Unassigned (Tap to assign)', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Due Date', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                Text(DateFormatter.formatFull(task.dueDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssigneePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Assign Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: const Text('Unassigned'),
              onTap: () {
                context.read<TaskDetailCubit>().assignUser(null, widget.orgId);
                Navigator.pop(ctx);
              },
            ),
            ...widget.state.orgMembers.map(
              (m) => ListTile(
                leading: UserAvatar(name: m.name, size: 30),
                title: Text(m.name),
                subtitle: Text(m.role == 'org_admin' ? 'Org Admin' : 'Member'),
                onTap: () {
                  context.read<TaskDetailCubit>().assignUser(m.id, widget.orgId);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChanger() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Change Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TaskStatus.values.map((s) {
            final isSelected = widget.state.task.status == s;
            return ChoiceChip(
              label: Text(s.label),
              selected: isSelected,
              onSelected: (val) {
                if (val) context.read<TaskDetailCubit>().updateStatus(s);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments (${widget.state.comments.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...widget.state.comments.map((c) {
          final author = widget.state.orgMembers.firstWhere(
            (m) => m.id == c.authorId,
            orElse: () => User(id: c.authorId, name: 'Team Member', email: ''),
          );
          return CommentTile(comment: c, authorName: author.name);
        }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send_rounded, size: 18),
              onPressed: () {
                final body = _commentController.text.trim();
                if (body.isNotEmpty && widget.currentUser != null) {
                  context.read<TaskDetailCubit>().addComment(
                        authorId: widget.currentUser!.id,
                        body: body,
                      );
                  _commentController.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
