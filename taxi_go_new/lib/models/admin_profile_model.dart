/// Matches the anonymous object returned by `GET /api/Admin/profile`
/// (`AdminController.GetAdminProfile`): `{firstName, lastName, phoneNumber,
/// address, profilePhotoImg}`.
class AdminProfileModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? address;
  final String? profilePhotoImg;

  const AdminProfileModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.address,
    this.profilePhotoImg,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'],
      profilePhotoImg: json['profilePhotoImg'],
    );
  }
}
