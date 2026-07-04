class LoginRequestModel {
  final String countryCode;
  final String phoneNumber;

  const LoginRequestModel({
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
    };
  }
}