import 'package:equatable/equatable.dart';

enum TaskStatus {
  todo('todo', 'To Do'),
  inProgress('in_progress', 'In Progress'),
  review('review', 'In Review'),
  done('done', 'Done');

  final String value;
  final String label;
  const TaskStatus(this.value, this.label);

  static TaskStatus fromString(String? val) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TaskStatus.todo,
    );
  }
}

enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  final String value;
  final String label;
  const TaskPriority(this.value, this.label);

  static TaskPriority fromString(String? val) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TaskPriority.medium,
    );
  }
}

class TaskItem extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime? createdAt;

  const TaskItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assigneeId,
    this.dueDate,
    this.createdAt,
  });

  TaskItem copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    bool clearAssignee = false,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, projectId, title, description, status, priority, assigneeId, dueDate, createdAt];
}
