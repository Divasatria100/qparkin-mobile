import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';
import 'package:qparkin_app/utils/map_error_utils.dart';

/// Widget tests for error scenarios in MapPage
/// 
/// Tests:
/// - Error dialogs display correctly
/// - Error messages are clear
/// - Retry buttons work
/// 
/// Requirements: 5.1, 5.2, 5.3, 5.5

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Map Error Scenarios Widget Tests', () {
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

    testWidgets('Network error banner displays correctly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showNetworkErrorBanner(context);
                        },
                        child: const Text('Show Network Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger network error banner (Requirement 5.1, 5.3)
      await tester.tap(find.text('Show Network Error'));
      await tester.pumpAndSettle();

      // Verify error banner is displayed
      expect(find.text('Tidak Ada Koneksi Internet'), findsOneWidget);
      expect(find.text('Peta mungkin tidak dapat memuat dengan sempurna'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      // Verify action buttons
      expect(find.text('COBA LAGI'), findsOneWidget);
      expect(find.text('TUTUP'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Network error banner can be dismissed', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showNetworkErrorBanner(context);
                        },
                        child: const Text('Show Network Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show error banner
      await tester.tap(find.text('Show Network Error'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak Ada Koneksi Internet'), findsOneWidget);

      // Tap TUTUP button
      await tester.tap(find.text('TUTUP'));
      await tester.pumpAndSettle();

      // Verify banner is dismissed
      expect(find.text('Tidak Ada Koneksi Internet'), findsNothing);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Route calculation error snackbar displays correctly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showRouteCalculationError(context);
                        },
                        child: const Text('Show Route Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger route error snackbar (Requirement 4.5)
      await tester.tap(find.text('Show Route Error'));
      await tester.pumpAndSettle();

      // Verify error snackbar is displayed
      expect(find.text('Gagal menghitung rute. Periksa koneksi internet Anda.'), findsOneWidget);
      expect(find.byIcon(Icons.directions_off), findsOneWidget);
      expect(find.text('COBA LAGI'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Location error snackbar displays correctly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showLocationError(
                            context,
                            message: 'GPS tidak aktif',
                          );
                        },
                        child: const Text('Show Location Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger location error snackbar (Requirement 5.1, 5.2)
      await tester.tap(find.text('Show Location Error'));
      await tester.pumpAndSettle();

      // Verify error snackbar is displayed
      expect(find.text('GPS tidak aktif'), findsOneWidget);
      expect(find.byIcon(Icons.location_off), findsOneWidget);
      expect(find.text('COBA LAGI'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Map loading error snackbar displays correctly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showMapLoadingError(context);
                        },
                        child: const Text('Show Map Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger map loading error snackbar (Requirement 5.3)
      await tester.tap(find.text('Show Map Error'));
      await tester.pumpAndSettle();

      // Verify error snackbar is displayed
      expect(find.text('Beberapa bagian peta gagal dimuat'), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.text('COBA LAGI'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('General error snackbar displays correctly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showGeneralError(
                            context,
                            message: 'Terjadi kesalahan',
                          );
                        },
                        child: const Text('Show General Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger general error snackbar (Requirement 5.1)
      await tester.tap(find.text('Show General Error'));
      await tester.pumpAndSettle();

      // Verify error snackbar is displayed
      expect(find.text('Terjadi kesalahan'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('COBA LAGI'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Error message displays when mall loading fails', (WidgetTester tester) async {
      // Setup - mock service that throws error
      mockLocationService.shouldThrowError = true;
      mockLocationService.errorMessage = 'Failed to load malls';

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      // Manually set error state
      try {
        await mapProvider.loadMalls();
      } catch (e) {
        // Expected to fail
      }

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

      // Verify error state is displayed (Requirement 5.1)
      expect(find.text('Gagal memuat daftar mall'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Retry button works for network errors', (WidgetTester tester) async {
      // Setup
      bool retryCallbackCalled = false;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showNetworkErrorBanner(
                            context,
                            onRetry: () {
                              retryCallbackCalled = true;
                            },
                          );
                        },
                        child: const Text('Show Network Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show error banner
      await tester.tap(find.text('Show Network Error'));
      await tester.pumpAndSettle();

      // Tap retry button
      await tester.tap(find.text('COBA LAGI'));
      await tester.pumpAndSettle();

      // Verify retry callback was called
      expect(retryCallbackCalled, isTrue);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Retry button works for route calculation errors', (WidgetTester tester) async {
      // Setup
      bool retryCallbackCalled = false;

      final mapProvider = MapProvider(
        locationService: mockLocationService,
        routeService: mockRouteService,
      );

      await mapProvider.loadMalls();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showRouteCalculationError(
                            context,
                            onRetry: () {
                              retryCallbackCalled = true;
                            },
                          );
                        },
                        child: const Text('Show Route Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show error snackbar
      await tester.tap(find.text('Show Route Error'));
      await tester.pumpAndSettle();

      // Tap retry button
      await tester.tap(find.text('COBA LAGI'));
      await tester.pumpAndSettle();

      // Verify retry callback was called
      expect(retryCallbackCalled, isTrue);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Error messages are clear and user-friendly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Show various error messages
                          MapErrorUtils.showNetworkErrorBanner(context);
                        },
                        child: const Text('Show Errors'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show error
      await tester.tap(find.text('Show Errors'));
      await tester.pumpAndSettle();

      // Verify error message is in Indonesian and user-friendly (Requirement 5.1, 5.2, 5.3)
      expect(find.text('Tidak Ada Koneksi Internet'), findsOneWidget);
      expect(find.text('Peta mungkin tidak dapat memuat dengan sempurna'), findsOneWidget);

      // Verify message doesn't contain technical jargon
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('Error:'), findsNothing);
      expect(find.textContaining('null'), findsNothing);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Success message displays correctly', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showSuccess(
                            context,
                            message: 'Lokasi berhasil ditemukan',
                          );
                        },
                        child: const Text('Show Success'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show success message
      await tester.tap(find.text('Show Success'));
      await tester.pumpAndSettle();

      // Verify success snackbar is displayed
      expect(find.text('Lokasi berhasil ditemukan'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Multiple errors can be displayed sequentially', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showLocationError(context);
                        },
                        child: const Text('Show Location Error'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showRouteCalculationError(context);
                        },
                        child: const Text('Show Route Error'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show first error
      await tester.tap(find.text('Show Location Error'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal mendapatkan lokasi Anda'), findsOneWidget);

      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Show second error
      await tester.tap(find.text('Show Route Error'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal menghitung rute. Periksa koneksi internet Anda.'), findsOneWidget);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Error icons are appropriate for error types', (WidgetTester tester) async {
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
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showNetworkErrorBanner(context);
                        },
                        child: const Text('Network'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showLocationError(context);
                        },
                        child: const Text('Location'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          MapErrorUtils.showRouteCalculationError(context);
                        },
                        child: const Text('Route'),
                      ),
                      const Expanded(child: MapPage()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test network error icon
      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      await tester.tap(find.text('TUTUP'));
      await tester.pumpAndSettle();

      // Test location error icon
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.location_off), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));

      // Test route error icon
      await tester.tap(find.text('Route'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.directions_off), findsOneWidget);

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
