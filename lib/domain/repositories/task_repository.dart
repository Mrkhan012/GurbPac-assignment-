import '../entities/comment.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasks({
    String? projectId,
    String? orgId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? searchQuery,
  });

  Future<TaskItem> getTaskById(String taskId);
  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(TaskItem task);
  Future<void> deleteTask(String taskId);
  Future<TaskItem> assignTask({required String taskId, required String? assigneeId, required String orgId});

  Future<List<TaskComment>> getComments(String taskId);
  Future<TaskComment> addComment({required String taskId, required String authorId, required String body});
}
