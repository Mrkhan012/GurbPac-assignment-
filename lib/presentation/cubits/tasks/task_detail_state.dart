import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';

abstract class TaskDetailState extends Equatable {
  const TaskDetailState();

  @override
  List<Object?> get props => [];
}

class TaskDetailInitial extends TaskDetailState {}

class TaskDetailLoading extends TaskDetailState {}

class TaskDetailSuccess extends TaskDetailState {
  final TaskItem task;
  final User? assignee;
  final List<TaskComment> comments;
  final List<User> orgMembers;
  final bool isUpdating;

  const TaskDetailSuccess({
    required this.task,
    this.assignee,
    required this.comments,
    this.orgMembers = const [],
    this.isUpdating = false,
  });

  TaskDetailSuccess copyWith({
    TaskItem? task,
    User? assignee,
    bool clearAssignee = false,
    List<TaskComment>? comments,
    List<User>? orgMembers,
    bool? isUpdating,
  }) {
    return TaskDetailSuccess(
      task: task ?? this.task,
      assignee: clearAssignee ? null : (assignee ?? this.assignee),
      comments: comments ?? this.comments,
      orgMembers: orgMembers ?? this.orgMembers,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [task, assignee, comments, orgMembers, isUpdating];
}

class TaskDetailError extends TaskDetailState {
  final String message;
  const TaskDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
