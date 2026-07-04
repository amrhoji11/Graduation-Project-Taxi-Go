/// One waypoint on a drawable route line - matches the backend's
/// `RoutePointDto`, shared by the admin current-trips map, the driver trip
/// map, and the passenger order-detail map.
class RoutePointModel {
  final double lat;
  final double lng;

  const RoutePointModel({required this.lat, required this.lng});

  factory RoutePointModel.fromJson(Map<String, dynamic> json) {
    return RoutePointModel(
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
