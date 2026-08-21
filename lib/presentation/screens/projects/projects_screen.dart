import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/projects/project_list_cubit.dart';
import '../../cubits/projects/project_list_state.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/project_card.dart';
import '../../widgets/state_views.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    final user = authState.user;
    final orgId = user.orgId ?? 'org_a1b2c3';

    return BlocBuilder<ProjectListCubit, ProjectListState>(
      builder: (context, state) {
        if (state is ProjectListLoading) {
          return const LoadingView(message: 'Loading projects...');
        }

        if (state is ProjectListError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<ProjectListCubit>().loadProjects(orgId),
          );
        }

        if (state is ProjectListEmpty) {
          return EmptyView(
            title: 'No Projects Found',
            subtitle: 'Get started by creating your first project in this organization.',
            icon: Icons.folder_open_rounded,
            action: user.isAdmin
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.projectForm, arguments: {'orgId': orgId}),
                  )
                : null,
          );
        }

        if (state is ProjectListSuccess) {
          return RefreshIndicator(
            onRefresh: () => context.read<ProjectListCubit>().loadProjects(orgId),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.projects.length,
              itemBuilder: (context, index) {
                final project = state.projects[index];
                return ProjectCard(
                  project: project,
                  canManage: user.isAdmin,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.projectDetail,
                    arguments: project.id,
                  ),
                  onEdit: () => Navigator.pushNamed(
                    context,
                    AppRoutes.projectForm,
                    arguments: {'orgId': orgId, 'project': project},
                  ),
                  onDelete: () async {
                    final confirm = await ConfirmationDialog.show(
                      context,
                      title: 'Delete Project',
                      content: 'Are you sure you want to delete "${project.name}" and all of its tasks?',
                      confirmText: 'Delete',
                      isDestructive: true,
                    );
                    if (confirm == true && context.mounted) {
                      context.read<ProjectListCubit>().deleteProject(
                            projectId: project.id,
                            orgId: orgId,
                            currentUser: user,
                          );
                    }
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
