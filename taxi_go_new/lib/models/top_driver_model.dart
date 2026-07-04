/// Matches `TopDriverDto` returned by `GET /api/Admin/top-drivers`.
class TopDriverModel {
  final String driverId;
  final String driverName;
  final int completedTrips;
  final double avgRating;
  final int violationsCount;
  final double score;

  const TopDriverModel({
    required this.driverId,
    required this.driverName,
    required this.completedTrips,
    required this.avgRating,
    required this.violationsCount,
    required this.score,
  });

  factory TopDriverModel.fromJson(Map<String, dynamic> json) {
    return TopDriverModel(
      driverId: (json['driverId'] ?? '').toString(),
      driverName: json['driverName'] ?? '',
      completedTrips: json['completedTrips'] ?? 0,
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      violationsCount: json['violationsCount'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}
