import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/mall_info_card.dart';

void main() {
  group('MallInfoCard', () {
    testWidgets('displays mall name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Mega Mall Batam',
              address: 'Jl. Engku Putri, Batam Centre',
              distance: '2.5 km',
              availableSlots: 15,
            ),
          ),
        ),
      );

      expect(find.text('Mega Mall Batam'), findsOneWidget);
    });

    testWidgets('displays address with location icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'One Batam Mall',
              address: 'Jl. Duyung, Nagoya',
              distance: '1.2 km',
              availableSlots: 8,
            ),
          ),
        ),
      );

      expect(find.text('Jl. Duyung, Nagoya'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays distance with navigation icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '3.7 km',
              availableSlots: 20,
            ),
          ),
        ),
      );

      expect(find.text('3.7 km'), findsOneWidget);
      expect(find.byIcon(Icons.navigation), findsOneWidget);
    });

    testWidgets('displays available slots count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 12,
            ),
          ),
        ),
      );

      expect(find.text('12 slot tersedia'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows green color for many available slots (>10)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 15,
            ),
          ),
        ),
      );

      final checkIcon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(checkIcon.color, const Color(0xFF4CAF50)); // Green
    });

    testWidgets('shows yellow color for limited slots (3-10)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 5,
            ),
          ),
        ),
      );

      final checkIcon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(checkIcon.color, const Color(0xFFFF9800)); // Yellow/Orange
    });

    testWidgets('shows red color for few slots (<3)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 2,
            ),
          ),
        ),
      );

      final checkIcon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(checkIcon.color, const Color(0xFFF44336)); // Red
    });

    testWidgets('displays parking icon with purple background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 10,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_parking), findsOneWidget);
      final parkingIcon = tester.widget<Icon>(find.byIcon(Icons.local_parking));
      expect(parkingIcon.color, const Color(0xFF573ED1)); // Purple
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 10,
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

    testWidgets('handles long address with ellipsis', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: MallInfoCard(
                mallName: 'Test Mall',
                address: 'Very Long Address That Should Be Truncated With Ellipsis',
                distance: '1.0 km',
                availableSlots: 10,
              ),
            ),
          ),
        ),
      );

      final addressText = tester.widget<Text>(
        find.text('Very Long Address That Should Be Truncated With Ellipsis'),
      );
      expect(addressText.overflow, TextOverflow.ellipsis);
      expect(addressText.maxLines, 2);
    });

    testWidgets('displays divider between sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 10,
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('handles zero available slots', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Test Address',
              distance: '1.0 km',
              availableSlots: 0,
            ),
          ),
        ),
      );

      expect(find.text('0 slot tersedia'), findsOneWidget);
      
      final checkIcon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(checkIcon.color, const Color(0xFFF44336)); // Red for full
    });
  });
}
