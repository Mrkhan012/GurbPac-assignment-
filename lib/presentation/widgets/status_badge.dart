import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/task.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TaskStatus.todo:
        color = AppColors.statusTodo;
        break;
      case TaskStatus.inProgress:
        color = AppColors.statusInProgress;
        break;
      case TaskStatus.review:
        color = AppColors.statusReview;
        break;
      case TaskStatus.done:
        color = AppColors.statusDone;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
