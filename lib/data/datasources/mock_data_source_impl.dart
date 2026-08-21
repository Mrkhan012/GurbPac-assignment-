import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/simulation_manager.dart';
import '../../core/services/storage_service.dart';
import '../models/auth_token_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/organization_model.dart';
import '../models/org_member_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import 'mock_data_source.dart';

class MockDataSourceImpl implements MockDataSource {
  final SimulationManager _simulationManager;
  final _uuid = const Uuid();

  bool _isInitialized = false;

  final List<OrganizationModel> _organizations = [];
  final List<UserModel> _users = [];
  final List<OrgMemberModel> _orgMembers = [];
  final List<ProjectModel> _projects = [];
  final List<TaskModel> _tasks = [];
  final List<CommentModel> _comments = [];
  final List<NotificationModel> _notifications = [];
  final List<Map<String, dynamic>> _testCredentials = [];
  Map<String, dynamic>? _mockLoginResponseTemplate;

  MockDataSourceImpl({
    required SimulationManager simulationManager,
    StorageService? storageService,
  }) : _simulationManager = simulationManager;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/mock_data/TaskFlow-MockData.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      _organizations.clear();
      if (data['organizations'] is List) {
        for (var item in data['organizations']) {
          _organizations.add(OrganizationModel.fromJson(item));
        }
      }

      _users.clear();
      if (data['users'] is List) {
        for (var item in data['users']) {
          _users.add(UserModel.fromJson(item));
        }
      }

      _orgMembers.clear();
      if (data['org_members'] is List) {
        for (var item in data['org_members']) {
          _orgMembers.add(OrgMemberModel.fromJson(item));
        }
      }

      _projects.clear();
      if (data['projects'] is List) {
        for (var item in data['projects']) {
          _projects.add(ProjectModel.fromJson(item));
        }
      }

      _tasks.clear();
      if (data['tasks'] is List) {
        for (var item in data['tasks']) {
          _tasks.add(TaskModel.fromJson(item));
        }
      }

      _comments.clear();
      if (data['comments'] is List) {
        for (var item in data['comments']) {
          _comments.add(CommentModel.fromJson(item));
        }
      }

      _notifications.clear();
      if (data['notifications'] is List) {
        for (var item in data['notifications']) {
          _notifications.add(NotificationModel.fromJson(item));
        }
      }

      if (data['auth_mock'] is Map) {
        final authMock = data['auth_mock'] as Map<String, dynamic>;
        _testCredentials.clear();
        if (authMock['test_credentials'] is List) {
          for (var item in authMock['test_credentials']) {
            _testCredentials.add(item as Map<String, dynamic>);
          }
        }
        _mockLoginResponseTemplate = authMock['mock_login_response'] as Map<String, dynamic>?;
      }

      _isInitialized = true;
    } catch (e) {
      throw ServerException('Failed to load mock dataset: $e');
    }
  }

  @override
  Future<({UserModel user, AuthTokenModel token})> login({
    required String email,
    required String password,
  }) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final trimmedEmail = email.trim().toLowerCase();
    final credMatch = _testCredentials.firstWhere(
      (c) => (c['email'] as String).toLowerCase() == trimmedEmail && c['password'] == password,
      orElse: () => {},
    );

    if (credMatch.isEmpty) {
      throw const AuthException('Invalid email or password');
    }

    final userMatch = _users.firstWhere(
      (u) => u.email.toLowerCase() == trimmedEmail,
      orElse: () => UserModel(
        id: 'user_${_uuid.v4().substring(0, 6)}',
        name: trimmedEmail.split('@').first,
        email: trimmedEmail,
        orgId: credMatch['org_id'] as String?,
        role: credMatch['role'] as String?,
      ),
    );

    final userWithRole = UserModel(
      id: userMatch.id,
      name: userMatch.name,
      email: userMatch.email,
      avatarUrl: userMatch.avatarUrl,
      orgId: credMatch['org_id'] as String? ?? userMatch.orgId,
      role: credMatch['role'] as String? ?? userMatch.role,
    );

    final token = AuthTokenModel(
      accessToken: _mockLoginResponseTemplate?['access_token'] ?? 'mock.access.token.${_uuid.v4().substring(0, 8)}',
      refreshToken: _mockLoginResponseTemplate?['refresh_token'] ?? 'mock.refresh.token.${_uuid.v4().substring(0, 8)}',
      accessTokenExpiresInSeconds: _mockLoginResponseTemplate?['access_token_expires_in_seconds'] ?? 900,
      refreshTokenExpiresInSeconds: _mockLoginResponseTemplate?['refresh_token_expires_in_seconds'] ?? 604800,
      issuedAt: DateTime.now(),
    );

    return (user: userWithRole, token: token);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String orgId,
  }) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final newUser = UserModel(
      id: 'user_${_uuid.v4().substring(0, 6)}',
      name: name,
      email: email,
      avatarUrl: 'https://i.pravatar.cc/150?img=${_users.length + 1}',
      orgId: orgId,
      role: 'member',
    );

    _users.add(newUser);
    _orgMembers.add(OrgMemberModel(orgId: orgId, userId: newUser.id, role: 'member'));
    _testCredentials.add({'email': email, 'password': password, 'org_id': orgId, 'role': 'member'});

    return newUser;
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    if (refreshToken.isEmpty) {
      throw const AuthException('Invalid refresh token');
    }

    return AuthTokenModel(
      accessToken: 'mock.access.token.refreshed_${_uuid.v4().substring(0, 8)}',
      refreshToken: 'mock.refresh.token.refreshed_${_uuid.v4().substring(0, 8)}',
      accessTokenExpiresInSeconds: 900,
      refreshTokenExpiresInSeconds: 604800,
      issuedAt: DateTime.now(),
    );
  }

  @override
  Future<List<OrganizationModel>> getOrganizations() async {
    await init();
    await _simulationManager.simulateNetworkCall();
    return List.unmodifiable(_organizations);
  }

  @override
  Future<List<UserModel>> getOrgMembers(String orgId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final memberEntries = _orgMembers.where((m) => m.orgId == orgId).toList();
    final result = <UserModel>[];

    for (var entry in memberEntries) {
      final user = _users.firstWhere(
        (u) => u.id == entry.userId,
        orElse: () => UserModel(id: entry.userId, name: 'User ${entry.userId}', email: '$entry.userId@test.com'),
      );
      result.add(UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        orgId: orgId,
        role: entry.role,
      ));
    }
    return result;
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw const NotFoundException('User not found'),
    );
    final member = _orgMembers.firstWhere((m) => m.userId == userId, orElse: () => const OrgMemberModel(orgId: '', userId: '', role: 'member'));
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      orgId: member.orgId.isNotEmpty ? member.orgId : user.orgId,
      role: member.role.isNotEmpty ? member.role : user.role,
    );
  }

  @override
  Future<List<ProjectModel>> getProjects({required String orgId}) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final orgProjects = _projects.where((p) => p.orgId == orgId).toList();
    return orgProjects.map((p) {
      final count = _tasks.where((t) => t.projectId == p.id).length;
      return ProjectModel.fromEntity(p.copyWith(taskCount: count));
    }).toList();
  }

  @override
  Future<ProjectModel> getProjectById(String projectId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1) throw const NotFoundException('Project not found');
    final p = _projects[index];
    final count = _tasks.where((t) => t.projectId == p.id).length;
    return ProjectModel.fromEntity(p.copyWith(taskCount: count));
  }

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final newProject = ProjectModel(
      id: project.id.isNotEmpty ? project.id : 'proj_${_uuid.v4().substring(0, 6)}',
      orgId: project.orgId,
      name: project.name,
      description: project.description,
      taskCount: 0,
      status: project.status,
      createdAt: DateTime.now(),
    );
    _projects.insert(0, newProject);
    return newProject;
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) throw const NotFoundException('Project not found');

    final updated = project.copyWith(
      taskCount: _tasks.where((t) => t.projectId == project.id).length,
    );
    _projects[index] = ProjectModel.fromEntity(updated);
    return _projects[index];
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1) throw const NotFoundException('Project not found');
    _projects.removeAt(index);
    _tasks.removeWhere((t) => t.projectId == projectId);
  }

  @override
  Future<List<TaskModel>> getTasks({
    String? projectId,
    String? orgId,
    String? status,
    String? priority,
    String? assigneeId,
    String? searchQuery,
  }) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    var result = List<TaskModel>.from(_tasks);

    if (orgId != null) {
      final orgProjectIds = _projects.where((p) => p.orgId == orgId).map((p) => p.id).toSet();
      result = result.where((t) => orgProjectIds.contains(t.projectId)).toList();
    }

    if (projectId != null) {
      result = result.where((t) => t.projectId == projectId).toList();
    }

    if (status != null && status.isNotEmpty) {
      result = result.where((t) => t.status.value == status).toList();
    }

    if (priority != null && priority.isNotEmpty) {
      result = result.where((t) => t.priority.value == priority).toList();
    }

    if (assigneeId != null) {
      if (assigneeId == 'unassigned') {
        result = result.where((t) => t.assigneeId == null || t.assigneeId!.isEmpty).toList();
      } else {
        result = result.where((t) => t.assigneeId == assigneeId).toList();
      }
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();
    }

    return result;
  }

  @override
  Future<TaskModel> getTaskById(String taskId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) throw const NotFoundException('Task not found');
    return _tasks[index];
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final newTask = TaskModel(
      id: task.id.isNotEmpty ? task.id : 'task_${_uuid.v4().substring(0, 6)}',
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    return newTask;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) throw const NotFoundException('Task not found');
    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) throw const NotFoundException('Task not found');
    _tasks.removeAt(index);
    _comments.removeWhere((c) => c.taskId == taskId);
  }

  @override
  Future<TaskModel> assignTask({required String taskId, required String? assigneeId}) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) throw const NotFoundException('Task not found');

    final updated = _tasks[index].copyWith(
      assigneeId: assigneeId,
      clearAssignee: assigneeId == null,
    );
    _tasks[index] = TaskModel.fromEntity(updated);

    if (assigneeId != null) {
      _notifications.insert(
        0,
        NotificationModel(
          id: 'notif_${_uuid.v4().substring(0, 6)}',
          userId: assigneeId,
          type: 'task_assigned',
          taskId: taskId,
          message: 'You were assigned to "${updated.title}"',
          read: false,
          createdAt: DateTime.now(),
        ),
      );
    }
    return _tasks[index];
  }

  @override
  Future<List<CommentModel>> getComments(String taskId) async {
    await init();
    await _simulationManager.simulateNetworkCall();
    return _comments.where((c) => c.taskId == taskId).toList();
  }

  @override
  Future<CommentModel> addComment({required String taskId, required String authorId, required String body}) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final newComment = CommentModel(
      id: 'cmt_${_uuid.v4().substring(0, 6)}',
      taskId: taskId,
      authorId: authorId,
      body: body,
      createdAt: DateTime.now(),
    );
    _comments.add(newComment);
    return newComment;
  }

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await init();
    await _simulationManager.simulateNetworkCall();
    return _notifications.where((n) => n.userId == userId).toList();
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await init();
    await _simulationManager.simulateNetworkCall();

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel.fromEntity(
        _notifications[index].copyWith(read: true),
      );
    }
  }
}
