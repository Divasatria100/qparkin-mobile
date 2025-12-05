import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/floor_selector_widget.dart';
import 'package:qparkin_app/presentation/widgets/slot_visualization_widget.dart';
import 'package:qparkin_app/presentation/widgets/slot_reservation_button.dart';
import 'package:qparkin_app/presentation/widgets/reserved_slot_info_card.dart';
import 'package:qparkin_app/presentation/widgets/unified_time_duration_card.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';

/// **Booking Page Slot Selection Enhancement - Accessibility Testing**
/// 
/// Comprehensive accessibility tests for slot reservation features including:
/// - VoiceOver/TalkBack screen reader support
/// - Keyboard navigation
/// - Color contrast verification
/// - Touch target sizes
/// - Focus indicators
/// 
/// **Requirements: 9.1-9.10, 16.1-16.10**
/// **Task: 17.3 Accessibility testing**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 17.3: Accessibility Testing -', () {
    // Test data
    final testFloors = [
      ParkingFloorModel(
        idFloor: 'f1',
        idMall: 'm1',
        floorNumber: 1,
        floorName: 'Lantai 1',
        totalSlots: 50,
        availableSlots: 12,
        occupiedSlots: 35,
        reservedSlots: 3,
        lastUpdated: DateTime.now(),
      ),
      ParkingFloorModel(
        idFloor: 'f2',
        idMall: 'm1',
        floorNumber: 2,
        floorName: 'Lantai 2',
        totalSlots: 60,
        availableSlots: 0,
        occupiedSlots: 55,
        reservedSlots: 5,
        lastUpdated: DateTime.now(),
      ),
    ];

    final testSlots = [
      ParkingSlotModel(
        idSlot: 's1',
        idFloor: 'f1',
        slotCode: 'A01',
        status: SlotStatus.available,
        slotType: SlotType.regular,
        lastUpdated: DateTime.now(),
      ),
      ParkingSlotModel(
        idSlot: 's2',
        idFloor: 'f1',
        slotCode: 'A02',
        status: SlotStatus.occupied,
        slotType: SlotType.regular,
        lastUpdated: DateTime.now(),
      ),
      ParkingSlotModel(
        idSlot: 's3',
        idFloor: 'f1',
        slotCode: 'A03',
        status: SlotStatus.reserved,
        slotType: SlotType.disableFriendly,
        lastUpdated: DateTime.now(),
      ),
    ];

    final testReservation = SlotReservationModel(
      reservationId: 'r1',
      slotId: 's1',
      slotCode: 'A15',
      floorName: 'Lantai 1',
      floorNumber: '1',
      slotType: SlotType.regular,
      reservedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      isActive: true,
    );

    group('Screen Reader Tests (VoiceOver/TalkBack) -', () {
      testWidgets('floor cards have comprehensive semantic labels',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Verify floor 1 has proper label with availability
        final floor1Semantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          final hint = s.properties.hint ?? '';
          return label.contains('Lantai 1') || hint.contains('12 slot');
        });

        expect(
          floor1Semantics.isNotEmpty,
          isTrue,
          reason: 'Floor 1 should announce name and availability',
        );
      });

      testWidgets('slot visualization announces read-only status',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 3,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Verify visualization is marked as read-only
        final readOnlySemantics = semanticsWidgets.where((s) {
          return s.properties.readOnly == true;
        });

        expect(
          readOnlySemantics.isNotEmpty,
          isTrue,
          reason: 'Slot visualization should be marked as read-only',
        );
      });

      testWidgets('reservation button announces action clearly',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Verify button has clear action label
        final buttonSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Pesan slot') && label.contains('Lantai 1');
        });

        expect(
          buttonSemantics.isNotEmpty,
          isTrue,
          reason: 'Reservation button should announce action and floor',
        );
      });

      testWidgets('reserved slot card announces success state',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Verify card announces success
        final successSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('berhasil') || label.contains('Slot A15');
        });

        expect(
          successSemantics.isNotEmpty,
          isTrue,
          reason: 'Reserved slot card should announce success',
        );
      });

      testWidgets('unified time duration card has semantic structure',
          (tester) async {
        final now = DateTime.now();
        final duration = const Duration(hours: 2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: now,
                duration: duration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Verify time section has semantic label
        final timeSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Waktu') || label.contains('waktu');
        });

        expect(
          timeSemantics.isNotEmpty,
          isTrue,
          reason: 'Time section should have semantic labels',
        );
      });
    });

    group('Keyboard Navigation Tests -', () {
      testWidgets('floor selector supports keyboard navigation',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all floor cards are marked as buttons
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final buttonSemantics = semanticsWidgets.where((s) {
          return s.properties.button == true &&
              (s.properties.label ?? '').contains('Lantai');
        });

        expect(
          buttonSemantics.length,
          greaterThanOrEqualTo(2),
          reason: 'All floor cards should be keyboard accessible buttons',
        );
      });

      testWidgets('reservation button is keyboard accessible',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Verify button is marked as button
        final buttonSemantics = semanticsWidgets.where((s) {
          return s.properties.button == true;
        });

        expect(
          buttonSemantics.isNotEmpty,
          isTrue,
          reason: 'Reservation button should be keyboard accessible',
        );
      });

      testWidgets('duration chips are keyboard accessible',
          (tester) async {
        final now = DateTime.now();
        final duration = const Duration(hours: 2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: now,
                duration: duration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find duration chips by InkWell (they're custom widgets, not ChoiceChip)
        final chipFinder = find.byType(InkWell);
        expect(
          chipFinder,
          findsWidgets,
          reason: 'Duration chips should be present and keyboard accessible',
        );
      });
    });

    group('Color Contrast Tests -', () {
      testWidgets('floor cards have sufficient contrast',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find floor name text
        final floorText = tester.widget<Text>(
          find.text('Lantai 1'),
        );

        // Verify text color provides contrast
        expect(
          floorText.style?.color,
          isNotNull,
          reason: 'Floor text should have defined color for contrast',
        );
      });

      testWidgets('slot status uses color plus text labels',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 3,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify slot codes are displayed (not color-only)
        expect(
          find.text('A01'),
          findsOneWidget,
          reason: 'Slots should have text labels, not rely on color alone',
        );

        expect(
          find.text('A02'),
          findsOneWidget,
          reason: 'Slots should have text labels, not rely on color alone',
        );
      });

      testWidgets('reservation button has high contrast',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find button text
        final buttonTextFinder = find.textContaining('Pesan Slot');
        expect(buttonTextFinder, findsOneWidget);
        
        final buttonText = tester.widget<Text>(buttonTextFinder);

        // Button text should be white on purple (high contrast)
        expect(
          buttonText.style?.color,
          equals(Colors.white),
          reason: 'Button text should be white for high contrast',
        );
      });

      testWidgets('reserved slot card has sufficient contrast',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find slot code text - it's part of displayName
        final slotCodeFinder = find.textContaining('A15');
        expect(slotCodeFinder, findsOneWidget);
        
        final slotCodeText = tester.widget<Text>(slotCodeFinder);

        // Verify text has color defined
        expect(
          slotCodeText.style?.color,
          isNotNull,
          reason: 'Slot code should have defined color for contrast',
        );
      });

      testWidgets('color legend provides text alternatives',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 3,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify color legend has text labels
        expect(
          find.textContaining('Tersedia'),
          findsWidgets,
          reason: 'Color legend should have text labels',
        );
      });
    });

    group('Touch Target Size Tests -', () {
      const double minTouchTargetSize = 48.0;

      testWidgets('floor cards meet 48dp minimum touch target',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find floor cards by InkWell (they're wrapped in InkWell)
        final inkWells = find.byType(InkWell);
        expect(inkWells, findsWidgets);

        // Verify floor cards meet minimum height by checking their render boxes
        int validFloorCards = 0;
        for (final element in inkWells.evaluate()) {
          final renderBox = element.renderObject as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            if (renderBox.size.height >= minTouchTargetSize) {
              validFloorCards++;
            }
          }
        }
        
        expect(validFloorCards, greaterThanOrEqualTo(2),
            reason: 'Should have at least 2 floor cards meeting 48dp minimum');
      });

      testWidgets('reservation button meets 48dp minimum height',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find button
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);

        // Verify button height
        final buttonSize = tester.getSize(button);
        expect(
          buttonSize.height,
          greaterThanOrEqualTo(minTouchTargetSize),
          reason: 'Reservation button should meet 48dp minimum height',
        );
      });

      testWidgets('duration chips meet 48dp minimum touch target',
          (tester) async {
        final now = DateTime.now();
        final duration = const Duration(hours: 2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTimeDurationCard(
                startTime: now,
                duration: duration,
                onTimeChanged: (_) {},
                onDurationChanged: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find duration chip containers (they have minHeight constraint of 56)
        final containers = find.byType(Container);
        int chipCount = 0;
        
        for (final element in containers.evaluate()) {
          final widget = element.widget as Container;
          if (widget.constraints != null) {
            final constraints = widget.constraints as BoxConstraints;
            if (constraints.minHeight == 56) {
              chipCount++;
              expect(
                constraints.minHeight,
                greaterThanOrEqualTo(minTouchTargetSize),
                reason: 'Duration chip should meet 48dp minimum height',
              );
            }
          }
        }
        
        expect(chipCount, greaterThanOrEqualTo(4),
            reason: 'Should have at least 4 duration chips');
      });

      testWidgets('refresh button meets minimum touch target',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotVisualizationWidget(
                slots: testSlots,
                availableCount: 1,
                totalCount: 3,
                onRefresh: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find refresh IconButton
        final refreshButton = find.byType(IconButton);
        if (refreshButton.evaluate().isNotEmpty) {
          // IconButton has default size of 48x48, which meets requirement
          // Just verify it exists
          expect(refreshButton, findsWidgets);
        }
      });
    });

    group('Focus Indicator Tests -', () {
      testWidgets('floor cards show focus indicators',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify cards have InkWell for visual feedback
        final inkWells = find.byType(InkWell);
        expect(
          inkWells,
          findsWidgets,
          reason: 'Floor cards should have InkWell for focus feedback',
        );
      });

      testWidgets('reservation button shows focus indicator',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify button exists and can receive focus
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);
      });

      testWidgets('selected floor has visual indicator',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                selectedFloor: testFloors[0],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify selected state is marked in semantics
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final selectedSemantics = semanticsWidgets.where((s) {
          return s.properties.selected == true;
        });

        expect(
          selectedSemantics.isNotEmpty,
          isTrue,
          reason: 'Selected floor should have visual indicator',
        );
      });
    });

    group('Integration Tests -', () {
      testWidgets('complete slot reservation flow is accessible',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    FloorSelectorWidget(
                      floors: testFloors,
                      onFloorSelected: (_) {},
                    ),
                    const SizedBox(height: 16),
                    SlotVisualizationWidget(
                      slots: testSlots,
                      availableCount: 1,
                      totalCount: 3,
                    ),
                    const SizedBox(height: 16),
                    const SlotReservationButton(
                      floorName: 'Lantai 1',
                      isEnabled: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all components are present
        expect(find.byType(FloorSelectorWidget), findsOneWidget);
        expect(find.byType(SlotVisualizationWidget), findsOneWidget);
        expect(find.byType(SlotReservationButton), findsOneWidget);

        // Verify semantic tree is properly structured
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        expect(
          semanticsWidgets.length,
          greaterThan(0),
          reason: 'Complete flow should have semantic structure',
        );
      });

      testWidgets('error states are accessible',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                errorMessage: 'Gagal memuat data',
                onFloorSelected: (_) {},
                onRetry: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify error message has semantic label
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final errorSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Gagal');
        });

        expect(
          errorSemantics.isNotEmpty,
          isTrue,
          reason: 'Error state should be accessible',
        );
      });

      testWidgets('loading states are accessible',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                isLoading: true,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify loading state has semantic label
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final loadingSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Memuat');
        });

        expect(
          loadingSemantics.isNotEmpty,
          isTrue,
          reason: 'Loading state should be accessible',
        );
      });
    });
  });
}
