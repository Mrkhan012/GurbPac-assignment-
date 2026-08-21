import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/core/network/simulation_manager.dart';
import 'package:gurbpac/data/datasources/mock_data_source_impl.dart';
import 'package:gurbpac/data/repositories/task_repository_impl.dart';
import 'package:gurbpac/data/repositories/user_repository_impl.dart';
import 'package:gurbpac/domain/entities/task.dart';
import 'package:gurbpac/domain/usecases/task_usecases.dart';
import 'auth_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimulationManager simulationManager;
  late FakeStorageService fakeStorageService;
  late MockDataSourceImpl mockDataSource;
  late TaskRepositoryImpl taskRepository;
  late UserRepositoryImpl userRepository;
  late TaskUseCases taskUseCases;

  setUp(() {
    simulationManager = SimulationManager()..delayMilliseconds = 0;
    fakeStorageService = FakeStorageService();
    mockDataSource = MockDataSourceImpl(
      simulationManager: simulationManager,
      storageService: fakeStorageService,
    );
    taskRepository = TaskRepositoryImpl(
      dataSource: mockDataSource,
      storageService: fakeStorageService,
    );
    userRepository = UserRepositoryImpl(dataSource: mockDataSource);
    taskUseCases = TaskUseCases(taskRepository, userRepository);
  });

  group('Task Filtering & Search Logic', () {
    test('Filters tasks by status', () async {
      final doneTasks = await taskUseCases.getTasks(
        orgId: 'org_a1b2c3',
        status: TaskStatus.done,
      );
      expect(doneTasks, isNotEmpty);
      expect(doneTasks.every((t) => t.status == TaskStatus.done), isTrue);
    });

    test('Filters tasks by priority', () async {
      final urgentTasks = await taskUseCases.getTasks(
        orgId: 'org_a1b2c3',
        priority: TaskPriority.urgent,
      );
      expect(urgentTasks, isNotEmpty);
      expect(urgentTasks.every((t) => t.priority == TaskPriority.urgent), isTrue);
    });

    test('Filters tasks by assignee', () async {
      final assignedTasks = await taskUseCases.getTasks(
        orgId: 'org_a1b2c3',
        assigneeId: 'user_002',
      );
      expect(assignedTasks, isNotEmpty);
      expect(assignedTasks.every((t) => t.assigneeId == 'user_002'), isTrue);
    });

    test('Filters unassigned tasks', () async {
      final unassigned = await taskUseCases.getTasks(
        orgId: 'org_a1b2c3',
        assigneeId: 'unassigned',
      );
      expect(unassigned, isNotEmpty);
      expect(unassigned.every((t) => t.assigneeId == null), isTrue);
    });

    test('Searches tasks by title keyword', () async {
      final searchResults = await taskUseCases.getTasks(
        orgId: 'org_a1b2c3',
        searchQuery: 'Figma',
      );
      expect(searchResults.length, 1);
      expect(searchResults.first.title, contains('Figma'));
    });
  });
}
