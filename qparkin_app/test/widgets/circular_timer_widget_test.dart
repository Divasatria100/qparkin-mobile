import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/circular_timer_widget.dart';

void main() {
  group('CircularTimerWidget', () {
    testWidgets('displays timer with correct initial format', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(hours: 1, minutes: 30, seconds: 45));
      bool timerUpdated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              isBooking: false,
              onTimerUpdate: (duration) {
                timerUpdated = true;
              },
            ),
          ),
        ),
      );

      // Wait for initial timer update
      await tester.pump(const Duration(milliseconds: 100));

      // Verify timer text is displayed in HH:MM:SS format
      expect(find.textContaining(':'), findsOneWidget);
      
      // Verify label is displayed
      expect(find.text('Durasi Parkir'), findsOneWidget);
      
      // Verify timer callback was called
      expect(timerUpdated, true);
    });

    testWidgets('displays booking label when isBooking is true', (WidgetTester tester) async {
      final startTime = DateTime.now();
      final endTime = DateTime.now().add(const Duration(hours: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              endTime: endTime,
              isBooking: true,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify booking label is displayed
      expect(find.text('Sisa Waktu Booking'), findsOneWidget);
    });

    testWidgets('updates timer display every second', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(seconds: 5));
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              isBooking: false,
              onTimerUpdate: (duration) {
                updateCount++;
              },
            ),
          ),
        ),
      );

      // Initial update
      await tester.pump(const Duration(milliseconds: 100));
      final initialCount = updateCount;

      // Wait for 2 seconds
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Verify timer updated at least twice
      expect(updateCount, greaterThan(initialCount));
    });

    testWidgets('renders circular progress ring', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(hours: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              isBooking: false,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify CustomPaint widget exists (for circular progress)
      expect(find.byType(CustomPaint), findsWidgets);
      
      // Verify container with circular shape
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      
      // Find the main circular container
      bool foundCircularContainer = false;
      for (final element in containers.evaluate()) {
        final container = element.widget as Container;
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            foundCircularContainer = true;
            break;
          }
        }
      }
      expect(foundCircularContainer, true);
    });

    testWidgets('has correct dimensions (240px diameter)', (WidgetTester tester) async {
      final startTime = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              isBooking: false,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Find the main container
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, 240);
      expect(container.constraints?.maxHeight, 240);
    });

    testWidgets('calculates remaining time for booking correctly', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(minutes: 30));
      final endTime = DateTime.now().add(const Duration(minutes: 30));
      Duration? capturedDuration;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              endTime: endTime,
              isBooking: true,
              onTimerUpdate: (duration) {
                capturedDuration = duration;
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify remaining time is approximately 30 minutes
      expect(capturedDuration, isNotNull);
      expect(capturedDuration!.inMinutes, closeTo(30, 1));
    });

    testWidgets('shows zero when booking time exceeded', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(hours: 2));
      final endTime = DateTime.now().subtract(const Duration(hours: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              endTime: endTime,
              isBooking: true,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify zero time is displayed when time exceeded
      expect(find.text('00:00:00'), findsOneWidget);
    });

    testWidgets('has proper semantic labels for accessibility', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(hours: 1, minutes: 30));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              isBooking: false,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify semantic label exists (outer Semantics has 'Timer parkir')
      final semantics = tester.getSemantics(find.byType(CircularTimerWidget));
      expect(semantics.label, contains('Timer parkir'));
    });

    testWidgets('disposes timer properly', (WidgetTester tester) async {
      final startTime = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              isBooking: false,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Remove widget from tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Verify no errors occur (timer disposed properly)
      expect(tester.takeException(), isNull);
    });
  });
}
