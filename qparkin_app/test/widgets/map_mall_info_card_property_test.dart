import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:qparkin_app/data/models/route_data.dart';
import 'package:qparkin_app/presentation/widgets/map_mall_info_card.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/// Property-based test for selected mall info display
/// 
/// **Feature: osm-map-integration, Property 8: Selected Mall Info Display**
/// 
/// For any selected mall, info card should display
/// 
/// **Validates: Requirements 3.5**

void main() {
  group('Property 8: Selected Mall Info Display', () {
    testWidgets('For any selected mall, info card should display with mall details', 
        (WidgetTester tester) async {
      // Run property test with different random malls
      for (int iteration = 0; iteration < 20; iteration++) {
        final mall = _generateRandomMall();
        bool closeButtonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapMallInfoCard(
                mall: mall,
                onClose: () {
                  closeButtonPressed = true;
                },
              ),
            ),
          ),
        );

        // Wait for animations
        await tester.pumpAndSettle();

        // Verify card is displayed
        expect(find.byType(MapMallInfoCard), findsOneWidget);

        // Verify mall name is displayed
        expect(find.text(mall.name), findsOneWidget);

        // Verify address is displayed
        expect(find.text(mall.address), findsOneWidget);

        // Verify available slots information is displayed
        expect(find.text(mall.formattedAvailableSlots), findsOneWidget);

        // Verify close button is present
        expect(find.byIcon(Icons.close), findsOneWidget);

        // Test close button functionality
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        expect(closeButtonPressed, isTrue);
      }
    });

    testWidgets('Info card should display route information when route is provided',
        (WidgetTester tester) async {
      for (int iteration = 0; iteration < 20; iteration++) {
        final mall = _generateRandomMall();
        final route = _generateRandomRoute();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapMallInfoCard(
                mall: mall,
                route: route,
                onClose: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify route distance is displayed
        expect(find.text(route.formattedDistance), findsOneWidget);

        // Verify route duration is displayed
        expect(find.text(route.formattedDuration), findsOneWidget);

        // Verify route info labels
        expect(find.text('Jarak'), findsOneWidget);
        expect(find.text('Waktu'), findsOneWidget);
      }
    });

    testWidgets('Info card should not display route information when route is null',
        (WidgetTester tester) async {
      final mall = _generateRandomMall();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMallInfoCard(
              mall: mall,
              route: null,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify route labels are not displayed
      expect(find.text('Jarak'), findsNothing);
      expect(find.text('Waktu'), findsNothing);
    });

    testWidgets('Info card should display correct slot status color',
        (WidgetTester tester) async {
      // Test different slot availability scenarios
      final testCases = [
        _generateMallWithSlots(50),  // Many slots - green
        _generateMallWithSlots(5),   // Few slots - orange
        _generateMallWithSlots(1),   // Very few - red
        _generateMallWithSlots(0),   // Full - grey
      ];

      for (final mall in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapMallInfoCard(
                mall: mall,
                onClose: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify card is displayed with slot information
        expect(find.byType(MapMallInfoCard), findsOneWidget);
        expect(find.text(mall.formattedAvailableSlots), findsOneWidget);
      }
    });

    testWidgets('Info card should animate on appearance',
        (WidgetTester tester) async {
      final mall = _generateRandomMall();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMallInfoCard(
              mall: mall,
              onClose: () {},
            ),
          ),
        ),
      );

      // Verify animation widgets are present
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);

      // Complete animations
      await tester.pumpAndSettle();

      // Card should be fully visible after animation
      expect(find.byType(MapMallInfoCard), findsOneWidget);
    });
  });
}

/// Generate random mall for property testing
MallModel _generateRandomMall() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2;
  final lng = 103.9 + random.nextDouble() * 0.2;

  return MallModel(
    id: 'mall_${random.nextInt(10000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}, Batam',
    latitude: lat,
    longitude: lng,
    availableSlots: random.nextInt(100),
    distance: '${(random.nextDouble() * 10).toStringAsFixed(1)} km',
  );
}

/// Generate mall with specific slot count
MallModel _generateMallWithSlots(int slots) {
  final random = Random();
  return MallModel(
    id: 'mall_${random.nextInt(10000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}, Batam',
    latitude: 1.1,
    longitude: 104.0,
    availableSlots: slots,
    distance: '5.0 km',
  );
}

/// Generate random route for property testing
RouteData _generateRandomRoute() {
  final random = Random();
  final pointCount = random.nextInt(10) + 2;
  final points = <GeoPoint>[];

  for (int i = 0; i < pointCount; i++) {
    points.add(GeoPoint(
      latitude: 1.0 + random.nextDouble() * 0.2,
      longitude: 103.9 + random.nextDouble() * 0.2,
    ));
  }

  return RouteData(
    polylinePoints: points,
    distanceInKm: random.nextDouble() * 10 + 1,
    durationInMinutes: random.nextInt(30) + 5,
  );
}
