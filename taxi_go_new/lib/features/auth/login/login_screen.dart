import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/auth/presentation/screens/otp_screen.dart';
import 'package:taxi_go_new/features/auth/presentation/screens/register_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final String? initialPhoneNumber;

  const LoginScreen({super.key, this.initialPhoneNumber});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController phoneController =
      TextEditingController(text: widget.initialPhoneNumber);

  /// Backend `PhoneHelper.BuildInternationalPhone` concatenates this
  /// directly with the local number, so it must already include the `+`.
  static const String _countryCode = '+970';

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _login() {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginEnterPhone),
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(
      countryCode: _countryCode,
      phoneNumber: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                countryCode: state.countryCode,
                phoneNumber: state.phoneNumber,
              ),
            ),
          );
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
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
                      Icons.local_taxi_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.loginWelcomeBack,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 52,
                        width: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: Text(
                          _countryCode,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          hint: l10n.loginPhoneHint,
                          prefixIcon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: l10n.loginSendOtp,
                    isLoading: isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(l10n.loginNoAccount),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
