import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/notification_model.dart';
import 'package:taxi_go_new/repositories/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationCubit({
    required this.notificationRepository,
  }) : super(const NotificationInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationLoading());

    try {
      final notifications = await notificationRepository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationFailure(message: e.toString()));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await notificationRepository.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      emit(NotificationFailure(message: e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationRepository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      emit(NotificationFailure(message: e.toString()));
    }
  }
}
