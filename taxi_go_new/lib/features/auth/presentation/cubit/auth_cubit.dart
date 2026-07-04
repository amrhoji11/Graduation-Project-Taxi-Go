import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/features/auth/data/repositories/auth_repository.dart';
import 'package:taxi_go_new/models/auth_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  /// The backend `AccountController.Login` always returns HTTP 200, even
  /// for business failures (phone not registered, driver not approved yet,
  /// cooldown, SMS send failure) - this exact string is the only success
  /// case (see `AuthRepository.LoginAsync` on the backend). Any other
  /// message text means the OTP was NOT actually sent.
  static const String _otpSentMessage = 'تم إرسال رمز التحقق إلى هاتفك';

  AuthCubit({
    required this.authRepository,
  }) : super(const AuthInitial());

  Future<void> login({
    required String countryCode,
    required String phoneNumber,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await authRepository.login(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
      );

      final message = (response.data is Map ? response.data['message'] : null)
          ?.toString() ?? '';

      if (message != _otpSentMessage) {
        emit(AuthFailure(message: message.isEmpty ? 'Login failed' : message));
        return;
      }

      emit(
        AuthLoginSuccess(
          message: message,
          countryCode: countryCode,
          phoneNumber: phoneNumber,
        ),
      );
    } catch (e) {
      emit(
        AuthFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otpCode,
  }) async {
    emit(const AuthLoading());

    try {
      final AuthModel authModel = await authRepository.verifyOtp(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      emit(
        AuthVerifyOtpSuccess(
          authModel: authModel,
        ),
      );
    } catch (e) {
      emit(
        AuthFailure(
          message: e.toString(),
        ),
      );
    }
  }

  /// Backend always returns HTTP 200 with a raw status string for this
  /// action - this is the only exact string that means an OTP was actually
  /// sent (see `AuthRepository.RequestChangePhoneNumberAsync` on the backend).
  static const String _changePhoneOtpSentMessage = 'تم إرسال رمز التحقق';

  Future<void> requestChangePhone({
    required String countryCode,
    required String phoneNumber,
  }) async {
    emit(const AuthLoading());

    try {
      final message = await authRepository.requestChangePhone(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
      );

      if (message != _changePhoneOtpSentMessage) {
        emit(AuthFailure(message: message.isEmpty ? 'Request failed' : message));
        return;
      }

      emit(AuthChangePhoneRequested(message: message));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> confirmChangePhone({
    required String countryCode,
    required String phoneNumber,
    required String token,
  }) async {
    emit(const AuthLoading());

    try {
      final message = await authRepository.confirmChangePhone(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        token: token,
      );

      emit(AuthChangePhoneConfirmed(message: message));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Backend `RegisterPassengerAsync`/`RegisterDriverAsync` reuse the exact
  /// same "OTP sent" string as login, and always return HTTP 200 - even when
  /// the phone number is already registered (that case just sets a
  /// different `message`). So, like `login()` above, the message text is
  /// the only reliable success signal.
  Future<void> registerPassenger({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    String? address,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await authRepository.registerPassenger(
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        address: address,
      );

      final message = (response.data is Map ? response.data['message'] : null)
          ?.toString() ?? '';

      if (message != _otpSentMessage) {
        emit(AuthFailure(message: message.isEmpty ? 'Registration failed' : message));
        return;
      }

      emit(
        AuthRegisterOtpSent(
          message: message,
          countryCode: countryCode,
          phoneNumber: phoneNumber,
          role: RegisteringRole.passenger,
        ),
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> registerDriver({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    String? address,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await authRepository.registerDriver(
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        address: address,
      );

      final message = (response.data is Map ? response.data['message'] : null)
          ?.toString() ?? '';

      if (message != _otpSentMessage) {
        emit(AuthFailure(message: message.isEmpty ? 'Registration failed' : message));
        return;
      }

      emit(
        AuthRegisterOtpSent(
          message: message,
          countryCode: countryCode,
          phoneNumber: phoneNumber,
          role: RegisteringRole.driver,
        ),
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Backend `ConfirmPassengerRegisterAsync` only ever returns HTTP 400 for
  /// messages containing "فشل"/"انتهت" (expired) - a wrong OTP
  /// ("رمز التحقق غير صحيح") comes back as HTTP 200, so this exact success
  /// string is the only reliable signal (see `AuthRepository.
  /// ConfirmPassengerRegisterAsync` on the backend).
  static const String _passengerCreatedMessage = 'تم إنشاء الحساب بنجاح';

  /// Same caveat as above, for the driver confirm endpoint.
  static const String _driverCreatedMessage =
      'تم إنشاء حساب السائق بانتظار موافقة المكتب';

  Future<void> confirmRegisterPassenger({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await authRepository.confirmRegisterPassenger(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        otp: otp,
      );

      final message = (response.data is Map ? response.data['message'] : null)
          ?.toString() ?? '';

      if (message != _passengerCreatedMessage) {
        emit(AuthFailure(message: message.isEmpty ? 'Verification failed' : message));
        return;
      }

      emit(
        AuthRegisterConfirmed(
          message: message,
          role: RegisteringRole.passenger,
        ),
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> confirmRegisterDriver({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await authRepository.confirmRegisterDriver(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        otp: otp,
      );

      final message = (response.data is Map ? response.data['message'] : null)
          ?.toString() ?? '';

      if (message != _driverCreatedMessage) {
        emit(AuthFailure(message: message.isEmpty ? 'Verification failed' : message));
        return;
      }

      emit(
        AuthRegisterConfirmed(
          message: message,
          role: RegisteringRole.driver,
        ),
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await authRepository.logout();
      emit(const AuthLogoutSuccess());
    } catch (e) {
      emit(
        AuthFailure(
          message: e.toString(),
        ),
      );
    }
  }
}
