class RefreshTokenModel {
  final String refreshToken;

  const RefreshTokenModel({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}