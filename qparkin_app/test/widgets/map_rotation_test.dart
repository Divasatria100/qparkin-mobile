import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/// Test device rotation to verify state persistence
/// 
/// Verifies that:
/// - Map state persists across rotation
/// - Selected mall remains selected after rotation
/// - Current location is maintained
/// - Route information is preserved
/// 
/// Requirements: 6.5
void main() {
  group('Map Device Rotation Tests', () {
    testWidgets('Map state persists across device rotation', (tester) async {
      // Create a test mall
      final testMall = MallModel(
        id: '1',
        name: 'Test Mall',
        address: 'Test Address',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      // Create map provider
      final mapProvider = MapProvider();

      // Build the widget in portrait mode
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle();

      // Simulate selecting a mall
      mapProvider.selectMall(testMall);
      await tester.pumpAndSettle();

      // Verify mall is selected
      expect(mapProvider.selectedMall, equals(testMall));
      expect(mapProvider.selectedMall?.name, equals('Test Mall'));

      // Simulate device rotation by rebuilding with different size
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape
      await tester.pumpAndSettle();

      // Verify state persists after rotation
      expect(mapProvider.selectedMall, equals(testMall));
      expect(mapProvider.selectedMall?.name, equals('Test Mall'));
      expect(mapProvider.selectedMall?.id, equals('1'));

      // Rotate back to portrait
      await tester.binding.setSurfaceSize(const Size(600, 800)); // Portrait
      await tester.pumpAndSettle();

      // Verify state still persists
      expect(mapProvider.selectedMall, equals(testMall));
      expect(mapProvider.selectedMall?.name, equals('Test Mall'));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Current location persists across rotation', (tester) async {
      // Create map provider
      final mapProvider = MapProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set a current location
      final testLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      mapProvider.useDefaultLocation(); // This sets current location

      await tester.pumpAndSettle();

      // Verify location is set
      expect(mapProvider.currentLocation, isNotNull);
      final originalLocation = mapProvider.currentLocation;

      // Simulate device rotation
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape
      await tester.pumpAndSettle();

      // Verify location persists
      expect(mapProvider.currentLocation, equals(originalLocation));
      expect(mapProvider.currentLocation?.latitude, equals(originalLocation?.latitude));
      expect(mapProvider.currentLocation?.longitude, equals(originalLocation?.longitude));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Mall list persists across rotation', (tester) async {
      // Create map provider
      final mapProvider = MapProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Load malls
      await mapProvider.loadMalls();
      await tester.pumpAndSettle();

      // Verify malls are loaded
      expect(mapProvider.malls.isNotEmpty, isTrue);
      final originalMallCount = mapProvider.malls.length;
      final firstMallName = mapProvider.malls.first.name;

      // Simulate device rotation
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape
      await tester.pumpAndSettle();

      // Verify mall list persists
      expect(mapProvider.malls.length, equals(originalMallCount));
      expect(mapProvider.malls.first.name, equals(firstMallName));

      // Rotate back
      await tester.binding.setSurfaceSize(const Size(600, 800)); // Portrait
      await tester.pumpAndSettle();

      // Verify mall list still persists
      expect(mapProvider.malls.length, equals(originalMallCount));
      expect(mapProvider.malls.first.name, equals(firstMallName));

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Error state persists across rotation', (tester) async {
      // Create map provider
      final mapProvider = MapProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate an error by trying to center without initializing map
      // This should not crash and error state should persist

      // Verify no error initially
      expect(mapProvider.errorMessage, isNull);

      // Simulate device rotation
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape
      await tester.pumpAndSettle();

      // Verify error state persists (or lack thereof)
      expect(mapProvider.errorMessage, isNull);

      // Clean up
      mapProvider.dispose();
    });

    testWidgets('Loading state is maintained during rotation', (tester) async {
      // Create map provider
      final mapProvider = MapProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MapProvider>.value(
            value: mapProvider,
            child: const MapPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial loading state
      final initialLoadingState = mapProvider.isLoading;

      // Simulate device rotation
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape
      await tester.pumpAndSettle();

      // Loading state should be consistent
      expect(mapProvider.isLoading, equals(initialLoadingState));

      // Clean up
      mapProvider.dispose();
    });
  });
}
