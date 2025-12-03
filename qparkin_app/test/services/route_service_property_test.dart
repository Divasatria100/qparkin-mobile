import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/data/services/route_service.dart';
import 'package:qparkin_app/data/models/route_data.dart';

/// Property-based test for RouteService
/// Tests universal properties that should hold across all valid inputs
/// 
/// **Feature: osm-map-integration, Property 9: Route Calculation Trigger**
/// **Validates: Requirements 4.1**
void main() {
  group('RouteService Property Tests', () {
    late RouteService routeService;

    setUp(() {
      routeService = RouteService();
    });

    test(
      'Property 9: Route Calculation Trigger - '
      'For any mall selection with valid location, route should be calculated',
      () async {
        // Run property test with 100 iterations as specified in design
        const int iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Generate random valid origin and destination in Batam area
          // Batam coordinates: lat 1.0-1.2, lng 103.9-104.1
          final origin = _generateRandomBatamLocation();
          final destination = _generateRandomBatamLocation();

          try {
            // Calculate route
            final route = await routeService.calculateRoute(origin, destination);

            // Verify route was calculated successfully
            expect(route, isNotNull, reason: 'Route should not be null');
            expect(route.polylinePoints, isNotEmpty,
                reason: 'Route should have polyline points');
            expect(route.distanceInKm, greaterThan(0),
                reason: 'Distance should be positive');
            expect(route.durationInMinutes, greaterThan(0),
                reason: 'Duration should be positive');

            // Verify polyline starts near origin and ends near destination
            final firstPoint = route.polylinePoints.first;
            final lastPoint = route.polylinePoints.last;

            // Allow some tolerance for routing (within 1km)
            final distanceToOrigin = _calculateDistance(origin, firstPoint);
            final distanceToDestination =
                _calculateDistance(destination, lastPoint);

            expect(distanceToOrigin, lessThan(1.0),
                reason: 'Route should start near origin');
            expect(distanceToDestination, lessThan(1.0),
                reason: 'Route should end near destination');

            successCount++;
          } catch (e) {
            // Network errors are acceptable in property tests
            // but other errors should fail the test
            if (e is! NetworkException) {
              fail('Unexpected error for valid coordinates: $e');
            }
          }
        }

        // At least 80% of iterations should succeed
        // (allowing for occasional network issues)
        expect(successCount, greaterThan(iterations * 0.8),
            reason: 'At least 80% of route calculations should succeed');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'Property: Route calculation should reject invalid coordinates',
      () async {
        // Test with 50 iterations of invalid coordinates
        const int iterations = 50;

        for (int i = 0; i < iterations; i++) {
          // Generate invalid coordinates
          final invalidOrigin = _generateInvalidLocation();
          final validDestination = _generateRandomBatamLocation();

          // Should throw InvalidCoordinatesException
          expect(
            () => routeService.calculateRoute(invalidOrigin, validDestination),
            throwsA(isA<InvalidCoordinatesException>()),
            reason: 'Should reject invalid origin coordinates',
          );

          // Test with invalid destination
          final validOrigin = _generateRandomBatamLocation();
          final invalidDestination = _generateInvalidLocation();

          expect(
            () => routeService.calculateRoute(validOrigin, invalidDestination),
            throwsA(isA<InvalidCoordinatesException>()),
            reason: 'Should reject invalid destination coordinates',
          );
        }
      },
    );

    test(
      'Property: Route polyline extraction should preserve all points',
      () async {
        // Test with 20 iterations (fewer due to network calls)
        const int iterations = 20;

        for (int i = 0; i < iterations; i++) {
          final origin = _generateRandomBatamLocation();
          final destination = _generateRandomBatamLocation();

          try {
            final route = await routeService.calculateRoute(origin, destination);
            final polyline = routeService.getRoutePolyline(route);

            // Verify polyline extraction preserves all points
            expect(polyline.length, equals(route.polylinePoints.length),
                reason: 'Polyline should contain all route points');

            // Verify points are identical
            for (int j = 0; j < polyline.length; j++) {
              expect(polyline[j].latitude, equals(route.polylinePoints[j].latitude));
              expect(polyline[j].longitude, equals(route.polylinePoints[j].longitude));
            }
          } catch (e) {
            // Skip network errors
            if (e is! NetworkException) {
              fail('Unexpected error: $e');
            }
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}

/// Generate a random location within Batam area
/// Batam coordinates: lat 1.0-1.2, lng 103.9-104.1
GeoPoint _generateRandomBatamLocation() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2; // 1.0 to 1.2
  final lng = 103.9 + random.nextDouble() * 0.2; // 103.9 to 104.1
  return GeoPoint(latitude: lat, longitude: lng);
}

/// Generate an invalid location (outside valid coordinate ranges)
GeoPoint _generateInvalidLocation() {
  final random = Random();
  final choice = random.nextInt(4);

  switch (choice) {
    case 0:
      // Invalid latitude (> 90)
      return GeoPoint(latitude: 91.0 + random.nextDouble() * 10, longitude: 104.0);
    case 1:
      // Invalid latitude (< -90)
      return GeoPoint(latitude: -91.0 - random.nextDouble() * 10, longitude: 104.0);
    case 2:
      // Invalid longitude (> 180)
      return GeoPoint(latitude: 1.1, longitude: 181.0 + random.nextDouble() * 10);
    case 3:
    default:
      // Invalid longitude (< -180)
      return GeoPoint(latitude: 1.1, longitude: -181.0 - random.nextDouble() * 10);
  }
}

/// Calculate distance between two points using Haversine formula
/// Returns distance in kilometers
double _calculateDistance(GeoPoint point1, GeoPoint point2) {
  const double earthRadiusKm = 6371.0;

  final lat1Rad = _degreesToRadians(point1.latitude);
  final lat2Rad = _degreesToRadians(point2.latitude);
  final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
  final deltaLonRad = _degreesToRadians(point2.longitude - point1.longitude);

  final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

/// Convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * pi / 180.0;
}
