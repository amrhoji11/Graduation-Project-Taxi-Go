/// Mirrors `PassengerTripReportDto` (`GET /Passengers/trips-report`) - one
/// completed trip in the passenger's own report (the backend only includes
/// trips that have a `CompletedAt`, there is no `status`/`price` field).
class PassengerTripReportModel {
  final String driverName;
  final String pickupLocation;
  final String destination;
  final Duration? duration;
  final int? rating;
  final String? comment;
  final DateTime completedAt;

  const PassengerTripReportModel({
    required this.driverName,
    required this.pickupLocation,
    required this.destination,
    this.duration,
    this.rating,
    this.comment,
    required this.completedAt,
  });

  factory PassengerTripReportModel.fromJson(Map<String, dynamic> json) {
    return PassengerTripReportModel(
      driverName: json['driverName'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      destination: json['destination'] ?? '',
      duration: _parseDuration(json['duration']),
      rating: json['rating'],
      comment: json['comment'],
      completedAt:
          DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  /// .NET serializes `TimeSpan` as `"[-][d.]hh:mm:ss[.fffffff]"` by default.
  static Duration? _parseDuration(dynamic value) {
    if (value == null) return null;

    final text = value.toString();
    final parts = text.split(':');
    if (parts.length < 3) return null;

    final days = parts[0].contains('.') ? parts[0].split('.') : null;
    final hours = int.tryParse(days != null ? days[1] : parts[0]) ?? 0;
    final dayCount = days != null ? int.tryParse(days[0]) ?? 0 : 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = double.tryParse(parts[2]) ?? 0;

    return Duration(
      days: dayCount,
      hours: hours,
      minutes: minutes,
      seconds: seconds.toInt(),
    );
  }
}
