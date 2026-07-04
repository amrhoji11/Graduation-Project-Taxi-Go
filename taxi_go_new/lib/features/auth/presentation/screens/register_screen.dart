import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/auth/presentation/screens/register_otp_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  /// Same constant/comment as `LoginScreen` - backend concatenates this
  /// directly with the local number, so it must already include the `+`.
  static const String _countryCode = '+970';

  RegisteringRole _role = RegisteringRole.passenger;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _register() {
    final l10n = AppLocalizations.of(context)!;
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    // Backend `RegisterPassengerRequest`/`RegisterDriverRequest` enforce
    // [MinLength(3)] on both name fields.
    if (firstName.length < 3 || lastName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authNameTooShort)),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginEnterPhone)),
      );
      return;
    }

    final cubit = context.read<AuthCubit>();

    if (_role == RegisteringRole.passenger) {
      cubit.registerPassenger(
        firstName: firstName,
        lastName: lastName,
        countryCode: _countryCode,
        phoneNumber: phone,
        address: address.isEmpty ? null : address,
      );
    } else {
      cubit.registerDriver(
        firstName: firstName,
        lastName: lastName,
        countryCode: _countryCode,
        phoneNumber: phone,
        address: address.isEmpty ? null : address,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterOtpScreen(
                role: state.role,
                countryCode: state.countryCode,
                phoneNumber: state.phoneNumber,
              ),
            ),
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
          appBar: AppBar(title: Text(l10n.authCreateAccount)),
          body: SafeArea(
            child: SingleChildScrollView(
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
                      Icons.person_add_alt_1_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.authIAmA,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<RegisteringRole>(
                    segments: [
                      ButtonSegment(
                        value: RegisteringRole.passenger,
                        label: Text(l10n.commonPassenger),
                        icon: const Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: RegisteringRole.driver,
                        label: Text(l10n.commonDriver),
                        icon: const Icon(Icons.local_taxi_outlined),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (selection) {
                      setState(() => _role = selection.first);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: firstNameController,
                    label: l10n.authFirstName,
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: lastNameController,
                    label: l10n.authLastName,
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: addressController,
                    label: l10n.authAddressOptional,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: l10n.loginSendOtp,
                    isLoading: isLoading,
                    onPressed: _register,
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
