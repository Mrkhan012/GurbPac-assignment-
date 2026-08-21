import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/notifications/notification_cubit.dart';
import '../../cubits/notifications/notification_state.dart';
import '../../cubits/projects/project_list_cubit.dart';
import '../../cubits/tasks/task_list_cubit.dart';
import '../../widgets/offline_banner.dart';
import '../notifications/notifications_screen.dart';
import '../projects/projects_screen.dart';
import '../settings/settings_screen.dart';
import '../tasks/tasks_screen.dart';
import 'home_dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final orgId = authState.user.orgId ?? 'org_a1b2c3';
      context.read<ProjectListCubit>().loadProjects(orgId);
      context.read<TaskListCubit>().loadTasks(orgId: orgId);
      context.read<NotificationCubit>().loadNotifications(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated || state is SessionExpired) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
        }
      },
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final pages = [
          HomeDashboardView(user: authState.user),
          const ProjectsScreen(),
          const TasksScreen(),
          NotificationsScreen(userId: authState.user.id),
          SettingsScreen(user: authState.user),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_getTitleForIndex(_currentIndex)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadData,
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: Column(
            children: [
              const OfflineBanner(),
              Expanded(child: pages[_currentIndex]),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _buildFab(authState.user.orgId ?? ''),
        );
      },
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'TaskFlow';
      case 1:
        return 'Projects';
      case 2:
        return 'Tasks';
      case 3:
        return 'Notifications';
      case 4:
        return 'Profile & Settings';
      default:
        return 'TaskFlow';
    }
  }

  Widget _buildBottomNav() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, notifState) {
        final unreadCount = notifState is NotificationSuccess ? notifState.unreadCount : 0;

        return NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
            const NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Projects'),
            const NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'Tasks'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                child: const Icon(Icons.notifications),
              ),
              label: 'Inbox',
            ),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      },
    );
  }

  Widget? _buildFab(String orgId) {
    if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.projectForm, arguments: {'orgId': orgId}),
        child: const Icon(Icons.add),
      );
    }
    if (_currentIndex == 2 || _currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.taskForm, arguments: {'orgId': orgId}),
        child: const Icon(Icons.add_task_rounded),
      );
    }
    return null;
  }
}
