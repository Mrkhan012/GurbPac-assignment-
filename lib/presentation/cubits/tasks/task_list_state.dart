import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListSuccess extends TaskListState {
  final List<TaskItem> tasks;
  final List<User> orgMembers;
  final TaskStatus? statusFilter;
  final TaskPriority? priorityFilter;
  final String? assigneeFilter;
  final String? searchQuery;
  final String? projectId;

  const TaskListSuccess({
    required this.tasks,
    this.orgMembers = const [],
    this.statusFilter,
    this.priorityFilter,
    this.assigneeFilter,
    this.searchQuery,
    this.projectId,
  });

  TaskListSuccess copyWith({
    List<TaskItem>? tasks,
    List<User>? orgMembers,
    TaskStatus? statusFilter,
    bool clearStatusFilter = false,
    TaskPriority? priorityFilter,
    bool clearPriorityFilter = false,
    String? assigneeFilter,
    bool clearAssigneeFilter = false,
    String? searchQuery,
    String? projectId,
  }) {
    return TaskListSuccess(
      tasks: tasks ?? this.tasks,
      orgMembers: orgMembers ?? this.orgMembers,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      priorityFilter: clearPriorityFilter ? null : (priorityFilter ?? this.priorityFilter),
      assigneeFilter: clearAssigneeFilter ? null : (assigneeFilter ?? this.assigneeFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      projectId: projectId ?? this.projectId,
    );
  }

  bool get hasActiveFilters =>
      statusFilter != null ||
      priorityFilter != null ||
      assigneeFilter != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  @override
  List<Object?> get props => [
        tasks,
        orgMembers,
        statusFilter,
        priorityFilter,
        assigneeFilter,
        searchQuery,
        projectId,
      ];
}

class TaskListEmpty extends TaskListState {
  final String message;
  final bool hasActiveFilters;

  const TaskListEmpty([
    this.message = 'No tasks found.',
    this.hasActiveFilters = false,
  ]);

  @override
  List<Object?> get props => [message, hasActiveFilters];
}

class TaskListError extends TaskListState {
  final String message;
  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}
