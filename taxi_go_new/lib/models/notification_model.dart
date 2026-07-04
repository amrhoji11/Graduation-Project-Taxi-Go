/// Matches `NotificationDto` (`GET /Notifications`) and the SignalR
/// `ReceiveNotification` push payload - both shapes are deliberately
/// identical on the backend (`NotificationRepository.SendNotificationAsync`),
/// so one parser covers both the REST history and the live push.
///
/// `type` is the enum's *name* (e.g. "DriverArrived"), not a number - this
/// DTO is one of the few with `[JsonConverter(typeof(JsonStringEnumConverter))]`
/// on the backend, unlike Order/Trip statuses which serialize as raw ints.
class NotificationModel {
  final int id;
  final String type;
  final int? orderId;
  final int? tripId;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    this.orderId,
    this.tripId,
    required this.title,
    required this.body,
    this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _toInt(json['notificationId'] ?? json['id']),
      type: json['type']?.toString() ?? '',
      orderId: _toIntNullable(json['orderId']),
      tripId: _toIntNullable(json['tripId']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isRead: json['isRead'] ?? false,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
