class FavoriteLocationModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const FavoriteLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory FavoriteLocationModel.fromJson(Map<String, dynamic> json) {
    return FavoriteLocationModel(
      id: _toInt(json['id'] ?? json['favoriteLocationId']),
      name: json['name'] ?? '',
      address: json['address'] ?? json['locationName'] ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}