import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/point_empty_state.dart';

void main() {
  group('PointEmptyState Widget Tests', () {
    testWidgets('should display empty state message', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointEmptyState(),
          ),
        ),
      );

      // Assert
      expect(find.text('Belum ada riwayat poin'), findsOneWidget);
    });

    testWidgets('should display call-to-action text', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointEmptyState(),
          ),
        ),
      );

      // Assert
      expect(
        find.textContaining('Mulai parkir untuk mendapatkan poin reward'),
        findsOneWidget,
      );
    });

    testWidgets('should display history icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointEmptyState(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('should have proper semantic label for accessibility',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointEmptyState(),
          ),
        ),
      );

      // Assert
      final semantics = tester.getSemantics(find.byType(PointEmptyState));
      expect(
        semantics.label,
        contains('Belum ada riwayat poin'),
      );
    });

    testWidgets('should be centered on screen', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointEmptyState(),
          ),
        ),
      );

      // Assert
      final center = find.ancestor(
        of: find.byIcon(Icons.history),
        matching: find.byType(Center),
      );
      expect(center, findsOneWidget);
    });

    testWidgets('should display complete message with proper styling',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointEmptyState(),
          ),
        ),
      );

      // Assert - Check main message
      final mainMessage = tester.widget<Text>(
        find.text('Belum ada riwayat poin'),
      );
      expect(mainMessage.style?.fontWeight, FontWeight.w600);
      expect(mainMessage.textAlign, TextAlign.center);

      // Assert - Check call-to-action text
      final ctaText = tester.widget<Text>(
        find.textContaining('Mulai parkir untuk mendapatkan poin reward'),
      );
      expect(ctaText.textAlign, TextAlign.center);
    });
  });
}
