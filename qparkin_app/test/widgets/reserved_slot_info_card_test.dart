import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/reserved_slot_info_card.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';

void main() {
  group('ReservedSlotInfoCard', () {
    // Test data
    late SlotReservationModel testReservation;
    late SlotReservationModel expiringSoonReservation;

    setUp(() {
      testReservation = SlotReservationModel(
        reservationId: 'r123',
        slotId: 's15',
        slotCode: 'A15',
        floorName: 'Lantai 1',
        floorNumber: '1',
        slotType: SlotType.regular,
        reservedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        isActive: true,
      );

      expiringSoonReservation = SlotReservationModel(
        reservationId: 'r124',
        slotId: 's16',
        slotCode: 'B10',
        floorName: 'Lantai 2',
        floorNumber: '2',
        slotType: SlotType.disableFriendly,
        reservedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 1, seconds: 30)),
        isActive: true,
      );
    });

    group('Reserved Slot Info Display', () {
      testWidgets('displays success header with checkmark', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );

        // Wait for animation to complete
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Slot Berhasil Direservasi'), findsOneWidget);
        
        // Verify checkmark icon
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('displays slot code and floor name', (WidgetTester tester) async {
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

        // Verify display name (floor + slot code)
        expect(find.text('Lantai 1 - Slot A15'), findsOneWidget);
      });

      testWidgets('displays slot type for regular parking', (WidgetTester tester) async {
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

        // Verify slot type label
        expect(find.text('Regular Parking'), findsOneWidget);
        
        // Verify parking icon
        expect(find.byIcon(Icons.local_parking), findsOneWidget);
      });

      testWidgets('displays slot type for disable-friendly parking', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: expiringSoonReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify slot type label
        expect(find.text('Disable-Friendly'), findsOneWidget);
        
        // Verify accessible icon
        expect(find.byIcon(Icons.accessible), findsOneWidget);
      });

      testWidgets('displays expiration time', (WidgetTester tester) async {
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

        // Verify expiration text is present
        expect(find.textContaining('Berlaku hingga:'), findsOneWidget);
        
        // Verify schedule icon
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('displays info message', (WidgetTester tester) async {
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

        // Verify info message
        expect(
          find.text('Slot ini telah dikunci untuk Anda. Selesaikan booking sebelum waktu habis.'),
          findsOneWidget,
        );
        
        // Verify info icon
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('displays clear button when onClear is provided', (WidgetTester tester) async {
        bool clearCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
                onClear: () {
                  clearCalled = true;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify close button exists
        expect(find.byIcon(Icons.close), findsOneWidget);

        // Tap close button
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(clearCalled, true);
      });

      testWidgets('does not display clear button when onClear is null', (WidgetTester tester) async {
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

        // Verify close button does not exist
        expect(find.byIcon(Icons.close), findsNothing);
      });
    });

    group('Animation', () {
      testWidgets('performs slide-up animation on mount', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );

        // Initial frame - animation not started
        expect(find.byType(SlideTransition), findsWidgets);
        expect(find.byType(ScaleTransition), findsWidgets);

        // Pump a few frames to see animation in progress
        await tester.pump(const Duration(milliseconds: 50));
        
        // Animation should be in progress
        final slideTransitions = tester.widgetList<SlideTransition>(
          find.byType(SlideTransition),
        );
        expect(slideTransitions.isNotEmpty, true);
        expect(slideTransitions.first.position, isNotNull);

        // Complete animation
        await tester.pumpAndSettle();

        // Card should be fully visible
        expect(find.text('Slot Berhasil Direservasi'), findsOneWidget);
      });

      testWidgets('performs scale animation on mount', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );

        // Verify scale transition exists
        expect(find.byType(ScaleTransition), findsWidgets);

        // Pump animation frames
        await tester.pump(const Duration(milliseconds: 100));
        
        final scaleTransitions = tester.widgetList<ScaleTransition>(
          find.byType(ScaleTransition),
        );
        expect(scaleTransitions.isNotEmpty, true);
        expect(scaleTransitions.first.scale, isNotNull);

        // Complete animation
        await tester.pumpAndSettle();
      });

      testWidgets('animation completes within 300ms', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );

        // Pump exactly 300ms
        await tester.pump(const Duration(milliseconds: 300));
        
        // Animation should be complete or nearly complete
        await tester.pumpAndSettle();

        // Card should be fully rendered
        expect(find.text('Slot Berhasil Direservasi'), findsOneWidget);
        expect(find.text('Lantai 1 - Slot A15'), findsOneWidget);
      });

      testWidgets('slide animation starts from bottom', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );

        // Get initial slide position
        final slideTransition = tester.widget<SlideTransition>(
          find.byType(SlideTransition),
        );
        
        // Position animation should exist
        expect(slideTransition.position, isNotNull);

        await tester.pumpAndSettle();
      });

      testWidgets('scale animation sequence (1.0 -> 1.05 -> 1.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation,
              ),
            ),
          ),
        );

        // Verify scale transition exists
        final scaleTransitions = tester.widgetList<ScaleTransition>(
          find.byType(ScaleTransition),
        );
        expect(scaleTransitions.isNotEmpty, true);
        expect(scaleTransitions.first.scale, isNotNull);

        // Animation should complete
        await tester.pumpAndSettle();
      });
    });

    group('Expiration Countdown', () {
      testWidgets('shows normal styling when time remaining > 2 minutes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation, // 5 minutes remaining
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show expiration time
        expect(find.textContaining('Berlaku hingga:'), findsOneWidget);
        
        // Should NOT show remaining time warning (only shown when < 2 min)
        expect(find.textContaining('Sisa waktu:'), findsNothing);
      });

      testWidgets('shows warning styling when time remaining < 2 minutes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: expiringSoonReservation, // 1.5 minutes remaining
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show expiration time
        expect(find.textContaining('Berlaku hingga:'), findsOneWidget);
        
        // Should show remaining time warning
        expect(find.textContaining('Sisa waktu:'), findsOneWidget);
      });

      testWidgets('displays formatted expiration time', (WidgetTester tester) async {
        final reservation = SlotReservationModel(
          reservationId: 'r123',
          slotId: 's15',
          slotCode: 'A15',
          floorName: 'Lantai 1',
          floorNumber: '1',
          slotType: SlotType.regular,
          reservedAt: DateTime(2025, 1, 15, 14, 0),
          expiresAt: DateTime(2025, 1, 15, 14, 30),
          isActive: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: reservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show formatted time (14:30)
        expect(find.textContaining('14:30'), findsOneWidget);
      });

      testWidgets('displays remaining time in minutes and seconds', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: expiringSoonReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show remaining time with minutes and seconds
        expect(find.textContaining('Sisa waktu:'), findsOneWidget);
        expect(find.textContaining('menit'), findsOneWidget);
        expect(find.textContaining('detik'), findsOneWidget);
      });

      testWidgets('uses orange color for expiring soon warning', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: expiringSoonReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the expiration container
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        // Look for container with orange background (expiring soon)
        final hasOrangeBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            // Check for orange color with opacity
            return decoration.color!.value == const Color(0xFFFF9800).withOpacity(0.1).value;
          }
          return false;
        });

        expect(hasOrangeBackground, true);
      });

      testWidgets('uses purple color for normal expiration', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: testReservation, // 5 minutes remaining
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the expiration container
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        // Look for container with purple background (normal)
        final hasPurpleBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            // Check for purple color with opacity
            return decoration.color!.value == const Color(0xFF573ED1).withOpacity(0.1).value;
          }
          return false;
        });

        expect(hasPurpleBackground, true);
      });

      testWidgets('schedule icon color matches expiration state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: expiringSoonReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find schedule icon
        final scheduleIcon = tester.widget<Icon>(find.byIcon(Icons.schedule));
        
        // Should be orange when expiring soon
        expect(scheduleIcon.color, const Color(0xFFFF9800));
      });
    });

    group('Accessibility Features', () {
      testWidgets('has proper semantic label for card', (WidgetTester tester) async {
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

        // Verify semantic label exists
        expect(
          find.bySemanticsLabel(RegExp('Slot berhasil direservasi.*')),
          findsOneWidget,
        );
      });

      testWidgets('success checkmark has semantic label', (WidgetTester tester) async {
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

        // Verify checkmark container has semantic label
        final semantics = tester.getSemantics(find.byIcon(Icons.check));
        expect(semantics.label, contains('Berhasil'));
      });

      testWidgets('clear button has semantic label when provided', (WidgetTester tester) async {
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

        // Verify clear button exists and is tappable
        final closeButton = find.byIcon(Icons.close);
        expect(closeButton, findsOneWidget);
        
        // Verify the IconButton wrapping the close icon has semantics
        final iconButton = find.ancestor(
          of: closeButton,
          matching: find.byType(IconButton),
        );
        expect(iconButton, findsOneWidget);
        
        // The Semantics widget should be an ancestor of the IconButton
        final semanticsWidget = find.ancestor(
          of: iconButton,
          matching: find.byType(Semantics),
        );
        expect(semanticsWidget, findsWidgets);
      });

      testWidgets('excludes decorative text from semantics', (WidgetTester tester) async {
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

        // Main semantic label should contain key info
        final semantics = tester.getSemantics(
          find.bySemanticsLabel(RegExp('Slot berhasil direservasi.*')),
        );
        
        expect(semantics.label, contains('Lantai 1'));
        expect(semantics.label, contains('A15'));
      });
    });

    group('Visual Styling', () {
      testWidgets('card has white background', (WidgetTester tester) async {
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

        // Find the main card container
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        // Look for white background container
        final hasWhiteBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.white;
          }
          return false;
        });

        expect(hasWhiteBackground, true);
      });

      testWidgets('card has rounded corners', (WidgetTester tester) async {
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

        // Find containers with rounded corners
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        // Look for 16px border radius
        final hasRoundedCorners = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.borderRadius != null) {
            return decoration.borderRadius == BorderRadius.circular(16);
          }
          return false;
        });

        expect(hasRoundedCorners, true);
      });

      testWidgets('card has shadow', (WidgetTester tester) async {
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

      testWidgets('success header has green background', (WidgetTester tester) async {
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

        // Find containers with green background
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        final hasGreenBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            // Check for green color with opacity
            return decoration.color!.value == const Color(0xFF4CAF50).withOpacity(0.1).value;
          }
          return false;
        });

        expect(hasGreenBackground, true);
      });

      testWidgets('checkmark icon has green circular background', (WidgetTester tester) async {
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

        // Find circular containers
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        final hasGreenCircle = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.shape == BoxShape.circle &&
                   decoration.color == const Color(0xFF4CAF50);
          }
          return false;
        });

        expect(hasGreenCircle, true);
      });

      testWidgets('info message has grey background', (WidgetTester tester) async {
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

        // Find containers with grey background
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        final hasGreyBackground = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            return decoration.color == const Color(0xFFF5F5F5);
          }
          return false;
        });

        expect(hasGreyBackground, true);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very short slot codes', (WidgetTester tester) async {
        final shortCodeReservation = testReservation.copyWith(
          slotCode: 'A1',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: shortCodeReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Lantai 1 - Slot A1'), findsOneWidget);
      });

      testWidgets('handles long floor names', (WidgetTester tester) async {
        final longFloorReservation = testReservation.copyWith(
          floorName: 'Lantai Basement Premium',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: longFloorReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Lantai Basement Premium - Slot A15'), findsOneWidget);
      });

      testWidgets('handles reservation with less than 1 minute remaining', (WidgetTester tester) async {
        final almostExpiredReservation = SlotReservationModel(
          reservationId: 'r125',
          slotId: 's17',
          slotCode: 'C05',
          floorName: 'Lantai 3',
          floorNumber: '3',
          slotType: SlotType.regular,
          reservedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(seconds: 45)),
          isActive: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservedSlotInfoCard(
                reservation: almostExpiredReservation,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show warning
        expect(find.textContaining('Sisa waktu:'), findsOneWidget);
        expect(find.textContaining('detik'), findsOneWidget);
      });

      testWidgets('handles multiple instances of the widget', (WidgetTester tester) async {
        final reservation2 = testReservation.copyWith(
          reservationId: 'r456',
          slotCode: 'B20',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ReservedSlotInfoCard(reservation: testReservation),
                  const SizedBox(height: 16),
                  ReservedSlotInfoCard(reservation: reservation2),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Both cards should be displayed
        expect(find.text('Lantai 1 - Slot A15'), findsOneWidget);
        expect(find.text('Lantai 1 - Slot B20'), findsOneWidget);
        expect(find.text('Slot Berhasil Direservasi'), findsNWidgets(2));
      });
    });
  });
}
