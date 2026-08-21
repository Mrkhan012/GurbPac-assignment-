import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/project_usecases.dart';
import 'project_list_state.dart';

class ProjectListCubit extends Cubit<ProjectListState> {
  final ProjectUseCases _projectUseCases;

  ProjectListCubit({required ProjectUseCases projectUseCases})
      : _projectUseCases = projectUseCases,
        super(ProjectListInitial());

  Future<void> loadProjects(String orgId) async {
    emit(ProjectListLoading());
    try {
      final projects = await _projectUseCases.getProjects(orgId);
      if (projects.isEmpty) {
        emit(const ProjectListEmpty());
      } else {
        emit(ProjectListSuccess(projects));
      }
    } on Failure catch (f) {
      emit(ProjectListError(f.message));
    } catch (e) {
      emit(ProjectListError(e.toString()));
    }
  }

  Future<void> createProject(Project project) async {
    try {
      await _projectUseCases.createProject(project);
      await loadProjects(project.orgId);
    } on Failure catch (f) {
      emit(ProjectListError(f.message));
    } catch (e) {
      emit(ProjectListError(e.toString()));
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _projectUseCases.updateProject(project);
      await loadProjects(project.orgId);
    } on Failure catch (f) {
      emit(ProjectListError(f.message));
    } catch (e) {
      emit(ProjectListError(e.toString()));
    }
  }

  Future<void> deleteProject({
    required String projectId,
    required String orgId,
    required User currentUser,
  }) async {
    try {
      await _projectUseCases.deleteProject(
        projectId: projectId,
        requestingUser: currentUser,
      );
      await loadProjects(orgId);
    } on Failure catch (f) {
      emit(ProjectListError(f.message));
    } catch (e) {
      emit(ProjectListError(e.toString()));
    }
  }
}
