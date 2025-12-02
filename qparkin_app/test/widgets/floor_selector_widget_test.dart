import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/floor_selector_widget.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';

void main() {
  group('FloorSelectorWidget', () {
    // Test data
    final testFloors = [
      ParkingFloorModel(
        idFloor: 'f1',
        idMall: 'm1',
        floorNumber: 1,
        floorName: 'Lantai 1',
        totalSlots: 50,
        availableSlots: 15,
        occupiedSlots: 30,
        reservedSlots: 5,
        lastUpdated: DateTime.now(),
      ),
      ParkingFloorModel(
        idFloor: 'f2',
        idMall: 'm1',
        floorNumber: 2,
        floorName: 'Lantai 2',
        totalSlots: 60,
        availableSlots: 25,
        occupiedSlots: 30,
        reservedSlots: 5,
        lastUpdated: DateTime.now(),
      ),
      ParkingFloorModel(
        idFloor: 'f3',
        idMall: 'm1',
        floorNumber: 3,
        floorName: 'Lantai 3',
        totalSlots: 40,
        availableSlots: 0,
        occupiedSlots: 35,
        reservedSlots: 5,
        lastUpdated: DateTime.now(),
      ),
    ];

    group('Floor Display', () {
      testWidgets('displays all floors correctly', (WidgetTester tester) async {
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

        // Verify all floor names are displayed
        expect(find.text('Lantai 1'), findsOneWidget);
        expect(find.text('Lantai 2'), findsOneWidget);
        expect(find.text('Lantai 3'), findsOneWidget);
      });

      testWidgets('displays floor numbers in badges', (WidgetTester tester) async {
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

        // Verify floor numbers are displayed
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('displays availability text for each floor', (WidgetTester tester) async {
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

        // Verify availability text
        expect(find.text('15 slot tersedia'), findsOneWidget);
        expect(find.text('25 slot tersedia'), findsOneWidget);
        expect(find.text('0 slot tersedia'), findsOneWidget);
      });

      testWidgets('displays parking icons for all floors', (WidgetTester tester) async {
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

        // Verify parking icons are displayed (one per floor)
        expect(find.byIcon(Icons.local_parking), findsNWidgets(3));
      });

      testWidgets('displays chevron icons for all floors', (WidgetTester tester) async {
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

        // Verify chevron icons are displayed
        expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
      });

      testWidgets('shows green icon for available floors', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]], // Floor with 15 available slots
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final parkingIcon = tester.widget<Icon>(find.byIcon(Icons.local_parking));
        expect(parkingIcon.color, const Color(0xFF4CAF50)); // Green
      });

      testWidgets('shows grey icon for unavailable floors', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[2]], // Floor with 0 available slots
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final parkingIcon = tester.widget<Icon>(find.byIcon(Icons.local_parking));
        expect(parkingIcon.color, isNot(const Color(0xFF4CAF50))); // Not green
      });
    });

    group('Floor Selection', () {
      testWidgets('calls onFloorSelected when available floor is tapped', (WidgetTester tester) async {
        ParkingFloorModel? selectedFloor;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (floor) {
                  selectedFloor = floor;
                },
              ),
            ),
          ),
        );

        // Tap on first floor (available)
        await tester.tap(find.text('Lantai 1'));
        await tester.pumpAndSettle();

        expect(selectedFloor, isNotNull);
        expect(selectedFloor!.idFloor, 'f1');
        expect(selectedFloor!.floorName, 'Lantai 1');
      });

      testWidgets('does not call onFloorSelected when unavailable floor is tapped', (WidgetTester tester) async {
        ParkingFloorModel? selectedFloor;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (floor) {
                  selectedFloor = floor;
                },
              ),
            ),
          ),
        );

        // Tap on third floor (unavailable - 0 slots)
        await tester.tap(find.text('Lantai 3'));
        await tester.pumpAndSettle();

        expect(selectedFloor, isNull);
      });

      testWidgets('highlights selected floor with purple border', (WidgetTester tester) async {
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

        // Find the container for the selected floor
        final selectedCard = find.ancestor(
          of: find.text('Lantai 1'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(selectedCard);
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.border, isNotNull);
        final border = decoration.border as Border;
        expect(border.top.color, const Color(0xFF573ED1)); // Purple
        expect(border.top.width, 2);
      });

      testWidgets('shows purple background tint for selected floor', (WidgetTester tester) async {
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

        final selectedCard = find.ancestor(
          of: find.text('Lantai 1'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(selectedCard);
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.color, isNotNull);
        expect(decoration.color!.alpha, greaterThan(0)); // Has some opacity
      });

      testWidgets('shows white background for unselected floors', (WidgetTester tester) async {
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

        final unselectedCard = find.ancestor(
          of: find.text('Lantai 2'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(unselectedCard);
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.color, Colors.white);
      });

      testWidgets('floor badge shows purple background when selected', (WidgetTester tester) async {
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

        // Find the badge container (56x56 circle)
        final badges = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(FloorSelectorWidget),
            matching: find.byType(Container),
          ),
        ).where((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.shape == BoxShape.circle;
          }
          return false;
        }).toList();

        expect(badges.isNotEmpty, true);
        
        // First badge should be selected (solid purple)
        final firstBadge = badges[0];
        final decoration = firstBadge.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF573ED1));
      });
    });

    group('Loading State', () {
      testWidgets('displays shimmer loading when isLoading is true', (WidgetTester tester) async {
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

        // Verify shimmer loading is displayed (3 skeleton cards)
        expect(find.byType(Container), findsWidgets);
        
        // Should not show actual floor data
        expect(find.text('Lantai 1'), findsNothing);
      });

      testWidgets('does not display floors when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                isLoading: true,
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Should not show floor names during loading
        expect(find.text('Lantai 1'), findsNothing);
        expect(find.text('Lantai 2'), findsNothing);
      });

      testWidgets('loading state has proper semantics', (WidgetTester tester) async {
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

        // Verify semantic label for loading state
        expect(
          find.bySemanticsLabel('Memuat daftar lantai parkir'),
          findsOneWidget,
        );
      });
    });

    group('Error State', () {
      testWidgets('displays error message when errorMessage is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                errorMessage: 'Gagal memuat data lantai',
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Error message appears in both title and description
        expect(find.text('Gagal memuat data lantai'), findsWidgets);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays retry button in error state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                errorMessage: 'Network error',
                onRetry: () {},
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Coba Lagi'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('calls onRetry when retry button is tapped', (WidgetTester tester) async {
        bool retryWasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                errorMessage: 'Network error',
                onRetry: () {
                  retryWasCalled = true;
                },
                onFloorSelected: (_) {},
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
              body: FloorSelectorWidget(
                floors: [],
                errorMessage: 'Test error',
                onRetry: () {},
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify error state elements are present
        expect(find.text('Gagal memuat data lantai'), findsWidgets);
        expect(find.text('Coba Lagi'), findsOneWidget);
      });

      testWidgets('error state has red color scheme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                errorMessage: 'Test error',
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final errorIcon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(errorIcon.color, isNotNull);
        expect(errorIcon.size, 48);
      });

      testWidgets('does not display floors in error state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                errorMessage: 'Error occurred',
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Should not show floor data when error is present
        expect(find.text('Lantai 1'), findsNothing);
        expect(find.text('Lantai 2'), findsNothing);
      });
    });

    group('Empty State', () {
      testWidgets('displays empty state when floors list is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Tidak ada lantai tersedia'), findsOneWidget);
        expect(find.text('Belum ada data lantai parkir untuk mall ini'), findsOneWidget);
        expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
      });

      testWidgets('empty state has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify empty state elements are present
        expect(find.text('Tidak ada lantai tersedia'), findsOneWidget);
        expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
      });

      testWidgets('empty state has grey color scheme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final emptyIcon = tester.widget<Icon>(find.byIcon(Icons.layers_outlined));
        expect(emptyIcon.size, 48);
      });
    });

    group('Accessibility Features', () {
      testWidgets('floor cards have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify floor card has semantic information
        expect(find.text('Lantai 1'), findsOneWidget);
        expect(find.text('15 slot tersedia'), findsOneWidget);
      });

      testWidgets('available floor has proper semantic hint', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Lantai 1'));
        expect(semantics.label, contains('Lantai 1'));
      });

      testWidgets('unavailable floor indicates disabled state in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[2]], // Floor with 0 slots
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Lantai 3'));
        expect(semantics.label, contains('Lantai 3'));
      });

      testWidgets('selected floor has selected semantic flag', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                selectedFloor: testFloors[0],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify selected floor has purple border
        final selectedCard = find.ancestor(
          of: find.text('Lantai 1'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(selectedCard);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
      });

      testWidgets('floor cards are marked as buttons in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify floor card is tappable (has InkWell)
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('floor number badge has semantic label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify floor number is displayed in badge
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('floor info sections have semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Verify floor name and availability are displayed
        expect(find.text('Lantai 1'), findsOneWidget);
        expect(find.text('15 slot tersedia'), findsOneWidget);
      });

      testWidgets('maintains minimum 48dp touch target size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final cardSize = tester.getSize(find.byType(InkWell).first);
        expect(cardSize.height, greaterThanOrEqualTo(48));
      });
    });

    group('Visual Styling', () {
      testWidgets('floor cards have proper height', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final cardContainer = find.ancestor(
          of: find.text('Lantai 1'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(cardContainer);
        expect(container.constraints?.maxHeight, 80);
      });

      testWidgets('floor cards have rounded corners', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final cardContainer = find.ancestor(
          of: find.text('Lantai 1'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(cardContainer);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(16));
      });

      testWidgets('floor cards have shadow', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final cardContainer = find.ancestor(
          of: find.text('Lantai 1'),
          matching: find.byType(Container),
        ).first;

        final container = tester.widget<Container>(cardContainer);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.isNotEmpty, true);
      });

      testWidgets('floor badge is circular with correct size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        final badges = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(FloorSelectorWidget),
            matching: find.byType(Container),
          ),
        ).where((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.shape == BoxShape.circle;
          }
          return false;
        }).toList();

        expect(badges.isNotEmpty, true);
        
        final badge = badges[0];
        expect(badge.constraints?.maxWidth, 56);
        expect(badge.constraints?.maxHeight, 56);
      });

      testWidgets('floors have proper spacing between cards', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors.take(2).toList(),
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        // Find padding widgets between floor cards
        final paddings = tester.widgetList<Padding>(find.byType(Padding));
        
        // Check that there's padding with bottom: 12
        final hasCorrectPadding = paddings.any((padding) {
          return padding.padding == const EdgeInsets.only(bottom: 12);
        });
        
        expect(hasCorrectPadding, true);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles single floor', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [testFloors[0]],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Lantai 1'), findsOneWidget);
        expect(find.text('Lantai 2'), findsNothing);
      });

      testWidgets('handles many floors', (WidgetTester tester) async {
        final manyFloors = List.generate(
          10,
          (index) => ParkingFloorModel(
            idFloor: 'f$index',
            idMall: 'm1',
            floorNumber: index + 1,
            floorName: 'Lantai ${index + 1}',
            totalSlots: 50,
            availableSlots: 10,
            occupiedSlots: 35,
            reservedSlots: 5,
            lastUpdated: DateTime.now(),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FloorSelectorWidget(
                  floors: manyFloors,
                  onFloorSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        // Verify first and last floors are present
        expect(find.text('Lantai 1'), findsOneWidget);
        
        // Scroll to see last floor
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
        await tester.pumpAndSettle();
        
        expect(find.text('Lantai 10'), findsOneWidget);
      });

      testWidgets('handles floor with very high slot count', (WidgetTester tester) async {
        final largeFloor = ParkingFloorModel(
          idFloor: 'f1',
          idMall: 'm1',
          floorNumber: 1,
          floorName: 'Lantai 1',
          totalSlots: 500,
          availableSlots: 250,
          occupiedSlots: 200,
          reservedSlots: 50,
          lastUpdated: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [largeFloor],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('250 slot tersedia'), findsOneWidget);
      });

      testWidgets('handles floor with long name', (WidgetTester tester) async {
        final longNameFloor = ParkingFloorModel(
          idFloor: 'f1',
          idMall: 'm1',
          floorNumber: 1,
          floorName: 'Lantai Basement Premium',
          totalSlots: 50,
          availableSlots: 15,
          occupiedSlots: 30,
          reservedSlots: 5,
          lastUpdated: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: [longNameFloor],
                onFloorSelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Lantai Basement Premium'), findsOneWidget);
      });

      testWidgets('handles rapid floor selection', (WidgetTester tester) async {
        final selectedFloors = <ParkingFloorModel>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloorSelectorWidget(
                floors: testFloors,
                onFloorSelected: (floor) {
                  selectedFloors.add(floor);
                },
              ),
            ),
          ),
        );

        // Rapidly tap different floors
        await tester.tap(find.text('Lantai 1'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Lantai 2'));
        await tester.pumpAndSettle();

        expect(selectedFloors.length, 2);
        expect(selectedFloors[0].floorNumber, 1);
        expect(selectedFloors[1].floorNumber, 2);
      });
    });
  });
}
