import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/services/location_service.dart';

/// Property-based test for MapProvider location marker display
/// Tests universal properties that should hold across all valid inputs
/// 
/// **Feature: osm-map-integration, Property 3: Location Marker Display**
/// **Validates: Requirements 2.2**
void main() {
  group('MapProvider Location Marker Property Tests', () {
    test(
      'Property 3: Location Marker Display - '
      'For any state with location permission and current location, marker should display',
      () async {
        // Run property test with 100 iterations as specified in design
        const int iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock location service
          final mockLocationService = MockLocationService();
          final provider = MapProvider(locationService: mockLocationService);

          // Generate random location in Batam area
          final randomLocation = _generateRandomBatamLocation();
          
          // Mock location service to return the random location
          mockLocationService.mockCurrentPosition = Position(
            latitude: randomLocation.latitude,
            longitude: randomLocation.longitude,
            timestamp: DateTime.now(),
            accuracy: 10.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );

          try {
            // Get current location (simulating permission granted)
            await provider.getCurrentLocation();

            // Verify that current location is set
            expect(provider.currentLocation, isNotNull,
                reason: 'Current location should be set after getting location');
            
            expect(provider.hasCurrentLocation, isTrue,
                reason: 'hasCurrentLocation should be true when location is available');

            // Verify location matches the mocked position
            expect(provider.currentLocation!.latitude, 
                closeTo(randomLocation.latitude, 0.0001),
                reason: 'Latitude should match mocked position');
            
            expect(provider.currentLocation!.longitude,
                closeTo(randomLocation.longitude, 0.0001),
                reason: 'Longitude should match mocked position');

            successCount++;
          } catch (e) {
            // Should not throw errors with mocked service
            fail('Unexpected error with valid location: $e');
          }

          provider.dispose();
        }

        // All iterations should succeed with mocked service
        expect(successCount, equals(iterations),
            reason: 'All iterations should succeed with mocked location service');
      },
    );

    test(
      'Property: Location should not be set when permission is denied',
      () async {
        // Test with 50 iterations
        const int iterations = 50;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock location service that denies permission
          final mockLocationService = MockLocationService();
          mockLocationService.mockPermissionDenied = true;
          final provider = MapProvider(locationService: mockLocationService);

          try {
            // Attempt to get current location
            await provider.getCurrentLocation();
            
            // Should not reach here
            fail('Should throw PermissionDeniedException');
          } on PermissionDeniedException {
            // Expected exception
            expect(provider.currentLocation, isNull,
                reason: 'Current location should remain null when permission denied');
            
            expect(provider.hasCurrentLocation, isFalse,
                reason: 'hasCurrentLocation should be false when permission denied');
          } catch (e) {
            fail('Unexpected exception type: $e');
          }

          provider.dispose();
        }
      },
    );

    test(
      'Property: Location should not be set when GPS is disabled',
      () async {
        // Test with 50 iterations
        const int iterations = 50;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock location service that has GPS disabled
          final mockLocationService = MockLocationService();
          mockLocationService.mockGpsDisabled = true;
          final provider = MapProvider(locationService: mockLocationService);

          try {
            // Attempt to get current location
            await provider.getCurrentLocation();
            
            // Should not reach here
            fail('Should throw LocationServiceDisabledException');
          } on LocationServiceDisabledException {
            // Expected exception
            expect(provider.currentLocation, isNull,
                reason: 'Current location should remain null when GPS disabled');
            
            expect(provider.hasCurrentLocation, isFalse,
                reason: 'hasCurrentLocation should be false when GPS disabled');
          } catch (e) {
            fail('Unexpected exception type: $e');
          }

          provider.dispose();
        }
      },
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

/// Mock LocationService for testing
class MockLocationService extends LocationService {
  Position? mockCurrentPosition;
  bool mockPermissionDenied = false;
  bool mockGpsDisabled = false;

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (mockGpsDisabled) {
      return false;
    }
    return true;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    if (mockPermissionDenied) {
      return LocationPermission.denied;
    }
    return LocationPermission.whileInUse;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (mockPermissionDenied) {
      return LocationPermission.denied;
    }
    return LocationPermission.whileInUse;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (mockGpsDisabled) {
      throw LocationServiceDisabledException();
    }
    if (mockPermissionDenied) {
      throw PermissionDeniedException('Permission denied');
    }
    if (mockCurrentPosition == null) {
      throw Exception('Mock position not set');
    }
    return mockCurrentPosition!;
  }
}

