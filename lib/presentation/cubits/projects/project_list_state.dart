import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

abstract class ProjectListState extends Equatable {
  const ProjectListState();

  @override
  List<Object?> get props => [];
}

class ProjectListInitial extends ProjectListState {}

class ProjectListLoading extends ProjectListState {}

class ProjectListSuccess extends ProjectListState {
  final List<Project> projects;
  final bool isFromCache;

  const ProjectListSuccess(this.projects, {this.isFromCache = false});

  @override
  List<Object?> get props => [projects, isFromCache];
}

class ProjectListEmpty extends ProjectListState {
  final String message;
  const ProjectListEmpty([this.message = 'No projects found in this organization.']);

  @override
  List<Object?> get props => [message];
}

class ProjectListError extends ProjectListState {
  final String message;
  const ProjectListError(this.message);

  @override
  List<Object?> get props => [message];
}
