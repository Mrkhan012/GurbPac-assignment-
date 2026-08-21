import '../models/auth_token_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/organization_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

abstract class MockDataSource {
  Future<void> init();

  Future<({UserModel user, AuthTokenModel token})> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String orgId,
  });

  Future<AuthTokenModel> refreshToken(String refreshToken);

  Future<List<OrganizationModel>> getOrganizations();
  Future<List<UserModel>> getOrgMembers(String orgId);
  Future<UserModel> getUserById(String userId);

  Future<List<ProjectModel>> getProjects({required String orgId});
  Future<ProjectModel> getProjectById(String projectId);
  Future<ProjectModel> createProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject(String projectId);

  Future<List<TaskModel>> getTasks({
    String? projectId,
    String? orgId,
    String? status,
    String? priority,
    String? assigneeId,
    String? searchQuery,
  });
  Future<TaskModel> getTaskById(String taskId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<TaskModel> assignTask({required String taskId, required String? assigneeId});

  Future<List<CommentModel>> getComments(String taskId);
  Future<CommentModel> addComment({required String taskId, required String authorId, required String body});

  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markNotificationRead(String notificationId);
}
