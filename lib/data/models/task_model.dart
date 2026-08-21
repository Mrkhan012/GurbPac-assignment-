import '../../domain/entities/task.dart';

class TaskModel extends TaskItem {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    super.status,
    super.priority,
    super.assigneeId,
    super.dueDate,
    super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatus.fromString(json['status'] as String?),
      priority: TaskPriority.fromString(json['priority'] as String?),
      assigneeId: json['assignee_id'] as String?,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'assignee_id': assigneeId,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskItem task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
    );
  }
}
