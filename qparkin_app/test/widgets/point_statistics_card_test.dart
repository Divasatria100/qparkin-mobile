import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/point_statistics_model.dart';
import 'package:qparkin_app/presentation/widgets/point_statistics_card.dart';

void main() {
  group('PointStatisticsCard Widget Tests', () {
    testWidgets('displays all 4 statistics correctly', (WidgetTester tester) async {
      // Arrange
      final statistics = PointStatistics(
        totalEarned: 5000,
        totalUsed: 2000,
        thisMonthEarned: 500,
        thisMonthUsed: 200,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: statistics,
            ),
          ),
        ),
      );

      // Assert - check header
      expect(find.text('Statistik Poin'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);

      // Assert - check all 4 metrics
      expect(find.text('Total Didapat'), findsOneWidget);
      expect(find.text('5.000'), findsOneWidget);
      
      expect(find.text('Total Digunakan'), findsOneWidget);
      expect(find.text('2.000'), findsOneWidget);
      
      expect(find.text('Bulan Ini Didapat'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      
      expect(find.text('Bulan Ini Digunakan'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('displays loading state with shimmer', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert - shimmer boxes should be present
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.text('Total Didapat'), findsNothing);
    });

    testWidgets('displays correct icons for each metric', (WidgetTester tester) async {
      // Arrange
      final statistics = PointStatistics(
        totalEarned: 1000,
        totalUsed: 500,
        thisMonthEarned: 100,
        thisMonthUsed: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: statistics,
            ),
          ),
        ),
      );

      // Assert - check all icons are present
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('displays zero values correctly', (WidgetTester tester) async {
      // Arrange
      final statistics = PointStatistics(
        totalEarned: 0,
        totalUsed: 0,
        thisMonthEarned: 0,
        thisMonthUsed: 0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: statistics,
            ),
          ),
        ),
      );

      // Assert - all values should show 0
      expect(find.text('0'), findsNWidgets(4));
    });

    testWidgets('formats large numbers with thousand separators', (WidgetTester tester) async {
      // Arrange
      final statistics = PointStatistics(
        totalEarned: 123456,
        totalUsed: 98765,
        thisMonthEarned: 12345,
        thisMonthUsed: 6789,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: statistics,
            ),
          ),
        ),
      );

      // Assert - check formatted numbers
      expect(find.text('123.456'), findsOneWidget);
      expect(find.text('98.765'), findsOneWidget);
      expect(find.text('12.345'), findsOneWidget);
      expect(find.text('6.789'), findsOneWidget);
    });

    testWidgets('has proper semantic labels for accessibility', (WidgetTester tester) async {
      // Arrange
      final statistics = PointStatistics(
        totalEarned: 1000,
        totalUsed: 500,
        thisMonthEarned: 100,
        thisMonthUsed: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: statistics,
            ),
          ),
        ),
      );

      // Assert - check main semantic label
      expect(
        tester.getSemantics(find.byType(PointStatisticsCard)),
        matchesSemantics(
          label: 'Statistik poin. Total didapat 1.000, '
              'Total digunakan 500, '
              'Bulan ini didapat 100, '
              'Bulan ini digunakan 50',
        ),
      );
    });

    testWidgets('uses responsive grid layout', (WidgetTester tester) async {
      // Arrange
      final statistics = PointStatistics(
        totalEarned: 1000,
        totalUsed: 500,
        thisMonthEarned: 100,
        thisMonthUsed: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: statistics,
            ),
          ),
        ),
      );

      // Assert - GridView should be present
      expect(find.byType(GridView), findsOneWidget);
      
      // Check that all 4 items are rendered
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.semanticChildCount, equals(4));
    });

    testWidgets('does not display statistics when null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              statistics: null,
            ),
          ),
        ),
      );

      // Assert - only header should be visible
      expect(find.text('Statistik Poin'), findsOneWidget);
      expect(find.text('Total Didapat'), findsNothing);
    });

    testWidgets('loading state shows 4 shimmer boxes', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointStatisticsCard(
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert - should have 4 shimmer boxes in grid
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.semanticChildCount, equals(4));
    });
  });
}
