class LocationModel {
  final String address;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}