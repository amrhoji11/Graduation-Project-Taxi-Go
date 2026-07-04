import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

/// Confirms the OTP sent by `registerPassenger`/`registerDriver`, which
/// actually creates the account row in the database. This is a separate
/// step from login: the backend's confirm-register endpoints never return
/// an access/refresh token, so after the account is created here, the user
/// is sent back to [LoginScreen] to request a *second*, separate login OTP.
class RegisterOtpScreen extends StatefulWidget {
  final RegisteringRole role;
  final String countryCode;
  final String phoneNumber;

  const RegisterOtpScreen({
    super.key,
    required this.role,
    required this.countryCode,
    required this.phoneNumber,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _confirm() {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.authEnterOtp)),
      );
      return;
    }

    final cubit = context.read<AuthCubit>();

    if (widget.role == RegisteringRole.passenger) {
      cubit.confirmRegisterPassenger(
        countryCode: widget.countryCode,
        phoneNumber: widget.phoneNumber,
        otp: otp,
      );
    } else {
      cubit.confirmRegisterDriver(
        countryCode: widget.countryCode,
        phoneNumber: widget.phoneNumber,
        otp: otp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterConfirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                initialPhoneNumber: widget.phoneNumber,
              ),
            ),
            (route) => false,
          );
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.authConfirmRegistration)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.authEnterVerificationCode,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.authCodeSentTo} ${widget.countryCode}${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  label: l10n.settingsOtpCode,
                  hint: '••••••',
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: l10n.commonConfirm,
                  isLoading: isLoading,
                  onPressed: _confirm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
