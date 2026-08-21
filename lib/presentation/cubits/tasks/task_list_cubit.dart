import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/task_usecases.dart';
import 'task_list_state.dart';

class TaskListCubit extends Cubit<TaskListState> {
  final TaskUseCases _taskUseCases;
  final UserRepository _userRepository;

  TaskStatus? _currentStatus;
  TaskPriority? _currentPriority;
  String? _currentAssignee;
  String? _currentSearch;
  String? _currentProjectId;
  String? _currentOrgId;
  List<User> _members = [];

  TaskListCubit({
    required TaskUseCases taskUseCases,
    required UserRepository userRepository,
  })  : _taskUseCases = taskUseCases,
        _userRepository = userRepository,
        super(TaskListInitial());

  Future<void> loadTasks({
    String? orgId,
    String? projectId,
    bool retainFilters = false,
  }) async {
    _currentOrgId = orgId ?? _currentOrgId;
    _currentProjectId = projectId ?? _currentProjectId;

    if (!retainFilters) {
      _currentStatus = null;
      _currentPriority = null;
      _currentAssignee = null;
      _currentSearch = null;
    }

    emit(TaskListLoading());
    try {
      if (_currentOrgId != null && _members.isEmpty) {
        _members = await _userRepository.getOrgMembers(_currentOrgId!);
      }

      await _fetchFilteredTasks();
    } on Failure catch (f) {
      emit(TaskListError(f.message));
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> setFilter({
    TaskStatus? status,
    bool clearStatus = false,
    TaskPriority? priority,
    bool clearPriority = false,
    String? assigneeId,
    bool clearAssignee = false,
    String? search,
  }) async {
    if (clearStatus) {
      _currentStatus = null;
    } else if (status != null) {
      _currentStatus = status;
    }

    if (clearPriority) {
      _currentPriority = null;
    } else if (priority != null) {
      _currentPriority = priority;
    }

    if (clearAssignee) {
      _currentAssignee = null;
    } else if (assigneeId != null) {
      _currentAssignee = assigneeId;
    }

    if (search != null) {
      _currentSearch = search;
    }

    await _fetchFilteredTasks();
  }

  Future<void> clearAllFilters() async {
    _currentStatus = null;
    _currentPriority = null;
    _currentAssignee = null;
    _currentSearch = null;
    await _fetchFilteredTasks();
  }

  Future<void> _fetchFilteredTasks() async {
    final tasks = await _taskUseCases.getTasks(
      orgId: _currentOrgId,
      projectId: _currentProjectId,
      status: _currentStatus,
      priority: _currentPriority,
      assigneeId: _currentAssignee,
      searchQuery: _currentSearch,
    );

    if (tasks.isEmpty) {
      final hasFilters = _currentStatus != null ||
          _currentPriority != null ||
          _currentAssignee != null ||
          (_currentSearch != null && _currentSearch!.isNotEmpty);
      emit(TaskListEmpty('No matching tasks found.', hasFilters));
    } else {
      emit(TaskListSuccess(
        tasks: tasks,
        orgMembers: _members,
        statusFilter: _currentStatus,
        priorityFilter: _currentPriority,
        assigneeFilter: _currentAssignee,
        searchQuery: _currentSearch,
        projectId: _currentProjectId,
      ));
    }
  }

  Future<void> createTask(TaskItem task) async {
    try {
      await _taskUseCases.createTask(task);
      await loadTasks(retainFilters: true);
    } on Failure catch (f) {
      emit(TaskListError(f.message));
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final task = await _taskUseCases.getTaskById(taskId);
      await _taskUseCases.updateTask(task.copyWith(status: newStatus));
      await _fetchFilteredTasks();
    } on Failure catch (f) {
      emit(TaskListError(f.message));
    }
  }

  Future<void> updateTaskPriority(String taskId, TaskPriority newPriority) async {
    try {
      final task = await _taskUseCases.getTaskById(taskId);
      await _taskUseCases.updateTask(task.copyWith(priority: newPriority));
      await _fetchFilteredTasks();
    } on Failure catch (f) {
      emit(TaskListError(f.message));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskUseCases.deleteTask(taskId);
      await _fetchFilteredTasks();
    } on Failure catch (f) {
      emit(TaskListError(f.message));
    }
  }
}
