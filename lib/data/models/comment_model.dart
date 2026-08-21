import '../../domain/entities/comment.dart';

class CommentModel extends TaskComment {
  const CommentModel({
    required super.id,
    required super.taskId,
    required super.authorId,
    required super.body,
    super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      authorId: json['author_id'] as String,
      body: json['body'] as String,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'author_id': authorId,
      'body': body,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory CommentModel.fromEntity(TaskComment comment) {
    return CommentModel(
      id: comment.id,
      taskId: comment.taskId,
      authorId: comment.authorId,
      body: comment.body,
      createdAt: comment.createdAt,
    );
  }
}
