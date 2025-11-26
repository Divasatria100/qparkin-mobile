import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/cost_breakdown_card.dart';

void main() {
  group('CostBreakdownCard', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Estimasi Biaya'), findsOneWidget);
    });

    testWidgets('displays first hour rate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Jam pertama'), findsOneWidget);
      expect(find.text('Rp 5.000'), findsOneWidget);
    });

    testWidgets('displays additional hours rate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('2 jam berikutnya'), findsOneWidget);
      expect(find.text('Rp 10.000'), findsOneWidget);
    });

    testWidgets('does not display additional hours when zero', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 0,
              additionalHours: 0,
              totalCost: 5000,
            ),
          ),
        ),
      );

      expect(find.text('0 jam berikutnya'), findsNothing);
    });

    testWidgets('displays total cost', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Total Estimasi'), findsOneWidget);
      expect(find.text('Rp 15.000'), findsOneWidget);
    });

    testWidgets('total cost has purple color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final totalText = find.text('Rp 15.000');
      final textWidget = tester.widget<Text>(totalText);
      
      expect(textWidget.style?.color, const Color(0xFF573ED1));
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('displays info box', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Biaya final dihitung saat keluar'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('info box has blue background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final infoContainer = find.ancestor(
        of: find.byIcon(Icons.info),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(infoContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, const Color(0xFF2196F3).withOpacity(0.1));
    });

    testWidgets('formats currency with thousand separators', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 10000,
              additionalHoursRate: 50000,
              additionalHours: 3,
              totalCost: 160000,
            ),
          ),
        ),
      );

      expect(find.text('Rp 10.000'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget);
      expect(find.text('Rp 160.000'), findsOneWidget);
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
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

    testWidgets('displays dividers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('animates total cost changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update with new cost
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 15000,
              additionalHours: 3,
              totalCost: 20000,
            ),
          ),
        ),
      );

      // Animation should be in progress
      await tester.pump(const Duration(milliseconds: 150));
      
      // Should eventually show new value
      await tester.pumpAndSettle();
      expect(find.text('Rp 20.000'), findsOneWidget);
    });

    testWidgets('handles large numbers correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 100000,
              additionalHoursRate: 500000,
              additionalHours: 5,
              totalCost: 2600000,
            ),
          ),
        ),
      );

      expect(find.text('Rp 100.000'), findsOneWidget);
      expect(find.text('Rp 500.000'), findsOneWidget);
      expect(find.text('Rp 2.600.000'), findsOneWidget);
    });

    testWidgets('displays correct additional hours text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 1,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('1 jam berikutnya'), findsOneWidget);
    });

    testWidgets('info icon has correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final infoIcon = tester.widget<Icon>(find.byIcon(Icons.info));
      expect(infoIcon.color, const Color(0xFF2196F3));
      expect(infoIcon.size, 16);
    });

    testWidgets('breakdown items have correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 10000,
              additionalHours: 2,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final firstHourLabel = tester.widget<Text>(find.text('Jam pertama'));
      expect(firstHourLabel.style?.fontSize, 14);
    });

    testWidgets('handles zero cost', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostBreakdownCard(
              firstHourRate: 0,
              additionalHoursRate: 0,
              additionalHours: 0,
              totalCost: 0,
            ),
          ),
        ),
      );

      expect(find.text('Rp 0'), findsWidgets);
    });
  });
}
