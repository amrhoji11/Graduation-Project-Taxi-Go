import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/features/notifications/cubit/notification_cubit.dart';
import 'package:taxi_go_new/features/notifications/screens/notifications_screen.dart';

/// Shared notification bell + unread badge, reused by the Passenger,
/// Driver and Admin home shells - all three roles can receive real
/// notifications on the backend (`NotificationsController` has no role
/// restriction, and `NotificationHub` puts Admins in the `Office` group too).
class NotificationBadgeIcon extends StatefulWidget {
  const NotificationBadgeIcon({super.key});

  @override
  State<NotificationBadgeIcon> createState() => _NotificationBadgeIconState();
}

class _NotificationBadgeIconState extends State<NotificationBadgeIcon> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsLoaded
            ? state.unreadCount
            : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
                if (context.mounted) {
                  context.read<NotificationCubit>().loadNotifications();
                }
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
