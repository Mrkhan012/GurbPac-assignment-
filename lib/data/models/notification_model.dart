import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.taskId,
    required super.message,
    required super.read,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'task_assigned',
      taskId: json['task_id'] as String,
      message: json['message'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'task_id': taskId,
      'message': message,
      'read': read,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory NotificationModel.fromEntity(AppNotification notif) {
    return NotificationModel(
      id: notif.id,
      userId: notif.userId,
      type: notif.type,
      taskId: notif.taskId,
      message: notif.message,
      read: notif.read,
      createdAt: notif.createdAt,
    );
  }
}
