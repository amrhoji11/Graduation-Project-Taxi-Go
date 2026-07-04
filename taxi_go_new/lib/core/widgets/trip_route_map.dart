import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/utils/route_progress.dart';

/// Shared trip route map: pickup/dropoff/driver markers plus a completed
/// (driven)/remaining two-color polyline. Used identically by the Admin,
/// Driver, and Passenger trip screens - each owns its own GPS/SignalR
/// plumbing (which differs per role) and just feeds in the latest known
/// points here. Rebuilding this widget only updates the `markers`/
/// `polylines` sets passed to [GoogleMap]; the plugin diffs them
/// internally rather than recreating the underlying native map view, so
/// frequent position updates don't cause a full map reload/flicker.
class TripRouteMap extends StatefulWidget {
  final LatLng pickup;
  final LatLng? dropoff;
  final LatLng? driverPosition;
  final List<LatLng> routePoints;
  final double height;

  const TripRouteMap({
    super.key,
    required this.pickup,
    this.dropoff,
    this.driverPosition,
    this.routePoints = const [],
    this.height = 260,
  });

  @override
  State<TripRouteMap> createState() => _TripRouteMapState();
}

class _TripRouteMapState extends State<TripRouteMap> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      if (widget.dropoff != null)
        Marker(
          markerId: const MarkerId('dropoff'),
          position: widget.dropoff!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      if (widget.driverPosition != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: widget.pickup, zoom: 13),
          markers: markers,
          polylines: _buildPolylines(),
          onMapCreated: (controller) => _controller = controller,
        ),
      ),
    );
  }

  Set<Polyline> _buildPolylines() {
    if (widget.routePoints.length < 2) return const {};

    // No driver position yet (e.g. just assigned, no GPS fix received)
    // - show the full route in one color rather than nothing.
    if (widget.driverPosition == null) {
      return {
        Polyline(
          polylineId: const PolylineId('full'),
          points: widget.routePoints,
          color: AppColors.primary,
          width: 5,
        ),
      };
    }

    final progress = computeRouteProgress(widget.routePoints, widget.driverPosition!);
    final polylines = <Polyline>{};

    if (progress.completedPoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('completed'),
          points: progress.completedPoints,
          color: AppColors.neutral,
          width: 5,
        ),
      );
    }

    if (progress.remainingPoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('remaining'),
          points: progress.remainingPoints,
          color: AppColors.primary,
          width: 5,
        ),
      );
    }

    return polylines;
  }
}
