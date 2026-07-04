/// Matches `PassengerDto` returned by `GET /api/Admin/GetAllPassengers`.
class PassengerModel {
  final String userId;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? profilePhotoUrl;
  final DateTime? updatedAt;
  final bool isDeleted;
  final bool isActive;
  final bool isBlocked;
  final int completedOrdersCount;

  const PassengerModel({
    required this.userId,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.profilePhotoUrl,
    this.updatedAt,
    this.isDeleted = false,
    this.isActive = true,
    this.isBlocked = false,
    this.completedOrdersCount = 0,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      userId: (json['userId'] ?? '').toString(),
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      profilePhotoUrl: json['profilePhotoUrl'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      isDeleted: json['isDeleted'] ?? false,
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      completedOrdersCount: json['completedOrdersCount'] ?? 0,
    );
  }
}

/// Matches `PassengerProfileDto` returned by `GET /api/Admin/profile/{id}`.
class PassengerProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? address;
  final String phoneNumber;
  final String? profileImageUrl;
  final bool isActive;
  final bool isBlocked;
  final int completedOrdersCount;
  final DateTime? createdAt;

  const PassengerProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.address,
    required this.phoneNumber,
    this.profileImageUrl,
    this.isActive = true,
    this.isBlocked = false,
    this.completedOrdersCount = 0,
    this.createdAt,
  });

  factory PassengerProfileModel.fromJson(Map<String, dynamic> json) {
    return PassengerProfileModel(
      id: (json['id'] ?? '').toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      address: json['address'],
      phoneNumber: json['phoneNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      completedOrdersCount: json['completedOrdersCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
