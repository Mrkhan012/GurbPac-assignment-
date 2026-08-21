import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/simulation_manager.dart';
import 'storage_service.dart';
import '../../data/datasources/mock_data_source.dart';
import '../../data/datasources/mock_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/notification_usecases.dart';
import '../../domain/usecases/project_usecases.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../presentation/cubits/auth/auth_cubit.dart';
import '../../presentation/cubits/debug/debug_simulation_cubit.dart';
import '../../presentation/cubits/notifications/notification_cubit.dart';
import '../../presentation/cubits/projects/project_detail_cubit.dart';
import '../../presentation/cubits/projects/project_list_cubit.dart';
import '../../presentation/cubits/tasks/task_detail_cubit.dart';
import '../../presentation/cubits/tasks/task_list_cubit.dart';
import '../../presentation/cubits/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  sl.registerLazySingleton<SimulationManager>(() => SimulationManager());

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  sl.registerLazySingleton<StorageService>(
    () => StorageServiceImpl(prefs: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<MockDataSource>(
    () => MockDataSourceImpl(simulationManager: sl(), storageService: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl(), storageService: sl()),
  );
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(dataSource: sl(), storageService: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(dataSource: sl(), storageService: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton<AuthUseCases>(() => AuthUseCases(sl()));
  sl.registerLazySingleton<ProjectUseCases>(() => ProjectUseCases(sl()));
  sl.registerLazySingleton<TaskUseCases>(() => TaskUseCases(sl(), sl()));
  sl.registerLazySingleton<NotificationUseCases>(() => NotificationUseCases(sl()));

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authUseCases: sl(), storageService: sl()),
  );
  sl.registerFactory<ProjectListCubit>(
    () => ProjectListCubit(projectUseCases: sl()),
  );
  sl.registerFactory<ProjectDetailCubit>(
    () => ProjectDetailCubit(projectUseCases: sl(), taskUseCases: sl()),
  );
  sl.registerFactory<TaskListCubit>(
    () => TaskListCubit(taskUseCases: sl(), userRepository: sl()),
  );
  sl.registerFactory<TaskDetailCubit>(
    () => TaskDetailCubit(taskUseCases: sl(), userRepository: sl()),
  );
  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(notificationUseCases: sl()),
  );
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(storageService: sl()),
  );
  sl.registerLazySingleton<DebugSimulationCubit>(
    () => DebugSimulationCubit(simulationManager: sl()),
  );
}
