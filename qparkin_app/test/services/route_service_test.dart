import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/data/services/route_service.dart';
import 'package:qparkin_app/data/models/route_data.dart';

/// Unit tests for RouteService
/// Tests specific examples, edge cases, and error conditions
void main() {
  group('RouteService', () {
    late RouteService routeService;

    setUp(() {
      routeService = RouteService();
    });

    group('calculateRoute', () {
      test('should calculate route with valid coordinates in Batam', () async {
        // Arrange: Two mall locations in Batam
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538); // Mega Mall
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534); // BCS Mall

        // Act
        final route = await routeService.calculateRoute(origin, destination);

        // Assert
        expect(route, isNotNull);
        expect(route.polylinePoints, isNotEmpty);
        expect(route.distanceInKm, greaterThan(0));
        expect(route.durationInMinutes, greaterThan(0));
        
        // Verify route starts near origin
        final firstPoint = route.polylinePoints.first;
        expect(firstPoint.latitude, closeTo(origin.latitude, 0.01));
        expect(firstPoint.longitude, closeTo(origin.longitude, 0.01));
        
        // Verify route ends near destination
        final lastPoint = route.polylinePoints.last;
        expect(lastPoint.latitude, closeTo(destination.latitude, 0.01));
        expect(lastPoint.longitude, closeTo(destination.longitude, 0.01));
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should calculate route between distant points', () async {
        // Arrange: Points further apart in Batam
        final origin = GeoPoint(latitude: 1.0822, longitude: 103.9635); // Grand Batam Mall
        final destination = GeoPoint(latitude: 1.1456, longitude: 104.0304); // Kepri Mall

        // Act
        final route = await routeService.calculateRoute(origin, destination);

        // Assert
        expect(route, isNotNull);
        expect(route.polylinePoints, isNotEmpty);
        expect(route.distanceInKm, greaterThan(1.0)); // Should be > 1km apart
        expect(route.durationInMinutes, greaterThan(0));
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should throw InvalidCoordinatesException for invalid origin latitude', () async {
        // Arrange: Invalid latitude (> 90)
        final invalidOrigin = GeoPoint(latitude: 95.0, longitude: 104.0);
        final validDestination = GeoPoint(latitude: 1.1191, longitude: 104.0538);

        // Act & Assert
        expect(
          () => routeService.calculateRoute(invalidOrigin, validDestination),
          throwsA(isA<InvalidCoordinatesException>()),
        );
      });

      test('should throw InvalidCoordinatesException for invalid origin longitude', () async {
        // Arrange: Invalid longitude (< -180)
        final invalidOrigin = GeoPoint(latitude: 1.1191, longitude: -185.0);
        final validDestination = GeoPoint(latitude: 1.1304, longitude: 104.0534);

        // Act & Assert
        expect(
          () => routeService.calculateRoute(invalidOrigin, validDestination),
          throwsA(isA<InvalidCoordinatesException>()),
        );
      });

      test('should throw InvalidCoordinatesException for invalid destination latitude', () async {
        // Arrange: Invalid latitude (< -90)
        final validOrigin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final invalidDestination = GeoPoint(latitude: -95.0, longitude: 104.0);

        // Act & Assert
        expect(
          () => routeService.calculateRoute(validOrigin, invalidDestination),
          throwsA(isA<InvalidCoordinatesException>()),
        );
      });

      test('should throw InvalidCoordinatesException for invalid destination longitude', () async {
        // Arrange: Invalid longitude (> 180)
        final validOrigin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final invalidDestination = GeoPoint(latitude: 1.1304, longitude: 185.0);

        // Act & Assert
        expect(
          () => routeService.calculateRoute(validOrigin, invalidDestination),
          throwsA(isA<InvalidCoordinatesException>()),
        );
      });

      test('should handle edge case: latitude at boundary (90)', () async {
        // Arrange: Valid boundary latitude
        final origin = GeoPoint(latitude: 90.0, longitude: 0.0);
        final destination = GeoPoint(latitude: 89.0, longitude: 0.0);

        // Act & Assert
        // Should not throw InvalidCoordinatesException
        // May throw RouteCalculationException or NetworkException due to routing issues
        try {
          await routeService.calculateRoute(origin, destination);
        } catch (e) {
          expect(e, isNot(isA<InvalidCoordinatesException>()));
        }
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should handle edge case: latitude at boundary (-90)', () async {
        // Arrange: Valid boundary latitude
        final origin = GeoPoint(latitude: -90.0, longitude: 0.0);
        final destination = GeoPoint(latitude: -89.0, longitude: 0.0);

        // Act & Assert
        // Should not throw InvalidCoordinatesException
        try {
          await routeService.calculateRoute(origin, destination);
        } catch (e) {
          expect(e, isNot(isA<InvalidCoordinatesException>()));
        }
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should handle edge case: longitude at boundary (180)', () async {
        // Arrange: Valid boundary longitude
        final origin = GeoPoint(latitude: 0.0, longitude: 180.0);
        final destination = GeoPoint(latitude: 0.0, longitude: 179.0);

        // Act & Assert
        // Should not throw InvalidCoordinatesException
        try {
          await routeService.calculateRoute(origin, destination);
        } catch (e) {
          expect(e, isNot(isA<InvalidCoordinatesException>()));
        }
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should handle edge case: longitude at boundary (-180)', () async {
        // Arrange: Valid boundary longitude
        final origin = GeoPoint(latitude: 0.0, longitude: -180.0);
        final destination = GeoPoint(latitude: 0.0, longitude: -179.0);

        // Act & Assert
        // Should not throw InvalidCoordinatesException
        try {
          await routeService.calculateRoute(origin, destination);
        } catch (e) {
          expect(e, isNot(isA<InvalidCoordinatesException>()));
        }
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should calculate reasonable distance and duration', () async {
        // Arrange: Two nearby points
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);

        // Act
        final route = await routeService.calculateRoute(origin, destination);

        // Assert: Distance should be reasonable (< 5km for nearby points)
        expect(route.distanceInKm, lessThan(5.0));
        
        // Assert: Duration should be reasonable (< 30 minutes for nearby points)
        expect(route.durationInMinutes, lessThan(30));
        
        // Assert: Distance and duration should be positive
        expect(route.distanceInKm, greaterThan(0));
        expect(route.durationInMinutes, greaterThan(0));
      }, timeout: const Timeout(Duration(seconds: 15)));
    });

    group('getRoutePolyline', () {
      test('should extract polyline points from RouteData', () async {
        // Arrange: Calculate a route first
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);
        final route = await routeService.calculateRoute(origin, destination);

        // Act
        final polyline = routeService.getRoutePolyline(route);

        // Assert
        expect(polyline, isNotEmpty);
        expect(polyline.length, equals(route.polylinePoints.length));
        
        // Verify points are identical
        for (int i = 0; i < polyline.length; i++) {
          expect(polyline[i].latitude, equals(route.polylinePoints[i].latitude));
          expect(polyline[i].longitude, equals(route.polylinePoints[i].longitude));
        }
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should return empty list for RouteData with no points', () {
        // Arrange: Create RouteData with empty polyline
        final route = RouteData(
          polylinePoints: [],
          distanceInKm: 0.0,
          durationInMinutes: 0,
        );

        // Act
        final polyline = routeService.getRoutePolyline(route);

        // Assert
        expect(polyline, isEmpty);
      });

      test('should preserve all polyline points', () async {
        // Arrange: Calculate a route
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);
        final route = await routeService.calculateRoute(origin, destination);
        final originalPointCount = route.polylinePoints.length;

        // Act
        final polyline = routeService.getRoutePolyline(route);

        // Assert: All points should be preserved
        expect(polyline.length, equals(originalPointCount));
      }, timeout: const Timeout(Duration(seconds: 15)));
    });

    group('Error Handling', () {
      test('should handle network timeout gracefully', () async {
        // Note: This test may pass or fail depending on network conditions
        // It's here to document expected behavior
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);

        try {
          await routeService.calculateRoute(origin, destination);
        } catch (e) {
          // If network error occurs, it should be a NetworkException
          if (e is NetworkException) {
            expect(e.toString(), contains('NetworkException'));
          }
        }
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should provide meaningful error messages', () async {
        // Arrange: Invalid coordinates
        final invalidOrigin = GeoPoint(latitude: 100.0, longitude: 104.0);
        final validDestination = GeoPoint(latitude: 1.1191, longitude: 104.0538);

        // Act & Assert
        try {
          await routeService.calculateRoute(invalidOrigin, validDestination);
          fail('Should have thrown InvalidCoordinatesException');
        } catch (e) {
          expect(e, isA<InvalidCoordinatesException>());
          expect(e.toString(), contains('Invalid'));
          expect(e.toString(), contains('latitude'));
        }
      });
    });

    group('Distance and Duration Calculations', () {
      test('should calculate distance correctly', () async {
        // Arrange: Two points with known approximate distance
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);

        // Act
        final route = await routeService.calculateRoute(origin, destination);

        // Assert: Distance should be positive and reasonable
        expect(route.distanceInKm, greaterThan(0));
        expect(route.distanceInKm, lessThan(10.0)); // Should be < 10km
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should calculate duration correctly', () async {
        // Arrange
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);

        // Act
        final route = await routeService.calculateRoute(origin, destination);

        // Assert: Duration should be positive and reasonable
        expect(route.durationInMinutes, greaterThan(0));
        expect(route.durationInMinutes, lessThan(60)); // Should be < 1 hour
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should have consistent distance-duration relationship', () async {
        // Arrange
        final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
        final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);

        // Act
        final route = await routeService.calculateRoute(origin, destination);

        // Assert: Average speed should be reasonable (between 10-100 km/h)
        final averageSpeedKmh = (route.distanceInKm / route.durationInMinutes) * 60;
        expect(averageSpeedKmh, greaterThan(10.0)); // Minimum reasonable speed
        expect(averageSpeedKmh, lessThan(100.0)); // Maximum reasonable speed
      }, timeout: const Timeout(Duration(seconds: 15)));
    });
  });
}
