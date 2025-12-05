import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/floor_selector_widget.dart';
import 'package:qparkin_app/presentation/widgets/slot_visualization_widget.dart';
import 'package:qparkin_app/presentation/widgets/slot_reservation_button.dart';
import 'package:qparkin_app/presentation/widgets/reserved_slot_info_card.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';

/// Screen Reader Accessibility Tests
/// 
/// Tests VoiceOver/TalkBack navigation, announcements, and focus order
/// for slot reservation features.
/// 
/// Requirements: 9.1-9.10, 16.1-16.10
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screen Reader Tests - Floor Selector', () {
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

    testWidgets('floor cards have proper semantic labels', (tester) async {
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

      // Find all Semantics widgets
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify floor 1 has proper label
      final floor1Semantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Lantai 1');
      });

      expect(
        floor1Semantics.isNotEmpty,
        isTrue,
        reason: 'Floor 1 should have semantic label',
      );

      // Verify floor 1 has hint about availability
      final floor1WithHint = semanticsWidgets.where((s) {
        final hint = s.properties.hint ?? '';
        return hint.contains('12 slot tersedia');
      });

      expect(
        floor1WithHint.isNotEmpty,
        isTrue,
        reason: 'Floor 1 should announce availability',
      );
    });

    testWidgets('unavailable floor announces disabled state', (tester) async {
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

      // Verify floor 2 (unavailable) has proper hint
      final floor2WithHint = semanticsWidgets.where((s) {
        final hint = s.properties.hint ?? '';
        return hint.contains('Tidak tersedia');
      });

      expect(
        floor2WithHint.isNotEmpty,
        isTrue,
        reason: 'Unavailable floor should announce disabled state',
      );
    });

    testWidgets('floor selector announces button role', (tester) async {
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

      // Verify floor cards are marked as buttons
      final buttonSemantics = semanticsWidgets.where((s) {
        return s.properties.button == true &&
            (s.properties.label ?? '').contains('Lantai');
      });

      expect(
        buttonSemantics.length,
        greaterThanOrEqualTo(2),
        reason: 'Floor cards should be marked as buttons',
      );
    });

    testWidgets('selected floor announces selected state', (tester) async {
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

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify selected floor has selected property
      final selectedSemantics = semanticsWidgets.where((s) {
        return s.properties.selected == true;
      });

      expect(
        selectedSemantics.isNotEmpty,
        isTrue,
        reason: 'Selected floor should announce selected state',
      );
    });

    testWidgets('loading state has semantic announcement', (tester) async {
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
      await tester.pump(); // Use pump() instead of pumpAndSettle() for shimmer animations

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify loading state has proper label
      final loadingSemantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Memuat');
      });

      expect(
        loadingSemantics.isNotEmpty,
        isTrue,
        reason: 'Loading state should have semantic label',
      );
    });

    testWidgets('error state has semantic announcement with retry', (tester) async {
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

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify error state has proper label
      final errorSemantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Gagal');
      });

      expect(
        errorSemantics.isNotEmpty,
        isTrue,
        reason: 'Error state should have semantic label',
      );

      // Verify retry button has proper semantics
      final retrySemantics = semanticsWidgets.where((s) {
        return s.properties.button == true &&
            (s.properties.label ?? '').contains('coba lagi');
      });

      expect(
        retrySemantics.isNotEmpty,
        isTrue,
        reason: 'Retry button should have semantic label',
      );
    });
  });

  group('Screen Reader Tests - Slot Visualization', () {
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

    testWidgets('slot visualization has proper semantic label', (tester) async {
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

      // Verify visualization has proper label
      final vizSemantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Visualisasi slot');
      });

      expect(
        vizSemantics.isNotEmpty,
        isTrue,
        reason: 'Slot visualization should have semantic label',
      );
    });

    testWidgets('individual slots announce status and type', (tester) async {
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

      // Verify slot A01 (available) has proper label
      final slot1Semantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Slot A01');
      });

      expect(
        slot1Semantics.isNotEmpty,
        isTrue,
        reason: 'Slot should have semantic label with code',
      );

      // Verify slot has status in hint
      final slotWithStatus = semanticsWidgets.where((s) {
        final hint = s.properties.hint ?? '';
        return hint.contains('Tersedia') || hint.contains('Terisi');
      });

      expect(
        slotWithStatus.isNotEmpty,
        isTrue,
        reason: 'Slot should announce status',
      );
    });

    testWidgets('color legend announces status meanings', (tester) async {
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

      // Verify color legend has proper label
      final legendSemantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Keterangan warna');
      });

      expect(
        legendSemantics.isNotEmpty,
        isTrue,
        reason: 'Color legend should have semantic label',
      );
    });

    testWidgets('refresh button announces action', (tester) async {
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

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify refresh button has proper semantics
      final refreshSemantics = semanticsWidgets.where((s) {
        return s.properties.button == true &&
            (s.properties.label ?? '').contains('perbarui');
      });

      expect(
        refreshSemantics.isNotEmpty,
        isTrue,
        reason: 'Refresh button should have semantic label',
      );
    });

    testWidgets('slot visualization is marked as read-only', (tester) async {
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
        return s.properties.readOnly == true &&
            (s.properties.label ?? '').contains('Visualisasi');
      });

      expect(
        readOnlySemantics.isNotEmpty,
        isTrue,
        reason: 'Slot visualization should be marked as read-only',
      );
    });
  });

  group('Screen Reader Tests - Slot Reservation Button', () {
    testWidgets('reservation button has proper semantic label', (tester) async {
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

      // Verify button has proper label
      final buttonSemantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Pesan slot acak');
      });

      expect(
        buttonSemantics.isNotEmpty,
        isTrue,
        reason: 'Reservation button should have semantic label',
      );
    });

    testWidgets('reservation button announces action hint', (tester) async {
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

      // Verify button has hint
      final buttonWithHint = semanticsWidgets.where((s) {
        final hint = s.properties.hint ?? '';
        return hint.contains('Ketuk untuk mereservasi');
      });

      expect(
        buttonWithHint.isNotEmpty,
        isTrue,
        reason: 'Reservation button should have action hint',
      );
    });

    testWidgets('disabled button announces disabled state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SlotReservationButton(
              floorName: 'Lantai 1',
              isEnabled: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify button is marked as disabled
      final disabledSemantics = semanticsWidgets.where((s) {
        return s.properties.enabled == false &&
            (s.properties.label ?? '').contains('Pesan slot');
      });

      expect(
        disabledSemantics.isNotEmpty,
        isTrue,
        reason: 'Disabled button should announce disabled state',
      );
    });

    testWidgets('loading button announces loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SlotReservationButton(
              floorName: 'Lantai 1',
              isLoading: true,
              isEnabled: true,
            ),
          ),
        ),
      );
      await tester.pump(); // Use pump() instead of pumpAndSettle() for loading animations

      // Find loading text
      final loadingText = find.text('Mereservasi...');
      expect(
        loadingText,
        findsOneWidget,
        reason: 'Loading button should show loading text',
      );
    });
  });

  group('Screen Reader Tests - Reserved Slot Info Card', () {
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

    testWidgets('reserved slot card has proper semantic label', (tester) async {
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

      // Verify card has proper label
      final cardSemantics = semanticsWidgets.where((s) {
        final label = s.properties.label ?? '';
        return label.contains('Slot berhasil direservasi');
      });

      expect(
        cardSemantics.isNotEmpty,
        isTrue,
        reason: 'Reserved slot card should have semantic label',
      );
    });

    testWidgets('reserved slot card announces slot details', (tester) async {
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

      // Verify card announces slot code and floor
      final cardWithDetails = semanticsWidgets.where((s) {
        final hint = s.properties.hint ?? '';
        return hint.contains('A15') && hint.contains('Lantai 1');
      });

      expect(
        cardWithDetails.isNotEmpty,
        isTrue,
        reason: 'Reserved slot card should announce slot details',
      );
    });

    testWidgets('clear button has proper semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservedSlotInfoCard(
              reservation: testReservation,
              onClear: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      // Verify clear button has proper semantics
      final clearSemantics = semanticsWidgets.where((s) {
        return s.properties.button == true &&
            (s.properties.label ?? '').contains('Hapus');
      });

      expect(
        clearSemantics.isNotEmpty,
        isTrue,
        reason: 'Clear button should have semantic label',
      );
    });
  });

  group('Screen Reader Tests - Focus Order', () {
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
    ];

    testWidgets('focus order follows logical reading order', (tester) async {
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
                    totalCount: 1,
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

      // Verify all interactive elements are present in order
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
        reason: 'Should have semantic widgets in logical order',
      );
    });

    testWidgets('all interactive elements are keyboard accessible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FloorSelectorWidget(
                  floors: testFloors,
                  onFloorSelected: (_) {},
                ),
                const SlotReservationButton(
                  floorName: 'Lantai 1',
                  isEnabled: true,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all buttons have proper semantics
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      final buttonSemantics = semanticsWidgets.where((s) {
        return s.properties.button == true;
      });

      expect(
        buttonSemantics.length,
        greaterThanOrEqualTo(2),
        reason: 'All interactive elements should be marked as buttons',
      );
    });
  });
}
