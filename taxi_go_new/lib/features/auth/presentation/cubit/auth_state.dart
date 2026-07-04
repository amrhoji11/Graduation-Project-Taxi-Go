part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoginSuccess extends AuthState {
  final String message;
  final String countryCode;
  final String phoneNumber;

  const AuthLoginSuccess({
    required this.message,
    required this.countryCode,
    required this.phoneNumber,
  });
}

class AuthVerifyOtpSuccess extends AuthState {
  final AuthModel authModel;

  const AuthVerifyOtpSuccess({
    required this.authModel,
  });
}

enum RegisteringRole { passenger, driver }

class AuthRegisterOtpSent extends AuthState {
  final String message;
  final String countryCode;
  final String phoneNumber;
  final RegisteringRole role;

  const AuthRegisterOtpSent({
    required this.message,
    required this.countryCode,
    required this.phoneNumber,
    required this.role,
  });
}

/// Account has been created in the database (passenger row, or driver row +
/// pending `DriverApproval`). No tokens are issued here - the backend's
/// confirm-register endpoints never return a `LoginResponse`, so the user
/// must still go through `/Account/login` + `/Account/verify-otp` separately.
class AuthRegisterConfirmed extends AuthState {
  final String message;
  final RegisteringRole role;

  const AuthRegisterConfirmed({
    required this.message,
    required this.role,
  });
}

class AuthLogoutSuccess extends AuthState {
  const AuthLogoutSuccess();
}

class AuthChangePhoneRequested extends AuthState {
  final String message;

  const AuthChangePhoneRequested({required this.message});
}

class AuthChangePhoneConfirmed extends AuthState {
  final String message;

  const AuthChangePhoneConfirmed({required this.message});
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({
    required this.message,
  });
}