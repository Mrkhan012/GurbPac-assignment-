import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
        icon = Icons.keyboard_arrow_down_rounded;
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        icon = Icons.drag_handle_rounded;
        break;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        icon = Icons.keyboard_arrow_up_rounded;
        break;
      case TaskPriority.urgent:
        color = AppColors.priorityUrgent;
        icon = Icons.priority_high_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            priority.label,
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
