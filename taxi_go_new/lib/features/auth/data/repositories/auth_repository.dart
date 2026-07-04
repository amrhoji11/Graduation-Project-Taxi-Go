import 'package:dio/dio.dart';
import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/core/storage/token_storage.dart';
import 'package:taxi_go_new/models/auth_model.dart';
import 'package:taxi_go_new/models/login_request_model.dart';
import 'package:taxi_go_new/models/refresh_token_model.dart';
import 'package:taxi_go_new/models/verify_otp_model.dart';

/// Talks to `TaxiApp.Backend.Api.Controllers.AccountController`
/// (base route `api/Account`). The backend has no password - everything is
/// phone + OTP via SMS. `PhoneNumber` must be sent as digits only (backend
/// regex `^\d{9,10}$`, no `+`); `CountryCode` is sent separately and is
/// concatenated server-side (`PhoneHelper.BuildInternationalPhone`).
class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({
    required this.apiClient,
  });

  Future<Response> login({
    required String countryCode,
    required String phoneNumber,
  }) async {
    final request = LoginRequestModel(
      countryCode: countryCode,
      phoneNumber: _normalizePhone(phoneNumber),
    );

    return apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
  }

  Future<AuthModel> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otpCode,
  }) async {
    final request = VerifyOtpModel(
      countryCode: countryCode,
      phoneNumber: _normalizePhone(phoneNumber),
      otpCode: otpCode,
    );

    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      data: request.toJson(),
    );

    final authModel = AuthModel.fromJson(response.data);

    await TokenStorage.instance.saveTokens(
      accessToken: authModel.accessToken,
      refreshToken: authModel.refreshToken,
      userId: authModel.userId,
      role: authModel.role,
    );

    return authModel;
  }

  /// Matches backend `RegisterPassengerRequest` exactly
  /// (`FirstName`, `LastName`, `CountryCode`, `PhoneNumber`, `Address?`).
  Future<Response> registerPassenger({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    String? address,
  }) async {
    return apiClient.post(
      ApiEndpoints.registerPassenger,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'countryCode': countryCode,
        'phoneNumber': _normalizePhone(phoneNumber),
        'address': ?address,
      },
    );
  }

  /// Matches backend `ConfirmOtpRequest` (`CountryCode`, `PhoneNumber`, `Otp`).
  Future<Response> confirmRegisterPassenger({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    return apiClient.post(
      ApiEndpoints.confirmRegisterPassenger,
      data: {
        'countryCode': countryCode,
        'phoneNumber': _normalizePhone(phoneNumber),
        'otp': otp,
      },
    );
  }

  /// Matches backend `RegisterDriverRequest` exactly (same shape as passenger).
  Future<Response> registerDriver({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    String? address,
  }) async {
    return apiClient.post(
      ApiEndpoints.registerDriver,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'countryCode': countryCode,
        'phoneNumber': _normalizePhone(phoneNumber),
        'address': ?address,
      },
    );
  }

  Future<Response> confirmRegisterDriver({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    return apiClient.post(
      ApiEndpoints.confirmRegisterDriver,
      data: {
        'countryCode': countryCode,
        'phoneNumber': _normalizePhone(phoneNumber),
        'otp': otp,
      },
    );
  }

  Future<AuthModel> refreshToken() async {
    final refreshToken = await TokenStorage.instance.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token found');
    }

    final request = RefreshTokenModel(
      refreshToken: refreshToken,
    );

    final response = await apiClient.post(
      ApiEndpoints.refreshToken,
      data: request.toJson(),
    );

    final authModel = AuthModel.fromJson(response.data);

    await TokenStorage.instance.saveTokens(
      accessToken: authModel.accessToken,
      refreshToken: authModel.refreshToken,
      userId: authModel.userId,
      role: authModel.role,
    );

    return authModel;
  }

  /// `POST /Account/request-change-phone` - backend always returns HTTP 200
  /// with a raw Arabic status string (never wrapped in `{message: ...}`),
  /// success and failure are only distinguishable by the exact string.
  Future<String> requestChangePhone({
    required String countryCode,
    required String phoneNumber,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.requestChangePhone,
      data: {
        'countryCode': countryCode,
        'phoneNumber': _normalizePhone(phoneNumber),
      },
    );

    return response.data?.toString() ?? '';
  }

  /// `POST /Account/confirm-change-phone` - returns a raw success string on
  /// 200, or throws (via `ApiClient`) on the 400 failure case.
  Future<String> confirmChangePhone({
    required String countryCode,
    required String phoneNumber,
    required String token,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.confirmChangePhone,
      data: {
        'countryCode': countryCode,
        'phoneNumber': _normalizePhone(phoneNumber),
        'token': token,
      },
    );

    return response.data?.toString() ?? '';
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.instance.getRefreshToken();

      await apiClient.post(
        ApiEndpoints.logout,
        data: {'refreshToken': refreshToken ?? ''},
      );
    } finally {
      await TokenStorage.instance.clear();
    }
  }

  /// Strips a `+countryCode`/`countryCode` prefix (if the user typed it by
  /// mistake) and a leading `0`, since the backend's `PhoneNumber` field must
  /// be local digits only (`^\d{9,10}$`, no `+`) - the country code is sent
  /// as a separate field and concatenated server-side.
  String _normalizePhone(String phoneNumber) {
    var phone = phoneNumber.trim().replaceAll(' ', '');

    if (phone.startsWith('+970')) {
      phone = phone.substring(4);
    } else if (phone.startsWith('970')) {
      phone = phone.substring(3);
    }

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    return phone;
  }
}
