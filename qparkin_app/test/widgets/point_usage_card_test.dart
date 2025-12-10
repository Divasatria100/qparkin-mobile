import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/point_usage_card.dart';

void main() {
  group('PointUsageCard Widget Tests', () {
    testWidgets('displays available points correctly', (WidgetTester tester) async {
      int pointsChanged = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 500,
              totalCost: 10000,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      expect(find.text('500 poin tersedia'), findsOneWidget);
      expect(find.text('Gunakan Poin'), findsOneWidget);
    });

    testWidgets('toggle switch enables point selection', (WidgetTester tester) async {
      int pointsChanged = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 500,
              totalCost: 10000,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      // Initially, point selector should not be visible
      expect(find.text('Jumlah Poin'), findsNothing);

      // Toggle the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Now point selector should be visible
      expect(find.text('Jumlah Poin'), findsOneWidget);
    });

    testWidgets('calculates maximum usable points correctly', (WidgetTester tester) async {
      int pointsChanged = 0;

      // Available points: 500
      // Total cost: 10000
      // Conversion rate: 10 (100 points = 1000 rupiah)
      // Max points for cost: 10000 / 10 = 1000
      // Max usable: min(500, 1000) = 500
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 500,
              totalCost: 10000,
              pointConversionRate: 10.0,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      // Toggle the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Check max usable points message
      expect(find.textContaining('Maksimal 500 poin dapat digunakan'), findsOneWidget);
    });

    testWidgets('max button sets points to maximum', (WidgetTester tester) async {
      int pointsChanged = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 500,
              totalCost: 10000,
              pointConversionRate: 10.0,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      // Toggle the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Tap max button
      await tester.tap(find.text('Maks'));
      await tester.pumpAndSettle();

      // Verify callback was called with max points
      expect(pointsChanged, 500);
    });

    testWidgets('displays cost breakdown correctly', (WidgetTester tester) async {
      int pointsChanged = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 500,
              totalCost: 10000,
              pointConversionRate: 10.0,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      // Toggle the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Set points to 100
      await tester.enterText(find.byType(TextField), '100');
      await tester.pumpAndSettle();

      // Check cost breakdown
      // Original cost: 10000
      // Point reduction: 100 * 10 = 1000
      // Final cost: 10000 - 1000 = 9000
      expect(find.text('Rp 10.000'), findsOneWidget);
      expect(find.textContaining('Potongan Poin (100 poin)'), findsOneWidget);
      expect(find.text('- Rp 1.000'), findsOneWidget);
      expect(find.text('Rp 9.000'), findsOneWidget);
    });

    testWidgets('handles insufficient points scenario', (WidgetTester tester) async {
      int pointsChanged = 0;

      // Available points: 50
      // Total cost: 10000
      // Conversion rate: 10
      // Max points for cost: 1000
      // Max usable: min(50, 1000) = 50
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 50,
              totalCost: 10000,
              pointConversionRate: 10.0,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      // Toggle the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Check max usable points message
      expect(find.textContaining('Maksimal 50 poin dapat digunakan'), findsOneWidget);

      // Tap max button
      await tester.tap(find.text('Maks'));
      await tester.pumpAndSettle();

      // Verify only 50 points are used
      expect(pointsChanged, 50);

      // Check cost breakdown shows remaining cost
      expect(find.text('Rp 10.000'), findsOneWidget);
      expect(find.textContaining('Potongan Poin (50 poin)'), findsOneWidget);
      expect(find.text('- Rp 500'), findsOneWidget);
      expect(find.text('Rp 9.500'), findsOneWidget);
    });

    testWidgets('handles sufficient points scenario', (WidgetTester tester) async {
      int pointsChanged = 0;

      // Available points: 2000
      // Total cost: 5000
      // Conversion rate: 10
      // Max points for cost: 5000 / 10 = 500
      // Max usable: min(2000, 500) = 500
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 2000,
              totalCost: 5000,
              pointConversionRate: 10.0,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
            ),
          ),
        ),
      );

      // Toggle the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Check max usable points message (should be limited by cost)
      expect(find.textContaining('Maksimal 500 poin dapat digunakan'), findsOneWidget);

      // Tap max button
      await tester.tap(find.text('Maks'));
      await tester.pumpAndSettle();

      // Verify only 500 points are used (enough to cover full cost)
      expect(pointsChanged, 500);

      // Check cost breakdown shows zero remaining cost
      expect(find.text('Rp 5.000'), findsOneWidget);
      expect(find.textContaining('Potongan Poin (500 poin)'), findsOneWidget);
      expect(find.text('- Rp 5.000'), findsOneWidget);
      expect(find.text('Rp 0'), findsOneWidget);
    });

    testWidgets('disables controls when loading', (WidgetTester tester) async {
      int pointsChanged = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointUsageCard(
              availablePoints: 500,
              totalCost: 10000,
              onPointsChanged: (points) {
                pointsChanged = points;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      // Switch should be disabled
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });
  });
}
