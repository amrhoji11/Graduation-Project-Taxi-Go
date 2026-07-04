import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/utils/route_progress.dart';
import 'package:taxi_go_new/core/utils/trip_format.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/trips/cubit/admin_current_trips_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_current_trip_model.dart';

/// Live view of every trip currently in progress (Assigned/DriverArrived/
/// InProgress) - a map with one marker per driver plus a detail list below,
/// refreshed on a timer (see [AdminCurrentTripsCubit] for why polling
/// instead of SignalR).
class AdminCurrentTripsScreen extends StatefulWidget {
  const AdminCurrentTripsScreen({super.key});

  @override
  State<AdminCurrentTripsScreen> createState() => _AdminCurrentTripsScreenState();
}

class _AdminCurrentTripsScreenState extends State<AdminCurrentTripsScreen> {
  static const LatLng _fallbackCenter = LatLng(31.9038, 35.2034); // Ramallah

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    context.read<AdminCurrentTripsCubit>().load();
    context.read<AdminCurrentTripsCubit>().startPolling();
    context.read<AdminCurrentTripsCubit>().startRealtime();
  }

  @override
  void dispose() {
    context.read<AdminCurrentTripsCubit>().stopPolling();
    context.read<AdminCurrentTripsCubit>().stopRealtime();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<AdminCurrentTripModel> trips) {
    final markers = <Marker>{};

    for (final t in trips) {
      if (t.driverLastLat != null && t.driverLastLng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('driver-${t.tripId}'),
            position: LatLng(t.driverLastLat!, t.driverLastLng!),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: t.driverName,
              snippet: t.detailedStatus,
            ),
          ),
        );
      }

      if (t.orders.isEmpty) continue;
      final order = t.orders.first;

      markers.add(
        Marker(
          markerId: MarkerId('pickup-${t.tripId}'),
          position: LatLng(order.pickupLat, order.pickupLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: order.pickupLocation),
        ),
      );

      if (order.dropoffLat != null && order.dropoffLng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('dropoff-${t.tripId}'),
            position: LatLng(order.dropoffLat!, order.dropoffLng!),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: order.dropoffLocation),
          ),
        );
      }
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(List<AdminCurrentTripModel> trips) {
    final polylines = <Polyline>{};

    for (final t in trips) {
      if (t.routePoints.length < 2) continue;

      final routePoints = t.routePoints.map((p) => LatLng(p.lat, p.lng)).toList();

      if (t.driverLastLat == null || t.driverLastLng == null) {
        // No driver fix yet - show the full route in one color rather
        // than nothing.
        polylines.add(
          Polyline(
            polylineId: PolylineId('route-${t.tripId}'),
            points: routePoints,
            color: AppColors.primary,
            width: 4,
          ),
        );
        continue;
      }

      final progress = computeRouteProgress(
        routePoints,
        LatLng(t.driverLastLat!, t.driverLastLng!),
      );

      if (progress.completedPoints.length >= 2) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('route-completed-${t.tripId}'),
            points: progress.completedPoints,
            color: AppColors.neutral,
            width: 4,
          ),
        );
      }

      if (progress.remainingPoints.length >= 2) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('route-remaining-${t.tripId}'),
            points: progress.remainingPoints,
            color: AppColors.primary,
            width: 4,
          ),
        );
      }
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminCurrentTripsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminCurrentTripsCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<AdminCurrentTripsCubit, AdminCurrentTripsState>(
        builder: (context, state) {
          if (state is AdminCurrentTripsLoading || state is AdminCurrentTripsInitial) {
            return const AppLoading();
          }

          if (state is AdminCurrentTripsFailure) {
            return AppErrorState(
              message: state.message,
              onRetry: () => context.read<AdminCurrentTripsCubit>().load(),
            );
          }

          final trips = (state as AdminCurrentTripsLoaded).trips;

          if (trips.isEmpty) {
            return AppEmptyState(
              icon: Icons.map_outlined,
              title: AppLocalizations.of(context)!.adminNoActiveTrips,
            );
          }

          final markers = _buildMarkers(trips);
          final polylines = _buildPolylines(trips);
          final firstWithLocation = trips.firstWhere(
            (t) => t.driverLastLat != null && t.driverLastLng != null,
            orElse: () => trips.first,
          );
          final initialCenter = firstWithLocation.driverLastLat != null
              ? LatLng(firstWithLocation.driverLastLat!, firstWithLocation.driverLastLng!)
              : _fallbackCenter;

          return Column(
            children: [
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: initialCenter, zoom: 11),
                  markers: markers,
                  polylines: polylines,
                  onMapCreated: (controller) => _mapController = controller,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: trips.length,
                  itemBuilder: (context, index) => _TripCard(trip: trips[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final AdminCurrentTripModel trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                backgroundImage: trip.driverProfilePhotoUrl != null
                    ? NetworkImage(trip.driverProfilePhotoUrl!)
                    : null,
                child: trip.driverProfilePhotoUrl == null
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.driverTripHash}${trip.tripId} - ${trip.driverName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.vehiclePlateNumber != null
                          ? '${trip.vehicleMake ?? ''} ${trip.vehicleModel ?? ''} (${trip.vehiclePlateNumber})'
                          : l10n.commonNoVehicle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              AppStatusChip(
                label: trip.detailedStatus,
                tone: tripStatusTone(trip.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...trip.orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${order.passengerName}: ${order.pickupLocation} -> ${order.dropoffLocation ?? l10n.commonNA}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (trip.etaMinutes != null ||
              trip.totalDistanceMeters != null ||
              trip.coveredDistanceMeters != null ||
              trip.remainingDistanceMeters != null) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: 4,
              children: [
                if (trip.etaMinutes != null)
                  _InfoChip(text: l10n.commonEtaLabel(TripFormat.etaMinutes(trip.etaMinutes!))),
                if (trip.totalDistanceMeters != null)
                  _InfoChip(
                    text: l10n.commonDistanceTotalLabel(
                      TripFormat.distanceMeters(trip.totalDistanceMeters!),
                    ),
                  ),
                if (trip.coveredDistanceMeters != null)
                  _InfoChip(
                    text: l10n.commonDistanceCoveredLabel(
                      TripFormat.distanceMeters(trip.coveredDistanceMeters!),
                    ),
                  ),
                if (trip.remainingDistanceMeters != null)
                  _InfoChip(
                    text: l10n.commonDistanceRemainingLabel(
                      TripFormat.distanceMeters(trip.remainingDistanceMeters!),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
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
