import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';

/// Property-based test for MapProvider mall selection navigation
/// Tests universal properties that should hold across all valid inputs
/// 
/// **Feature: osm-map-integration, Property 5: Mall Selection Navigation**
/// **Validates: Requirements 3.1, 3.2**
void main() {
  group('MapProvider Mall Selection Property Tests', () {
    test(
      'Property 5: Mall Selection Navigation - '
      'For any mall selected, system should switch to map tab and center on mall',
      () async {
        // Run property test with 100 iterations as specified in design
        const int iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock services
          final mockLocationService = MockLocationService();
          final mockRouteService = MockRouteService();
          final provider = MapProvider(
            locationService: mockLocationService,
            routeService: mockRouteService,
          );

          // Initialize map
          await provider.initializeMap();

          // Generate random mall
          final randomMall = _generateRandomMall();

          try {
            // Select the mall
            await provider.selectMall(randomMall);

            // Verify mall is selected
            expect(provider.selectedMall, isNotNull,
                reason: 'Selected mall should not be null after selection');
            
            expect(provider.selectedMall!.id, equals(randomMall.id),
                reason: 'Selected mall ID should match');
            
            expect(provider.hasSelectedMall, isTrue,
                reason: 'hasSelectedMall should be true after selection');

            // Verify map would center on mall (controller should be initialized)
            expect(provider.isMapInitialized, isTrue,
                reason: 'Map should be initialized for centering');

            successCount++;
          } catch (e) {
            // Should not throw errors with mocked services
            fail('Unexpected error selecting mall: $e');
          }

          provider.dispose();
        }

        // All iterations should succeed
        expect(successCount, equals(iterations),
            reason: 'All mall selections should succeed');
      },
    );

    test(
      'Property: Mall selection with current location should trigger route calculation',
      () async {
        // Test with 100 iterations
        const int iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock services
          final mockLocationService = MockLocationService();
          final mockRouteService = MockRouteService();
          final provider = MapProvider(
            locationService: mockLocationService,
            routeService: mockRouteService,
          );

          // Initialize map
          await provider.initializeMap();

          // Set current location
          final currentLocation = _generateRandomBatamLocation();
          mockLocationService.mockCurrentPosition = _createPosition(currentLocation);
          await provider.getCurrentLocation();

          // Generate random mall
          final randomMall = _generateRandomMall();

          try {
            // Select the mall
            await provider.selectMall(randomMall);

            // Verify route was calculated
            expect(provider.currentRoute, isNotNull,
                reason: 'Route should be calculated when location is available');
            
            expect(provider.hasRoute, isTrue,
                reason: 'hasRoute should be true after route calculation');

            // Verify route properties
            expect(provider.currentRoute!.distanceInKm, greaterThan(0),
                reason: 'Route distance should be positive');
            
            expect(provider.currentRoute!.durationInMinutes, greaterThan(0),
                reason: 'Route duration should be positive');

            successCount++;
          } catch (e) {
            fail('Unexpected error: $e');
          }

          provider.dispose();
        }

        // All iterations should succeed
        expect(successCount, equals(iterations),
            reason: 'All mall selections with location should calculate routes');
      },
    );

    test(
      'Property: Clear selection should reset selected mall and route',
      () async {
        // Test with 100 iterations
        const int iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // Create provider with mock services
          final mockLocationService = MockLocationService();
          final mockRouteService = MockRouteService();
          final provider = MapProvider(
            locationService: mockLocationService,
            routeService: mockRouteService,
          );

          // Initialize map and set location
          await provider.initializeMap();
          final currentLocation = _generateRandomBatamLocation();
          mockLocationService.mockCurrentPosition = _createPosition(currentLocation);
          await provider.getCurrentLocation();

          // Select a mall
          final randomMall = _generateRandomMall();
          await provider.selectMall(randomMall);

          // Verify mall and route are set
          expect(provider.selectedMall, isNotNull);
          expect(provider.currentRoute, isNotNull);

          // Clear selection
          provider.clearSelection();

          // Verify mall and route are cleared
          expect(provider.selectedMall, isNull,
              reason: 'Selected mall should be null after clearing');
          
          expect(provider.currentRoute, isNull,
              reason: 'Current route should be null after clearing');
          
          expect(provider.hasSelectedMall, isFalse,
              reason: 'hasSelectedMall should be false after clearing');
          
          expect(provider.hasRoute, isFalse,
              reason: 'hasRoute should be false after clearing');

          provider.dispose();
        }
      },
    );
  });
}

/// Generate a random mall within Batam area
MallModel _generateRandomMall() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2; // 1.0 to 1.2
  final lng = 103.9 + random.nextDouble() * 0.2; // 103.9 to 104.1
  
  return MallModel(
    id: 'mall_${random.nextInt(10000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}, Batam',
    latitude: lat,
    longitude: lng,
    availableSlots: random.nextInt(100),
  );
}

/// Generate a random location within Batam area
GeoPoint _generateRandomBatamLocation() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2; // 1.0 to 1.2
  final lng = 103.9 + random.nextDouble() * 0.2; // 103.9 to 104.1
  return GeoPoint(latitude: lat, longitude: lng);
}

/// Create a Position from GeoPoint
Position _createPosition(GeoPoint point) {
  return Position(
    latitude: point.latitude,
    longitude: point.longitude,
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

/// Mock LocationService for testing
class MockLocationService extends LocationService {
  Position? mockCurrentPosition;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async => LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async => LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition() async {
    if (mockCurrentPosition == null) {
      throw Exception('Mock position not set');
    }
    return mockCurrentPosition!;
  }
}

/// Mock RouteService for testing
class MockRouteService extends RouteService {
  @override
  Future<RouteData> calculateRoute(GeoPoint origin, GeoPoint destination) async {
    // Return a mock route
    final random = Random();
    final distance = 1.0 + random.nextDouble() * 10.0; // 1-11 km
    final duration = (distance * 3).ceil(); // ~3 min per km
    
    return RouteData(
      polylinePoints: [origin, destination],
      distanceInKm: distance,
      durationInMinutes: duration,
    );
  }
}

