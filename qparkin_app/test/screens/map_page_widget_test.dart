import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';

/// Widget tests for MapPage
/// 
/// Tests:
/// - Map page renders correctly
/// - Tab navigation works
/// - Mall list displays
/// - Loading indicators appear
/// 
/// Requirements: 1.1, 6.4

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapPage Widget Tests', () {
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

    testWidgets('MapPage renders correctly with all UI elements', (WidgetTester tester) async {
      // Setup
      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar (Requirement 1.1)
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify TabBar (Requirement 1.1)
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Peta'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Daftar Mall'), findsOneWidget);

      // Verify TabBarView
      expect(find.byType(TabBarView), findsOneWidget);

      // Verify bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Tab navigation switches between Peta and Daftar Mall', (WidgetTester tester) async {
      // Setup
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

      // Initially on Peta tab
      expect(find.byType(TabBarView), findsOneWidget);

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify Daftar Mall content is displayed
      expect(find.text('Pilih Mall'), findsOneWidget);
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // Switch back to Peta tab
      final petaTab = find.widgetWithText(Tab, 'Peta');
      await tester.tap(petaTab);
      await tester.pumpAndSettle();

      // Verify we're back on map view
      expect(find.byType(TabBarView), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Mall list displays all malls correctly', (WidgetTester tester) async {
      // Setup
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

      // Verify header
      expect(find.text('Pilih Mall'), findsOneWidget);
      expect(find.text('Ketuk mall untuk memilih lokasi parkir'), findsOneWidget);

      // Verify all malls are displayed
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);
      expect(find.text('BCS Mall'), findsOneWidget);
      expect(find.text('Harbour Bay Mall'), findsOneWidget);
      expect(find.text('Grand Batam Mall'), findsOneWidget);
      expect(find.text('Kepri Mall'), findsOneWidget);

      // Verify mall cards have required elements
      expect(find.byIcon(Icons.local_parking), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets);
      expect(find.text('Rute'), findsWidgets);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Loading indicator appears while malls are loading', (WidgetTester tester) async {
      // Setup - provider that will show loading state
      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      // Build widget before loading malls
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pump(); // Don't settle yet

      // Start loading malls (this will trigger loading state)
      mapProvider.loadMalls();
      await tester.pump(); // Pump once to show loading indicator

      // Verify loading indicator appears (Requirement 6.4)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat daftar mall...'), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify loading indicator is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Memuat daftar mall...'), findsNothing);

      // Verify malls are displayed
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Mall card displays all required information', (WidgetTester tester) async {
      // Setup
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

      // Verify first mall card has all elements
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);
      expect(find.text('Jl. Engku Putri no.1, Batam Centre'), findsOneWidget);
      expect(find.textContaining('slot tersedia'), findsWidgets);
      expect(find.byIcon(Icons.local_parking), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets);
      expect(find.byIcon(Icons.check_circle), findsWidgets);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Selecting a mall shows booking button', (WidgetTester tester) async {
      // Setup
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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Initially no booking button
      expect(find.text('Booking Sekarang'), findsNothing);

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Switch back to list to see booking button
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify booking button appears
      expect(find.text('Booking Sekarang'), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Selected mall card has visual highlight', (WidgetTester tester) async {
      // Setup
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

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Switch back to list
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify selection indicator (check icon)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Rute button is present for each mall', (WidgetTester tester) async {
      // Setup
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

      // Verify Rute buttons (one for each mall)
      final ruteButtons = find.text('Rute');
      expect(ruteButtons, findsNWidgets(5)); // 5 malls

      // Verify navigation icons
      expect(find.byIcon(Icons.navigation), findsNWidgets(5));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Map view is displayed on Peta tab', (WidgetTester tester) async {
      // Setup
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

      // Verify we're on Peta tab by default
      expect(find.byType(TabBarView), findsOneWidget);

      // The MapView widget should be present
      // Note: We can't fully test OSMFlutter widget in unit tests,
      // but we can verify the structure is correct

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Bottom navigation bar is present', (WidgetTester tester) async {
      // Setup
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

      // Verify bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Tab icons are displayed correctly', (WidgetTester tester) async {
      // Setup
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

      // Verify tab icons
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Mall list has proper scrolling', (WidgetTester tester) async {
      // Setup
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

      // Verify ListView is present
      expect(find.byType(ListView), findsOneWidget);

      // Verify first mall is visible
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify we can scroll (last mall should be more visible)
      expect(find.text('Kepri Mall'), findsOneWidget);

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
    // No state to reset
  }
}
