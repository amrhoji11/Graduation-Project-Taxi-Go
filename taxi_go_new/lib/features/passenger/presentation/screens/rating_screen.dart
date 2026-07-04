import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/complaints/cubit/complaints_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/order_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/complaint_enums.dart';
import 'package:taxi_go_new/models/order_model.dart';

/// Dedicated post-trip screen, reached either from `OrderDetailScreen`'s
/// rate/complaint actions or by tapping a `RateTrip` notification. Combines
/// driver rating (`POST /PassengerTrips/rate-driver`) and complaint
/// submission (`POST /api/orders/{orderId}/complaints`) - two independent
/// backend entities - behind one screen and one submit action, since both
/// are about the same just-finished trip. The backend enforces its own
/// rules (1-5 stars, 30-minute rating window, one rating per order, no
/// complaints before a driver is assigned) - failures surface the real
/// backend message rather than a generic one.
class RatingScreen extends StatefulWidget {
  final int orderId;

  const RatingScreen({super.key, required this.orderId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  int _stars = 0;
  bool _reportIssue = false;
  ComplaintTargetTypeEnum _targetType = ComplaintTargetTypeEnum.driver;
  ComplaintReasonType _reasonType = ComplaintReasonType.behavior;
  bool _isSubmitting = false;

  /// Tracks a rating just submitted in this session, separate from
  /// `order.rating` (which only updates once the order is re-fetched) - lets
  /// a retry after a complaint-only failure skip re-submitting the rating.
  bool _justRated = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderDetail(widget.orderId);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(OrderDetailModel order) async {
    final l10n = AppLocalizations.of(context)!;
    final alreadyRated = order.rating != null || _justRated;

    if (!alreadyRated && _stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ratingScreenStarsRequired)),
      );
      return;
    }

    if (_reportIssue && _descriptionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ratingScreenDescriptionRequired)),
      );
      return;
    }

    if (alreadyRated && !_reportIssue) return;

    setState(() => _isSubmitting = true);

    if (!alreadyRated) {
      await context.read<OrderCubit>().rateDriver(
        orderId: widget.orderId,
        stars: _stars,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      );

      if (!mounted) return;
      final orderState = context.read<OrderCubit>().state;
      if (orderState is OrderFailure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(orderState.message)));
        return;
      }
      _justRated = true;
    }

    if (_reportIssue) {
      await context.read<ComplaintsCubit>().createComplaint(
        orderId: widget.orderId,
        targetType: _targetType,
        reasonType: _reasonType,
        description: _descriptionCtrl.text.trim(),
      );

      if (!mounted) return;
      final complaintState = context.read<ComplaintsCubit>().state;
      if (complaintState is ComplaintsFailure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(complaintState.message)));
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ratingScreenSuccess)));
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ratingScreenTitle)),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderDetailLoaded && state.order.orderId == widget.orderId) {
            return _buildForm(context, state.order);
          }

          if (state is OrderFailure) {
            return AppErrorState(
              message: state.message,
              onRetry: () => context.read<OrderCubit>().getOrderDetail(widget.orderId),
            );
          }

          return const AppLoading();
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, OrderDetailModel order) {
    final l10n = AppLocalizations.of(context)!;
    final alreadyRated = order.rating != null || _justRated;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.driverName != null) ...[
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: order.driverProfilePhotoUrl != null
                        ? NetworkImage(order.driverProfilePhotoUrl!)
                        : null,
                    child: order.driverProfilePhotoUrl == null
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ratingScreenDriverPrefix,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(order.driverName!, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (alreadyRated) ...[
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ratingScreenAlreadyRated,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (order.rating != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${order.rating!.stars ?? '-'} / 5',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (order.rating!.comment != null && order.rating!.comment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                order.rating!.comment!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            AppSectionHeader(title: l10n.ratingScreenStarsLabel),
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final value = i + 1;
                      return IconButton(
                        iconSize: 36,
                        onPressed: () => setState(() => _stars = value),
                        icon: Icon(
                          value <= _stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  AppTextField(
                    controller: _commentCtrl,
                    label: l10n.orderDetailCommentOptional,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ratingScreenTimeWindowNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ratingScreenReportIssueToggle),
            subtitle: Text(l10n.ratingScreenReportIssueHint),
            value: _reportIssue,
            onChanged: (value) => setState(() => _reportIssue = value),
          ),
          if (_reportIssue) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<ComplaintTargetTypeEnum>(
                    initialValue: _targetType,
                    decoration: InputDecoration(labelText: l10n.orderDetailAgainst),
                    items: [
                      DropdownMenuItem(
                        value: ComplaintTargetTypeEnum.driver,
                        child: Text(l10n.commonDriver),
                      ),
                      DropdownMenuItem(
                        value: ComplaintTargetTypeEnum.trip,
                        child: Text(l10n.commonTrip),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _targetType = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<ComplaintReasonType>(
                    initialValue: _reasonType,
                    decoration: InputDecoration(labelText: l10n.commonReason),
                    items: ComplaintReasonType.values
                        .where((r) => r != ComplaintReasonType.unknown)
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _reasonType = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _descriptionCtrl,
                    label: l10n.commonDescription,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (!alreadyRated || _reportIssue)
            AppPrimaryButton(
              label: l10n.ratingScreenSubmit,
              icon: Icons.send,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : () => _submit(order),
            ),
        ],
      ),
    );
  }
}
