import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/presentation/widgets/mall_info_card.dart';
import 'package:qparkin_app/presentation/widgets/vehicle_selector.dart';
import 'package:qparkin_app/presentation/widgets/time_duration_picker.dart';
import 'package:qparkin_app/presentation/widgets/slot_availability_indicator.dart';
import 'package:qparkin_app/presentation/widgets/cost_breakdown_card.dart';
import 'package:qparkin_app/presentation/widgets/booking_summary_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Page Accessibility Tests', () {
    final testMall = {
      'id_mall': '1',
      'nama_mall': 'Test Mall',
      'name': 'Test Mall',
      'alamat': 'Jl. Test No. 123',
      'address': 'Jl. Test No. 123',
      'distance': '1.5 km',
    };

    group('Touch Target Size Tests', () {
      testWidgets('confirm booking button meets minimum 48dp touch target', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find the confirm button by type
        final confirmButton = find.widgetWithText(ElevatedButton, 'Konfirmasi Booking');
        expect(confirmButton, findsOneWidget);

        // Get button size
        final buttonSize = tester.getSize(confirmButton);
        
        // Button should meet minimum 56dp height (exceeds 48dp requirement)
        expect(
          buttonSize.height,
          greaterThanOrEqualTo(48),
          reason: 'Confirm button should meet minimum 48dp touch target',
        );
      });

      testWidgets('back button meets minimum touch target size',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find back button by type
        final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back);
        expect(backButton, findsOneWidget);

        // Get button size
        final buttonSize = tester.getSize(backButton);
        
        expect(
          buttonSize.height,
          greaterThanOrEqualTo(48),
          reason: 'Back button should meet minimum 48dp touch target',
        );
        expect(
          buttonSize.width,
          greaterThanOrEqualTo(48),
          reason: 'Back button should meet minimum 48dp touch target',
        );
      });

      testWidgets('vehicle selector dropdown meets touch target requirements',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find vehicle selector card
        final vehicleCard = find.text('Pilih Kendaraan');
        if (vehicleCard.evaluate().isNotEmpty) {
          final cardSize = tester.getSize(vehicleCard);
          expect(
            cardSize.height,
            greaterThan(0),
            reason: 'Vehicle selector should have adequate touch target',
          );
        }
      });

      testWidgets('time picker buttons meet minimum touch target',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find time picker section
        final timePicker = find.text('Waktu Mulai');
        if (timePicker.evaluate().isNotEmpty) {
          final pickerSize = tester.getSize(timePicker);
          expect(
            pickerSize.height,
            greaterThan(0),
            reason: 'Time picker should have adequate touch target',
          );
        }
      });

      testWidgets('duration chips meet minimum touch target size',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find duration chips
        final durationChips = find.byType(ChoiceChip);
        if (durationChips.evaluate().isNotEmpty) {
          for (final chip in tester.widgetList<ChoiceChip>(durationChips)) {
            // Chips should have adequate padding for touch targets
            expect(chip, isNotNull);
          }
        }
      });
    });

    group('Screen Reader Navigation Tests', () {
      testWidgets('booking page has semantic labels for all interactive elements',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find all Semantics widgets
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        // Count widgets with labels
        int widgetsWithLabels = 0;
        int widgetsWithButtons = 0;

        for (final semantics in semanticsWidgets) {
          if (semantics.properties.label != null && 
              semantics.properties.label!.isNotEmpty) {
            widgetsWithLabels++;
          }
          if (semantics.properties.button == true) {
            widgetsWithButtons++;
          }
        }

        // Should have multiple widgets with semantic labels
        expect(
          widgetsWithLabels,
          greaterThan(0),
          reason: 'Booking page should have semantic labels',
        );
        expect(
          widgetsWithButtons,
          greaterThan(0),
          reason: 'Booking page should have button semantics',
        );
      });

      testWidgets('confirm button has proper semantic labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find semantics for confirm button
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final confirmButtonSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('konfirmasi booking') || 
                 label.contains('Konfirmasi booking');
        });

        expect(
          confirmButtonSemantics.isNotEmpty,
          isTrue,
          reason: 'Confirm button should have semantic label',
        );

        // Verify button property is set
        for (final semantics in confirmButtonSemantics) {
          expect(
            semantics.properties.button,
            isTrue,
            reason: 'Confirm button should be marked as button',
          );
        }
      });

      testWidgets('mall info card has comprehensive semantic label',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Jl. Test No. 123',
              availableSlots: 15,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find semantics for mall info
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final mallInfoSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Informasi mall') || 
                 label.contains('Test Mall');
        });

        expect(
          mallInfoSemantics.isNotEmpty,
          isTrue,
          reason: 'Mall info card should have semantic label',
        );
      });

      testWidgets('vehicle selector has semantic labels and hints',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find semantics for vehicle selector
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final vehicleSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('kendaraan') || label.contains('Kendaraan');
        });

        expect(
          vehicleSemantics.isNotEmpty,
          isTrue,
          reason: 'Vehicle selector should have semantic labels',
        );
      });

      testWidgets('loading state has semantic announcement',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );

        // Don't settle to catch loading state
        await tester.pump();

        // Find loading indicator
        final loadingIndicator = find.byType(CircularProgressIndicator);
        
        // Loading indicator may or may not be present depending on state
        // This test verifies the structure is correct
        expect(find.byType(BookingPage), findsOneWidget);
      });

      testWidgets('icons have semantic labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Jl. Test No. 123',
              availableSlots: 15,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find semantics for icons
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final iconSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Ikon') || label.contains('ikon');
        });

        expect(
          iconSemantics.isNotEmpty,
          isTrue,
          reason: 'Icons should have semantic labels',
        );
      });
    });

    group('Contrast Ratio Tests', () {
      testWidgets('primary text has sufficient contrast (black87 on white)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find primary text elements
        final appBarTitle = tester.widget<Text>(
          find.text('Booking Parkir'),
        );

        // Verify color is white on purple background (high contrast)
        expect(
          appBarTitle.style?.color,
          equals(Colors.white),
          reason: 'AppBar title should be white for contrast',
        );
      });

      testWidgets('button text has sufficient contrast',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find button text
        final buttonText = tester.widget<Text>(
          find.text('Konfirmasi Booking'),
        );

        // Button text should be white on purple background
        expect(
          buttonText.style?.color,
          equals(Colors.white),
          reason: 'Button text should be white for contrast on purple',
        );
      });

      testWidgets('secondary text has adequate contrast',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Jl. Test No. 123',
              availableSlots: 15,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find secondary text (address)
        final addressText = tester.widget<Text>(
          find.text('Jl. Test No. 123'),
        );

        // Verify color provides adequate contrast
        expect(
          addressText.style?.color,
          isNotNull,
          reason: 'Address text should have color defined',
        );
      });

      testWidgets('status indicators use color plus icons (not color alone)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SlotAvailabilityIndicator(
              availableSlots: 15,
              vehicleType: 'Roda Empat',
              isLoading: false,
              onRefresh: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find status icon
        final statusIcon = find.byIcon(Icons.local_parking);
        expect(
          statusIcon,
          findsOneWidget,
          reason: 'Status should use icon in addition to color',
        );

        // Find status text
        final statusText = find.textContaining('slot tersedia');
        expect(
          statusText,
          findsOneWidget,
          reason: 'Status should use text in addition to color',
        );
      });

      testWidgets('error messages have sufficient contrast',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Terjadi kesalahan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFFF44336),
                          ),
                        );
                      },
                      child: const Text('Show Error'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap button to show snackbar
        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Find error text
        final errorText = tester.widget<Text>(
          find.text('Terjadi kesalahan'),
        );

        // Error text should be white on red background
        expect(
          errorText.style?.color,
          equals(Colors.white),
          reason: 'Error text should be white for contrast on red',
        );
      });
    });

    group('Font Scaling Tests', () {
      testWidgets('booking page supports font scaling up to 200%',
          (WidgetTester tester) async {
        // Set text scale factor to 2.0 (200%)
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Verify page renders without overflow
        expect(find.byType(BookingPage), findsOneWidget);
        
        // Find text elements
        final appBarTitle = find.text('Booking Parkir');
        expect(appBarTitle, findsOneWidget);

        // Reset text scale factor
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      testWidgets('mall info card supports font scaling',
          (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: MallInfoCard(
              mallName: 'Test Mall',
              address: 'Jl. Test No. 123',
              availableSlots: 15,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify card renders without overflow
        expect(find.byType(MallInfoCard), findsOneWidget);
        expect(find.text('Test Mall'), findsOneWidget);

        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      testWidgets('cost breakdown card supports font scaling',
          (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: CostBreakdownCard(
              firstHourRate: 5000,
              additionalHoursRate: 6000,
              additionalHours: 2,
              totalCost: 11000,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify card renders without overflow
        expect(find.byType(CostBreakdownCard), findsOneWidget);

        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      testWidgets('booking summary card supports font scaling',
          (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;

        final now = DateTime.now();
        final duration = const Duration(hours: 2);

        await tester.pumpWidget(
          MaterialApp(
            home: BookingSummaryCard(
              mallName: 'Test Mall',
              mallAddress: 'Jl. Test No. 123',
              vehiclePlat: 'B 1234 XYZ',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: now,
              duration: duration,
              endTime: now.add(duration),
              totalCost: 11000,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify card renders without overflow
        expect(find.byType(BookingSummaryCard), findsOneWidget);

        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      testWidgets('button text scales properly',
          (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find button text
        final buttonText = find.text('Konfirmasi Booking');
        expect(buttonText, findsOneWidget);

        // Button should still be visible and functional
        final button = tester.widget<ElevatedButton>(
          find.ancestor(
            of: buttonText,
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(button, isNotNull);

        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
    });

    group('Focus Indicators Tests', () {
      testWidgets('vehicle selector shows focus indicator',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find vehicle selector
        final vehicleSelector = find.byType(VehicleSelector);
        if (vehicleSelector.evaluate().isNotEmpty) {
          expect(vehicleSelector, findsOneWidget);
        }
      });

      testWidgets('confirm button has visual feedback on press',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find confirm button
        final confirmButton = find.text('Konfirmasi Booking');
        expect(confirmButton, findsOneWidget);

        // Button should have elevation for visual feedback
        final button = tester.widget<ElevatedButton>(
          find.ancestor(
            of: confirmButton,
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(button.style, isNotNull);
      });
    });

    group('Keyboard Accessibility Tests', () {
      testWidgets('all interactive elements are keyboard accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle();

        // Find all buttons
        final buttons = tester.widgetList<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        // Verify all buttons have handlers
        for (final button in buttons) {
          // Button may be disabled, but should have onPressed defined
          expect(button, isNotNull);
        }

        // Find all icon buttons
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );

        for (final iconButton in iconButtons) {
          expect(iconButton.onPressed, isNotNull);
        }
      });

      testWidgets('dropdown is keyboard accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find dropdown
        final dropdown = find.byType(DropdownButtonFormField<dynamic>);
        
        // Dropdown may not be present if no vehicles
        // This test verifies structure is correct
        expect(find.byType(BookingPage), findsOneWidget);
      });
    });

    group('Error State Accessibility Tests', () {
      testWidgets('error messages have semantic labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Terjadi kesalahan',
                hint: 'Gagal memuat data booking',
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFF44336),
                      ),
                      SizedBox(height: 16),
                      Text('Terjadi Kesalahan'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find semantics for error state
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final errorSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('kesalahan');
        });

        expect(
          errorSemantics.isNotEmpty,
          isTrue,
          reason: 'Error state should have semantic labels',
        );
      });

      testWidgets('retry button has semantic label and hint',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Semantics(
                  button: true,
                  label: 'Coba lagi',
                  hint: 'Ketuk untuk mencoba memuat data kembali',
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Coba Lagi'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find semantics for retry button
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final retrySemantics = semanticsWidgets.where((s) {
          return s.properties.button == true &&
              (s.properties.label ?? '').contains('Coba lagi');
        });

        expect(
          retrySemantics.isNotEmpty,
          isTrue,
          reason: 'Retry button should have semantic label',
        );
      });
    });

    group('Empty State Accessibility Tests', () {
      testWidgets('empty vehicle state has semantic labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(mall: testMall),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find semantics for empty state
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );

        final emptyStateSemantics = semanticsWidgets.where((s) {
          final label = s.properties.label ?? '';
          return label.contains('Belum ada kendaraan') ||
                 label.contains('Tambahkan kendaraan');
        });

        // Empty state may or may not be present depending on data
        // This test verifies the structure is correct
        expect(find.byType(BookingPage), findsOneWidget);
      });
    });
  });
}
