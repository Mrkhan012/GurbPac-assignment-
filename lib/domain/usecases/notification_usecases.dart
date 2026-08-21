import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class NotificationUseCases {
  final NotificationRepository _repository;

  NotificationUseCases(this._repository);

  Future<List<AppNotification>> getNotifications(String userId) {
    return _repository.getNotifications(userId);
  }

  Future<void> markAsRead(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
