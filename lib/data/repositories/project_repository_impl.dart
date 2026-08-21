import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final MockDataSource _dataSource;
  final StorageService _storageService;

  ProjectRepositoryImpl({
    required MockDataSource dataSource,
    required StorageService storageService,
  })  : _dataSource = dataSource,
        _storageService = storageService;

  @override
  Future<List<Project>> getProjects({required String orgId}) async {
    try {
      final projects = await _dataSource.getProjects(orgId: orgId);
      final cacheJson = projects.map((p) => p.toJson()).toList();
      await _storageService.saveCachedData('projects_$orgId', cacheJson);
      return projects;
    } on NetworkException {
      final cached = _storageService.getCachedData('projects_$orgId');
      if (cached is List) {
        return cached.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw const NetworkFailure('No internet connection and no cached projects found.');
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
  Future<Project> getProjectById(String projectId) async {
    try {
      return await _dataSource.getProjectById(projectId);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      return await _dataSource.createProject(model);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Project> updateProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      return await _dataSource.updateProject(model);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteProject({required String projectId, required String requestingUserId}) async {
    try {
      await _dataSource.deleteProject(projectId);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
