import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();

  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {}

class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailSuccess extends ProjectDetailState {
  final Project project;
  final List<TaskItem> tasks;
  final Map<TaskStatus, int> statusCounts;

  const ProjectDetailSuccess({
    required this.project,
    required this.tasks,
    required this.statusCounts,
  });

  int get totalTasks => tasks.length;
  double get completionRate => totalTasks == 0 ? 0.0 : (statusCounts[TaskStatus.done] ?? 0) / totalTasks;

  @override
  List<Object?> get props => [project, tasks, statusCounts];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
