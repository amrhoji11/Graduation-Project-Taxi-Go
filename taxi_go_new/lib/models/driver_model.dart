/// Maps to `DriverListItemDto` returned by `GET /api/Admin/GetAllDrivers`
/// (TaxiApp.Backend AdminRepository.GetActiveDriversAsync), which joins
/// `Driver` with its `ApplicationUser` to populate `name`/`phone`.
enum DriverStatus {
  available,
  busy,
  shared,
  offline,
  rejected,
  returningToOffice,
  unknown;

  static DriverStatus fromValue(dynamic value) {
    if (value is int) {
      switch (value) {
        case 0:
          return DriverStatus.available;
        case 1:
          return DriverStatus.busy;
        case 2:
          return DriverStatus.shared;
        case 3:
          return DriverStatus.offline;
        case 4:
          return DriverStatus.rejected;
        case 5:
          return DriverStatus.returningToOffice;
      }
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'available':
          return DriverStatus.available;
        case 'busy':
          return DriverStatus.busy;
        case 'shared':
          return DriverStatus.shared;
        case 'offline':
          return DriverStatus.offline;
        case 'rejected':
          return DriverStatus.rejected;
        case 'returningtooffice':
          return DriverStatus.returningToOffice;
      }
    }

    return DriverStatus.unknown;
  }

  String get label {
    switch (this) {
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.busy:
      case DriverStatus.shared: // Legacy value - backend never assigns this anymore.
        return 'Busy';
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.rejected:
        return 'Rejected';
      case DriverStatus.returningToOffice:
        return 'Returning to office';
      case DriverStatus.unknown:
        return 'Unknown';
    }
  }
}

class DriverModel {
  final String userId;
  final String? name;
  final String? phone;
  final String? profilePhotoUrl;
  final DriverStatus status;
  final double? lastLat;
  final double? lastLng;
  final DateTime? lastSeenAt;
  final bool isDeleted;
  final bool isActive;
  final bool isBlocked;
  final double rating;
  final int ratingCount;

  const DriverModel({
    required this.userId,
    this.name,
    this.phone,
    this.profilePhotoUrl,
    this.status = DriverStatus.unknown,
    this.lastLat,
    this.lastLng,
    this.lastSeenAt,
    this.isDeleted = false,
    this.isActive = true,
    this.isBlocked = false,
    this.rating = 0,
    this.ratingCount = 0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      userId: (json['userId'] ?? '').toString(),
      name: json['name'] ?? json['fullName'] ?? json['driverName'],
      phone: json['phone'] ?? json['phoneNumber'],
      profilePhotoUrl: json['profilePhotoUrl'],
      status: DriverStatus.fromValue(json['status']),
      lastLat: _toDoubleNullable(json['lastLat']),
      lastLng: _toDoubleNullable(json['lastLng']),
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'].toString())
          : null,
      isDeleted: json['isDeleted'] ?? false,
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
