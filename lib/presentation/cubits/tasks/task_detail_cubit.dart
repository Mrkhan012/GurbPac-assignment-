import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/task_usecases.dart';
import 'task_detail_state.dart';

class TaskDetailCubit extends Cubit<TaskDetailState> {
  final TaskUseCases _taskUseCases;
  final UserRepository _userRepository;

  TaskDetailCubit({
    required TaskUseCases taskUseCases,
    required UserRepository userRepository,
  })  : _taskUseCases = taskUseCases,
        _userRepository = userRepository,
        super(TaskDetailInitial());

  Future<void> loadTaskDetail(String taskId, String orgId) async {
    emit(TaskDetailLoading());
    try {
      final task = await _taskUseCases.getTaskById(taskId);
      final comments = await _taskUseCases.getComments(taskId);
      final members = await _userRepository.getOrgMembers(orgId);

      User? assignee;
      if (task.assigneeId != null) {
        assignee = members.where((m) => m.id == task.assigneeId).firstOrNull;
      }

      emit(TaskDetailSuccess(
        task: task,
        assignee: assignee,
        comments: comments,
        orgMembers: members,
      ));
    } on Failure catch (f) {
      emit(TaskDetailError(f.message));
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }

  Future<void> updateStatus(TaskStatus status) async {
    final s = state;
    if (s is! TaskDetailSuccess) return;

    emit(s.copyWith(isUpdating: true));
    try {
      final updated = await _taskUseCases.updateTask(s.task.copyWith(status: status));
      emit(s.copyWith(task: updated, isUpdating: false));
    } on Failure catch (f) {
      emit(TaskDetailError(f.message));
    }
  }

  Future<void> updatePriority(TaskPriority priority) async {
    final s = state;
    if (s is! TaskDetailSuccess) return;

    emit(s.copyWith(isUpdating: true));
    try {
      final updated = await _taskUseCases.updateTask(s.task.copyWith(priority: priority));
      emit(s.copyWith(task: updated, isUpdating: false));
    } on Failure catch (f) {
      emit(TaskDetailError(f.message));
    }
  }

  Future<void> assignUser(String? userId, String orgId) async {
    final s = state;
    if (s is! TaskDetailSuccess) return;

    emit(s.copyWith(isUpdating: true));
    try {
      final updated = await _taskUseCases.assignTask(
        taskId: s.task.id,
        assigneeId: userId,
        orgId: orgId,
      );

      User? newAssignee;
      if (userId != null) {
        newAssignee = s.orgMembers.where((m) => m.id == userId).firstOrNull;
      }

      emit(s.copyWith(
        task: updated,
        assignee: newAssignee,
        clearAssignee: userId == null,
        isUpdating: false,
      ));
    } on Failure catch (f) {
      emit(TaskDetailError(f.message));
    }
  }

  Future<void> addComment({required String authorId, required String body}) async {
    final s = state;
    if (s is! TaskDetailSuccess) return;

    emit(s.copyWith(isUpdating: true));
    try {
      final newComment = await _taskUseCases.addComment(
        taskId: s.task.id,
        authorId: authorId,
        body: body,
      );
      final updatedComments = List.of(s.comments)..add(newComment);
      emit(s.copyWith(comments: updatedComments, isUpdating: false));
    } on Failure catch (f) {
      emit(TaskDetailError(f.message));
    }
  }

  Future<void> deleteTask() async {
    final s = state;
    if (s is! TaskDetailSuccess) return;

    try {
      await _taskUseCases.deleteTask(s.task.id);
    } on Failure catch (f) {
      emit(TaskDetailError(f.message));
    }
  }
}
