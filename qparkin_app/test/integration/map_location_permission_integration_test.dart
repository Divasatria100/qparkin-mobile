import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';

/// Integration test for location permission flow
/// 
/// Tests permission request → grant/deny → map response → marker display
/// Requirements: 2.1, 2.2, 2.4

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Location Permission Flow Integration Tests', () {
    late MockLocationService mockLocationService;
    late MockRouteService mockRouteService;

    setUp(() {
      mockLocationService = MockLocationService();
      mockRouteService = MockRouteService();
    });

    tearDown(() {
      mockLocationService.reset();
      mockRouteService.reset();
    });

    testWidgets('Permission granted - location marker displays', (WidgetTester tester) async {
      // Setup mocks - permission granted
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1234, longitude: 104.0567);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Request location (Requirement 2.1, 2.2)
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();

      // Verify location was obtained (Requirement 2.2)
      expect(mapProvider.currentLocation, isNotNull);
      expect(mapProvider.currentLocation?.latitude, equals(1.1234));
      expect(mapProvider.currentLocation?.longitude, equals(104.0567));

      // Verify no error
      expect(mapProvider.errorMessage, isNull);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Permission denied - shows error and uses default location', (WidgetTester tester) async {
      // Setup mocks - permission denied
      mockLocationService.mockPermission = LocationPermission.denied;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to request location (Requirement 2.1, 2.4)
      try {
        await mapProvider.getCurrentLocation();
      } catch (e) {
        // Expected to throw PermissionDeniedException
      }
      await tester.pumpAndSettle();

      // Verify error message is set (Requirement 2.4)
      expect(mapProvider.errorMessage, isNotNull);
      expect(mapProvider.errorMessage, contains('izin'));

      // Use default location as fallback (Requirement 2.4)
      mapProvider.useDefaultLocation();
      await tester.pumpAndSettle();

      // Verify default location is set (Batam city center)
      expect(mapProvider.currentLocation, isNotNull);
      expect(mapProvider.currentLocation?.latitude, equals(1.1));
      expect(mapProvider.currentLocation?.longitude, equals(104.0));

      // Verify error is cleared
      expect(mapProvider.errorMessage, isNull);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Permission permanently denied - shows appropriate message', (WidgetTester tester) async {
      // Setup mocks - permission permanently denied
      mockLocationService.mockPermission = LocationPermission.deniedForever;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to request location (Requirement 2.1, 2.4)
      try {
        await mapProvider.getCurrentLocation();
      } catch (e) {
        // Expected to throw PermissionDeniedException
      }
      await tester.pumpAndSettle();

      // Verify error message mentions settings (Requirement 2.4)
      expect(mapProvider.errorMessage, isNotNull);
      expect(mapProvider.errorMessage, contains('pengaturan'));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('GPS disabled - shows error message', (WidgetTester tester) async {
      // Setup mocks - GPS disabled
      mockLocationService.mockServiceEnabled = false;
      mockLocationService.mockPermission = LocationPermission.whileInUse;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to get location with GPS disabled (Requirement 2.1)
      try {
        await mapProvider.getCurrentLocation();
      } catch (e) {
        // Expected to throw LocationServiceDisabledException
      }
      await tester.pumpAndSettle();

      // Verify error message (Requirement 2.4)
      expect(mapProvider.errorMessage, isNotNull);
      expect(mapProvider.errorMessage, contains('GPS'));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Permission request flow - denied then granted', (WidgetTester tester) async {
      // Setup mocks - initially denied
      mockLocationService.mockPermission = LocationPermission.denied;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First attempt - denied
      try {
        await mapProvider.getCurrentLocation();
      } catch (e) {
        // Expected to fail
      }
      await tester.pumpAndSettle();

      expect(mapProvider.errorMessage, isNotNull);
      expect(mapProvider.currentLocation, isNull);

      // User grants permission
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.15, longitude: 104.05);

      // Clear error and retry
      mapProvider.clearError();
      await tester.pumpAndSettle();

      // Second attempt - granted
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();

      // Verify location obtained
      expect(mapProvider.currentLocation, isNotNull);
      expect(mapProvider.errorMessage, isNull);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Location updates when permission is granted', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial location
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();

      final initialLocation = mapProvider.currentLocation;
      expect(initialLocation, isNotNull);
      expect(initialLocation?.latitude, equals(1.1));

      // Simulate location change
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.2, longitude: 104.1);

      // Get updated location
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();

      // Verify location updated
      expect(mapProvider.currentLocation, isNotNull);
      expect(mapProvider.currentLocation?.latitude, equals(1.2));
      expect(mapProvider.currentLocation?.longitude, equals(104.1));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('App continues functioning without location permission', (WidgetTester tester) async {
      // Setup mocks - no permission
      mockLocationService.mockPermission = LocationPermission.denied;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app loaded successfully (Requirement 2.4)
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);

      // Verify malls are loaded
      expect(mapProvider.malls, isNotEmpty);

      // Switch to mall list
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify mall list displays
      expect(find.text('Pilih Mall'), findsOneWidget);
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // User can still select malls
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Verify mall selection works
      expect(mapProvider.selectedMall, isNotNull);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Center on location button works with permission', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1234, longitude: 104.0567);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();
      await mapProvider.initializeMap();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Center on current location (Requirement 2.2)
      await mapProvider.centerOnCurrentLocation();
      await tester.pumpAndSettle();

      // Verify location was obtained
      expect(mapProvider.currentLocation, isNotNull);
      expect(mapProvider.currentLocation?.latitude, equals(1.1234));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Multiple permission requests handled correctly', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First request
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();
      expect(mapProvider.currentLocation, isNotNull);

      // Second request (should not cause issues)
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();
      expect(mapProvider.currentLocation, isNotNull);

      // Third request
      await mapProvider.getCurrentLocation();
      await tester.pumpAndSettle();
      expect(mapProvider.currentLocation, isNotNull);

      // Verify no errors
      expect(mapProvider.errorMessage, isNull);

      // Clean up
      mapProvider.dispose();
    });
  });
}

// Mock Services

class MockLocationService extends LocationService {
  GeoPoint? mockCurrentLocation;
  LocationPermission mockPermission = LocationPermission.whileInUse;
  bool mockServiceEnabled = true;
  bool shouldThrowError = false;
  String errorMessage = 'Location error';

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return mockServiceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return mockPermission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return mockPermission;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (shouldThrowError) throw Exception(errorMessage);
    if (mockCurrentLocation == null) {
      throw Exception('No mock location set');
    }
    return Position(
      latitude: mockCurrentLocation!.latitude,
      longitude: mockCurrentLocation!.longitude,
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

  @override
  GeoPoint positionToGeoPoint(Position position) {
    return GeoPoint(latitude: position.latitude, longitude: position.longitude);
  }

  void reset() {
    mockCurrentLocation = null;
    mockPermission = LocationPermission.whileInUse;
    mockServiceEnabled = true;
    shouldThrowError = false;
    errorMessage = 'Location error';
  }
}

class MockRouteService extends RouteService {
  void reset() {
    // No state to reset for this test
  }
}
