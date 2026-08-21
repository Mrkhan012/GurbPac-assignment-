import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/notification_usecases.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationUseCases _notificationUseCases;

  NotificationCubit({required NotificationUseCases notificationUseCases})
      : _notificationUseCases = notificationUseCases,
        super(NotificationInitial());

  Future<void> loadNotifications(String userId) async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationUseCases.getNotifications(userId);
      if (notifications.isEmpty) {
        emit(const NotificationEmpty());
      } else {
        emit(NotificationSuccess(notifications));
      }
    } on Failure catch (f) {
      emit(NotificationError(f.message));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _notificationUseCases.markAsRead(notificationId);
      final s = state;
      if (s is NotificationSuccess) {
        final updated = s.notifications.map((n) {
          return n.id == notificationId ? n.copyWith(read: true) : n;
        }).toList();
        emit(NotificationSuccess(updated));
      }
    } on Failure catch (f) {
      emit(NotificationError(f.message));
    }
  }
}
