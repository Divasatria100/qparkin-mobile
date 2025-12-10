import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/slot_availability_indicator.dart';

void main() {
  group('SlotAvailabilityIndicator', () {
    testWidgets('displays available slots count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 15,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.text('15 slot tersedia'), findsOneWidget);
      expect(find.text('Ketersediaan Slot'), findsOneWidget);
    });

    testWidgets('displays vehicle type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Dua',
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.text('Untuk Roda Dua'), findsOneWidget);
    });

    testWidgets('shows green color for many slots (>10)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 15,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Find the status circle container
      final circleContainer = find.ancestor(
        of: find.byIcon(Icons.local_parking),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(circleContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, const Color(0xFF4CAF50)); // Green
    });

    testWidgets('shows yellow color for limited slots (3-10)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 5,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final circleContainer = find.ancestor(
        of: find.byIcon(Icons.local_parking),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(circleContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, const Color(0xFFFF9800)); // Yellow/Orange
    });

    testWidgets('shows red color for few slots (<3)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 2,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final circleContainer = find.ancestor(
        of: find.byIcon(Icons.local_parking),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(circleContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, const Color(0xFFF44336)); // Red
    });

    testWidgets('shows red color for zero slots', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 0,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final circleContainer = find.ancestor(
        of: find.byIcon(Icons.local_parking),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(circleContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, const Color(0xFFF44336)); // Red
    });

    testWidgets('displays refresh button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('calls onRefresh when refresh button is tapped', (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {
                refreshCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(refreshCalled, true);
    });

    testWidgets('displays shimmer loading when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              isLoading: true,
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Should not display actual content during loading
      expect(find.text('15 slot tersedia'), findsNothing);
      expect(find.text('Ketersediaan Slot'), findsNothing);
      
      // Shimmer containers should be present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays content when isLoading is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              isLoading: false,
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.text('10 slot tersedia'), findsOneWidget);
      expect(find.text('Ketersediaan Slot'), findsOneWidget);
      expect(find.byIcon(Icons.local_parking), findsOneWidget);
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
      expect(card.color, Colors.white);
      
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('status circle has correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final circleContainer = find.ancestor(
        of: find.byIcon(Icons.local_parking),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(circleContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.shape, BoxShape.circle);
      expect(container.constraints?.maxWidth, 48);
      expect(container.constraints?.maxHeight, 48);
    });

    testWidgets('parking icon is white', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final parkingIcon = tester.widget<Icon>(find.byIcon(Icons.local_parking));
      expect(parkingIcon.color, Colors.white);
      expect(parkingIcon.size, 24);
    });

    testWidgets('refresh icon has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      final refreshIcon = tester.widget<Icon>(find.byIcon(Icons.refresh));
      expect(refreshIcon.size, 20);
    });

    testWidgets('displays correct text for different slot counts', (WidgetTester tester) async {
      // Test with 20 slots
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 20,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.text('20 slot tersedia'), findsOneWidget);
    });

    testWidgets('layout has proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotAvailabilityIndicator(
              availableSlots: 10,
              vehicleType: 'Roda Empat',
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Verify Row layout exists
      final row = find.ancestor(
        of: find.byIcon(Icons.local_parking),
        matching: find.byType(Row),
      );
      
      expect(row, findsOneWidget);
    });
  });
}
