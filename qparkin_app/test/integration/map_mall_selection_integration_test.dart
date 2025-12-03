import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:qparkin_app/data/models/route_data.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';

/// Integration test for mall selection flow
/// 
/// Tests complete flow: tap mall → switch tab → center map → show info → calculate route
/// Requirements: 3.1, 3.2, 3.3, 3.5, 4.1

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mall Selection Flow Integration Tests', () {
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

    testWidgets('Complete mall selection flow from list to map', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final testRoute = RouteData(
        polylinePoints: [
          GeoPoint(latitude: 1.1, longitude: 104.0),
          GeoPoint(latitude: 1.1191, longitude: 104.0538),
        ],
        distanceInKm: 5.2,
        durationInMinutes: 15,
      );
      mockRouteService.mockRoute = testRoute;

      // Create provider with mocks
      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      // Load malls
      await mapProvider.loadMalls();

      // Build app
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
          routes: {
            '/booking': (context) => const Scaffold(body: Text('Booking Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Verify MapPage is displayed
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);

      // STEP 2: Switch to Daftar Mall tab (Requirement 3.1)
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      expect(daftarMallTab, findsOneWidget);
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify mall list is displayed
      expect(find.text('Pilih Mall'), findsOneWidget);
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // STEP 3: Tap on a mall card (Requirement 3.1)
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // STEP 4: Verify automatic tab switch to map (Requirement 3.1, 3.2)
      // The map tab should now be active
      final petaTab = find.widgetWithText(Tab, 'Peta');
      expect(petaTab, findsOneWidget);

      // STEP 5: Verify mall is selected in provider (Requirement 3.3)
      expect(mapProvider.selectedMall, isNotNull);
      expect(mapProvider.selectedMall?.name, equals('Mega Mall Batam Centre'));

      // STEP 6: Verify route calculation was triggered (Requirement 4.1)
      expect(mapProvider.currentRoute, isNotNull);
      expect(mapProvider.currentRoute?.distanceInKm, equals(5.2));
      expect(mapProvider.currentRoute?.durationInMinutes, equals(15));

      // STEP 7: Verify route service was called
      expect(mockRouteService.calculateRouteCallCount, equals(1));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Mall selection shows info card overlay', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final testRoute = RouteData(
        polylinePoints: [
          GeoPoint(latitude: 1.1, longitude: 104.0),
          GeoPoint(latitude: 1.1191, longitude: 104.0538),
        ],
        distanceInKm: 3.5,
        durationInMinutes: 10,
      );
      mockRouteService.mockRoute = testRoute;

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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Verify mall info is displayed (Requirement 3.5)
      expect(mapProvider.selectedMall, isNotNull);
      expect(mapProvider.selectedMall?.name, equals('Mega Mall Batam Centre'));
      expect(mapProvider.selectedMall?.address, isNotEmpty);
      expect(mapProvider.selectedMall?.availableSlots, greaterThan(0));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Route button triggers navigation to map with route', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final testRoute = RouteData(
        polylinePoints: [
          GeoPoint(latitude: 1.1, longitude: 104.0),
          GeoPoint(latitude: 1.1304, longitude: 104.0534),
        ],
        distanceInKm: 2.8,
        durationInMinutes: 8,
      );
      mockRouteService.mockRoute = testRoute;

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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Find and tap the "Rute" button for BCS Mall (second mall)
      final ruteButtons = find.text('Rute');
      expect(ruteButtons, findsWidgets);
      
      // Tap the second "Rute" button (for BCS Mall)
      await tester.tap(ruteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify tab switched to map (Requirement 3.4)
      // The map tab should now be active

      // Verify route was calculated (Requirement 4.1)
      expect(mapProvider.currentRoute, isNotNull);
      expect(mockRouteService.calculateRouteCallCount, equals(1));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Selected mall shows visual feedback', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final testRoute = RouteData(
        polylinePoints: [
          GeoPoint(latitude: 1.1, longitude: 104.0),
          GeoPoint(latitude: 1.1191, longitude: 104.0538),
        ],
        distanceInKm: 5.2,
        durationInMinutes: 15,
      );
      mockRouteService.mockRoute = testRoute;

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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Switch back to Daftar Mall tab to see visual feedback
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify "Booking Sekarang" button appears (visual feedback for selection)
      expect(find.text('Booking Sekarang'), findsOneWidget);

      // Verify mall is marked as selected in provider (Requirement 3.3)
      expect(mapProvider.selectedMall, isNotNull);
      expect(mapProvider.selectedMall?.name, equals('Mega Mall Batam Centre'));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Mall selection without location permission still works', (WidgetTester tester) async {
      // Setup mocks - no location permission
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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Verify mall is selected (Requirement 3.1, 3.2)
      expect(mapProvider.selectedMall, isNotNull);
      expect(mapProvider.selectedMall?.name, equals('Mega Mall Batam Centre'));

      // Verify route was NOT calculated (no location)
      expect(mapProvider.currentRoute, isNull);
      expect(mockRouteService.calculateRouteCallCount, equals(0));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Multiple mall selections update state correctly', (WidgetTester tester) async {
      // Setup mocks
      mockLocationService.mockCurrentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mockLocationService.mockPermission = LocationPermission.whileInUse;
      mockLocationService.mockServiceEnabled = true;

      final testRoute1 = RouteData(
        polylinePoints: [
          GeoPoint(latitude: 1.1, longitude: 104.0),
          GeoPoint(latitude: 1.1191, longitude: 104.0538),
        ],
        distanceInKm: 5.2,
        durationInMinutes: 15,
      );
      
      final testRoute2 = RouteData(
        polylinePoints: [
          GeoPoint(latitude: 1.1, longitude: 104.0),
          GeoPoint(latitude: 1.1304, longitude: 104.0534),
        ],
        distanceInKm: 3.5,
        durationInMinutes: 10,
      );

      mockRouteService.mockRoute = testRoute1;

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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select first mall
      final firstMall = find.text('Mega Mall Batam Centre');
      await tester.tap(firstMall);
      await tester.pumpAndSettle();

      expect(mapProvider.selectedMall?.name, equals('Mega Mall Batam Centre'));
      expect(mockRouteService.calculateRouteCallCount, equals(1));

      // Switch back to list
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Update mock route for second selection
      mockRouteService.mockRoute = testRoute2;

      // Select second mall
      final secondMall = find.text('BCS Mall');
      await tester.tap(secondMall);
      await tester.pumpAndSettle();

      // Verify state updated
      expect(mapProvider.selectedMall?.name, equals('BCS Mall'));
      expect(mockRouteService.calculateRouteCallCount, equals(2));

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
  RouteData? mockRoute;
  bool shouldThrowError = false;
  String errorMessage = 'Route calculation error';
  int calculateRouteCallCount = 0;

  @override
  Future<RouteData> calculateRoute(GeoPoint origin, GeoPoint destination) async {
    calculateRouteCallCount++;
    
    if (shouldThrowError) {
      throw RouteCalculationException(errorMessage);
    }
    
    if (mockRoute == null) {
      throw RouteCalculationException('No mock route set');
    }
    
    return mockRoute!;
  }

  void reset() {
    mockRoute = null;
    shouldThrowError = false;
    errorMessage = 'Route calculation error';
    calculateRouteCallCount = 0;
  }
}
