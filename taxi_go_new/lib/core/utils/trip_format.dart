/// Shared formatting for trip ETA/distance values, used by the admin
/// current-trips map and the passenger trip-tracking screen.
class TripFormat {
  TripFormat._();

  static String etaMinutes(int minutes) {
    if (minutes <= 0) return '< 1 min';
    return '$minutes min';
  }

  static String distanceMeters(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
