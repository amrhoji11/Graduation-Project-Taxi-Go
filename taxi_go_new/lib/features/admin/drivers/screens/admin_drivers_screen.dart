import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/drivers/cubit/driver_approvals_cubit.dart';
import 'package:taxi_go_new/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/models/driver_pending_model.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getDrivers();
  }

  Future<void> _refresh() async {
    await context.read<AdminCubit>().getDrivers();
  }

  void _confirmSoftDelete(DriverModel driver) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.adminDeleteDriverTitle),
          content: Text(
            '${l10n.adminConfirmDeletePrefix} ${driver.name ?? driver.userId}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AdminCubit>().softDeleteDriver(driver.userId);
              },
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
  }

  void _showDriverDetails(DriverModel driver) {
    final adminCubit = context.read<AdminCubit>();
    final approvalsCubit = context.read<DriverApprovalsCubit>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(driver.name ?? l10n.commonDriver),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<DriverApprovalDetailsModel>(
              future: approvalsCubit.fetchDriverDetails(driver.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return SizedBox(
                    height: 80,
                    child: Center(child: Text(l10n.commonFailedToLoadDetails)),
                  );
                }

                final details = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: details.profilePhotoUrl != null
                              ? NetworkImage(details.profilePhotoUrl!)
                              : null,
                          child: details.profilePhotoUrl == null
                              ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InfoRow(label: l10n.commonPhone, value: details.phone ?? l10n.commonNA),
                      _InfoRow(label: l10n.commonEmail, value: details.email ?? l10n.commonNA),
                      _InfoRow(label: l10n.commonStatus, value: details.status.label),
                      _InfoRow(
                        label: l10n.commonVehicle,
                        value: details.vehicleModel != null
                            ? '${details.vehicleModel} (${details.vehiclePlateNumber ?? '-'})'
                            : l10n.commonNoVehicle,
                      ),
                      _InfoRow(
                        label: l10n.commonRating,
                        value: details.ratingCount > 0
                            ? '${details.rating.toStringAsFixed(1)} / 5 (${details.ratingCount})'
                            : l10n.commonNoRatingsYet,
                      ),
                      _InfoRow(
                        label: l10n.commonTrips,
                        value:
                            '${details.totalTrips} ${l10n.commonTotal} • ${details.completedTrips} ${l10n.commonCompletedWord} • ${details.cancelledTrips} ${l10n.commonCancelledWord}',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      UserStatusActions(
                        isActive: details.isActive,
                        isBlocked: details.isBlocked,
                        onToggleActive: () async {
                          Navigator.pop(dialogContext);
                          await adminCubit.toggleActive(driver.userId);
                        },
                        onToggleBlock: ({reason, endsAt}) async {
                          Navigator.pop(dialogContext);
                          await adminCubit.toggleBlock(
                            driver.userId,
                            reason: reason,
                            endsAt: endsAt,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonClose),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is AdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.adminManageDrivers),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AdminLoading) {
      return const AppLoading();
    }

    if (state is AdminFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is DriversLoaded) {
      if (state.drivers.isEmpty) {
        return AppEmptyState(
          icon: Icons.local_taxi_outlined,
          title: l10n.adminNoDriversFound,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.drivers.length,
          itemBuilder: (context, index) {
            final driver = state.drivers[index];

            return _DriverCard(
              driver: driver,
              onTap: () => _showDriverDetails(driver),
              onDelete: () => _confirmSoftDelete(driver),
              onRestore: () {
                context.read<AdminCubit>().restoreDriver(driver.userId);
              },
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.local_taxi_outlined,
      title: l10n.adminNoDriversLoaded,
      actionLabel: l10n.adminLoadDrivers,
      onAction: _refresh,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  const _DriverCard({
    required this.driver,
    required this.onTap,
    required this.onDelete,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = driver.name?.trim().isNotEmpty == true
        ? driver.name!
        : l10n.commonUnknown;

    return InkWell(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: driver.profilePhotoUrl != null
                      ? NetworkImage(driver.profilePhotoUrl!)
                      : null,
                  child: driver.profilePhotoUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.commonPhonePrefix} ${driver.phone ?? l10n.commonNA}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (driver.ratingCount > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${driver.rating.toStringAsFixed(1)} (${driver.ratingCount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppStatusChip(
                      label: driver.status.label,
                      tone: driverStatusTone(driver.status),
                    ),
                    if (!driver.isActive || driver.isBlocked) ...[
                      const SizedBox(height: 4),
                      AppStatusChip(
                        label: driver.isBlocked ? l10n.commonBlocked : l10n.commonInactive,
                        tone: AppStatusTone.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (!driver.isDeleted)
                  AppSecondaryButton(
                    label: l10n.commonDelete,
                    icon: Icons.delete_outline,
                    expand: false,
                    onPressed: onDelete,
                  ),
                if (driver.isDeleted)
                  AppPrimaryButton(
                    label: l10n.commonRestore,
                    icon: Icons.restore,
                    expand: false,
                    onPressed: onRestore,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
