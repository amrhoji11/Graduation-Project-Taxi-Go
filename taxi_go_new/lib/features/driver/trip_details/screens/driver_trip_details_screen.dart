import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/utils/route_progress.dart';
import 'package:taxi_go_new/core/utils/trip_format.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import '../../../../models/cancel_trip_model.dart';
import '../../../../models/driver_active_state_model.dart';
import '../../../../models/trip_route_model.dart';
import '../../active/cubit/driver_active_state_cubit.dart';
import '../../presentation/cubit/driver_trip_cubit.dart';
import '../../../realtime/cubit/driver_location_cubit.dart';
import '../../../realtime/cubit/realtime_trip_cubit.dart';
import '../../../realtime/cubit/trip_route_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class DriverTripDetailsScreen extends StatefulWidget {
  final DriverActiveTripModel trip;

  const DriverTripDetailsScreen({super.key, required this.trip});

  @override
  State<DriverTripDetailsScreen> createState() =>
      _DriverTripDetailsScreenState();
}

class _DriverTripDetailsScreenState extends State<DriverTripDetailsScreen> {
  late DriverActiveTripModel trip;
  late final RealtimeTripCubit _realtimeTripCubit;
  late final DriverLocationCubit _driverLocationCubit;
  late final DriverActiveStateCubit _activeStateCubit;
  late final TripRouteCubit _tripRouteCubit;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    _realtimeTripCubit = context.read<RealtimeTripCubit>();
    _driverLocationCubit = context.read<DriverLocationCubit>();
    _activeStateCubit = context.read<DriverActiveStateCubit>();
    _tripRouteCubit = TripRouteCubit(
      loadRoute: () =>
          context.read<DriverTripCubit>().driverTripRepository.getRoute(tripId),
    );
    _startRealtime();
  }

  Future<void> _startRealtime() async {
    await _realtimeTripCubit.connectToTripHub();
    await _driverLocationCubit.startTracking();
    await _tripRouteCubit.load();
  }

  @override
  void dispose() {
    _driverLocationCubit.stopTracking();
    _realtimeTripCubit.disconnect();
    _tripRouteCubit.close();
    super.dispose();
  }

  int get tripId => trip.tripId;

  /// The stop this trip's route currently leads to - the first one not
  /// yet finished. Trips have exactly one active order in this system
  /// (shared/pooled trips were removed), so this is normally just
  /// `stops.first`, but the guard keeps it correct if that ever changes.
  DriverTripStopModel get _activeStop => trip.stops.firstWhere(
        (s) =>
            s.statusInTrip != TripOrderStatusType.droppedOff &&
            s.statusInTrip != TripOrderStatusType.cancelled &&
            s.statusInTrip != TripOrderStatusType.unassigned,
        orElse: () => trip.stops.first,
      );

  void _showCancelDialog() {
    TripCancelReason selected = TripCancelReason.driverIssue;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.driverCancelTrip),
              content: DropdownButton<TripCancelReason>(
                isExpanded: true,
                value: selected,
                items: TripCancelReason.values
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selected = value);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.commonBack),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<DriverTripCubit>().cancelTrip(
                      tripId: tripId,
                      reason: selected,
                    );
                  },
                  child: Text(l10n.driverConfirmCancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tripRouteCubit,
      child: MultiBlocListener(
      listeners: [
        BlocListener<RealtimeTripCubit, RealtimeTripState>(
          listener: (context, state) {
            if (state is RealtimeTripUpdated &&
                (state.eventName == 'UpdateDriverStatus' ||
                    state.eventName == 'UpdateTripStatus')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${state.eventName}: ${state.data}')),
              );
            }

            // Real road route + ETA recalculated server-side (e.g. just
            // accepted, or just picked up the passenger) - update the map
            // without a full screen reload.
            if (state is RealtimeTripUpdated &&
                state.eventName == 'RouteUpdated') {
              _tripRouteCubit.applyRouteUpdate(
                TripRouteModel.fromRouteUpdatedArgs(
                  state.data as List<Object?>?,
                ),
              );
            }

            if (state is RealtimeTripFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<DriverLocationCubit, DriverLocationState>(
          listener: (context, state) {
            // Drives this screen's own map marker/progress directly from
            // the local GPS stream - more responsive than waiting for the
            // SignalR echo, and doesn't depend on this client also having
            // joined the trip's SignalR group.
            if (state is DriverLocationSent) {
              _tripRouteCubit.updateDriverPosition(
                state.latitude,
                state.longitude,
              );
            }

            if (state is DriverLocationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${AppLocalizations.of(context)!.driverLocationErrorPrefix} ${state.message}',
                  ),
                ),
              );
            }
          },
        ),
        BlocListener<DriverTripCubit, DriverTripState>(
          listener: (context, state) {
            if (state is DriverTripActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _activeStateCubit.refresh();
            }

            if (state is DriverTripFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<DriverActiveStateCubit, DriverActiveStateState>(
          listener: (context, state) {
            if (state is! DriverActiveStateLoaded) return;

            if (state.data.state == DriverActiveStateType.onTrip &&
                state.data.trip != null &&
                state.data.trip!.tripId == tripId) {
              setState(() => trip = state.data.trip!);
            } else {
              // Trip is no longer active (completed/cancelled) - leave this
              // screen, the queue screen will pick up the new state.
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text('${AppLocalizations.of(context)!.driverTripHash}$tripId')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            BlocBuilder<TripRouteCubit, TripRouteState>(
              builder: (context, routeState) => _RouteSection(
                pickup: LatLng(_activeStop.pickupLat, _activeStop.pickupLng),
                dropoff: _activeStop.dropoffLat != null && _activeStop.dropoffLng != null
                    ? LatLng(_activeStop.dropoffLat!, _activeStop.dropoffLng!)
                    : null,
                routeState: routeState,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.driverTripStatus,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppStatusChip(
                    label: trip.status.label,
                    tone: AppStatusTone.info,
                  ),
                ],
              ),
            ),
            if (trip.status == DriverTripStatus.assigned)
              BlocBuilder<DriverTripCubit, DriverTripState>(
                builder: (context, state) {
                  final isLoading = state is DriverTripLoading;
                  return AppPrimaryButton(
                    label: AppLocalizations.of(context)!.driverStartTrip,
                    icon: Icons.play_arrow_rounded,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => context.read<DriverTripCubit>().startTrip(tripId),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.sm),
            AppSectionHeader(title: AppLocalizations.of(context)!.driverStops),
            ...trip.stops.map((stop) => _StopCard(stop: stop)),
            const SizedBox(height: AppSpacing.lg),
            AppSecondaryButton(
              label: AppLocalizations.of(context)!.driverCancelTrip,
              icon: Icons.cancel_outlined,
              onPressed: _showCancelDialog,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Map + ETA/remaining-distance summary for the driver's current leg.
/// Stateless - all the live data already lives in [TripRouteState].
class _RouteSection extends StatelessWidget {
  final LatLng pickup;
  final LatLng? dropoff;
  final TripRouteState routeState;

  const _RouteSection({
    required this.pickup,
    required this.dropoff,
    required this.routeState,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (routeState is! TripRouteLoaded) return const SizedBox.shrink();

    final loaded = routeState as TripRouteLoaded;
    final routePoints = loaded.route.points
        .map((p) => LatLng(p.lat, p.lng))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TripRouteMap(
          pickup: pickup,
          dropoff: dropoff,
          driverPosition: loaded.driverPosition,
          routePoints: routePoints,
        ),
        if (routePoints.length >= 2 && loaded.driverPosition != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) {
              final progress = computeRouteProgress(routePoints, loaded.driverPosition!);
              final etaMinutes = loaded.route.totalMinutes > 0 && progress.totalMeters > 0
                  ? (loaded.route.totalMinutes * progress.remainingMeters / progress.totalMeters).round()
                  : loaded.route.totalMinutes;

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: 4,
                children: [
                  _InfoChip(text: l10n.commonEtaLabel(TripFormat.etaMinutes(etaMinutes))),
                  _InfoChip(
                    text: l10n.commonDistanceRemainingLabel(
                      TripFormat.distanceMeters(progress.remainingMeters),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final DriverTripStopModel stop;

  const _StopCard({required this.stop});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stop.passengerName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              AppStatusChip(
                label: stop.statusInTrip.label,
                tone: tripOrderStatusTone(stop.statusInTrip),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.my_location, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(stop.pickupLocation)),
            ],
          ),
          if (stop.dropoffLocation != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(stop.dropoffLocation!)),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${AppLocalizations.of(context)!.driverOfferPassengersPrefix} ${stop.passengerCount}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (stop.statusInTrip == TripOrderStatusType.droppedOff ||
        stop.statusInTrip == TripOrderStatusType.cancelled ||
        stop.statusInTrip == TripOrderStatusType.unassigned) {
      return const SizedBox.shrink();
    }

    // Guarded by `DriverTripCubit`'s loading state - without this, rapid
    // double-tapping Arrived/Pickup/Dropoff could fire the same action
    // twice before the first request's response updates `stop.statusInTrip`.
    return BlocBuilder<DriverTripCubit, DriverTripState>(
      builder: (context, state) {
        final isLoading = state is DriverTripLoading;

        switch (stop.statusInTrip) {
          case TripOrderStatusType.assigned:
            return AppPrimaryButton(
              label: l10n.driverArrived,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () => context.read<DriverTripCubit>().arrived(stop.orderId),
            );
          case TripOrderStatusType.driverArrived:
            return AppPrimaryButton(
              label: l10n.commonPickup,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () => context
                      .read<DriverTripCubit>()
                      .pickupPassenger(stop.orderId),
            );
          case TripOrderStatusType.pickedUp:
            return AppPrimaryButton(
              label: l10n.commonDropoff,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () => context
                      .read<DriverTripCubit>()
                      .dropOffPassenger(stop.orderId),
            );
          case TripOrderStatusType.droppedOff:
          case TripOrderStatusType.cancelled:
          case TripOrderStatusType.unassigned:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
