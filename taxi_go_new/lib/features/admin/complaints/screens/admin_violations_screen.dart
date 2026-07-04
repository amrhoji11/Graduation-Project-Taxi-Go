import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/complaints/cubit/complaints_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_complaint_model.dart';
import 'package:taxi_go_new/models/complaint_enums.dart';

/// Admin-only screen reusing the existing `ComplaintsCubit`/`ComplaintsRepository`
/// (already registered app-wide) to review complaints and resolve violations.
class AdminViolationsScreen extends StatefulWidget {
  const AdminViolationsScreen({super.key});

  @override
  State<AdminViolationsScreen> createState() => _AdminViolationsScreenState();
}

class _AdminViolationsScreenState extends State<AdminViolationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ComplaintsCubit>().getAdminComplaints();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      if (_tabController.index == 1) {
        context.read<ComplaintsCubit>().getViolations();
      } else {
        context.read<ComplaintsCubit>().getAdminComplaints();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showResolveDialog(AdminComplaintModel complaint) {
    bool createViolation = false;
    ViolationTypeEnum violationType = ViolationTypeEnum.behavior;
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.violationResolveComplaint),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text(l10n.violationCreateAgainstDriver),
                    value: createViolation,
                    onChanged: (value) {
                      setDialogState(() => createViolation = value ?? false);
                    },
                  ),
                  if (createViolation) ...[
                    DropdownButtonFormField<ViolationTypeEnum>(
                      initialValue: violationType,
                      decoration: InputDecoration(labelText: l10n.violationType),
                      items: ViolationTypeEnum.values
                          .where((v) => v != ViolationTypeEnum.unknown)
                          .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => violationType = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: reasonController,
                      label: l10n.violationReason,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ComplaintsCubit>().updateComplaintStatus(
                          complaintId: complaint.id,
                          status: ComplaintStatusType.resolved,
                          createViolation: createViolation,
                          violationType: violationType,
                          violationReason: reasonController.text.trim().isEmpty
                              ? null
                              : reasonController.text.trim(),
                        );
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.commonResolve),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => reasonController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminComplaintsViolations),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.adminComplaintsTabLabel),
            Tab(text: l10n.adminViolationsTabLabel),
          ],
        ),
      ),
      body: BlocConsumer<ComplaintsCubit, ComplaintsState>(
        listener: (context, state) {
          if (state is ComplaintsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is ComplaintsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildComplaintsTab(context, state),
              _buildViolationsTab(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildComplaintsTab(BuildContext context, ComplaintsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ComplaintsLoading) {
      return const AppLoading();
    }

    if (state is AdminComplaintsLoaded) {
      if (state.complaints.isEmpty) {
        return AppEmptyState(
          icon: Icons.report_problem_outlined,
          title: l10n.adminNoComplaintsFound,
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<ComplaintsCubit>().getAdminComplaints(),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.complaints.length,
          itemBuilder: (context, index) {
            final complaint = state.complaints[index];
            final isOpen = complaint.status != ComplaintStatusType.resolved &&
                complaint.status != ComplaintStatusType.rejected;

            return AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.report_problem_outlined, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${complaint.senderName} → ${complaint.againstUserName ?? complaint.targetType.label}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (complaint.tripId != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.driverTripHash}${complaint.tripId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.adminReasonPrefix} ${complaint.reasonType.label}\n${complaint.description}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (complaint.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            complaint.createdAt!.toLocal().toString().split('.').first,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  isOpen
                      ? AppPrimaryButton(
                          label: l10n.commonResolve,
                          expand: false,
                          onPressed: () => _showResolveDialog(complaint),
                        )
                      : AppStatusChip(
                          label: complaint.status.label,
                          tone: complaintStatusTone(complaint.status),
                        ),
                ],
              ),
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.report_problem_outlined,
      title: l10n.adminNoComplaintsLoaded,
      actionLabel: l10n.adminLoadComplaints,
      onAction: () => context.read<ComplaintsCubit>().getAdminComplaints(),
    );
  }

  Widget _buildViolationsTab(BuildContext context, ComplaintsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ComplaintsLoading) {
      return const AppLoading();
    }

    if (state is ViolationsLoaded) {
      if (state.violations.isEmpty) {
        return AppEmptyState(
          icon: Icons.warning_amber_outlined,
          title: l10n.adminNoViolationsFound,
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<ComplaintsCubit>().getViolations(),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.violations.length,
          itemBuilder: (context, index) {
            final violation = state.violations[index];

            return AppCard(
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined, color: AppColors.error),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${violation.driverName} (${violation.type.label})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          violation.reason,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  violation.status == ViolationStatusType.active
                      ? AppPrimaryButton(
                          label: l10n.commonResolve,
                          expand: false,
                          onPressed: () {
                            context.read<ComplaintsCubit>().resolveViolation(violation.id);
                          },
                        )
                      : AppStatusChip(
                          label: violation.status.label,
                          tone: violationStatusTone(violation.status),
                        ),
                ],
              ),
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.warning_amber_outlined,
      title: l10n.adminNoViolationsLoaded,
      actionLabel: l10n.adminLoadViolations,
      onAction: () => context.read<ComplaintsCubit>().getViolations(),
    );
  }
}
