import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/driver/presentation/cubit/driver_trip_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_active_state_model.dart';

/// Persistent (non-dialog) incoming-order card. Rendered identically on
/// the Driver Dashboard and Driver Queue screen - both screens just feed
/// in the same `DriverActiveStateCubit` offer, so there is exactly one
/// offer in play at any time and therefore no way for this to render as a
/// duplicate even if the underlying `NewTripOffer` SignalR notification
/// arrives more than once (it only ever replaces the single held offer,
/// never appends to a list).
class IncomingOfferCard extends StatelessWidget {
  final DriverOrderOfferModel offer;

  const IncomingOfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_taxi, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.driverNewTripOffer,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${l10n.driverOfferPickupPrefix} ${offer.pickupLocation}'),
          if (offer.dropoffLocation != null) ...[
            const SizedBox(height: 2),
            Text('${l10n.driverOfferDropoffPrefix} ${offer.dropoffLocation}'),
          ],
          const SizedBox(height: 2),
          Text('${l10n.driverOfferPassengersPrefix} ${offer.passengerCount}'),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<DriverTripCubit, DriverTripState>(
            builder: (context, state) {
              final isLoading = state is DriverTripLoading;

              return Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: l10n.commonReject,
                      icon: Icons.close,
                      onPressed: isLoading
                          ? null
                          : () => context.read<DriverTripCubit>().rejectOrder(offer.orderId),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppPrimaryButton(
                      label: l10n.commonAccept,
                      icon: Icons.check,
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () => context.read<DriverTripCubit>().acceptOrder(offer.orderId),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
