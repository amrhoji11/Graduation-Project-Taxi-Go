import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/driver/profile/cubit/driver_profile_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_profile_model.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverProfileCubit>().loadProfile();
  }

  void _showEditDialog(DriverProfileModel profile) {
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
                        networkUrl: profile.profilePhotoUrl,
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
                    context.read<DriverProfileCubit>().updateProfile(
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
    ).then((_) {
      firstNameController.dispose();
      lastNameController.dispose();
      addressController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverProfileCubit, DriverProfileState>(
      listener: (context, state) {
        if (state is DriverProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.commonProfileUpdated)),
          );
        }

        if (state is DriverProfileFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.driverProfileTitle),
            actions: [
              if (state is DriverProfileLoaded)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditDialog(state.profile),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DriverProfileState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is DriverProfileLoading || state is DriverProfileInitial) {
      return const AppLoading();
    }

    if (state is DriverProfileFailure) {
      return AppErrorState(
        message: state.message,
        onRetry: () => context.read<DriverProfileCubit>().loadProfile(),
      );
    }

    if (state is DriverProfileLoaded) {
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
                  backgroundImage: profile.profilePhotoUrl != null
                      ? NetworkImage(profile.profilePhotoUrl!)
                      : null,
                  child: profile.profilePhotoUrl == null
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    AppStatusChip(
                      label: profile.status.label,
                      tone: profile.isInQueue
                          ? AppStatusTone.success
                          : AppStatusTone.neutral,
                    ),
                    AppStatusChip(
                      label: profile.approvalStatus.label,
                      tone: AppStatusTone.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: _ProfileRow(
              icon: Icons.phone_outlined,
              label: l10n.commonPhone,
              value: profile.phoneNumber,
            ),
          ),
          AppCard(
            child: _ProfileRow(
              icon: Icons.home_outlined,
              label: l10n.commonAddress,
              value: profile.address ?? l10n.commonNotSet,
            ),
          ),
          if (profile.vehiclePlateNumber != null)
            AppCard(
              child: _ProfileRow(
                icon: Icons.directions_car_outlined,
                label: l10n.commonVehicle,
                value:
                    '${profile.vehicleMake ?? ''} ${profile.vehicleModel ?? ''} '
                    '(${profile.vehiclePlateNumber})',
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
