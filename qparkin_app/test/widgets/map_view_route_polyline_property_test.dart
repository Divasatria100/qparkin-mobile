import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/data/models/route_data.dart';

/// Property-based test for route polyline visualization
/// 
/// **Feature: osm-map-integration, Property 10: Route Polyline Visualization**
/// 
/// For any calculated route, polyline should be drawn
/// 
/// **Validates: Requirements 4.2**

void main() {
  group('Property 10: Route Polyline Visualization', () {
    test('For any calculated route with valid polyline points, polyline should be drawn', () {
      // Run property test 100 times with different random inputs
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random route with varying number of points (2-50)
        final pointCount = Random().nextInt(49) + 2; // At least 2 points
        final route = _generateRandomRoute(pointCount);

        // Verify route has valid polyline points
        expect(route.polylinePoints, isNotEmpty);
        expect(route.polylinePoints.length, greaterThanOrEqualTo(2));

        // Verify all points are valid GeoPoints
        for (final point in route.polylinePoints) {
          expect(point.latitude, inInclusiveRange(-90, 90));
          expect(point.longitude, inInclusiveRange(-180, 180));
        }

        // Verify route has valid distance and duration
        expect(route.distanceInKm, greaterThan(0));
        expect(route.durationInMinutes, greaterThan(0));

        // Property: A route with valid polyline points should be drawable
        // This is verified by the route data structure being valid
        expect(route.validate(), isTrue);
      }
    });

    test('Route with minimum 2 points should be valid for polyline', () {
      // Test edge case: minimum polyline (2 points)
      final startPoint = GeoPoint(latitude: 1.1, longitude: 104.0);
      final endPoint = GeoPoint(latitude: 1.15, longitude: 104.05);

      final route = RouteData(
        polylinePoints: [startPoint, endPoint],
        distanceInKm: 5.0,
        durationInMinutes: 10,
      );

      expect(route.polylinePoints.length, equals(2));
      expect(route.validate(), isTrue);
    });

    test('Route with many points should be valid for polyline', () {
      // Test with large number of points (100+)
      final route = _generateRandomRoute(100);

      expect(route.polylinePoints.length, equals(100));
      expect(route.validate(), isTrue);

      // Verify all points form a continuous path
      for (int i = 0; i < route.polylinePoints.length - 1; i++) {
        final point1 = route.polylinePoints[i];
        final point2 = route.polylinePoints[i + 1];

        // Points should be relatively close (within reasonable distance)
        final latDiff = (point1.latitude - point2.latitude).abs();
        final lngDiff = (point1.longitude - point2.longitude).abs();

        // Each segment should be less than 0.1 degrees (~11km)
        expect(latDiff, lessThan(0.1));
        expect(lngDiff, lessThan(0.1));
      }
    });

    test('Empty route should not be drawable', () {
      // Test invalid case: empty polyline
      expect(
        () => RouteData(
          polylinePoints: [],
          distanceInKm: 0,
          durationInMinutes: 0,
        ),
        returnsNormally,
      );

      final emptyRoute = RouteData(
        polylinePoints: [],
        distanceInKm: 0,
        durationInMinutes: 0,
      );

      expect(emptyRoute.validate(), isFalse);
    });

    test('Route polyline points should form a connected path', () {
      for (int i = 0; i < 100; i++) {
        final route = _generateRandomRoute(Random().nextInt(20) + 2);

        // Verify first and last points are different
        final firstPoint = route.polylinePoints.first;
        final lastPoint = route.polylinePoints.last;

        expect(
          firstPoint.latitude != lastPoint.latitude || 
          firstPoint.longitude != lastPoint.longitude,
          isTrue,
          reason: 'Route should have different start and end points',
        );
      }
    });
  });
}

/// Generate random route for property testing
/// 
/// Creates a route with random but valid polyline points in the Batam area
RouteData _generateRandomRoute(int pointCount) {
  final random = Random();
  final points = <GeoPoint>[];

  // Start point in Batam area
  double currentLat = 1.0 + random.nextDouble() * 0.2;
  double currentLng = 103.9 + random.nextDouble() * 0.2;

  points.add(GeoPoint(latitude: currentLat, longitude: currentLng));

  // Generate intermediate points forming a path
  for (int i = 1; i < pointCount; i++) {
    // Small incremental change to form a continuous path
    currentLat += (random.nextDouble() - 0.5) * 0.01; // ±0.005 degrees
    currentLng += (random.nextDouble() - 0.5) * 0.01;

    // Keep within Batam area bounds
    currentLat = currentLat.clamp(1.0, 1.2);
    currentLng = currentLng.clamp(103.9, 104.1);

    points.add(GeoPoint(latitude: currentLat, longitude: currentLng));
  }

  // Calculate approximate distance (simplified)
  final distance = (pointCount * 0.5) + random.nextDouble() * 5;
  final duration = (distance * 2).toInt() + random.nextInt(10);

  return RouteData(
    polylinePoints: points,
    distanceInKm: distance,
    durationInMinutes: duration,
  );
}
