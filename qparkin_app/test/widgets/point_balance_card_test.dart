import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/point_balance_card.dart';

void main() {
  group('PointBalanceCard Widget Tests', () {
    testWidgets('displays balance correctly', (WidgetTester tester) async {
      // Arrange
      const testBalance = 1250;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              balance: testBalance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Saldo Poin'), findsOneWidget);
      expect(find.text('1.250'), findsOneWidget);
      expect(find.byIcon(Icons.stars), findsOneWidget);
    });

    testWidgets('displays loading state with shimmer', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert - shimmer boxes should be present
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.text('Saldo Poin'), findsNothing);
    });

    testWidgets('displays error state with retry button', (WidgetTester tester) async {
      // Arrange
      bool retryPressed = false;
      const errorMessage = 'Koneksi gagal';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              error: errorMessage,
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Test retry button tap
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      expect(retryPressed, isTrue);
    });

    testWidgets('retry button has minimum 48x48dp touch target', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              error: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Assert - find the InkWell container
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byWidget(inkWell),
          matching: find.byType(Container),
        ).first,
      );
      
      final constraints = container.constraints;
      expect(constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(constraints?.minHeight, greaterThanOrEqualTo(48));
    });

    testWidgets('has proper semantic labels for accessibility', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              balance: 500,
            ),
          ),
        ),
      );

      // Assert - check semantic labels exist
      expect(
        tester.getSemantics(find.byType(PointBalanceCard)),
        matchesSemantics(
          label: 'Saldo poin Anda. 500 poin',
        ),
      );
    });

    testWidgets('formats large balance numbers correctly', (WidgetTester tester) async {
      // Arrange
      const largeBalance = 123456;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              balance: largeBalance,
            ),
          ),
        ),
      );

      // Assert - should use Indonesian number format with dots
      expect(find.text('123.456'), findsOneWidget);
    });

    testWidgets('displays zero balance correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              balance: 0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Saldo Poin'), findsOneWidget);
    });

    testWidgets('error state without retry callback does not show button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointBalanceCard(
              error: 'Error occurred',
              onRetry: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsNothing);
    });
  });
}
