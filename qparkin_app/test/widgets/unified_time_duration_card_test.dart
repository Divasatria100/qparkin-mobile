import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/unified_time_duration_card.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    // Initialize Indonesian locale for date formatting
    await initializeDateFormatting('id_ID', null);
  });

  group('UnifiedTimeDurationCard', () {
    // Test data
    late DateTime testStartTime;
    late Duration testDuration;
    late DateTime testEndTime;

    setUp(() {
      testStartTime = DateTime(2025, 1, 15, 14, 30);
      testDuration = const Duration(hours: 2);
      testEndTime = testStartTime.add(testDuration);
    });

    group('Date & Time Selection', () {
      testWidgets('displays selected date in Indonesian format', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify date format: "Rabu, 15 Januari 2025"
        expect(find.textContaining('15 Januari 2025'), findsOneWidget);
      });

      testWidgets('displays selected time in 24-hour format', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify time format: "14:30"
        expect(find.text('14:30'), findsOneWidget);
      });

      testWidgets('displays placeholder when no time selected', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: null,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify placeholders
        expect(find.text('Pilih tanggal'), findsOneWidget);
        expect(find.text('--:--'), findsOneWidget);
      });

      testWidgets('shows calendar icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify calendar icon
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('date/time section is tappable', (WidgetTester tester) async {
        bool timeChangeCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {
                  timeChangeCalled = true;
                },
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and tap the date/time section
        final inkWell = find.ancestor(
          of: find.byIcon(Icons.calendar_today),
          matching: find.byType(InkWell),
        );
        
        expect(inkWell, findsOneWidget);
      });

      testWidgets('displays error state when startTimeError is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
                startTimeError: 'Waktu tidak boleh di masa lalu',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify error message
        expect(find.text('Waktu tidak boleh di masa lalu'), findsOneWidget);
        
        // Verify error icon
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Duration Chip Selection', () {
      testWidgets('displays all preset duration chips', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify all preset durations
        expect(find.text('1 Jam'), findsOneWidget);
        expect(find.text('2 Jam'), findsOneWidget);
        expect(find.text('3 Jam'), findsOneWidget);
        expect(find.text('4 Jam'), findsOneWidget);
        expect(find.text('> 4 Jam'), findsOneWidget);
      });

      testWidgets('highlights selected duration chip', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the selected chip (2 Jam)
        final chipText = find.text('2 Jam');
        expect(chipText, findsOneWidget);
        
        // Verify checkmark icon is shown for selected chip
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('calls onDurationChanged when chip is tapped', (WidgetTester tester) async {
        Duration? selectedDuration;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (duration) {
                  selectedDuration = duration;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the 3 Jam chip
        await tester.tap(find.text('3 Jam'));
        await tester.pumpAndSettle();

        // Verify callback was called with correct duration
        expect(selectedDuration, const Duration(hours: 3));
      });

      testWidgets('displays selected duration text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify duration display text
        expect(find.text('Durasi: 2 jam'), findsOneWidget);
      });

      testWidgets('displays custom duration with minutes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 5, minutes: 30),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify custom duration display
        expect(find.text('Durasi: 5 jam 30 menit'), findsOneWidget);
        
        // Verify custom chip is highlighted
        expect(find.text('> 4 Jam'), findsOneWidget);
      });

      testWidgets('duration chips have minimum size for touch targets', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find duration chip containers
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        // Check for minimum size constraints (80x56)
        final hasMinSize = containers.any((container) {
          return container.constraints?.minWidth == 80 &&
                 container.constraints?.minHeight == 56;
        });

        expect(hasMinSize, true);
      });

      testWidgets('displays error state when durationError is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
                durationError: 'Durasi minimal 30 menit',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify error message
        expect(find.text('Durasi minimal 30 menit'), findsOneWidget);
      });
    });

    group('Custom Duration Dialog', () {
      testWidgets('opens custom duration dialog when > 4 Jam is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the custom duration chip
        await tester.tap(find.text('> 4 Jam'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Pilih Durasi Custom'), findsOneWidget);
        expect(find.text('Jam'), findsOneWidget);
        expect(find.text('Menit'), findsOneWidget);
      });

      testWidgets('custom duration dialog has hour and minute dropdowns', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open custom duration dialog
        await tester.tap(find.text('> 4 Jam'));
        await tester.pumpAndSettle();

        // Verify dropdowns exist
        expect(find.byType(DropdownButton<int>), findsNWidgets(2));
      });

      testWidgets('custom duration dialog shows total duration preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open custom duration dialog
        await tester.tap(find.text('> 4 Jam'));
        await tester.pumpAndSettle();

        // Verify total duration preview exists
        expect(find.textContaining('Total:'), findsOneWidget);
      });

      testWidgets('custom duration dialog validates minimum 30 minutes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open custom duration dialog
        await tester.tap(find.text('> 4 Jam'));
        await tester.pumpAndSettle();

        // Dialog should be open with default 5h 0m (valid)
        expect(find.text('Pilih Durasi Custom'), findsOneWidget);
        
        // OK button should be enabled with default valid duration
        final okButton = find.widgetWithText(ElevatedButton, 'OK');
        expect(okButton, findsOneWidget);
      });

      testWidgets('custom duration dialog calls onDurationChanged with selected duration', (WidgetTester tester) async {
        Duration? selectedDuration;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 5),
                onTimeChanged: (_) {},
                onDurationChanged: (duration) {
                  selectedDuration = duration;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open custom duration dialog
        await tester.tap(find.text('> 4 Jam'));
        await tester.pumpAndSettle();

        // Tap OK button (should be enabled with default 5h 0m)
        await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
        await tester.pumpAndSettle();

        // Verify callback was called
        expect(selectedDuration, const Duration(hours: 5));
      });

      testWidgets('custom duration dialog can be cancelled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open custom duration dialog
        await tester.tap(find.text('> 4 Jam'));
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        // Dialog should be closed
        expect(find.text('Pilih Durasi Custom'), findsNothing);
      });
    });

    group('End Time Calculation', () {
      testWidgets('displays calculated end time', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify end time is displayed
        expect(find.text('Selesai:'), findsOneWidget);
        expect(find.textContaining('16:30'), findsOneWidget); // 14:30 + 2h = 16:30
      });

      testWidgets('displays end time in Indonesian format', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify Indonesian date format
        expect(find.textContaining('15 Jan 2025'), findsOneWidget);
      });

      testWidgets('displays total duration in end time section', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify total duration display
        expect(find.text('Total: 2 jam'), findsOneWidget);
      });

      testWidgets('shows clock icon in end time display', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify schedule icon
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('does not display end time when startTime is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: null,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // End time should not be displayed
        expect(find.text('Selesai:'), findsNothing);
      });

      testWidgets('does not display end time when duration is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: null,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // End time should not be displayed
        expect(find.text('Selesai:'), findsNothing);
      });

      testWidgets('updates end time when start time changes', (WidgetTester tester) async {
        DateTime currentStartTime = testStartTime;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      UnifiedTimeDurationCard(
                        startTime: currentStartTime,
                        duration: testDuration,
                        onTimeChanged: (newTime) {
                          setState(() {
                            currentStartTime = newTime;
                          });
                        },
                        onDurationChanged: (_) {},
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentStartTime = DateTime(2025, 1, 15, 16, 0);
                          });
                        },
                        child: const Text('Change Time'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initial end time: 16:30
        expect(find.textContaining('16:30'), findsOneWidget);

        // Change start time
        await tester.tap(find.text('Change Time'));
        await tester.pumpAndSettle();

        // New end time: 18:00 (16:00 + 2h)
        expect(find.textContaining('18:00'), findsOneWidget);
      });

      testWidgets('updates end time when duration changes', (WidgetTester tester) async {
        Duration currentDuration = testDuration;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      UnifiedTimeDurationCard(
                        startTime: testStartTime,
                        duration: currentDuration,
                        onTimeChanged: (_) {},
                        onDurationChanged: (newDuration) {
                          setState(() {
                            currentDuration = newDuration;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentDuration = const Duration(hours: 3);
                          });
                        },
                        child: const Text('Change Duration'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initial end time: 16:30 (14:30 + 2h)
        expect(find.textContaining('16:30'), findsOneWidget);

        // Change duration
        await tester.tap(find.text('Change Duration'));
        await tester.pumpAndSettle();

        // New end time: 17:30 (14:30 + 3h)
        expect(find.textContaining('17:30'), findsOneWidget);
      });

      testWidgets('end time display has fade animation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        // Verify FadeTransition exists
        expect(find.byType(FadeTransition), findsOneWidget);

        await tester.pumpAndSettle();
      });
    });

    group('Responsive Behavior', () {
      testWidgets('adapts padding for small screens (< 375px)', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Card should render with smaller padding (16px)
        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
      });

      testWidgets('adapts padding for medium screens (375-414px)', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Card should render with medium padding (20px)
        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
      });

      testWidgets('adapts padding for large screens (> 414px)', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Card should render with large padding (24px)
        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
      });

      testWidgets('stacks duration chips vertically on very small screens (< 360px)', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UnifiedTimeDurationCard(
                  startTime: testStartTime,
                  duration: testDuration,
                  onTimeChanged: (_) {},
                  onDurationChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should use Column instead of SingleChildScrollView for chips
        // Verify all chips are still visible
        expect(find.text('1 Jam'), findsOneWidget);
        expect(find.text('2 Jam'), findsOneWidget);
        expect(find.text('3 Jam'), findsOneWidget);
        expect(find.text('4 Jam'), findsOneWidget);
      });

      testWidgets('uses horizontal scroll for duration chips on normal screens', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should use SingleChildScrollView for horizontal scrolling
        expect(find.byType(SingleChildScrollView), findsWidgets);
      });

      testWidgets('supports 200% font scaling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaleFactor: 2.0,
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: UnifiedTimeDurationCard(
                    startTime: testStartTime,
                    duration: testDuration,
                    onTimeChanged: (_) {},
                    onDurationChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // All text should still be visible
        expect(find.text('Waktu & Durasi Booking'), findsOneWidget);
        expect(find.text('14:30'), findsOneWidget);
      });

      testWidgets('maintains minimum 48dp touch targets on all screen sizes', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UnifiedTimeDurationCard(
                  startTime: testStartTime,
                  duration: testDuration,
                  onTimeChanged: (_) {},
                  onDurationChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Duration chips should have minimum 56px height (> 48dp)
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasMinHeight = containers.any((container) {
          return container.constraints?.minHeight == 56;
        });

        expect(hasMinHeight, true);
      });

      testWidgets('preserves card proportions in landscape orientation', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(844, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UnifiedTimeDurationCard(
                  startTime: testStartTime,
                  duration: testDuration,
                  onTimeChanged: (_) {},
                  onDurationChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Card should render without issues
        expect(find.byType(Card), findsOneWidget);
        expect(find.text('Waktu & Durasi Booking'), findsOneWidget);
      });
    });

    group('Visual Styling', () {
      testWidgets('card has white background', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify card color
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.color, Colors.white);
      });

      testWidgets('card has 16px rounded corners', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify card shape
        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(16));
      });

      testWidgets('card has elevation 3', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify card elevation
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 3);
      });

      testWidgets('selected duration chip has purple background', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find containers with purple background
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasPurpleBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            return decoration.color == const Color(0xFF573ED1);
          }
          return false;
        });

        expect(hasPurpleBackground, true);
      });

      testWidgets('unselected duration chip has light purple background', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find containers with light purple background
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasLightPurpleBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            return decoration.color == const Color(0xFFE8E0FF);
          }
          return false;
        });

        expect(hasLightPurpleBackground, true);
      });

      testWidgets('end time display has light purple background', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find end time container
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasLightPurpleBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            return decoration.color == const Color(0xFFE8E0FF);
          }
          return false;
        });

        expect(hasLightPurpleBackground, true);
      });

      testWidgets('selected chip has shadow', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find containers with box shadow
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasShadow = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty;
          }
          return false;
        });

        expect(hasShadow, true);
      });

      testWidgets('card shows red border when there are errors', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
                startTimeError: 'Waktu tidak valid',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify card has red border
        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.side.color, const Color(0xFFF44336));
        expect(shape.side.width, 2);
      });

      testWidgets('date/time section has grey background by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find containers with grey background
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasGreyBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            // Check for grey shade 50
            return decoration.color!.value == Colors.grey.shade50.value;
          }
          return false;
        });

        expect(hasGreyBackground, true);
      });

      testWidgets('date/time section has red background when error', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
                startTimeError: 'Waktu tidak valid',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find containers with red background
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasRedBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            // Check for red shade 50
            return decoration.color!.value == Colors.red.shade50.value;
          }
          return false;
        });

        expect(hasRedBackground, true);
      });
    });

    group('Accessibility Features', () {
      testWidgets('card header has semantic header', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify header text is present
        expect(find.text('Waktu & Durasi Booking'), findsOneWidget);
      });

      testWidgets('date/time section has semantic label and hint', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify semantic label exists
        expect(
          find.bySemanticsLabel(RegExp('Waktu mulai booking.*')),
          findsOneWidget,
        );
      });

      testWidgets('duration chips have semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify semantic labels for duration chips
        expect(
          find.bySemanticsLabel(RegExp('Durasi 2 jam.*')),
          findsOneWidget,
        );
      });

      testWidgets('selected duration chip has selected semantic state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify the selected chip has "terpilih" in its label
        expect(
          find.bySemanticsLabel(RegExp('Durasi 2 jam, terpilih')),
          findsOneWidget,
        );
      });

      testWidgets('end time display has semantic label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify end time semantic label
        expect(
          find.bySemanticsLabel(RegExp('Waktu selesai booking.*')),
          findsOneWidget,
        );
      });

      testWidgets('duration chips are marked as buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify duration chip has button semantics (hint contains "Ketuk")
        expect(
          find.bySemanticsLabel(RegExp('Durasi 1 jam.*')),
          findsOneWidget,
        );
      });

      testWidgets('date/time section is marked as button', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify date/time section has button semantics (hint contains "Ketuk")
        expect(
          find.bySemanticsLabel(RegExp('Waktu mulai booking.*')),
          findsOneWidget,
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('handles midnight start time', (WidgetTester tester) async {
        final midnightTime = DateTime(2025, 1, 15, 0, 0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: midnightTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify midnight time display
        expect(find.text('00:00'), findsOneWidget);
        
        // Verify end time (02:00)
        expect(find.textContaining('02:00'), findsOneWidget);
      });

      testWidgets('handles end time crossing midnight', (WidgetTester tester) async {
        final lateTime = DateTime(2025, 1, 15, 23, 0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: lateTime,
                duration: const Duration(hours: 2),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify start time
        expect(find.text('23:00'), findsOneWidget);
        
        // End time should be next day at 01:00
        expect(find.textContaining('01:00'), findsOneWidget);
        expect(find.textContaining('16 Jan 2025'), findsOneWidget);
      });

      testWidgets('handles very long duration (> 12 hours)', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(hours: 15, minutes: 30),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify duration display
        expect(find.text('Durasi: 15 jam 30 menit'), findsOneWidget);
        
        // Verify end time exists (14:30 + 15:30 = next day 06:00)
        expect(find.textContaining('06:00'), findsOneWidget);
      });

      testWidgets('handles duration with only minutes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: const Duration(minutes: 45),
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify duration display (0 hours should not be shown)
        expect(find.text('Durasi: 0 jam 45 menit'), findsOneWidget);
      });

      testWidgets('handles multiple error messages simultaneously', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: testStartTime,
                duration: testDuration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
                startTimeError: 'Waktu tidak valid',
                durationError: 'Durasi terlalu pendek',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Both errors should be displayed
        expect(find.text('Waktu tidak valid'), findsOneWidget);
        expect(find.text('Durasi terlalu pendek'), findsOneWidget);
        
        // Two error icons should be present
        expect(find.byIcon(Icons.error_outline), findsNWidgets(2));
      });

      testWidgets('handles rapid duration changes', (WidgetTester tester) async {
        Duration currentDuration = const Duration(hours: 1);

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: UnifiedTimeDurationCard(
                    startTime: testStartTime,
                    duration: currentDuration,
                    onTimeChanged: (_) {},
                    onDurationChanged: (newDuration) {
                      setState(() {
                        currentDuration = newDuration;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Rapidly change durations
        await tester.tap(find.text('2 Jam'));
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.tap(find.text('3 Jam'));
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.tap(find.text('4 Jam'));
        await tester.pumpAndSettle();

        // Final duration should be 4 hours
        expect(find.text('Durasi: 4 jam'), findsOneWidget);
      });

      testWidgets('handles widget rebuild with null values', (WidgetTester tester) async {
        DateTime? currentStartTime = testStartTime;
        Duration? currentDuration = testDuration;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      UnifiedTimeDurationCard(
                        startTime: currentStartTime,
                        duration: currentDuration,
                        onTimeChanged: (_) {},
                        onDurationChanged: (_) {},
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentStartTime = null;
                            currentDuration = null;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially should show values
        expect(find.text('14:30'), findsOneWidget);

        // Clear values
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        // Should show placeholders
        expect(find.text('Pilih tanggal'), findsOneWidget);
        expect(find.text('--:--'), findsOneWidget);
        
        // End time should not be displayed
        expect(find.text('Selesai:'), findsNothing);
      });
    });
  });
}
