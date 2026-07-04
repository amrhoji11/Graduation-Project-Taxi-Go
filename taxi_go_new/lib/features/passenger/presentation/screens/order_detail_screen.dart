import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/utils/route_progress.dart';
import 'package:taxi_go_new/core/utils/trip_format.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/order_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/rating_screen.dart';
import 'package:taxi_go_new/features/realtime/cubit/realtime_trip_cubit.dart';
import 'package:taxi_go_new/features/realtime/cubit/trip_route_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/order_model.dart';
import 'package:taxi_go_new/models/trip_route_model.dart';

/// Shows a single order's full detail, including trip/driver/vehicle info
/// once assigned (`OrderDetailDto`), and lets the passenger cancel, rate the
/// driver, or file a complaint - all against real backend endpoints.
class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int? _joinedTripId;
  late final TripRouteCubit _tripRouteCubit;

  @override
  void initState() {
    super.initState();
    _tripRouteCubit = TripRouteCubit(
      loadRoute: () =>
          context.read<OrderCubit>().orderRepository.getTripRoute(widget.orderId),
    );
    _load();
    _connectRealtime();
  }

  Future<void> _connectRealtime() async {
    final realtime = context.read<RealtimeTripCubit>();
    await realtime.connectToTripHub();
  }

  void _load() {
    context.read<OrderCubit>().getOrderDetail(widget.orderId);
  }

  void _refreshSilently() {
    context.read<OrderCubit>().refreshOrderDetail(widget.orderId);
  }

  void _maybeJoinTrip(OrderDetailModel order) {
    final tripId = order.tripId;
    if (tripId == null || tripId == _joinedTripId) return;
    _joinedTripId = tripId;
    context.read<RealtimeTripCubit>().joinTrip(tripId);
    _tripRouteCubit.load();
  }

  /// Parses the raw `{ driverId, lat, lng }` payload of a
  /// `DriverLocationUpdated` push into just this screen's map marker -
  /// cheap and local, no network round-trip, which is what keeps this
  /// frequent (every ~10m of driver movement) event from re-triggering the
  /// flicker a full reload used to cause (see the `RouteUpdated`/
  /// `UpdateTripStatus` handling below).
  void _applyDriverLocationPing(dynamic data) {
    final arguments = data as List<Object?>?;
    if (arguments == null || arguments.isEmpty) return;

    final payload = arguments.first;
    if (payload is! Map) return;

    final lat = payload['lat'];
    final lng = payload['lng'];
    if (lat is! num || lng is! num) return;

    _tripRouteCubit.updateDriverPosition(lat.toDouble(), lng.toDouble());
  }

  @override
  void dispose() {
    _tripRouteCubit.close();
    final tripId = _joinedTripId;
    if (tripId != null) {
      context.read<RealtimeTripCubit>().leaveTrip(tripId);
    }
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.orderDetailCancelTitle),
        content: Text(l10n.orderDetailCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.orderDetailYesCancel),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<OrderCubit>().cancelOrder(widget.orderId);
    }
  }

  /// Both "Rate driver" and "File a complaint" lead to the same dedicated
  /// [RatingScreen] (it adapts based on whether this order already has a
  /// rating) - the same screen a `RateTrip` notification tap opens.
  /// `pushReplacement` rather than `push`: there's nothing useful to return
  /// to here once the passenger has moved on to rating/complaining, and it
  /// avoids this screen's own `OrderCubit`/`ComplaintsCubit` listeners
  /// firing a second time for actions actually submitted from the screen
  /// on top (both cubits are app-wide singletons).
  void _goToRatingScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RatingScreen(orderId: widget.orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tripRouteCubit,
      child: MultiBlocListener(
      listeners: [
        BlocListener<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderDetailLoaded) {
              _maybeJoinTrip(state.order);
            }

            if (state is OrderActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _load();
            }

            if (state is OrderFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<RealtimeTripCubit, RealtimeTripState>(
          listener: (context, state) {
            if (state is RealtimeTripConnected) {
              final orderState = context.read<OrderCubit>().state;
              if (orderState is OrderDetailLoaded) {
                _maybeJoinTrip(orderState.order);
              }
            }

            // Only status-changing events justify a full re-fetch here -
            // `DriverLocationUpdated` (which fires every few seconds while
            // a trip is active) used to trigger a full reload on every
            // single GPS ping, which is what caused the reported
            // flicker/freeze after order creation. It's now routed to the
            // map's own cheap, local-only position update instead of being
            // ignored.
            if (state is RealtimeTripUpdated &&
                (state.eventName == 'UpdateTripStatus' ||
                    state.eventName == 'LeaveTrip')) {
              _refreshSilently();
            }

            if (state is RealtimeTripUpdated &&
                state.eventName == 'DriverLocationUpdated') {
              _applyDriverLocationPing(state.data);
            }

            if (state is RealtimeTripUpdated &&
                state.eventName == 'RouteUpdated') {
              _tripRouteCubit.applyRouteUpdate(
                TripRouteModel.fromRouteUpdatedArgs(
                  state.data as List<Object?>?,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('${AppLocalizations.of(context)!.orderDetailOrderHash}${widget.orderId}'),
        ),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading || state is OrderInitial) {
              return const AppLoading();
            }

            if (state is OrderFailure) {
              return AppErrorState(message: state.message, onRetry: _load);
            }

            if (state is OrderDetailLoaded) {
              return _buildDetail(state.order);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      ),
    );
  }

  Widget _buildDetail(OrderDetailModel order) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async => _refreshSilently(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.orderDetailOrderHash}${order.orderId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppStatusChip(
                  label: order.status.label,
                  tone: orderStatusTone(order.status),
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.my_location,
                  label: l10n.commonPickup,
                  value: order.pickupLocation,
                ),
                if (order.dropoffLocation != null) ...[
                  const Divider(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: l10n.commonDropoff,
                    value: order.dropoffLocation!,
                  ),
                ],
                const Divider(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.people_outline,
                  label: l10n.commonPassengers,
                  value: '${order.passengerCount} • ${order.priority.label}',
                ),
                if (order.scheduledAt != null) ...[
                  const Divider(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: l10n.orderDetailScheduled,
                    value: order.scheduledAt!.toLocal().toString().split('.').first,
                  ),
                ],
              ],
            ),
          ),
          if (order.hasDriverAssigned) ...[
            AppSectionHeader(title: l10n.commonDriver),
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
                          order.driverName ?? l10n.commonDriver,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.tripStatus?.label ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (order.vehiclePlateNumber != null)
              AppCard(
                child: _DetailRow(
                  icon: Icons.directions_car_outlined,
                  label: l10n.commonVehicle,
                  value:
                      '${order.vehicleMake ?? ''} ${order.vehicleModel ?? ''} '
                      '(${order.vehiclePlateNumber}) - ${order.vehicleColor ?? ''}',
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            BlocBuilder<TripRouteCubit, TripRouteState>(
              builder: (context, routeState) => _RouteSection(
                pickup: LatLng(order.pickupLat, order.pickupLng),
                dropoff: order.dropoffLat != null && order.dropoffLng != null
                    ? LatLng(order.dropoffLat!, order.dropoffLng!)
                    : null,
                fallbackDriverPosition: order.driverLastLat != null && order.driverLastLng != null
                    ? LatLng(order.driverLastLat!, order.driverLastLng!)
                    : null,
                routeState: routeState,
              ),
            ),
          ],
          if (order.rating != null)
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
                          '${l10n.orderDetailYourRating} ${order.rating?.stars ?? '-'} / 5',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (order.rating?.comment != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            order.rating!.comment!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          if (order.isActive)
            AppSecondaryButton(
              label: l10n.orderDetailCancelTitle,
              icon: Icons.cancel_outlined,
              onPressed: _confirmCancel,
            ),
          if (order.status == OrderStatusType.completed &&
              order.rating == null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppPrimaryButton(
              label: l10n.orderDetailRateDriver,
              icon: Icons.star_outline,
              onPressed: _goToRatingScreen,
            ),
          ],
          if (order.status == OrderStatusType.completed) ...[
            const SizedBox(height: AppSpacing.sm),
            AppSecondaryButton(
              label: l10n.orderDetailFileComplaint,
              icon: Icons.report_problem_outlined,
              onPressed: _goToRatingScreen,
            ),
          ],
        ],
      ),
    );
  }
}

/// Map + ETA/remaining-distance summary once a driver is assigned.
/// Stateless - all the live data already lives in [TripRouteState];
/// [fallbackDriverPosition] (the order detail's own last-known driver fix)
/// only fills the marker in before the first live SignalR position
/// arrives.
class _RouteSection extends StatelessWidget {
  final LatLng pickup;
  final LatLng? dropoff;
  final LatLng? fallbackDriverPosition;
  final TripRouteState routeState;

  const _RouteSection({
    required this.pickup,
    required this.dropoff,
    required this.fallbackDriverPosition,
    required this.routeState,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final loaded = routeState is TripRouteLoaded ? routeState as TripRouteLoaded : null;
    final routePoints = (loaded?.route.points ?? const [])
        .map((p) => LatLng(p.lat, p.lng))
        .toList();
    final driverPosition = loaded?.driverPosition ?? fallbackDriverPosition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TripRouteMap(
          pickup: pickup,
          dropoff: dropoff,
          driverPosition: driverPosition,
          routePoints: routePoints,
        ),
        if (routePoints.length >= 2 && driverPosition != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) {
              final progress = computeRouteProgress(routePoints, driverPosition);
              final totalMinutes = loaded?.route.totalMinutes ?? 0;
              final etaMinutes = totalMinutes > 0 && progress.totalMeters > 0
                  ? (totalMinutes * progress.remainingMeters / progress.totalMeters).round()
                  : totalMinutes;

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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
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
