import 'package:equatable/equatable.dart';

class TaskComment extends Equatable {
  final String id;
  final String taskId;
  final String authorId;
  final String body;
  final DateTime? createdAt;

  const TaskComment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, taskId, authorId, body, createdAt];
}
