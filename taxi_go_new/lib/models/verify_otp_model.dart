class VerifyOtpModel {
  final String countryCode;
  final String phoneNumber;
  final String otpCode;

  const VerifyOtpModel({
    required this.countryCode,
    required this.phoneNumber,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
    };
  }
}