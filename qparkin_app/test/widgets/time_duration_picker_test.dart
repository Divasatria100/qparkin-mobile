import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/time_duration_picker.dart';

void main() {
  group('TimeDurationPicker', () {
    testWidgets('displays start time card', (WidgetTester tester) async {
      final startTime = DateTime(2024, 1, 15, 10, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: startTime,
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Waktu Mulai'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('15 Jan 2024'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('displays duration card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 3),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('3 jam'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('displays preset duration chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 1),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1h'), findsOneWidget);
      expect(find.text('2h'), findsOneWidget);
      expect(find.text('3h'), findsOneWidget);
      expect(find.text('4h'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('highlights selected duration chip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the 2h chip container
      final chip2h = find.ancestor(
        of: find.text('2h'),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(chip2h);
      final decoration = container.decoration as BoxDecoration;
      
      // Selected chip should have purple background
      expect(decoration.color, const Color(0xFF573ED1));
    });

    testWidgets('calls onDurationChanged when chip is tapped', (WidgetTester tester) async {
      Duration? selectedDuration;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 1),
              onStartTimeChanged: (_) {},
              onDurationChanged: (duration) {
                selectedDuration = duration;
              },
            ),
          ),
        ),
      );

      // Tap 3h chip
      await tester.tap(find.text('3h'));
      await tester.pumpAndSettle();

      expect(selectedDuration, const Duration(hours: 3));
    });

    testWidgets('displays calculated end time', (WidgetTester tester) async {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final duration = const Duration(hours: 2, minutes: 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: startTime,
              duration: duration,
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Selesai: 12:30, 15 Jan 2024'), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);
    });

    testWidgets('does not display end time when start time is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: null,
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.event_available), findsNothing);
      expect(find.text('--:--'), findsOneWidget);
      expect(find.text('Pilih waktu'), findsOneWidget);
    });

    testWidgets('does not display end time when duration is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: null,
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.event_available), findsNothing);
      expect(find.text('-- jam'), findsOneWidget);
    });

    testWidgets('formats duration with hours and minutes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2, minutes: 30),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('2 jam 30 menit'), findsOneWidget);
    });

    testWidgets('formats duration with hours only', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 4),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('4 jam'), findsOneWidget);
    });

    testWidgets('opens date picker when start time card is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap start time card
      await tester.tap(find.text('Waktu Mulai'));
      await tester.pumpAndSettle();

      // Date picker should appear
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('opens custom duration dialog when Custom chip is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap Custom chip
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Custom duration dialog should appear
      expect(find.text('Pilih Durasi Custom'), findsOneWidget);
      expect(find.text('Jam'), findsOneWidget);
      expect(find.text('Menit'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('highlights Custom chip for non-preset duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 5, minutes: 30),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the Custom chip container
      final customChip = find.ancestor(
        of: find.text('Custom'),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(customChip);
      final decoration = container.decoration as BoxDecoration;
      
      // Custom chip should be highlighted for non-preset duration
      expect(decoration.color, const Color(0xFF573ED1));
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      final cards = tester.widgetList<Card>(find.byType(Card));
      
      for (final card in cards) {
        expect(card.elevation, 2);
        expect(card.color, Colors.white);
        
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(16));
      }
    });

    testWidgets('end time display has purple background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      final endTimeContainer = find.ancestor(
        of: find.byIcon(Icons.event_available),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(endTimeContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, const Color(0xFF573ED1).withOpacity(0.1));
    });

    testWidgets('displays two cards in a row', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeDurationPicker(
              startTime: DateTime.now(),
              duration: const Duration(hours: 2),
              onStartTimeChanged: (_) {},
              onDurationChanged: (_) {},
            ),
          ),
        ),
      );

      // Should have a Row with two Expanded children
      final row = find.ancestor(
        of: find.byType(Card),
        matching: find.byType(Row),
      ).first;

      expect(row, findsOneWidget);
      
      final rowWidget = tester.widget<Row>(row);
      expect(rowWidget.children.whereType<Expanded>().length, 2);
    });
  });
}
