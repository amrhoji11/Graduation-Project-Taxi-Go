import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_go_new/core/utils/route_progress.dart';

void main() {
  group('computeRouteProgress', () {
    // A straight north-south route, ~3 segments of roughly equal length.
    final route = <LatLng>[
      const LatLng(31.9000, 35.2000),
      const LatLng(31.9100, 35.2000),
      const LatLng(31.9200, 35.2000),
      const LatLng(31.9300, 35.2000),
    ];

    final totalMeters = () {
      var total = 0.0;
      for (var i = 0; i < route.length - 1; i++) {
        total += Geolocator.distanceBetween(
          route[i].latitude,
          route[i].longitude,
          route[i + 1].latitude,
          route[i + 1].longitude,
        );
      }
      return total;
    }();

    test('completed + remaining distance sums to the total route distance', () {
      final driverPosition = const LatLng(31.9150, 35.2000); // mid-route

      final progress = computeRouteProgress(route, driverPosition);

      expect(progress.totalMeters, closeTo(totalMeters, 1.0));
    });

    test('driver near the start yields a small completed distance', () {
      final driverPosition = const LatLng(31.9005, 35.2000);

      final progress = computeRouteProgress(route, driverPosition);

      expect(progress.traveledMeters, lessThan(progress.remainingMeters));
      expect(progress.traveledMeters, lessThan(1000));
    });

    test('driver near the end yields a small remaining distance', () {
      final driverPosition = const LatLng(31.9295, 35.2000);

      final progress = computeRouteProgress(route, driverPosition);

      expect(progress.remainingMeters, lessThan(progress.traveledMeters));
      expect(progress.remainingMeters, lessThan(1000));
    });

    test('completed and remaining polylines share a boundary point', () {
      final driverPosition = const LatLng(31.9150, 35.2000);

      final progress = computeRouteProgress(route, driverPosition);

      expect(
        progress.completedPoints.last.latitude,
        closeTo(progress.remainingPoints.first.latitude, 1e-9),
      );
      expect(
        progress.completedPoints.last.longitude,
        closeTo(progress.remainingPoints.first.longitude, 1e-9),
      );
    });

    test('fewer than 2 route points yields zero-length progress', () {
      final progress = computeRouteProgress(
        [const LatLng(31.9000, 35.2000)],
        const LatLng(31.9000, 35.2000),
      );

      expect(progress.traveledMeters, 0);
      expect(progress.remainingMeters, 0);
    });
  });
}
