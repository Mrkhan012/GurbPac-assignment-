import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final MockDataSource _dataSource;
  final StorageService _storageService;

  TaskRepositoryImpl({
    required MockDataSource dataSource,
    required StorageService storageService,
  })  : _dataSource = dataSource,
        _storageService = storageService;

  @override
  Future<List<TaskItem>> getTasks({
    String? projectId,
    String? orgId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? searchQuery,
  }) async {
    try {
      final tasks = await _dataSource.getTasks(
        projectId: projectId,
        orgId: orgId,
        status: status?.value,
        priority: priority?.value,
        assigneeId: assigneeId,
        searchQuery: searchQuery,
      );
      if (projectId != null) {
        final cacheJson = tasks.map((t) => t.toJson()).toList();
        await _storageService.saveCachedData('tasks_$projectId', cacheJson);
      }
      return tasks;
    } on NetworkException {
      if (projectId != null) {
        final cached = _storageService.getCachedData('tasks_$projectId');
        if (cached is List) {
          return cached.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      throw const NetworkFailure('No internet connection and no cached tasks found.');
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskItem> getTaskById(String taskId) async {
    try {
      return await _dataSource.getTaskById(taskId);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    try {
      final model = TaskModel.fromEntity(task);
      return await _dataSource.createTask(model);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    try {
      final model = TaskModel.fromEntity(task);
      return await _dataSource.updateTask(model);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _dataSource.deleteTask(taskId);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskItem> assignTask({
    required String taskId,
    required String? assigneeId,
    required String orgId,
  }) async {
    try {
      return await _dataSource.assignTask(taskId: taskId, assigneeId: assigneeId);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<TaskComment>> getComments(String taskId) async {
    try {
      return await _dataSource.getComments(taskId);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskComment> addComment({
    required String taskId,
    required String authorId,
    required String body,
  }) async {
    try {
      return await _dataSource.addComment(taskId: taskId, authorId: authorId, body: body);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
