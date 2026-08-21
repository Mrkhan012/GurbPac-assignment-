import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../presentation/cubits/auth/auth_cubit.dart';
import '../presentation/cubits/debug/debug_simulation_cubit.dart';
import '../presentation/cubits/notifications/notification_cubit.dart';
import '../presentation/cubits/projects/project_list_cubit.dart';
import '../presentation/cubits/tasks/task_list_cubit.dart';
import '../presentation/cubits/theme/theme_cubit.dart';
import '../presentation/cubits/theme/theme_state.dart';
import 'routes.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<DebugSimulationCubit>(create: (_) => sl<DebugSimulationCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<ProjectListCubit>(create: (_) => sl<ProjectListCubit>()),
        BlocProvider<TaskListCubit>(create: (_) => sl<TaskListCubit>()),
        BlocProvider<NotificationCubit>(create: (_) => sl<NotificationCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'TaskFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
