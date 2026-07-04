import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/driver/active/cubit/driver_active_state_cubit.dart';
import 'package:taxi_go_new/features/driver/active/widgets/incoming_offer_card.dart';
import 'package:taxi_go_new/features/driver/presentation/cubit/driver_queue_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_active_state_model.dart';

class DriverQueueScreen extends StatefulWidget {
  const DriverQueueScreen({super.key});

  @override
  State<DriverQueueScreen> createState() => _DriverQueueScreenState();
}

class _DriverQueueScreenState extends State<DriverQueueScreen> {
  bool isInQueue = false;
  late final DriverActiveStateCubit _activeStateCubit;

  @override
  void initState() {
    super.initState();
    _activeStateCubit = context.read<DriverActiveStateCubit>();
    // `DriverHomeScreen` (always mounted underneath this screen) already
    // owns the SignalR `startWatching()`/`stopWatching()` lifecycle - this
    // screen only needs its own fresh fetch on open, per the same global
    // cubit, so the offer shown here is never stale even if it changed
    // while this screen wasn't on top.
    _activeStateCubit.refresh();
  }

  Future<void> _enterQueue() async {
    context.read<DriverQueueCubit>().enterQueue();
  }

  @override
  Widget build(BuildContext context) {
    // Accept/Reject success+failure handling (snackbar + active-state
    // refresh) lives on `DriverHomeScreen` only, which - unlike this
    // screen - is always mounted, so it never misses the result even if
    // the driver isn't looking at the Dashboard when they act on the
    // offer from here. Duplicating that listener here would just double
    // the snackbar.
    return BlocConsumer<DriverQueueCubit, DriverQueueState>(
        listener: (context, state) {
          if (state is DriverQueueSuccess) {
            setState(() {
              isInQueue = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is DriverQueueFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DriverQueueLoading;
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            appBar: AppBar(title: Text(l10n.driverQueueTitle)),
            // A fixed-height Column with a Spacer() used to push the button
            // to the bottom - on a short screen (small device, landscape,
            // or with system UI taking extra space) the content above could
            // overflow with no way to scroll, and nothing accounted for the
            // bottom system nav bar inset. Scrollable content + a button
            // pinned outside the scroll view, both inside SafeArea, fixes
            // both: content always fits, button is always reachable.
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          BlocBuilder<DriverActiveStateCubit, DriverActiveStateState>(
                            builder: (context, activeState) {
                              if (activeState is DriverActiveStateLoaded &&
                                  activeState.data.state == DriverActiveStateType.offerPending &&
                                  activeState.data.offer != null) {
                                return IncomingOfferCard(offer: activeState.data.offer!);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          AppCard(
                            margin: EdgeInsets.zero,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: isInQueue
                                      ? AppColors.success
                                      : AppColors.neutral,
                                  child: Icon(
                                    isInQueue ? Icons.check : Icons.pause,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.driverQueueStatus,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      AppStatusChip(
                                        label: isInQueue
                                            ? l10n.driverWaitingForOrders
                                            : l10n.commonInactive,
                                        tone: isInQueue
                                            ? AppStatusTone.success
                                            : AppStatusTone.neutral,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              color: !isInQueue
                                  ? AppColors.neutral.withValues(alpha: 0.08)
                                  : AppColors.primaryLight,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  isInQueue ? Icons.local_taxi : Icons.block,
                                  size: 56,
                                  color: isInQueue
                                      ? AppColors.primary
                                      : AppColors.neutral,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  isInQueue
                                      ? l10n.driverAvailableForTrips
                                      : l10n.driverEnterQueueToReceive,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: AppPrimaryButton(
                      label: isInQueue ? l10n.driverAlreadyInQueue : l10n.driverEnterQueue,
                      icon: Icons.queue,
                      isLoading: isLoading,
                      onPressed: (isLoading || isInQueue) ? null : _enterQueue,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}

