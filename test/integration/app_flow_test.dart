import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/core/network/simulation_manager.dart';
import 'package:gurbpac/data/datasources/mock_data_source_impl.dart';
import 'package:gurbpac/data/repositories/auth_repository_impl.dart';
import 'package:gurbpac/data/repositories/project_repository_impl.dart';
import 'package:gurbpac/data/repositories/task_repository_impl.dart';
import 'package:gurbpac/data/repositories/user_repository_impl.dart';
import 'package:gurbpac/domain/entities/task.dart';
import 'package:gurbpac/domain/usecases/auth_usecases.dart';
import 'package:gurbpac/domain/usecases/project_usecases.dart';
import 'package:gurbpac/domain/usecases/task_usecases.dart';
import '../unit/auth_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('End-to-End Flow: Login -> List Projects -> Create Task -> Assign -> Verify', () async {
    final fakeStorage = FakeStorageService();
    final simManager = SimulationManager()..delayMilliseconds = 0;
    final dataSource = MockDataSourceImpl(simulationManager: simManager, storageService: fakeStorage);

    final authRepo = AuthRepositoryImpl(dataSource: dataSource, storageService: fakeStorage);
    final projectRepo = ProjectRepositoryImpl(dataSource: dataSource, storageService: fakeStorage);
    final taskRepo = TaskRepositoryImpl(dataSource: dataSource, storageService: fakeStorage);
    final userRepo = UserRepositoryImpl(dataSource: dataSource);

    final authUseCases = AuthUseCases(authRepo);
    final projectUseCases = ProjectUseCases(projectRepo);
    final taskUseCases = TaskUseCases(taskRepo, userRepo);

    final authResult = await authUseCases.login(
      email: 'ava.admin@nimbusdigital.test',
      password: 'Password123!',
    );
    expect(authResult.user.id, 'user_001');

    final projects = await projectUseCases.getProjects(authResult.user.orgId!);
    expect(projects, isNotEmpty);
    final targetProject = projects.first;

    final newTask = await taskUseCases.createTask(
      TaskItem(
        id: '',
        projectId: targetProject.id,
        title: 'Complete Flutter assignment tests',
        description: 'Ensure all tests pass',
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
      ),
    );
    expect(newTask.id, isNotEmpty);

    final assignedTask = await taskUseCases.assignTask(
      taskId: newTask.id,
      assigneeId: 'user_002',
      orgId: authResult.user.orgId!,
    );
    expect(assignedTask.assigneeId, 'user_002');

    final comment = await taskUseCases.addComment(
      taskId: newTask.id,
      authorId: authResult.user.id,
      body: 'Great progress on this task!',
    );
    expect(comment.body, contains('Great progress'));

    final comments = await taskUseCases.getComments(newTask.id);
    expect(comments.any((c) => c.id == comment.id), isTrue);
  });
}
