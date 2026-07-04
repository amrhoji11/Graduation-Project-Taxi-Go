import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/notifications/cubit/notification_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/rating_screen.dart';
import 'package:taxi_go_new/features/realtime/cubit/realtime_trip_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
    context.read<RealtimeTripCubit>().connectToTripHub();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RealtimeTripCubit, RealtimeTripState>(
      listener: (context, state) {
        // The hub also pushes a connection-status ping with no real
        // notification id (`NotificationHub.OnConnectedAsync`) - ignore it,
        // only refresh on an actual `ReceiveNotification` push.
        if (state is RealtimeTripUpdated &&
            state.eventName == 'ReceiveNotification') {
          final data = state.data;
          final isSystemMessage = data is List &&
              data.isNotEmpty &&
              data.first is Map &&
              (data.first as Map)['isSystemMessage'] == true;

          if (!isSystemMessage) {
            context.read<NotificationCubit>().loadNotifications();
          }
        }
      },
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final unreadCount =
              state is NotificationsLoaded ? state.unreadCount : 0;
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.notificationsTitleWithCount(unreadCount)),
              actions: [
                TextButton(
                  onPressed: unreadCount == 0
                      ? null
                      : () => context.read<NotificationCubit>().markAllAsRead(),
                  child: Text(
                    l10n.notificationsReadAll,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    if (state is NotificationLoading || state is NotificationInitial) {
      return const AppLoading();
    }

    if (state is NotificationFailure) {
      return AppErrorState(
        message: state.message,
        onRetry: () => context.read<NotificationCubit>().loadNotifications(),
      );
    }

    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        return AppEmptyState(
          icon: Icons.notifications_none_rounded,
          title: l10n.notificationsEmptyTitle,
          subtitle: l10n.notificationsEmptySubtitle,
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.notifications.length,
          itemBuilder: (context, index) {
            final notification = state.notifications[index];

            return _NotificationCard(
              notification: notification,
              onRead: () =>
                  context.read<NotificationCubit>().markAsRead(notification.id),
              onTap: notification.type == 'RateTrip' && notification.orderId != null
                  ? () {
                      if (!notification.isRead) {
                        context.read<NotificationCubit>().markAsRead(notification.id);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RatingScreen(orderId: notification.orderId!),
                        ),
                      );
                    }
                  : null,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onRead;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notification,
    required this.onRead,
    this.onTap,
  });

  IconData get _icon {
    if (notification.type.startsWith('Trip')) return Icons.local_taxi;
    if (notification.type.startsWith('Order')) return Icons.receipt_long;
    if (notification.type.startsWith('Driver')) return Icons.person;
    if (notification.type == 'RateTrip') return Icons.star;
    if (notification.type == 'MessageReceived') return Icons.message;
    if (notification.type == 'Violation' || notification.type == 'Complaint') {
      return Icons.report_problem;
    }
    return Icons.notifications;
  }

  /// The backend persists `title`/`body` as literal strings at the moment a
  /// notification is created (a mix of hardcoded Arabic and English across
  /// call sites), independent of the passenger's currently selected app
  /// language - so a notification created while OSRM/whatever was in
  /// Arabic stays Arabic forever, even after switching the app to English
  /// (and vice versa). `type` is the one field that's always a stable,
  /// language-independent identifier (the enum name), so the displayed
  /// text is rendered entirely from it via the app's own l10n strings,
  /// ignoring the raw backend text - except `MessageReceived`, where the
  /// body *is* an actual chat message someone typed (real user content,
  /// not a template), so only its title is localized.
  (String title, String body) _localizedText(AppLocalizations l10n) {
    switch (notification.type) {
      case 'RateTrip':
        return (l10n.notifRateTripTitle, l10n.notifRateTripBody);
      case 'MessageReceived':
        return (l10n.notifMessageReceivedTitle, notification.body);
      case 'TripAssigned':
        return (l10n.notifTripAssignedTitle, l10n.notifTripAssignedBody);
      case 'DriverArrived':
        return (l10n.notifDriverArrivedTitle, l10n.notifDriverArrivedBody);
      case 'TripStarted':
        return (l10n.notifTripStartedTitle, l10n.notifTripStartedBody);
      case 'TripCompleted':
        return (l10n.notifTripCompletedTitle, l10n.notifTripCompletedBody);
      case 'DriverCancelledTrip':
        return (l10n.notifDriverCancelledTripTitle, l10n.notifDriverCancelledTripBody);
      case 'NewTripOffer':
        return (l10n.notifNewTripOfferTitle, l10n.notifNewTripOfferBody);
      case 'DriverRejectedTrip':
        return (l10n.notifDriverRejectedTripTitle, l10n.notifDriverRejectedTripBody);
      case 'DriverAcceptedTrip':
        return (l10n.notifDriverAcceptedTripTitle, l10n.notifDriverAcceptedTripBody);
      case 'PickedUp':
        return (l10n.notifPickedUpTitle, l10n.notifPickedUpBody);
      case 'OrderCreated':
        return (l10n.notifOrderCreatedTitle, l10n.notifOrderCreatedBody);
      case 'OrderCancelled':
        return (l10n.notifOrderCancelledTitle, l10n.notifOrderCancelledBody);
      case 'OrderNeedsReview':
        return (l10n.notifOrderNeedsReviewTitle, l10n.notifOrderNeedsReviewBody);
      case 'OrderReviewed':
        return (l10n.notifOrderReviewedTitle, l10n.notifOrderReviewedBody);
      case 'NoDriverFound':
        return (l10n.notifNoDriverFoundTitle, l10n.notifNoDriverFoundBody);
      case 'DelayWarning':
        return (l10n.notifDelayWarningTitle, l10n.notifDelayWarningBody);
      case 'DriverApprovalPending':
        return (l10n.notifDriverApprovalPendingTitle, l10n.notifDriverApprovalPendingBody);
      case 'DriverApproved':
        return (l10n.notifDriverApprovedTitle, l10n.notifDriverApprovedBody);
      case 'DriverRejected':
        return (l10n.notifDriverRejectedTitle, l10n.notifDriverRejectedBody);
      case 'DriverEnteredQueue':
        return (l10n.notifDriverEnteredQueueTitle, l10n.notifDriverEnteredQueueBody);
      case 'DriverLeftQueue':
        return (l10n.notifDriverLeftQueueTitle, l10n.notifDriverLeftQueueBody);
      case 'Violation':
        return (l10n.notifViolationTitle, l10n.notifViolationBody);
      case 'Complaint':
        return (l10n.notifComplaintTitle, l10n.notifComplaintBody);
      default:
        // Unknown/future type - fall back to whatever the backend sent
        // rather than silently showing nothing.
        return (notification.title, notification.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, body) = _localizedText(l10n);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? AppColors.surfaceMuted
                  : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon,
              size: 20,
              color: notification.isRead
                  ? AppColors.neutral
                  : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          notification.isRead
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: onRead,
                  child: Text(AppLocalizations.of(context)!.notificationsRead),
                ),
        ],
      ),
    );
  }
}
