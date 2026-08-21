import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../entities/user.dart';
import '../repositories/project_repository.dart';

class ProjectUseCases {
  final ProjectRepository _projectRepository;

  ProjectUseCases(this._projectRepository);

  Future<List<Project>> getProjects(String orgId) {
    return _projectRepository.getProjects(orgId: orgId);
  }

  Future<Project> getProjectById(String projectId) {
    return _projectRepository.getProjectById(projectId);
  }

  Future<Project> createProject(Project project) {
    return _projectRepository.createProject(project);
  }

  Future<Project> updateProject(Project project) {
    return _projectRepository.updateProject(project);
  }

  Future<void> deleteProject({
    required String projectId,
    required User requestingUser,
  }) async {
    if (!requestingUser.isAdmin) {
      throw const PermissionFailure('Forbidden: Only org_admin can delete projects');
    }
    await _projectRepository.deleteProject(
      projectId: projectId,
      requestingUserId: requestingUser.id,
    );
  }
}
