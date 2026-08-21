import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/mock_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final MockDataSource _dataSource;

  NotificationRepositoryImpl({required MockDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      return await _dataSource.getNotifications(userId);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dataSource.markNotificationRead(notificationId);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
