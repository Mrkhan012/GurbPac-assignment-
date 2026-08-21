import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects({required String orgId});
  Future<Project> getProjectById(String projectId);
  Future<Project> createProject(Project project);
  Future<Project> updateProject(Project project);
  Future<void> deleteProject({required String projectId, required String requestingUserId});
}
