import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';
import 'package:qparkin_app/presentation/widgets/circular_timer_widget.dart';
import 'package:qparkin_app/presentation/widgets/booking_detail_card.dart';
import 'package:qparkin_app/presentation/widgets/qr_exit_button.dart';

void main() {
  group('Responsive Layout Tests', () {
    late ActiveParkingModel mockParking;

    setUp(() {
      mockParking = ActiveParkingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BK001',
        qrCode: 'QR123456',
        namaMall: 'Mega Mall Batam',
        lokasiMall: 'Batam Centre',
        idParkiran: 'P001',
        kodeSlot: 'A-12',
        platNomor: 'BP 1234 XY',
        jenisKendaraan: 'Mobil',
        merkKendaraan: 'Toyota',
        tipeKendaraan: 'Avanza',
        waktuMasuk: DateTime.now().subtract(const Duration(hours: 1)),
        waktuSelesaiEstimas: DateTime.now().add(const Duration(hours: 1)),
        isBooking: true,
        biayaPerJam: 5000,
        biayaJamPertama: 5000,
        penalty: null,
        statusParkir: 'aktif',
      );
    });

    testWidgets('renders correctly on small screen (320x568)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  CircularTimerWidget(
                    startTime: mockParking.waktuMasuk,
                    endTime: mockParking.waktuSelesaiEstimas,
                    isBooking: mockParking.isBooking,
                    onTimerUpdate: (duration) {},
                  ),
                  const SizedBox(height: 24),
                  BookingDetailCard(activeParking: mockParking),
                  const SizedBox(height: 24),
                  QRExitButton(
                    qrCode: mockParking.qrCode,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify all widgets are rendered
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(find.byType(BookingDetailCard), findsOneWidget);
      expect(find.byType(QRExitButton), findsOneWidget);
    });

    testWidgets('renders correctly on medium screen (375x667)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  CircularTimerWidget(
                    startTime: mockParking.waktuMasuk,
                    endTime: mockParking.waktuSelesaiEstimas,
                    isBooking: mockParking.isBooking,
                    onTimerUpdate: (duration) {},
                  ),
                  const SizedBox(height: 24),
                  BookingDetailCard(activeParking: mockParking),
                  const SizedBox(height: 24),
                  QRExitButton(
                    qrCode: mockParking.qrCode,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify all widgets are rendered
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(find.byType(BookingDetailCard), findsOneWidget);
      expect(find.byType(QRExitButton), findsOneWidget);
    });

    testWidgets('renders correctly on large screen (414x896)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  CircularTimerWidget(
                    startTime: mockParking.waktuMasuk,
                    endTime: mockParking.waktuSelesaiEstimas,
                    isBooking: mockParking.isBooking,
                    onTimerUpdate: (duration) {},
                  ),
                  const SizedBox(height: 24),
                  BookingDetailCard(activeParking: mockParking),
                  const SizedBox(height: 24),
                  QRExitButton(
                    qrCode: mockParking.qrCode,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify all widgets are rendered
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(find.byType(BookingDetailCard), findsOneWidget);
      expect(find.byType(QRExitButton), findsOneWidget);
    });

    testWidgets('CircularTimerWidget maintains fixed size across screens', (WidgetTester tester) async {
      // Test on small screen
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: DateTime.now(),
              isBooking: false,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final smallScreenSize = tester.getSize(find.byType(CircularTimerWidget));

      // Test on large screen
      tester.view.physicalSize = const Size(414, 896);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularTimerWidget(
              startTime: DateTime.now(),
              isBooking: false,
              onTimerUpdate: (duration) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final largeScreenSize = tester.getSize(find.byType(CircularTimerWidget));

      // Timer should maintain same size (240x240)
      expect(smallScreenSize.width, 240);
      expect(smallScreenSize.height, 240);
      expect(largeScreenSize.width, 240);
      expect(largeScreenSize.height, 240);

      addTearDown(tester.view.reset);
    });

    testWidgets('QRExitButton is full width on all screen sizes', (WidgetTester tester) async {
      final screenSizes = [
        const Size(375, 667),
        const Size(414, 896),
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: QRExitButton(
                  qrCode: 'QR123',
                  isEnabled: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final buttonSize = tester.getSize(find.byType(QRExitButton));
        final screenWidth = size.width;

        // Button should be full width minus padding (24 * 2 = 48)
        expect(buttonSize.width, closeTo(screenWidth - 48, 1));
      }

      addTearDown(tester.view.reset);
    });

    testWidgets('BookingDetailCard adapts to screen width', (WidgetTester tester) async {
      final screenSizes = [
        const Size(375, 667),
        const Size(414, 896),
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: BookingDetailCard(activeParking: mockParking),
              ),
            ),
          ),
        );

        await tester.pump();

        final cardSize = tester.getSize(find.byType(BookingDetailCard));
        final screenWidth = size.width;

        // Card should adapt to available width
        expect(cardSize.width, closeTo(screenWidth - 48, 1));
      }

      addTearDown(tester.view.reset);
    });

    testWidgets('maintains proper spacing on different screen sizes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  CircularTimerWidget(
                    startTime: mockParking.waktuMasuk,
                    isBooking: false,
                    onTimerUpdate: (duration) {},
                  ),
                  const SizedBox(height: 24),
                  BookingDetailCard(activeParking: mockParking),
                  const SizedBox(height: 24),
                  QRExitButton(
                    qrCode: mockParking.qrCode,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify spacing between components exists
      final spacers = find.byType(SizedBox);
      expect(spacers, findsWidgets);

      // Verify all widgets are rendered with proper layout
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(find.byType(BookingDetailCard), findsOneWidget);
      expect(find.byType(QRExitButton), findsOneWidget);
    });

    testWidgets('content is scrollable when exceeds screen height', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 400); // Short screen
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  CircularTimerWidget(
                    startTime: mockParking.waktuMasuk,
                    isBooking: false,
                    onTimerUpdate: (duration) {},
                  ),
                  const SizedBox(height: 24),
                  BookingDetailCard(activeParking: mockParking),
                  const SizedBox(height: 24),
                  QRExitButton(
                    qrCode: mockParking.qrCode,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Try scrolling
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pump();

      // Verify widgets are still rendered after scroll
      expect(find.byType(CircularTimerWidget), findsOneWidget);
    });

    testWidgets('touch targets meet minimum size requirements (48dp)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                QRExitButton(
                  qrCode: 'QR123',
                  isEnabled: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // QRExitButton should be 56px (exceeds 48dp minimum)
      final buttonSize = tester.getSize(find.byType(ElevatedButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48));
    });
  });
}
