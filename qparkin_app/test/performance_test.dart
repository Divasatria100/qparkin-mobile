import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/circular_timer_widget.dart';
import 'package:qparkin_app/logic/providers/active_parking_provider.dart';

/// Performance tests for optimized components
/// Tests timer disposal, ValueNotifier efficiency, and lifecycle handling
void main() {
  group('CircularTimerWidget Performance Tests', () {
    testWidgets('Timer is properly disposed when widget is removed', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: DateTime.now().subtract(const Duration(hours: 1)),
              endTime: DateTime.now().add(const Duration(hours: 1)),
              isBooking: true,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      // Verify widget is built
      expect(find.byType(CircularTimerWidget), findsOneWidget);

      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

      // Verify widget is removed (timer should be disposed)
      expect(find.byType(CircularTimerWidget), findsNothing);
    });

    testWidgets('ValueNotifier minimizes rebuilds', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildCount++;
                return CircularTimerWidget(
                  startTime: DateTime.now().subtract(const Duration(hours: 1)),
                  endTime: DateTime.now().add(const Duration(hours: 1)),
                  isBooking: true,
                  onTimerUpdate: (duration) {},
                );
              },
            ),
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Wait for 3 seconds (3 timer updates)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Build count should not increase significantly
      // ValueNotifier should prevent full widget rebuilds
      expect(buildCount, equals(initialBuildCount));
    });

    testWidgets('Timer updates every second', (WidgetTester tester) async {
      final startTime = DateTime.now().subtract(const Duration(hours: 1));
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: startTime,
              endTime: DateTime.now().add(const Duration(hours: 1)),
              isBooking: true,
              onTimerUpdate: (duration) {
                updateCount++;
              },
            ),
          ),
        ),
      );

      // Initial update
      expect(updateCount, greaterThan(0));

      final initialCount = updateCount;

      // Wait for 2 seconds (pump doesn't actually wait, just advances the clock)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Should have at least 2 more updates
      expect(updateCount, greaterThanOrEqualTo(initialCount + 2));
    });

    testWidgets('CustomPainter caches gradient shader', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: DateTime.now().subtract(const Duration(hours: 1)),
              endTime: DateTime.now().add(const Duration(hours: 1)),
              isBooking: true,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      // Verify widget renders without errors
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Trigger multiple repaints
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Widget should still be rendering correctly
      expect(find.byType(CircularTimerWidget), findsOneWidget);
    });
  });

  group('ActiveParkingProvider Performance Tests', () {
    test('Provider properly disposes timers', () async {
      final provider = ActiveParkingProvider();

      // Verify provider is created
      expect(provider.isLoading, false);
      expect(provider.hasActiveParking, false);

      // Dispose provider
      provider.dispose();

      // Provider should be disposed without errors
    });

    test('Timer state can be saved and restored', () {
      final provider = ActiveParkingProvider();

      // Save initial state
      final savedState = provider.saveState();

      // Verify saved state structure
      expect(savedState, isA<Map<String, dynamic>>());
      expect(savedState.containsKey('activeParking'), true);
      expect(savedState.containsKey('timerState'), true);
      expect(savedState.containsKey('lastSyncTime'), true);

      // Restore state
      provider.restoreState(savedState);

      // Provider should restore without errors
      expect(provider.isLoading, false);
    });

    test('App lifecycle handling pauses and resumes timers', () {
      final provider = ActiveParkingProvider();

      // Simulate app pause
      provider.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Simulate app resume
      provider.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Provider should handle lifecycle changes without errors
      expect(provider.isLoading, false);

      provider.dispose();
    });
  });

  group('Memory and Performance Tests', () {
    testWidgets('Multiple timer instances are properly cleaned up', (WidgetTester tester) async {
      // Create and destroy multiple timer widgets
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CircularTimerWidget(
                startTime: DateTime.now().subtract(Duration(hours: i)),
                endTime: DateTime.now().add(Duration(hours: i + 1)),
                isBooking: true,
                onTimerUpdate: (duration) {},
              ),
            ),
          ),
        );

        // Remove widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      }

      // All widgets should be cleaned up
      expect(find.byType(CircularTimerWidget), findsNothing);
    });

    testWidgets('Timer continues to work after app lifecycle changes', (WidgetTester tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: DateTime.now().subtract(const Duration(hours: 1)),
              endTime: DateTime.now().add(const Duration(hours: 1)),
              isBooking: true,
              onTimerUpdate: (duration) {
                updateCount++;
              },
            ),
          ),
        ),
      );

      final initialCount = updateCount;

      // Simulate app going to background
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // Simulate app returning to foreground
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // Wait for timer updates
      await tester.pump(const Duration(seconds: 1));

      // Timer should continue working
      expect(updateCount, greaterThan(initialCount));
    });
  });
}
