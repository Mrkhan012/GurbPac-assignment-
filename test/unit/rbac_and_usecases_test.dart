import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/core/errors/failures.dart';
import 'package:gurbpac/core/network/simulation_manager.dart';
import 'package:gurbpac/data/datasources/mock_data_source_impl.dart';
import 'package:gurbpac/data/repositories/project_repository_impl.dart';
import 'package:gurbpac/data/repositories/task_repository_impl.dart';
import 'package:gurbpac/data/repositories/user_repository_impl.dart';
import 'package:gurbpac/domain/entities/user.dart';
import 'package:gurbpac/domain/usecases/project_usecases.dart';
import 'package:gurbpac/domain/usecases/task_usecases.dart';
import 'auth_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimulationManager simulationManager;
  late FakeStorageService fakeStorageService;
  late MockDataSourceImpl mockDataSource;
  late ProjectRepositoryImpl projectRepository;
  late TaskRepositoryImpl taskRepository;
  late UserRepositoryImpl userRepository;
  late ProjectUseCases projectUseCases;
  late TaskUseCases taskUseCases;

  setUp(() {
    simulationManager = SimulationManager()..delayMilliseconds = 0;
    fakeStorageService = FakeStorageService();
    mockDataSource = MockDataSourceImpl(
      simulationManager: simulationManager,
      storageService: fakeStorageService,
    );
    projectRepository = ProjectRepositoryImpl(
      dataSource: mockDataSource,
      storageService: fakeStorageService,
    );
    taskRepository = TaskRepositoryImpl(
      dataSource: mockDataSource,
      storageService: fakeStorageService,
    );
    userRepository = UserRepositoryImpl(dataSource: mockDataSource);
    projectUseCases = ProjectUseCases(projectRepository);
    taskUseCases = TaskUseCases(taskRepository, userRepository);
  });

  group('RBAC & Org Scoping Validation', () {
    const adminUser = User(
      id: 'user_001',
      name: 'Ava Thompson',
      email: 'ava.admin@nimbusdigital.test',
      orgId: 'org_a1b2c3',
      role: 'org_admin',
    );

    const memberUser = User(
      id: 'user_002',
      name: 'Marcus Lee',
      email: 'marcus.member@nimbusdigital.test',
      orgId: 'org_a1b2c3',
      role: 'member',
    );

    test('Org admin can successfully delete a project', () async {
      final projectsBefore = await projectUseCases.getProjects('org_a1b2c3');
      expect(projectsBefore.any((p) => p.id == 'proj_1001'), isTrue);

      await projectUseCases.deleteProject(
        projectId: 'proj_1001',
        requestingUser: adminUser,
      );

      final projectsAfter = await projectUseCases.getProjects('org_a1b2c3');
      expect(projectsAfter.any((p) => p.id == 'proj_1001'), isFalse);
    });

    test('Non-admin member attempting to delete a project throws PermissionFailure', () async {
      expect(
        () => projectUseCases.deleteProject(
          projectId: 'proj_1002',
          requestingUser: memberUser,
        ),
        throwsA(isA<PermissionFailure>()),
      );
    });

    test('Assigning an org member succeeds', () async {
      final updated = await taskUseCases.assignTask(
        taskId: 'task_2005',
        assigneeId: 'user_002',
        orgId: 'org_a1b2c3',
      );
      expect(updated.assigneeId, 'user_002');
    });

    test('Assigning user from another organization throws ValidationFailure', () async {
      expect(
        () => taskUseCases.assignTask(
          taskId: 'task_2005',
          assigneeId: 'user_004',
          orgId: 'org_a1b2c3',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
