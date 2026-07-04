import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/drivers/cubit/driver_approvals_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_pending_model.dart';

class AdminDriverApprovalsScreen extends StatefulWidget {
  const AdminDriverApprovalsScreen({super.key});

  @override
  State<AdminDriverApprovalsScreen> createState() => _AdminDriverApprovalsScreenState();
}

class _AdminDriverApprovalsScreenState extends State<AdminDriverApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverApprovalsCubit>().getPendingDrivers();
  }

  Future<void> _refresh() async {
    await context.read<DriverApprovalsCubit>().getPendingDrivers();
  }

  void _confirmApprove(DriverPendingModel driver) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.adminApproveDriverTitle),
          content: Text('${l10n.adminApprovePrefix} ${driver.fullName} ${l10n.adminApproveSuffix}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<DriverApprovalsCubit>().approveDriver(driver.userId);
              },
              child: Text(l10n.commonApprove),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(DriverPendingModel driver) {
    final notesController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${l10n.adminRejectPrefix} ${driver.fullName}'),
          content: AppTextField(
            controller: notesController,
            label: l10n.commonReasonOptional,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<DriverApprovalsCubit>().rejectDriver(
                      driver.userId,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );
              },
              child: Text(l10n.commonReject),
            ),
          ],
        );
      },
    ).then((_) => notesController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverApprovalsCubit, DriverApprovalsState>(
      listener: (context, state) {
        if (state is DriverApprovalsActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is DriverApprovalsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminPendingApprovalsTitle)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DriverApprovalsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is DriverApprovalsLoading) {
      return const AppLoading();
    }

    if (state is DriverApprovalsFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is PendingDriversLoaded) {
      if (state.drivers.isEmpty) {
        return AppEmptyState(
          icon: Icons.fact_check_outlined,
          title: l10n.adminNoPendingDrivers,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.drivers.length,
          itemBuilder: (context, index) {
            final driver = state.drivers[index];

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.commonPhonePrefix} ${driver.phoneNumber}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      AppPrimaryButton(
                        label: l10n.commonApprove,
                        icon: Icons.check,
                        expand: false,
                        onPressed: () => _confirmApprove(driver),
                      ),
                      AppSecondaryButton(
                        label: l10n.commonReject,
                        icon: Icons.close,
                        expand: false,
                        onPressed: () => _showRejectDialog(driver),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.fact_check_outlined,
      title: l10n.adminNoDataLoaded,
      actionLabel: l10n.adminLoadPendingDrivers,
      onAction: _refresh,
    );
  }
}
