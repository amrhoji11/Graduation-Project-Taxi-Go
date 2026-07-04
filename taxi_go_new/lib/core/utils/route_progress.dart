import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The split of a route's points into what's already been driven and
/// what's left, as of one driver position. `completedPoints` and
/// `remainingPoints` share their boundary point so the two polylines built
/// from them connect with no visible gap.
class RouteProgress {
  final List<LatLng> completedPoints;
  final List<LatLng> remainingPoints;
  final double traveledMeters;
  final double remainingMeters;

  const RouteProgress({
    required this.completedPoints,
    required this.remainingPoints,
    required this.traveledMeters,
    required this.remainingMeters,
  });

  double get totalMeters => traveledMeters + remainingMeters;
}

/// Splits [routePoints] (the full real-road route, in order) into a
/// completed/remaining pair based on the nearest point on the route to
/// [driverPosition]. Pure and cheap (a single O(n) pass) - safe to call on
/// every GPS update without any network round-trip, which is what keeps
/// the map redraw flicker-free.
RouteProgress computeRouteProgress(
  List<LatLng> routePoints,
  LatLng driverPosition,
) {
  if (routePoints.length < 2) {
    return RouteProgress(
      completedPoints: const [],
      remainingPoints: routePoints,
      traveledMeters: 0,
      remainingMeters: 0,
    );
  }

  var bestSegmentIndex = 0;
  var bestProjection = routePoints.first;
  var bestDistanceToDriver = double.infinity;

  for (var i = 0; i < routePoints.length - 1; i++) {
    final projection = _projectOntoSegment(
      routePoints[i],
      routePoints[i + 1],
      driverPosition,
    );

    final distanceToDriver = Geolocator.distanceBetween(
      driverPosition.latitude,
      driverPosition.longitude,
      projection.latitude,
      projection.longitude,
    );

    if (distanceToDriver < bestDistanceToDriver) {
      bestDistanceToDriver = distanceToDriver;
      bestSegmentIndex = i;
      bestProjection = projection;
    }
  }

  final completedPoints = <LatLng>[
    ...routePoints.sublist(0, bestSegmentIndex + 1),
    bestProjection,
  ];
  final remainingPoints = <LatLng>[
    bestProjection,
    ...routePoints.sublist(bestSegmentIndex + 1),
  ];

  return RouteProgress(
    completedPoints: completedPoints,
    remainingPoints: remainingPoints,
    traveledMeters: _pathLengthMeters(completedPoints),
    remainingMeters: _pathLengthMeters(remainingPoints),
  );
}

double _pathLengthMeters(List<LatLng> points) {
  var total = 0.0;

  for (var i = 0; i < points.length - 1; i++) {
    total += Geolocator.distanceBetween(
      points[i].latitude,
      points[i].longitude,
      points[i + 1].latitude,
      points[i + 1].longitude,
    );
  }

  return total;
}

/// Projects [p] onto segment [a]-[b] using a local equirectangular
/// approximation (longitude scaled by cos(latitude)) - accurate enough for
/// the short, city-block-scale segments between consecutive route points,
/// without pulling in a full geodesy library for this.
LatLng _projectOntoSegment(LatLng a, LatLng b, LatLng p) {
  final cosLat = math.cos(a.latitude * math.pi / 180);

  final ax = a.longitude * cosLat;
  final ay = a.latitude;
  final bx = b.longitude * cosLat;
  final by = b.latitude;
  final px = p.longitude * cosLat;
  final py = p.latitude;

  final dx = bx - ax;
  final dy = by - ay;
  final lengthSquared = dx * dx + dy * dy;

  var t = lengthSquared == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / lengthSquared;
  t = t.clamp(0.0, 1.0);

  return LatLng(
    a.latitude + t * (b.latitude - a.latitude),
    a.longitude + t * (b.longitude - a.longitude),
  );
}
