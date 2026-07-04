import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage();

  static final TokenStorage instance = TokenStorage();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'role';

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _role;

  Future<void> init() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    _userId = await _storage.read(key: _userIdKey);
    _role = await _storage.read(key: _roleKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? role,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _role = role;

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);

    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }

    if (role != null) {
      await _storage.write(key: _roleKey, value: role);
    }
  }

  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> saveUserRole(String role) async {
    _role = role;
    await _storage.write(key: _roleKey, value: role);
  }

  Future<void> saveUserId(String userId) async {
    _userId = userId;
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getAccessToken() async {
    _accessToken ??= await _storage.read(key: _accessTokenKey);
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    _refreshToken ??= await _storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  Future<String?> getUserRole() async {
    _role ??= await _storage.read(key: _roleKey);
    return _role;
  }

  Future<String?> getUserId() async {
    _userId ??= await _storage.read(key: _userIdKey);
    return _userId;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get role => _role;

  String? get cachedAccessToken => _accessToken;
  String? get cachedRefreshToken => _refreshToken;
  String? get cachedUserId => _userId;
  String? get cachedUserRole => _role;

  Future<bool> get isLoggedIn async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Synchronous version for use in widget `build()` methods (after
  /// `init()` has already populated the in-memory cache at app startup).
  bool get isLoggedInSync => _accessToken != null && _accessToken!.isNotEmpty;

  bool get isAdmin => _role == 'Admin';
  bool get isDriver => _role == 'Driver';
  bool get isPassenger => _role == 'Passenger';

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _role = null;

    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _roleKey);
  }

  /// Alias for [clear] - some screens call `logout()` instead of `clear()`.
  Future<void> logout() => clear();
}