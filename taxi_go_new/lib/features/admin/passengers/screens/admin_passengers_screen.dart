import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/passengers/cubit/admin_passengers_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/passenger_model.dart';

class AdminPassengersScreen extends StatefulWidget {
  const AdminPassengersScreen({super.key});

  @override
  State<AdminPassengersScreen> createState() => _AdminPassengersScreenState();
}

class _AdminPassengersScreenState extends State<AdminPassengersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminPassengersCubit>().getPassengers();
  }

  Future<void> _refresh() async {
    await context.read<AdminPassengersCubit>().getPassengers();
  }

  void _confirmSoftDelete(PassengerModel passenger) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.adminDeletePassengerTitle),
          content: Text('${l10n.adminConfirmDeletePrefix} ${passenger.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AdminPassengersCubit>().softDeletePassenger(passenger.userId);
              },
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
  }

  void _showPassengerDetails(PassengerModel passenger) {
    final cubit = context.read<AdminPassengersCubit>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(passenger.fullName),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<PassengerProfileModel>(
              future: cubit.fetchPassengerProfile(passenger.userId),
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
                          backgroundImage: details.profileImageUrl != null
                              ? NetworkImage(details.profileImageUrl!)
                              : null,
                          child: details.profileImageUrl == null
                              ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InfoRow(label: l10n.commonPhone, value: details.phoneNumber),
                      _InfoRow(label: l10n.commonAddress, value: details.address ?? l10n.commonNA),
                      _InfoRow(
                        label: l10n.adminCompletedOrders,
                        value: '${details.completedOrdersCount}',
                      ),
                      if (details.createdAt != null)
                        _InfoRow(
                          label: l10n.adminJoined,
                          value: details.createdAt!.toLocal().toString().split(' ').first,
                        ),
                      const SizedBox(height: AppSpacing.md),
                      UserStatusActions(
                        isActive: details.isActive,
                        isBlocked: details.isBlocked,
                        onToggleActive: () async {
                          Navigator.pop(dialogContext);
                          await cubit.toggleActive(passenger.userId);
                        },
                        onToggleBlock: ({reason, endsAt}) async {
                          Navigator.pop(dialogContext);
                          await cubit.toggleBlock(
                            passenger.userId,
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
    return BlocConsumer<AdminPassengersCubit, AdminPassengersState>(
      listener: (context, state) {
        if (state is AdminPassengersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AdminPassengersFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminManagePassengers)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminPassengersState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AdminPassengersLoading) {
      return const AppLoading();
    }

    if (state is AdminPassengersFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is AdminPassengersLoaded) {
      if (state.passengers.isEmpty) {
        return AppEmptyState(
          icon: Icons.people_outline,
          title: l10n.adminNoPassengersFound,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.passengers.length,
          itemBuilder: (context, index) {
            final passenger = state.passengers[index];

            return InkWell(
              onTap: () => _showPassengerDetails(passenger),
              child: AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: passenger.profilePhotoUrl != null
                          ? NetworkImage(passenger.profilePhotoUrl!)
                          : null,
                      child: passenger.profilePhotoUrl == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            passenger.fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.commonPhonePrefix} ${passenger.phoneNumber ?? l10n.commonNA}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${l10n.commonAddressPrefix} ${passenger.address ?? l10n.commonNA}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!passenger.isActive || passenger.isBlocked)
                          AppStatusChip(
                            label: passenger.isBlocked ? l10n.commonBlocked : l10n.commonInactive,
                            tone: AppStatusTone.error,
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        passenger.isDeleted
                            ? AppPrimaryButton(
                                label: l10n.commonRestore,
                                expand: false,
                                onPressed: () {
                                  context
                                      .read<AdminPassengersCubit>()
                                      .restorePassenger(passenger.userId);
                                },
                              )
                            : AppSecondaryButton(
                                label: l10n.commonDelete,
                                expand: false,
                                onPressed: () => _confirmSoftDelete(passenger),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.people_outline,
      title: l10n.adminNoPassengersLoaded,
      actionLabel: l10n.adminLoadPassengers,
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
            width: 110,
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
