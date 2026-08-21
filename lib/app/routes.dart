import 'package:flutter/material.dart';
import '../domain/entities/project.dart';
import '../domain/entities/task.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/projects/project_detail_screen.dart';
import '../presentation/screens/projects/project_form_screen.dart';
import '../presentation/screens/projects/projects_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/tasks/task_detail_screen.dart';
import '../presentation/screens/tasks/task_form_screen.dart';
import '../presentation/screens/tasks/tasks_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectDetail = '/project-detail';
  static const String projectForm = '/project-form';
  static const String tasks = '/tasks';
  static const String taskDetail = '/task-detail';
  static const String taskForm = '/task-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case projects:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: ProjectsScreen()));
      case projectDetail:
        final projectId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId));
      case projectForm:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ProjectFormScreen(
            orgId: args['orgId'] as String? ?? 'org_a1b2c3',
            project: args['project'] as Project?,
          ),
        );
      case tasks:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Tasks')),
            body: const TasksScreen(),
          ),
        );
      case taskDetail:
        final taskId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: taskId));
      case taskForm:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => TaskFormScreen(
            task: args['task'] as TaskItem?,
            projectId: args['projectId'] as String?,
            orgId: args['orgId'] as String?,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
