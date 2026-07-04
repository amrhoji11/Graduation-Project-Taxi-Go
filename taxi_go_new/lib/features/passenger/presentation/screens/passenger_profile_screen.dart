import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/passenger_profile_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/passenger_model.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() =>
      _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PassengerProfileCubit>().loadProfile();
  }

  void _showEditDialog(PassengerProfileModel profile) {
    final l10n = AppLocalizations.of(context)!;
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final addressController = TextEditingController(text: profile.address);
    File? pickedPhoto;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.commonEditProfile),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: AppAvatarPicker(
                        networkUrl: profile.profileImageUrl,
                        pickedFile: pickedPhoto,
                        onPicked: (file) =>
                            setDialogState(() => pickedPhoto = file),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: firstNameController,
                      label: l10n.authFirstName,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: lastNameController,
                      label: l10n.authLastName,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: addressController,
                      label: l10n.commonAddress,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<PassengerProfileCubit>().updateProfile(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      address: addressController.text.trim(),
                      profilePhoto: pickedPhoto,
                    );
                  },
                  child: Text(l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerProfileCubit, PassengerProfileState>(
      listener: (context, state) {
        if (state is PassengerProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.commonProfileUpdated)),
          );
        }

        if (state is PassengerProfileFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.passengerMyProfile),
            actions: [
              if (state is PassengerProfileLoaded)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditDialog(state.profile),
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(PassengerProfileState state) {
    if (state is PassengerProfileLoading || state is PassengerProfileInitial) {
      return const AppLoading();
    }

    if (state is PassengerProfileFailure) {
      return AppErrorState(
        message: state.message,
        onRetry: () => context.read<PassengerProfileCubit>().loadProfile(),
      );
    }

    if (state is PassengerProfileLoaded) {
      final profile = state.profile;

      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: profile.profileImageUrl != null
                      ? NetworkImage(profile.profileImageUrl!)
                      : null,
                  child: profile.profileImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 46,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: _ProfileRow(
              icon: Icons.phone_outlined,
              label: AppLocalizations.of(context)!.commonPhone,
              value: profile.phoneNumber,
            ),
          ),
          AppCard(
            child: _ProfileRow(
              icon: Icons.home_outlined,
              label: AppLocalizations.of(context)!.commonAddress,
              value: profile.address ?? AppLocalizations.of(context)!.commonNotSet,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}
