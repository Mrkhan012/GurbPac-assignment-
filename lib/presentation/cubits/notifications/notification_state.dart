import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<AppNotification> notifications;

  const NotificationSuccess(this.notifications);

  int get unreadCount => notifications.where((n) => !n.read).length;

  @override
  List<Object?> get props => [notifications];
}

class NotificationEmpty extends NotificationState {
  final String message;
  const NotificationEmpty([this.message = 'No notifications yet.']);

  @override
  List<Object?> get props => [message];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
