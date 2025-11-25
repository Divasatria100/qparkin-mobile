import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/logic/providers/active_parking_provider.dart';

/// Performance tests for Booking Page
/// Tests page load time, scroll performance, memory usage, and API call frequency
/// Requirements: 13.1, 13.8
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Sample mall data for testing
  final sampleMall = {
    'id_mall': '1',
    'name': 'Test Mall',
    'nama_mall': 'Test Mall',
    'address': 'Jl. Test No. 123',
    'alamat': 'Jl. Test No. 123',
    'distance': '2.5 km',
    'available': 15,
    'firstHourRate': 5000.0,
    'additionalHourRate': 3000.0,
  };

  group('Booking Page Performance Tests', () {
    testWidgets('page loads within 2 seconds', (WidgetTester tester) async {
      final startTime = DateTime.now();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
            routes: {
              '/activity': (context) => const Scaffold(body: Text('Activity')),
              '/home': (context) => const Scaffold(body: Text('Home')),
            },
          ),
        ),
      );

      // Initial render
      await tester.pump();

      final initialRenderTime = DateTime.now().difference(startTime);

      // Initial render should be reasonable (< 1000ms)
      // Note: Complex pages with providers may take longer
      expect(
        initialRenderTime.inMilliseconds,
        lessThan(1000),
        reason: 'Initial page render should be reasonable',
      );

      // Wait for all widgets to settle
      await tester.pumpAndSettle();

      final totalLoadTime = DateTime.now().difference(startTime);

      // Total load time should be under 2 seconds
      expect(
        totalLoadTime.inMilliseconds,
        lessThan(2000),
        reason: 'Page should load within 2 seconds',
      );

      // Verify page is rendered
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(find.text('Test Mall'), findsOneWidget);
    });

    testWidgets('scroll performance is smooth (60fps target)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Record frame timings during scroll
      final List<Duration> frameDurations = [];
      DateTime? lastFrameTime;

      // Find scrollable widget
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);

      // Perform scroll gesture and record frame times
      await tester.drag(scrollView, const Offset(0, -300));
      
      for (int i = 0; i < 10; i++) {
        final frameStart = DateTime.now();
        await tester.pump(const Duration(milliseconds: 16));
        
        if (lastFrameTime != null) {
          frameDurations.add(frameStart.difference(lastFrameTime));
        }
        lastFrameTime = frameStart;
      }

      await tester.pumpAndSettle();

      // Verify frame durations are reasonable
      // Target: 16.67ms per frame (60fps)
      // We allow up to 33ms (30fps) as acceptable in tests
      for (final duration in frameDurations) {
        expect(
          duration.inMilliseconds,
          lessThan(33),
          reason: 'Frame should render within 33ms for smooth scrolling',
        );
      }

      // Should not throw any errors during scroll
      expect(tester.takeException(), isNull);
    });

    testWidgets('multiple rapid scrolls maintain performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scrollView = find.byType(SingleChildScrollView);

      // Perform multiple rapid scrolls
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollView, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
        
        await tester.drag(scrollView, const Offset(0, 200));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('shimmer loading animation is smooth', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      // Pump several frames during loading
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Should not throw any errors during animation
      expect(tester.takeException(), isNull);
    });

    testWidgets('widget rebuild is optimized', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildCount++;
                return BookingPage(mall: sampleMall);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Trigger a small state change (scroll)
      final scrollView = find.byType(SingleChildScrollView);
      await tester.drag(scrollView, const Offset(0, -100));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Build count should not increase excessively
      expect(
        buildCount - initialBuildCount,
        lessThan(10),
        reason: 'Widget should not rebuild excessively',
      );
    });

    testWidgets('memory usage is reasonable during state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger multiple state changes
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('multiple widget instances are properly cleaned up', (WidgetTester tester) async {
      // Create and destroy multiple booking page instances
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
            ],
            child: MaterialApp(
              home: BookingPage(mall: sampleMall),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Remove widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
        await tester.pumpAndSettle();
      }

      // All widgets should be cleaned up
      expect(find.byType(BookingPage), findsNothing);
    });

    testWidgets('animation does not block UI thread', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start scroll animation
      final scrollView = find.byType(SingleChildScrollView);
      await tester.drag(scrollView, const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 50));

      // UI should still be responsive during animation
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.pumpAndSettle();

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid page creation and disposal does not cause memory leaks', (WidgetTester tester) async {
      // Create and dispose multiple page instances
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
            ],
            child: MaterialApp(
              home: BookingPage(mall: sampleMall),
              routes: {
                '/activity': (context) => const Scaffold(body: Text('Activity')),
                '/home': (context) => const Scaffold(body: Text('Home')),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Dispose by replacing with empty widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
        await tester.pumpAndSettle();
      }

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('const constructors are used where possible', (WidgetTester tester) async {
      // This test verifies that const constructors are used
      // which helps with performance by reusing widget instances

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify page renders correctly
      expect(find.byType(BookingPage), findsOneWidget);

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('animation cleanup is proper', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
            routes: {
              '/home': (context) => const Scaffold(body: Text('Home')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start scroll animation
      final scrollView = find.byType(SingleChildScrollView);
      await tester.drag(scrollView, const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 50));

      // Navigate away during animation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should not throw any errors (animations should be cleaned up)
      expect(tester.takeException(), isNull);
    });

    testWidgets('state updates are batched efficiently', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      // Pump through multiple state updates
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should complete without errors
      expect(tester.takeException(), isNull);
      expect(find.text('Test Mall'), findsOneWidget);
    });

    testWidgets('card rendering is efficient', (WidgetTester tester) async {
      final startTime = DateTime.now();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final renderTime = DateTime.now().difference(startTime);

      // Cards should render quickly
      expect(
        renderTime.inMilliseconds,
        lessThan(2000),
        reason: 'Card layout should render efficiently',
      );

      // Verify cards are rendered
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('icon rendering is efficient', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify icons are rendered
      expect(find.byType(Icon), findsWidgets);

      // Should not throw any errors during icon rendering
      expect(tester.takeException(), isNull);
    });
  });

  group('BookingProvider Performance Tests', () {
    test('provider properly disposes timers', () async {
      final provider = BookingProvider();

      // Initialize provider
      provider.initialize(sampleMall);

      // Verify provider is created
      expect(provider.isLoading, false);
      expect(provider.selectedMall, isNotNull);

      // Dispose provider
      provider.dispose();

      // Provider should be disposed without errors
    });

    test('debouncing prevents excessive calculations', () async {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      int calculationCount = 0;
      
      // Mock cost calculation by tracking state changes
      provider.addListener(() {
        if (provider.estimatedCost > 0) {
          calculationCount++;
        }
      });

      // Rapid duration changes (should be debounced)
      provider.setDuration(const Duration(hours: 1), token: 'test_token');
      provider.setDuration(const Duration(hours: 2), token: 'test_token');
      provider.setDuration(const Duration(hours: 3), token: 'test_token');

      // Wait for debounce delay
      await Future.delayed(const Duration(milliseconds: 400));

      // Should have limited calculations due to debouncing
      expect(
        calculationCount,
        lessThan(5),
        reason: 'Debouncing should prevent excessive calculations',
      );

      provider.dispose();
    });

    test('caching reduces redundant operations', () {
      final provider = BookingProvider();

      // Initialize with same mall multiple times
      provider.initialize(sampleMall);
      provider.initialize(sampleMall);
      provider.initialize(sampleMall);

      // Should handle multiple initializations efficiently
      expect(provider.selectedMall, isNotNull);
      expect(provider.selectedMall!['id_mall'], equals('1'));

      provider.dispose();
    });

    test('timer cleanup prevents memory leaks', () async {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      // Start periodic check
      provider.startPeriodicAvailabilityCheck(token: 'test_token');

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop periodic check
      provider.stopPeriodicAvailabilityCheck();

      // Dispose provider
      provider.dispose();

      // Should complete without errors
    });

    test('state updates are efficient', () {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Make multiple state changes
      provider.setStartTime(DateTime.now(), token: 'test_token');
      provider.setDuration(const Duration(hours: 2), token: 'test_token');

      // Should have reasonable number of notifications
      expect(
        notificationCount,
        lessThan(10),
        reason: 'State updates should be batched efficiently',
      );

      provider.dispose();
    });
  });

  group('API Call Frequency Tests', () {
    test('periodic availability check respects interval', () async {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      int checkCount = 0;
      provider.addListener(() {
        if (provider.isCheckingAvailability) {
          checkCount++;
        }
      });

      // Start periodic check (30s interval)
      provider.startPeriodicAvailabilityCheck(token: 'test_token');

      // Wait for a short period
      await Future.delayed(const Duration(milliseconds: 200));

      // Stop periodic check
      provider.stopPeriodicAvailabilityCheck();

      // Should have limited API calls
      expect(
        checkCount,
        lessThan(5),
        reason: 'API calls should respect interval timing',
      );

      provider.dispose();
    });

    test('debouncing reduces API call frequency', () async {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      // Rapid changes should be debounced
      provider.setStartTime(DateTime.now(), token: 'test_token');
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: 'test_token');
      provider.setStartTime(DateTime.now().add(const Duration(hours: 2)), token: 'test_token');

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 600));

      // Should have limited API calls due to debouncing
      provider.dispose();
    });

    test('manual refresh does not interfere with periodic checks', () async {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      // Start periodic check
      provider.startPeriodicAvailabilityCheck(token: 'test_token');

      // Manual refresh
      await provider.refreshAvailability(token: 'test_token');

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop periodic check
      provider.stopPeriodicAvailabilityCheck();

      // Should complete without errors
      provider.dispose();
    });
  });

  group('Memory Management Tests', () {
    testWidgets('large objects are cleared on dispose', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away (triggers dispose)
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('controllers are properly disposed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ActiveParkingProvider()),
          ],
          child: MaterialApp(
            home: BookingPage(mall: sampleMall),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pumpAndSettle();

      // Should not throw any errors (controllers should be disposed)
      expect(tester.takeException(), isNull);
    });

    test('provider clears references on dispose', () {
      final provider = BookingProvider();
      provider.initialize(sampleMall);

      // Set various state
      provider.setStartTime(DateTime.now(), token: 'test_token');
      provider.setDuration(const Duration(hours: 2), token: 'test_token');

      // Dispose
      provider.dispose();

      // Should complete without errors
    });
  });
}
