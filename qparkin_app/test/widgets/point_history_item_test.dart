import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/point_history_model.dart';
import 'package:qparkin_app/presentation/widgets/point_history_item.dart';

void main() {
  group('PointHistoryItem Widget Tests', () {
    testWidgets('displays addition history with green color', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        idTransaksi: 123,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Poin dari transaksi parkir',
        waktu: DateTime(2024, 12, 2, 14, 30),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Poin dari transaksi parkir'), findsOneWidget);
      expect(find.text('+100'), findsOneWidget);
      expect(find.text('2 Des 2024, 14:30'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('displays deduction history with red color', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 2,
        idUser: 1,
        poin: 50,
        perubahan: 'kurang',
        keterangan: 'Digunakan untuk pembayaran',
        waktu: DateTime(2024, 12, 1, 10, 15),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Digunakan untuk pembayaran'), findsOneWidget);
      expect(find.text('-50'), findsOneWidget);
      expect(find.text('1 Des 2024, 10:15'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('handles tap callback when provided', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        idTransaksi: 123,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Test transaction',
        waktu: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the item
      await tester.tap(find.byType(PointHistoryItem));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('has minimum 48dp touch target height', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Short text',
        waktu: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
            ),
          ),
        ),
      );

      // Assert - find the container with constraints
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PointHistoryItem),
          matching: find.byType(Container),
        ).first,
      );
      
      final constraints = container.constraints;
      expect(constraints?.minHeight, greaterThanOrEqualTo(48));
    });

    testWidgets('has proper semantic labels for accessibility', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        idTransaksi: 123,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Poin parkir',
        waktu: DateTime(2024, 12, 2, 14, 30),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - check semantic label content
      final semantics = tester.getSemantics(find.byType(PointHistoryItem));
      expect(
        semantics.label,
        'Penambahan poin. 100 poin. Poin parkir. 2 Des 2024, 14:30. Ketuk untuk melihat detail transaksi',
      );
    });

    testWidgets('truncates long description text', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'This is a very long description that should be truncated when displayed in the list item widget to prevent overflow issues',
        waktu: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: PointHistoryItem(
                history: history,
              ),
            ),
          ),
        ),
      );

      // Assert - should not overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays formatted date correctly', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Test',
        waktu: DateTime(2024, 1, 15, 9, 5),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
            ),
          ),
        ),
      );

      // Assert - check Indonesian date format
      expect(find.text('15 Jan 2024, 09:05'), findsOneWidget);
    });

    testWidgets('semantic label without transaction does not mention tap', (WidgetTester tester) async {
      // Arrange
      final history = PointHistory(
        idPoin: 1,
        idUser: 1,
        poin: 50,
        perubahan: 'kurang',
        keterangan: 'Penalty',
        waktu: DateTime(2024, 12, 2, 14, 30),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointHistoryItem(
              history: history,
            ),
          ),
        ),
      );

      // Assert - check semantic label doesn't mention tapping
      final semantics = tester.getSemantics(find.byType(PointHistoryItem));
      expect(
        semantics.label,
        'Pengurangan poin. 50 poin. Penalty. 2 Des 2024, 14:30',
      );
    });
  });
}
