import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/project_usecases.dart';
import '../../../domain/usecases/task_usecases.dart';
import 'project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectUseCases _projectUseCases;
  final TaskUseCases _taskUseCases;

  ProjectDetailCubit({
    required ProjectUseCases projectUseCases,
    required TaskUseCases taskUseCases,
  })  : _projectUseCases = projectUseCases,
        _taskUseCases = taskUseCases,
        super(ProjectDetailInitial());

  Future<void> loadProjectDetail(String projectId) async {
    emit(ProjectDetailLoading());
    try {
      final project = await _projectUseCases.getProjectById(projectId);
      final tasks = await _taskUseCases.getTasks(projectId: projectId);

      final counts = <TaskStatus, int>{
        TaskStatus.todo: 0,
        TaskStatus.inProgress: 0,
        TaskStatus.review: 0,
        TaskStatus.done: 0,
      };

      for (var task in tasks) {
        counts[task.status] = (counts[task.status] ?? 0) + 1;
      }

      emit(ProjectDetailSuccess(
        project: project,
        tasks: tasks,
        statusCounts: counts,
      ));
    } on Failure catch (f) {
      emit(ProjectDetailError(f.message));
    } catch (e) {
      emit(ProjectDetailError(e.toString()));
    }
  }
}
