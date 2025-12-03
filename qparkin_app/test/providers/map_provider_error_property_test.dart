import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';
import 'package:qparkin_app/data/models/route_data.dart';

/// Property-based test for MapProvider error logging
/// Tests universal properties that should hold across all valid inputs
/// 
/// **Feature: osm-map-integration, Property 13: Error Logging Consistency**
/// **Validates: Requirements 5.4**
void main() {
  group('MapProvider Error Logging Property Tests', () {
    test(
      'Property 13: Error Logging Consistency - '
      'For any error, system should log error details',
      () async {
        // Run property test with 100 iterations as specified in design
        const int iterations = 100;
        int errorsCaught = 0;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock services that throw errors
          final mockLocationService = MockLocationServiceWithErrors();
          final mockRouteService = MockRouteServiceWithErrors();
          final provider = MapProvider(
            locationService: mockLocationService,
            routeService: mockRouteService,
          );

          // Test different error scenarios randomly
          final errorType = i % 4;

          try {
            switch (errorType) {
              case 0:
                // Test location service disabled error
                mockLocationService.shouldThrowGpsError = true;
                await provider.getCurrentLocation();
                break;
              
              case 1:
                // Test permission denied error
                mockLocationService.shouldThrowPermissionError = true;
                await provider.getCurrentLocation();
                break;
              
              case 2:
                // Test route calculation error
                mockRouteService.shouldThrowRouteError = true;
                await provider.initializeMap();
                final origin = _generateRandomBatamLocation();
                final destination = _generateRandomBatamLocation();
                await provider.calculateRoute(origin, destination);
                break;
              
              case 3:
                // Test network error
                mockRouteService.shouldThrowNetworkError = true;
                await provider.initializeMap();
                final origin = _generateRandomBatamLocation();
                final destination = _generateRandomBatamLocation();
                await provider.calculateRoute(origin, destination);
                break;
            }
          } catch (e) {
            // Error should be caught
            errorsCaught++;

            // Verify error message is set in provider
            expect(provider.errorMessage, isNotNull,
                reason: 'Error message should be set when error occurs');
            
            expect(provider.errorMessage, isNotEmpty,
                reason: 'Error message should not be empty');

            // Verify error message is user-friendly (in Indonesian)
            final errorMsg = provider.errorMessage!.toLowerCase();
            final hasUserFriendlyMessage = 
                errorMsg.contains('gagal') ||
                errorMsg.contains('tidak') ||
                errorMsg.contains('izin') ||
                errorMsg.contains('koneksi') ||
                errorMsg.contains('gps');
            
            expect(hasUserFriendlyMessage, isTrue,
                reason: 'Error message should be user-friendly in Indonesian');
          }

          provider.dispose();
        }

        // All iterations should catch errors
        expect(errorsCaught, equals(iterations),
            reason: 'All error scenarios should be caught and logged');
      },
    );

    test(
      'Property: Clear error should reset error state',
      () async {
        // Test with 100 iterations
        const int iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock service that throws error
          final mockLocationService = MockLocationServiceWithErrors();
          mockLocationService.shouldThrowPermissionError = true;
          final provider = MapProvider(locationService: mockLocationService);

          try {
            // Trigger an error
            await provider.getCurrentLocation();
          } catch (e) {
            // Error expected
          }

          // Verify error is set
          expect(provider.errorMessage, isNotNull,
              reason: 'Error message should be set after error');

          // Clear error
          provider.clearError();

          // Verify error is cleared
          expect(provider.errorMessage, isNull,
              reason: 'Error message should be null after clearing');

          provider.dispose();
        }
      },
    );

    test(
      'Property: Multiple errors should update error message',
      () async {
        // Test with 50 iterations
        const int iterations = 50;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock services
          final mockLocationService = MockLocationServiceWithErrors();
          final mockRouteService = MockRouteServiceWithErrors();
          final provider = MapProvider(
            locationService: mockLocationService,
            routeService: mockRouteService,
          );

          String? firstError;
          String? secondError;

          try {
            // Trigger first error (location)
            mockLocationService.shouldThrowGpsError = true;
            await provider.getCurrentLocation();
          } catch (e) {
            firstError = provider.errorMessage;
          }

          expect(firstError, isNotNull, reason: 'First error should be set');

          try {
            // Trigger second error (route)
            await provider.initializeMap();
            mockRouteService.shouldThrowNetworkError = true;
            final origin = _generateRandomBatamLocation();
            final destination = _generateRandomBatamLocation();
            await provider.calculateRoute(origin, destination);
          } catch (e) {
            secondError = provider.errorMessage;
          }

          expect(secondError, isNotNull, reason: 'Second error should be set');
          
          // Error messages should be different (or at least updated)
          expect(secondError, isNot(equals(firstError)),
              reason: 'Error message should update for different errors');

          provider.dispose();
        }
      },
    );
  });
}

/// Generate a random location within Batam area
GeoPoint _generateRandomBatamLocation() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2; // 1.0 to 1.2
  final lng = 103.9 + random.nextDouble() * 0.2; // 103.9 to 104.1
  return GeoPoint(latitude: lat, longitude: lng);
}

/// Mock LocationService that throws errors for testing
class MockLocationServiceWithErrors extends LocationService {
  bool shouldThrowGpsError = false;
  bool shouldThrowPermissionError = false;

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (shouldThrowGpsError) {
      return false;
    }
    return true;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    if (shouldThrowPermissionError) {
      return LocationPermission.denied;
    }
    return LocationPermission.whileInUse;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (shouldThrowPermissionError) {
      return LocationPermission.denied;
    }
    return LocationPermission.whileInUse;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (shouldThrowGpsError) {
      throw LocationServiceDisabledException('GPS disabled');
    }
    if (shouldThrowPermissionError) {
      throw PermissionDeniedException('Permission denied');
    }
    return Position(
      latitude: 1.1,
      longitude: 104.0,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}

/// Mock RouteService that throws errors for testing
class MockRouteServiceWithErrors extends RouteService {
  bool shouldThrowRouteError = false;
  bool shouldThrowNetworkError = false;

  @override
  Future<RouteData> calculateRoute(GeoPoint origin, GeoPoint destination) async {
    if (shouldThrowNetworkError) {
      throw NetworkException('Network error');
    }
    if (shouldThrowRouteError) {
      throw RouteCalculationException('Route calculation failed');
    }
    
    // Return mock route
    return RouteData(
      polylinePoints: [origin, destination],
      distanceInKm: 5.0,
      durationInMinutes: 15,
    );
  }
}

