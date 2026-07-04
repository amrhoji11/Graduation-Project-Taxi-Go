class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String role;

  const AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      role: json['role'] ?? json['userRole'] ?? '',
    );
  }
}