import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/profile/cubit/admin_profile_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_profile_model.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProfileCubit>().getProfile();
  }

  void _showEditDialog(AdminProfileModel profile) {
    final l10n = AppLocalizations.of(context)!;
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final addressController = TextEditingController(text: profile.address ?? '');
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
                  children: [
                    Center(
                      child: AppAvatarPicker(
                        networkUrl: profile.profilePhotoImg,
                        pickedFile: pickedPhoto,
                        fallbackIcon: Icons.admin_panel_settings,
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
                    context.read<AdminProfileCubit>().editProfile(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          address: addressController.text.trim(),
                          profilePhoto: pickedPhoto,
                        );
                    Navigator.pop(dialogContext);
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
    return BlocConsumer<AdminProfileCubit, AdminProfileState>(
      listener: (context, state) {
        if (state is AdminProfileActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is AdminProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.adminProfileTitle),
            actions: [
              if (state is AdminProfileLoaded)
                IconButton(
                  onPressed: () => _showEditDialog(state.profile),
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminProfileState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AdminProfileLoading) {
      return const AppLoading();
    }

    if (state is AdminProfileFailure) {
      return AppErrorState(
        message: state.message,
        onRetry: () => context.read<AdminProfileCubit>().getProfile(),
      );
    }

    if (state is AdminProfileLoaded) {
      final profile = state.profile;

      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      profile.profilePhotoImg != null &&
                          profile.profilePhotoImg!.isNotEmpty
                      ? NetworkImage(profile.profilePhotoImg!)
                      : null,
                  child:
                      profile.profilePhotoImg == null ||
                          profile.profilePhotoImg!.isEmpty
                      ? const Icon(
                          Icons.admin_panel_settings,
                          size: 40,
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
              label: l10n.commonPhone,
              value: profile.phoneNumber,
            ),
          ),
          AppCard(
            child: _ProfileRow(
              icon: Icons.home_outlined,
              label: l10n.commonAddress,
              value: profile.address ?? l10n.commonNA,
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
