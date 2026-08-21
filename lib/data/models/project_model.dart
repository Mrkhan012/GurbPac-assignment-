import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.orgId,
    required super.name,
    required super.description,
    super.taskCount = 0,
    super.status = 'active',
    super.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      taskCount: json['task_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'description': description,
      'task_count': taskCount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      orgId: project.orgId,
      name: project.name,
      description: project.description,
      taskCount: project.taskCount,
      status: project.status,
      createdAt: project.createdAt,
    );
  }
}
