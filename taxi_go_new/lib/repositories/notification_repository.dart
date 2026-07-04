import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/notification_model.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  /// `GET /Notifications` - backend defaults `pageNumber`/`pageSize` to
  /// 1/20 itself if omitted, but they are passed explicitly for clarity.
  Future<List<NotificationModel>> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );

    final data = response.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is List) {
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<void> markAsRead(int notificationId) async {
    await apiClient.patch(ApiEndpoints.markNotificationAsRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await apiClient.patch(ApiEndpoints.markAllNotificationsAsRead);
  }
}
