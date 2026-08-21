import '../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/user_repository.dart';

class TaskUseCases {
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;

  TaskUseCases(this._taskRepository, this._userRepository);

  Future<List<TaskItem>> getTasks({
    String? projectId,
    String? orgId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? searchQuery,
  }) {
    return _taskRepository.getTasks(
      projectId: projectId,
      orgId: orgId,
      status: status,
      priority: priority,
      assigneeId: assigneeId,
      searchQuery: searchQuery,
    );
  }

  Future<TaskItem> getTaskById(String taskId) {
    return _taskRepository.getTaskById(taskId);
  }

  Future<TaskItem> createTask(TaskItem task) {
    return _taskRepository.createTask(task);
  }

  Future<TaskItem> updateTask(TaskItem task) {
    return _taskRepository.updateTask(task);
  }

  Future<void> deleteTask(String taskId) {
    return _taskRepository.deleteTask(taskId);
  }

  Future<TaskItem> assignTask({
    required String taskId,
    required String? assigneeId,
    required String orgId,
  }) async {
    if (assigneeId != null) {
      final members = await _userRepository.getOrgMembers(orgId);
      final isMember = members.any((u) => u.id == assigneeId);
      if (!isMember) {
        throw const ValidationFailure('Validation error: Cannot assign user from a different organization.');
      }
    }
    return _taskRepository.assignTask(
      taskId: taskId,
      assigneeId: assigneeId,
      orgId: orgId,
    );
  }

  Future<List<TaskComment>> getComments(String taskId) {
    return _taskRepository.getComments(taskId);
  }

  Future<TaskComment> addComment({
    required String taskId,
    required String authorId,
    required String body,
  }) {
    return _taskRepository.addComment(
      taskId: taskId,
      authorId: authorId,
      body: body,
    );
  }
}
