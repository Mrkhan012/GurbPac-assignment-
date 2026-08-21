import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import 'priority_badge.dart';
import 'status_badge.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final User? assignee;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus>? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.assignee,
    required this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: task.priority, compact: true),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  StatusBadge(status: task.status, compact: true),
                  const Spacer(),
                  if (task.dueDate != null) ...[
                    Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatShort(task.dueDate),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (assignee != null)
                    Tooltip(
                      message: assignee!.name,
                      child: UserAvatar(name: assignee!.name, size: 24),
                    )
                  else
                    const Tooltip(
                      message: 'Unassigned',
                      child: Icon(Icons.account_circle_outlined, size: 22, color: AppColors.textSecondaryLight),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
