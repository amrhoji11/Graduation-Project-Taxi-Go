/// Maps to `VehiclesResponseDto` returned by the backend `VehiclesController`.
enum VehicleSize {
  small,
  medium,
  large;

  static VehicleSize fromValue(dynamic value) {
    if (value is int) {
      switch (value) {
        case 1:
          return VehicleSize.medium;
        case 2:
          return VehicleSize.large;
        default:
          return VehicleSize.small;
      }
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'medium':
          return VehicleSize.medium;
        case 'large':
          return VehicleSize.large;
      }
    }

    return VehicleSize.small;
  }

  /// Index expected by the backend (`Enums` enum: Small=0, Medium=1, Large=2).
  int get apiValue => index;

  String get label {
    switch (this) {
      case VehicleSize.small:
        return 'Small';
      case VehicleSize.medium:
        return 'Medium';
      case VehicleSize.large:
        return 'Large';
    }
  }
}

class VehicleModel {
  final int id;
  final String plateNumber;
  final String make;
  final String model;
  final String color;
  final VehicleSize vehicleSize;
  final int seats;
  final int? year;
  final bool isActive;
  final bool isCurrent;
  final String? driverId;
  final String? driverName;
  final String? platePhotoUrl;

  const VehicleModel({
    required this.id,
    required this.plateNumber,
    this.make = '',
    required this.model,
    required this.color,
    this.vehicleSize = VehicleSize.small,
    this.seats = 0,
    this.year,
    this.isActive = true,
    this.isCurrent = true,
    this.driverId,
    this.driverName,
    this.platePhotoUrl,
  });

  String get type => model;
  String get status => isActive ? 'active' : 'inactive';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: _toInt(json['id'] ?? json['vehicleId']),
      plateNumber: json['plateNumber'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      vehicleSize: VehicleSize.fromValue(json['vehicleSize']),
      seats: _toInt(json['seats']),
      year: _toIntNullable(json['year']),
      isActive: json['isActive'] ?? true,
      isCurrent: json['isCurrent'] ?? true,
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'],
      platePhotoUrl: json['platePhotoUrl'],
    );
  }

  VehicleModel copyWith({
    int? id,
    String? plateNumber,
    String? make,
    String? model,
    String? color,
    VehicleSize? vehicleSize,
    int? seats,
    int? year,
    bool? isActive,
    bool? isCurrent,
    String? driverId,
    String? driverName,
    String? platePhotoUrl,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      color: color ?? this.color,
      vehicleSize: vehicleSize ?? this.vehicleSize,
      seats: seats ?? this.seats,
      year: year ?? this.year,
      isActive: isActive ?? this.isActive,
      isCurrent: isCurrent ?? this.isCurrent,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      platePhotoUrl: platePhotoUrl ?? this.platePhotoUrl,
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
