import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/storage/token_storage.dart';
import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/screens/admin_home_screen.dart';
import 'package:taxi_go_new/features/auth/login/login_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/driver/screens/driver_home_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/passenger_home_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.countryCode,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authEnterOtp),
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifyOtp(
      countryCode: widget.countryCode,
      phoneNumber: widget.phoneNumber,
      otpCode: otp,
    );
  }

  void _goToHomeByRole() {
    final storage = TokenStorage.instance;

    Widget screen = const LoginScreen();

    if (storage.isAdmin) {
      screen = const AdminHomeScreen();
    } else if (storage.isDriver) {
      screen = const DriverHomeScreen();
    } else if (storage.isPassenger) {
      screen = const PassengerHomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthVerifyOtpSuccess) {
          _goToHomeByRole();
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.authVerifyOtpTitle)),
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
                  label: l10n.authVerify,
                  isLoading: isLoading,
                  onPressed: _verifyOtp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
