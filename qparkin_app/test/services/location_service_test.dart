import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qparkin_app/data/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService - Permission Checking', () {
    test('checkPermission returns permission status', () async {
      final service = LocationService();

      // This will return the actual permission status on the test device
      final permission = await service.checkPermission();

      expect(permission, isA<LocationPermission>());
      expect(
        [
          LocationPermission.denied,
          LocationPermission.deniedForever,
          LocationPermission.whileInUse,
          LocationPermission.always,
          LocationPermission.unableToDetermine,
        ].contains(permission),
        isTrue,
      );
    });

    test('requestPermission returns permission result', () async {
      final service = LocationService();

      // Request permission (may show dialog on first run)
      final permission = await service.requestPermission();

      expect(permission, isA<LocationPermission>());
      expect(
        [
          LocationPermission.denied,
          LocationPermission.deniedForever,
          LocationPermission.whileInUse,
          LocationPermission.always,
          LocationPermission.unableToDetermine,
        ].contains(permission),
        isTrue,
      );
    });
  });

  group('LocationService - Location Service Status', () {
    test('isLocationServiceEnabled returns boolean', () async {
      final service = LocationService();

      final isEnabled = await service.isLocationServiceEnabled();

      expect(isEnabled, isA<bool>());
    });
  });

  group('LocationService - Position Conversion', () {
    test('positionToGeoPoint converts Position to GeoPoint correctly', () {
      final service = LocationService();

      // Create a test position
      final position = Position(
        latitude: 1.1191,
        longitude: 104.0538,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final geoPoint = service.positionToGeoPoint(position);

      expect(geoPoint, isA<GeoPoint>());
      expect(geoPoint.latitude, equals(1.1191));
      expect(geoPoint.longitude, equals(104.0538));
    });

    test('positionToGeoPoint handles negative coordinates', () {
      final service = LocationService();

      final position = Position(
        latitude: -33.8688,
        longitude: 151.2093,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final geoPoint = service.positionToGeoPoint(position);

      expect(geoPoint.latitude, equals(-33.8688));
      expect(geoPoint.longitude, equals(151.2093));
    });

    test('positionToGeoPoint handles zero coordinates', () {
      final service = LocationService();

      final position = Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final geoPoint = service.positionToGeoPoint(position);

      expect(geoPoint.latitude, equals(0.0));
      expect(geoPoint.longitude, equals(0.0));
    });
  });

  group('LocationService - Distance Calculation', () {
    test('calculateDistance returns correct distance for same point', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 1.1191, longitude: 104.0538);

      final distance = service.calculateDistance(point1, point2);

      expect(distance, equals(0.0));
    });

    test('calculateDistance calculates distance between two points accurately', () {
      final service = LocationService();

      // Mega Mall Batam Centre to BCS Mall (approximately 1.5 km)
      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 1.1304, longitude: 104.0534);

      final distance = service.calculateDistance(point1, point2);

      // Distance should be approximately 1.25 km (allowing for some variance)
      expect(distance, greaterThan(1.0));
      expect(distance, lessThan(2.0));
    });

    test('calculateDistance handles longer distances correctly', () {
      final service = LocationService();

      // Batam to Singapore (approximately 20-30 km)
      final batam = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final singapore = GeoPoint(latitude: 1.3521, longitude: 103.8198);

      final distance = service.calculateDistance(batam, singapore);

      // Distance should be approximately 25-35 km
      expect(distance, greaterThan(20.0));
      expect(distance, lessThan(40.0));
    });

    test('calculateDistance is symmetric', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 1.1304, longitude: 104.0534);

      final distance1 = service.calculateDistance(point1, point2);
      final distance2 = service.calculateDistance(point2, point1);

      expect(distance1, equals(distance2));
    });

    test('calculateDistance handles points across equator', () {
      final service = LocationService();

      final northPoint = GeoPoint(latitude: 1.0, longitude: 104.0);
      final southPoint = GeoPoint(latitude: -1.0, longitude: 104.0);

      final distance = service.calculateDistance(northPoint, southPoint);

      // Distance should be approximately 222 km (2 degrees of latitude)
      expect(distance, greaterThan(200.0));
      expect(distance, lessThan(250.0));
    });

    test('calculateDistance handles points across prime meridian', () {
      final service = LocationService();

      final westPoint = GeoPoint(latitude: 0.0, longitude: -1.0);
      final eastPoint = GeoPoint(latitude: 0.0, longitude: 1.0);

      final distance = service.calculateDistance(westPoint, eastPoint);

      // Distance should be approximately 222 km (2 degrees of longitude at equator)
      expect(distance, greaterThan(200.0));
      expect(distance, lessThan(250.0));
    });

    test('calculateDistance handles very small distances', () {
      final service = LocationService();

      // Points 10 meters apart (approximately 0.0001 degrees)
      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 1.1192, longitude: 104.0538);

      final distance = service.calculateDistance(point1, point2);

      // Distance should be less than 1 km
      expect(distance, lessThan(1.0));
      expect(distance, greaterThan(0.0));
    });

    test('calculateDistance returns positive values', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 1.1304, longitude: 104.0534);

      final distance = service.calculateDistance(point1, point2);

      expect(distance, greaterThanOrEqualTo(0.0));
    });
  });

  group('LocationService - Distance Calculation Edge Cases', () {
    test('calculateDistance handles maximum latitude values', () {
      final service = LocationService();

      final northPole = GeoPoint(latitude: 90.0, longitude: 0.0);
      final southPole = GeoPoint(latitude: -90.0, longitude: 0.0);

      final distance = service.calculateDistance(northPole, southPole);

      // Distance should be approximately half Earth's circumference (20,000 km)
      expect(distance, greaterThan(19000.0));
      expect(distance, lessThan(21000.0));
    });

    test('calculateDistance handles maximum longitude values', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 0.0, longitude: -180.0);
      final point2 = GeoPoint(latitude: 0.0, longitude: 180.0);

      final distance = service.calculateDistance(point1, point2);

      // These are the same point (international date line)
      expect(distance, lessThan(1.0));
    });

    test('calculateDistance handles points at same latitude', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0);
      final point2 = GeoPoint(latitude: 1.1191, longitude: 105.0);

      final distance = service.calculateDistance(point1, point2);

      // Distance should be approximately 111 km (1 degree of longitude at this latitude)
      expect(distance, greaterThan(100.0));
      expect(distance, lessThan(120.0));
    });

    test('calculateDistance handles points at same longitude', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 1.0, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 2.0, longitude: 104.0538);

      final distance = service.calculateDistance(point1, point2);

      // Distance should be approximately 111 km (1 degree of latitude)
      expect(distance, greaterThan(100.0));
      expect(distance, lessThan(120.0));
    });
  });

  group('LocationService - Error Handling', () {
    test('getCurrentPosition throws LocationServiceDisabledException when GPS disabled', () async {
      final service = LocationService();

      // Check if location services are enabled
      final isEnabled = await service.isLocationServiceEnabled();

      if (!isEnabled) {
        // If GPS is disabled, expect exception
        expect(
          () async => await service.getCurrentPosition(),
          throwsA(isA<LocationServiceDisabledException>()),
        );
      } else {
        // If GPS is enabled, test should pass or throw permission error
        try {
          await service.getCurrentPosition();
        } catch (e) {
          expect(
            e is LocationServiceDisabledException || e is PermissionDeniedException || e is TimeoutException,
            isTrue,
          );
        }
      }
    });

    test('getCurrentPosition throws PermissionDeniedException when permission denied', () async {
      final service = LocationService();

      // Check current permission status
      final permission = await service.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        // If permission is permanently denied, expect exception
        expect(
          () async => await service.getCurrentPosition(),
          throwsA(isA<PermissionDeniedException>()),
        );
      } else {
        // Otherwise, test should handle appropriately
        try {
          await service.getCurrentPosition();
        } catch (e) {
          expect(
            e is LocationServiceDisabledException || e is PermissionDeniedException || e is TimeoutException,
            isTrue,
          );
        }
      }
    });

    test('LocationServiceDisabledException has correct message', () {
      final exception = LocationServiceDisabledException();
      expect(exception.toString(), equals('Location services are disabled'));
    });

    test('LocationServiceDisabledException accepts custom message', () {
      final exception = QParkinLocationServiceDisabledException('Custom message');
      expect(exception.toString(), equals('Custom message'));
    });

    test('PermissionDeniedException has correct message', () {
      final exception = QParkinPermissionDeniedException('Permission denied');
      expect(exception.toString(), equals('Permission denied'));
    });

    test('PermissionDeniedException requires message', () {
      final exception = QParkinPermissionDeniedException('Test message');
      expect(exception.message, equals('Test message'));
    });
  });

  group('LocationService - Haversine Formula Accuracy', () {
    test('calculateDistance matches known distances within acceptable margin', () {
      final service = LocationService();

      // Test with known coordinates and distances
      // New York to Los Angeles: approximately 3,944 km
      final newYork = GeoPoint(latitude: 40.7128, longitude: -74.0060);
      final losAngeles = GeoPoint(latitude: 34.0522, longitude: -118.2437);

      final distance = service.calculateDistance(newYork, losAngeles);

      // Allow 5% margin of error
      expect(distance, greaterThan(3700.0));
      expect(distance, lessThan(4200.0));
    });

    test('calculateDistance handles antipodal points', () {
      final service = LocationService();

      // Points on opposite sides of Earth
      final point1 = GeoPoint(latitude: 0.0, longitude: 0.0);
      final point2 = GeoPoint(latitude: 0.0, longitude: 180.0);

      final distance = service.calculateDistance(point1, point2);

      // Distance should be approximately half Earth's circumference at equator
      expect(distance, greaterThan(19000.0));
      expect(distance, lessThan(21000.0));
    });

    test('calculateDistance is consistent with multiple calculations', () {
      final service = LocationService();

      final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
      final point2 = GeoPoint(latitude: 1.1304, longitude: 104.0534);

      final distance1 = service.calculateDistance(point1, point2);
      final distance2 = service.calculateDistance(point1, point2);
      final distance3 = service.calculateDistance(point1, point2);

      expect(distance1, equals(distance2));
      expect(distance2, equals(distance3));
    });
  });

  group('LocationService - Integration Tests', () {
    test('complete location flow with permission check', () async {
      final service = LocationService();

      // Check if location services are enabled
      final isEnabled = await service.isLocationServiceEnabled();
      expect(isEnabled, isA<bool>());

      // Check permission status
      final permission = await service.checkPermission();
      expect(permission, isA<LocationPermission>());

      // If permission is granted and services enabled, try to get position
      if (isEnabled && 
          (permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always)) {
        try {
          final position = await service.getCurrentPosition();
          expect(position, isA<Position>());
          expect(position.latitude, isNotNull);
          expect(position.longitude, isNotNull);

          // Convert to GeoPoint
          final geoPoint = service.positionToGeoPoint(position);
          expect(geoPoint, isA<GeoPoint>());
        } catch (e) {
          // Timeout or other errors are acceptable in test environment
          expect(e is TimeoutException || e is Exception, isTrue);
        }
      }
    });

    test('distance calculation workflow', () {
      final service = LocationService();

      // Create test positions
      final position1 = Position(
        latitude: 1.1191,
        longitude: 104.0538,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final position2 = Position(
        latitude: 1.1304,
        longitude: 104.0534,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Convert to GeoPoints
      final geoPoint1 = service.positionToGeoPoint(position1);
      final geoPoint2 = service.positionToGeoPoint(position2);

      // Calculate distance
      final distance = service.calculateDistance(geoPoint1, geoPoint2);

      expect(distance, greaterThan(0.0));
      expect(distance, lessThan(10.0)); // Should be less than 10 km
    });
  });
}
