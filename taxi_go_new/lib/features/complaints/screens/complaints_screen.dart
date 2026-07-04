import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/complaints/cubit/complaints_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/complaint_enums.dart';
import 'package:taxi_go_new/models/complaint_model.dart';

AppStatusTone _complaintStatusTextTone(String status) {
  switch (status.toLowerCase()) {
    case 'resolved':
      return AppStatusTone.success;
    case 'rejected':
      return AppStatusTone.error;
    case 'inreview':
    case 'in review':
      return AppStatusTone.warning;
    default:
      return AppStatusTone.info;
  }
}

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ComplaintsCubit>().getComplaints();
  }

  Future<void> _refresh() async {
    await context.read<ComplaintsCubit>().getComplaints();
  }

  void _showCreateComplaintDialog() {
    final orderIdController = TextEditingController();
    final descriptionController = TextEditingController();
    ComplaintTargetTypeEnum targetType = ComplaintTargetTypeEnum.driver;
    ComplaintReasonType reasonType = ComplaintReasonType.behavior;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.complaintsCreateTitle),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    AppTextField(
                      controller: orderIdController,
                      keyboardType: TextInputType.number,
                      label: l10n.complaintsOrderId,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<ComplaintTargetTypeEnum>(
                      initialValue: targetType,
                      decoration: InputDecoration(labelText: l10n.orderDetailAgainst),
                      items: ComplaintTargetTypeEnum.values
                          .where((t) => t != ComplaintTargetTypeEnum.unknown)
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => targetType = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<ComplaintReasonType>(
                      initialValue: reasonType,
                      decoration: InputDecoration(labelText: l10n.commonReason),
                      items: ComplaintReasonType.values
                          .where((r) => r != ComplaintReasonType.unknown)
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => reasonType = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: descriptionController,
                      maxLines: 3,
                      label: l10n.commonDescription,
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
                    final orderId = int.tryParse(
                      orderIdController.text.trim(),
                    );
                    final description = descriptionController.text.trim();

                    if (orderId == null || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.complaintsFillAllFields),
                        ),
                      );
                      return;
                    }

                    context.read<ComplaintsCubit>().createComplaint(
                      orderId: orderId,
                      targetType: targetType,
                      reasonType: reasonType,
                      description: description,
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.commonCreate),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      orderIdController.dispose();
      descriptionController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintsCubit, ComplaintsState>(
      listener: (context, state) {
        if (state is ComplaintsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<ComplaintsCubit>().getComplaints();
        }

        if (state is ComplaintsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.complaintsTitle),
            actions: [
              IconButton(
                onPressed: _showCreateComplaintDialog,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ComplaintsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ComplaintsLoading) {
      return const AppLoading();
    }

    if (state is ComplaintsLoaded) {
      if (state.complaints.isEmpty) {
        return AppEmptyState(
          icon: Icons.report_problem_outlined,
          title: l10n.complaintsNoComplaintsFound,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.complaints.length,
          itemBuilder: (context, index) {
            final complaint = state.complaints[index];

            return _ComplaintCard(complaint: complaint);
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.report_problem_outlined,
      title: l10n.complaintsNoComplaintsLoaded,
      actionLabel: l10n.complaintsLoadComplaints,
      onAction: _refresh,
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  const _ComplaintCard({
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
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
                  complaint.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.complaintsOrderIdPrefix} ${complaint.orderId}\n${complaint.description}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppStatusChip(
            label: complaint.status,
            tone: _complaintStatusTextTone(complaint.status),
          ),
        ],
      ),
    );
  }
}
