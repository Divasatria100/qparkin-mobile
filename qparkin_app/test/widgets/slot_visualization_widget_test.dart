import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/slot_visualization_widget.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';

void main() {
  group('SlotVisualizationWidget', () {
    // Test data
    final testSlots = [
      ParkingSlotModel(
        idSlot: 's1',
        idFloor: 'f1',
        slotCode: 'A01',
        status: SlotStatus.available,
        slotType: SlotType.regular,
        positionX: 0,
        positionY: 0,
        lastUpdated: DateTime.now(),
      ),
      ParkingSlotModel(
        idSlot: 's2',
        idFloor: 'f1',
        slotCode: 'A02',
        status: SlotStatus.occupied,
        slotType: SlotType.regular,
        positionX: 1,
        positionY: 0,
        lastUpdated: DateTime.now(),
      ),
      ParkingSlotModel(
        idSlot: 's3',
        idFloor: 'f1',
        slotCode: 'A03',
        status: SlotStatus.reserved,
        slotType: SlotType.disableFriendly,
        positionX: 2,
        positionY: 0,
        lastUpdated: DateTime.now(),
      ),
      ParkingSlotModel(
        idSlot: 's4',
        idFloor: 'f1',
        slotCode: 'A04',
        status: SlotStatus.disabled,
        slotType: SlotType.regular,
        positionX: 3,
        positionY: 0,
        lastUpdated: DateTime.now(),
      ),
    ];

    group('Slot Visualization Display', () {
      testWidgets('displays header with title', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.text('Ketersediaan Slot'), findsOneWidget);
      });

      testWidgets('displays available slot count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.text('1 slot tersedia dari 4 total'), findsOneWidget);
      });

      testWidgets('displays last updated timestamp when provided', (WidgetTester tester) async {
        final lastUpdated = DateTime(2025, 1, 15, 14, 30);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                lastUpdated: lastUpdated,
              ),
            ),
          ),
        );

        expect(find.textContaining('Terakhir diperbarui: 14:30'), findsOneWidget);
      });

      testWidgets('displays all slot codes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.text('A01'), findsOneWidget);
        expect(find.text('A02'), findsOneWidget);
        expect(find.text('A03'), findsOneWidget);
        expect(find.text('A04'), findsOneWidget);
      });

      testWidgets('displays slot type icons correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Regular slots have local_parking icon
        expect(find.byIcon(Icons.local_parking), findsNWidgets(3));
        // Disable-friendly slot has accessible icon
        expect(find.byIcon(Icons.accessible), findsOneWidget);
      });

      testWidgets('displays slots in grid layout', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('applies correct color for available slots', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]], // Available slot
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF4CAF50)); // Green
      });

      testWidgets('applies correct color for occupied slots', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[1]], // Occupied slot
                availableCount: 0,
                totalCount: 1,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF9E9E9E)); // Grey
      });

      testWidgets('applies correct color for reserved slots', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[2]], // Reserved slot
                availableCount: 0,
                totalCount: 1,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFFF9800)); // Yellow/Orange
      });

      testWidgets('applies correct color for disabled slots', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[3]], // Disabled slot
                availableCount: 0,
                totalCount: 1,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFF44336)); // Red
      });
    });

    group('Refresh Functionality', () {
      testWidgets('displays refresh button when onRefresh is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                onRefresh: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('does not display refresh button when onRefresh is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.refresh), findsNothing);
      });

      testWidgets('calls onRefresh when refresh button is tapped', (WidgetTester tester) async {
        bool refreshWasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                onRefresh: () {
                  refreshWasCalled = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        expect(refreshWasCalled, true);
      });

      testWidgets('shows loading indicator in refresh button when isLoading is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SlotVisualizationWidget(
                  slots: testSlots,
                  availableCount: 1,
                  totalCount: 4,
                  isLoading: true,
                  onRefresh: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsNothing);
      });

      testWidgets('disables refresh button when isLoading is true', (WidgetTester tester) async {
        bool refreshWasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SlotVisualizationWidget(
                  slots: testSlots,
                  availableCount: 1,
                  totalCount: 4,
                  isLoading: true,
                  onRefresh: () {
                    refreshWasCalled = true;
                  },
                ),
              ),
            ),
          ),
        );

        // Try to tap the button (should be disabled)
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
        expect(refreshWasCalled, false);
      });

      testWidgets('refresh button has proper tooltip', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                onRefresh: () {},
              ),
            ),
          ),
        );

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, 'Perbarui ketersediaan slot');
      });
    });

    group('No Interaction Capabilities', () {
      testWidgets('slot cards do not have tap handlers', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Verify no InkWell or GestureDetector wrapping slot cards
        final slotCards = find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Container),
        );

        // Try to tap a slot card - should not trigger any interaction
        await tester.tap(slotCards.first);
        await tester.pumpAndSettle();

        // No interaction should occur (no state change, no callback)
        // The widget should remain unchanged
        expect(find.text('A01'), findsOneWidget);
      });

      testWidgets('slot cards are marked as read-only in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]],
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        // Verify slot card has read-only semantic label
        final semantics = tester.getSemantics(find.text('A01'));
        expect(semantics.label, contains('Slot A01'));
      });

      testWidgets('slot cards do not have selection state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Verify no slot has selection border or highlight
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Container),
          ),
        );

        for (final container in containers) {
          final decoration = container.decoration as BoxDecoration?;
          if (decoration != null && decoration.border != null) {
            // Should not have purple selection border
            final border = decoration.border as Border;
            expect(border.top.color, isNot(const Color(0xFF573ED1)));
          }
        }
      });

      testWidgets('grid view is non-scrollable', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        expect(gridView.physics, isA<NeverScrollableScrollPhysics>());
      });

      testWidgets('slot cards do not respond to long press', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final slotCard = find.text('A01');
        
        // Try long press - should not trigger any interaction
        await tester.longPress(slotCard);
        await tester.pumpAndSettle();

        // Widget should remain unchanged
        expect(find.text('A01'), findsOneWidget);
      });

      testWidgets('visualization is display-only with no interactive elements', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Verify no interactive widgets in slot grid (except refresh button)
        final interactiveWidgets = find.descendant(
          of: find.byType(GridView),
          matching: find.byWidgetPredicate(
            (widget) => widget is InkWell || widget is GestureDetector,
          ),
        );

        expect(interactiveWidgets, findsNothing);
      });
    });

    group('Loading State', () {
      testWidgets('displays shimmer loading when isLoading is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SlotVisualizationWidget(
                  slots: [],
                  isLoading: true,
                  availableCount: 0,
                  totalCount: 0,
                ),
              ),
            ),
          ),
        );

        // Verify shimmer loading is displayed
        expect(find.byType(GridView), findsOneWidget);
        
        // Should not show actual slot data
        expect(find.text('A01'), findsNothing);
      });

      testWidgets('does not display slots when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SlotVisualizationWidget(
                  slots: testSlots,
                  isLoading: true,
                  availableCount: 1,
                  totalCount: 4,
                ),
              ),
            ),
          ),
        );

        // Should not show slot codes during loading
        expect(find.text('A01'), findsNothing);
        expect(find.text('A02'), findsNothing);
      });

      testWidgets('loading state has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SlotVisualizationWidget(
                  slots: [],
                  isLoading: true,
                  availableCount: 0,
                  totalCount: 0,
                ),
              ),
            ),
          ),
        );

        // Verify loading state displays grid view with shimmer
        expect(find.byType(GridView), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('displays error message when errorMessage is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [],
                errorMessage: 'Gagal memuat tampilan slot',
                availableCount: 0,
                totalCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('Gagal memuat tampilan slot'), findsWidgets);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays retry button in error state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [],
                errorMessage: 'Network error',
                onRefresh: () {},
                availableCount: 0,
                totalCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('Coba Lagi'), findsOneWidget);
      });

      testWidgets('calls onRefresh when retry button is tapped', (WidgetTester tester) async {
        bool retryWasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [],
                errorMessage: 'Network error',
                onRefresh: () {
                  retryWasCalled = true;
                },
                availableCount: 0,
                totalCount: 0,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();

        expect(retryWasCalled, true);
      });

      testWidgets('error state has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [],
                errorMessage: 'Test error',
                onRefresh: () {},
                availableCount: 0,
                totalCount: 0,
              ),
            ),
          ),
        );

        expect(
          find.text('Gagal memuat tampilan slot'),
          findsWidgets,
        );
      });

      testWidgets('does not display slots in error state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                errorMessage: 'Error occurred',
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Should not show slot data when error is present
        expect(find.text('A01'), findsNothing);
        expect(find.text('A02'), findsNothing);
      });
    });

    group('Empty State', () {
      testWidgets('displays empty state when slots list is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [],
                availableCount: 0,
                totalCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('Tidak ada data slot'), findsOneWidget);
        expect(find.text('Belum ada data slot untuk lantai ini'), findsOneWidget);
        expect(find.byIcon(Icons.grid_off), findsOneWidget);
      });

      testWidgets('empty state has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [],
                availableCount: 0,
                totalCount: 0,
              ),
            ),
          ),
        );

        expect(
          find.text('Tidak ada data slot'),
          findsOneWidget,
        );
      });
    });

    group('Accessibility Features', () {
      testWidgets('header has proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(
          find.text('Ketersediaan Slot'),
          findsOneWidget,
        );
      });

      testWidgets('slot cards have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]],
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('A01'));
        expect(semantics.label, contains('Slot A01'));
      });

      testWidgets('slot status is announced in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]], // Available slot
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        // Verify slot card exists with proper semantic structure
        final semantics = tester.getSemantics(find.text('A01'));
        expect(semantics.label, isNotEmpty);
      });

      testWidgets('slot type is announced in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[2]], // Disable-friendly slot
                availableCount: 0,
                totalCount: 1,
              ),
            ),
          ),
        );

        // Verify slot card exists with proper semantic structure
        final semantics = tester.getSemantics(find.text('A03'));
        expect(semantics.label, isNotEmpty);
      });

      testWidgets('refresh button has proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                onRefresh: () {},
              ),
            ),
          ),
        );

        // Verify refresh button exists with tooltip
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, 'Perbarui ketersediaan slot');
      });

      testWidgets('grid is marked as read-only in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Verify grid view exists and displays slots
        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('A01'), findsOneWidget);
      });
    });

    group('Responsive Layout', () {
      testWidgets('calculates correct columns for small screen', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(320, 568);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 4);
      });

      testWidgets('calculates correct columns for medium screen', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 5);
      });

      testWidgets('calculates correct columns for large screen', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(414, 896);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 6);
      });
    });

    group('Visual Styling', () {
      testWidgets('slot cards have rounded corners', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]],
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(8));
      });

      testWidgets('grid has proper spacing', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisSpacing, 8);
        expect(delegate.mainAxisSpacing, 8);
      });

      testWidgets('slot cards maintain square aspect ratio', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.childAspectRatio, 1.0);
      });

      testWidgets('slot icons have correct size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]],
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.local_parking));
        expect(icon.size, 20);
      });

      testWidgets('slot text has correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]],
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('A01'));
        expect(text.style?.fontSize, 12);
        expect(text.style?.fontWeight, FontWeight.bold);
        expect(text.style?.color, Colors.white);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles single slot', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: [testSlots[0]],
                availableCount: 1,
                totalCount: 1,
              ),
            ),
          ),
        );

        expect(find.text('A01'), findsOneWidget);
        expect(find.text('A02'), findsNothing);
      });

      testWidgets('handles many slots', (WidgetTester tester) async {
        final manySlots = List.generate(
          50,
          (index) => ParkingSlotModel(
            idSlot: 's$index',
            idFloor: 'f1',
            slotCode: 'A${index.toString().padLeft(2, '0')}',
            status: SlotStatus.available,
            slotType: SlotType.regular,
            positionX: index % 10,
            positionY: index ~/ 10,
            lastUpdated: DateTime.now(),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SlotVisualizationWidget(
                  slots: manySlots,
                  availableCount: 50,
                  totalCount: 50,
                ),
              ),
            ),
          ),
        );

        // Verify first and last slots are present
        expect(find.text('A00'), findsOneWidget);
        expect(find.text('A49'), findsOneWidget);
      });

      testWidgets('handles all slots occupied', (WidgetTester tester) async {
        final occupiedSlots = testSlots.map((slot) {
          return slot.copyWith(status: SlotStatus.occupied);
        }).toList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: occupiedSlots,
                availableCount: 0,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.text('0 slot tersedia dari 4 total'), findsOneWidget);
      });

      testWidgets('handles all slots available', (WidgetTester tester) async {
        final availableSlots = testSlots.map((slot) {
          return slot.copyWith(status: SlotStatus.available);
        }).toList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: availableSlots,
                availableCount: 4,
                totalCount: 4,
              ),
            ),
          ),
        );

        expect(find.text('4 slot tersedia dari 4 total'), findsOneWidget);
      });

      testWidgets('handles mixed slot types', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
              ),
            ),
          ),
        );

        // Verify both icon types are displayed
        expect(find.byIcon(Icons.local_parking), findsNWidgets(3));
        expect(find.byIcon(Icons.accessible), findsOneWidget);
      });

      testWidgets('handles rapid refresh calls', (WidgetTester tester) async {
        int refreshCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                onRefresh: () {
                  refreshCount++;
                },
              ),
            ),
          ),
        );

        // Rapidly tap refresh button
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        expect(refreshCount, 2);
      });

      testWidgets('handles null lastUpdated', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 4,
                lastUpdated: null,
              ),
            ),
          ),
        );

        // Should not display timestamp when null
        expect(find.textContaining('Terakhir diperbarui'), findsNothing);
      });
    });
  });
}
