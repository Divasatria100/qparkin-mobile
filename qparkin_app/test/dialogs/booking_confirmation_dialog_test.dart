import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qparkin_app/presentation/dialogs/booking_confirmation_dialog.dart';
import 'package:qparkin_app/data/models/booking_model.dart';

void main() {
  group('BookingConfirmationDialog', () {
    late BookingModel testBooking;

    setUp(() {
      // Create test booking data
      testBooking = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        lokasiMall: 'Jakarta',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        kodeSlot: 'A-01',
      );
    });

    testWidgets('displays success message and booking ID',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Booking Berhasil!'), findsOneWidget);
      // Verify transaction ID and booking ID are displayed
      expect(find.text('TRX001'), findsOneWidget);
      expect(find.text('ID Booking: BKG001'), findsOneWidget);
    });

    testWidgets('displays QR code section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify QR code section
      expect(find.text('QR Code Masuk'), findsOneWidget);
      expect(find.text('Tunjukkan di gerbang masuk'), findsOneWidget);
    });

    testWidgets('renders QR code widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify QR code widget exists
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Verify QR code is within a container with proper styling
      final containerFinder = find.ancestor(
        of: qrFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);
    });

    testWidgets('displays booking details', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify booking details
      expect(find.text('Detail Booking'), findsOneWidget);
      expect(find.text('Mall Test'), findsOneWidget);
      expect(find.text('A-01'), findsOneWidget);
      expect(find.text('B 1234 XYZ'), findsOneWidget);
      expect(find.text('2 jam'), findsOneWidget);
      expect(find.text('Rp 15.000'), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify action buttons
      expect(find.text('Lihat Aktivitas'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
    });

    testWidgets('calls onViewActivity callback when button is tapped',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
            onViewActivity: () {
              callbackCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to make button visible
      await tester.dragUntilVisible(
        find.text('Lihat Aktivitas'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Tap "Lihat Aktivitas" button
      await tester.tap(find.text('Lihat Aktivitas'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(callbackCalled, true);
    });

    testWidgets('calls onBackToHome callback when button is tapped',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
            onBackToHome: () {
              callbackCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to make button visible
      await tester.dragUntilVisible(
        find.text('Kembali ke Beranda'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Tap "Kembali ke Beranda" button
      await tester.tap(find.text('Kembali ke Beranda'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(callbackCalled, true);
    });

    testWidgets('close button calls onBackToHome callback',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
            onBackToHome: () {
              callbackCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(callbackCalled, true);
    });

    testWidgets('displays success animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      // Verify checkmark icon exists
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Pump frames to see animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));

      // Animation should complete
      await tester.pumpAndSettle();

      // Checkmark should still be visible
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('handles booking without optional fields',
        (WidgetTester tester) async {
      final minimalBooking = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        // No optional fields
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: minimalBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still display without errors
      expect(find.text('Booking Berhasil!'), findsOneWidget);
      expect(find.text('QR Code Masuk'), findsOneWidget);
    });

    testWidgets('formats date and time correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify formatted date/time is displayed
      expect(find.textContaining('15 Jan 2024'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
    });

    testWidgets('displays all booking summary sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all summary sections
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Kendaraan'), findsOneWidget);
      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('Estimasi Biaya'), findsOneWidget);
    });

    testWidgets('displays reserved slot information when available',
        (WidgetTester tester) async {
      final bookingWithReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        platNomor: 'B 1234 XYZ',
        kodeSlot: 'A15',
        idSlot: 's15',
        reservationId: 'r123',
        floorName: 'Lantai 1',
        floorNumber: '1',
        slotType: 'regular',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify reserved slot card is displayed
      expect(find.text('Slot Parkir Terkunci'), findsOneWidget);
      expect(find.text('Slot telah direservasi untuk Anda'), findsOneWidget);
      expect(find.text('Lantai 1 - Slot A15'), findsAtLeastNWidgets(1));
      expect(find.text('Regular Parking'), findsOneWidget);
      expect(
        find.text('Slot ini telah dikunci khusus untuk booking Anda'),
        findsOneWidget,
      );
    });

    testWidgets('displays disable-friendly slot type correctly',
        (WidgetTester tester) async {
      final bookingWithDisableFriendly = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        kodeSlot: 'D01',
        idSlot: 's01',
        reservationId: 'r456',
        floorName: 'Lantai 2',
        floorNumber: '2',
        slotType: 'disable_friendly',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithDisableFriendly,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify disable-friendly slot type
      expect(find.text('Disable-Friendly'), findsOneWidget);
      expect(find.byIcon(Icons.accessible), findsOneWidget);
    });

    testWidgets('does not display reserved slot card when not available',
        (WidgetTester tester) async {
      final bookingWithoutReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        kodeSlot: 'A01',
        // No idSlot or reservation fields
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithoutReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify reserved slot card is NOT displayed
      expect(find.text('Slot Parkir Terkunci'), findsNothing);
      expect(find.text('Slot telah direservasi untuk Anda'), findsNothing);
    });

    testWidgets('displays slot location in booking summary',
        (WidgetTester tester) async {
      final bookingWithReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        kodeSlot: 'A15',
        idSlot: 's15',
        floorName: 'Lantai 1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify slot location is displayed in summary
      expect(find.text('Lokasi Parkir'), findsOneWidget);
      expect(find.text('Lantai 1 - Slot A15'), findsAtLeastNWidgets(1));
    });

    testWidgets('reserved slot card has proper styling',
        (WidgetTester tester) async {
      final bookingWithReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'QR123456789',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        kodeSlot: 'A15',
        idSlot: 's15',
        floorName: 'Lantai 1',
        slotType: 'regular',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card exists
      final cardFinder = find.ancestor(
        of: find.text('Slot Parkir Terkunci'),
        matching: find.byType(Card),
      );
      expect(cardFinder, findsOneWidget);

      // Verify success icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Verify parking icon
      expect(find.byIcon(Icons.local_parking), findsAtLeastNWidgets(1));
    });

    testWidgets('QR code widget is rendered with booking data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: testBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find QR code widget
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Verify QR code section is displayed with proper labels
      expect(find.text('QR Code Masuk'), findsOneWidget);
      expect(find.text('Tunjukkan di gerbang masuk'), findsOneWidget);

      // Verify QR code is within proper container
      final containerFinder = find.ancestor(
        of: qrFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);
    });

    testWidgets('QR code section displays with slot reservation data',
        (WidgetTester tester) async {
      // Create booking with slot reservation
      final bookingWithSlotQR = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'BKG001|MALL001|s15|A15|L1|r123',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        kodeSlot: 'A15',
        idSlot: 's15',
        reservationId: 'r123',
        floorName: 'Lantai 1',
        floorNumber: '1',
        slotType: 'regular',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithSlotQR,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify QR code widget is rendered
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Verify reserved slot information is displayed alongside QR code
      expect(find.text('Slot Parkir Terkunci'), findsOneWidget);
      expect(find.text('Lantai 1 - Slot A15'), findsAtLeastNWidgets(1));
      expect(find.text('Regular Parking'), findsOneWidget);

      // Verify QR code section header
      expect(find.text('QR Code Masuk'), findsOneWidget);
      expect(find.text('Tunjukkan di gerbang masuk'), findsOneWidget);
    });

    testWidgets('QR code renders with proper styling for slot bookings',
        (WidgetTester tester) async {
      final bookingWithReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'BKG001|MALL001|s15|A15|Lantai 1',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        kodeSlot: 'A15',
        idSlot: 's15',
        floorName: 'Lantai 1',
        slotType: 'regular',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify QR code section is displayed
      expect(find.text('QR Code Masuk'), findsOneWidget);
      expect(find.text('Tunjukkan di gerbang masuk'), findsOneWidget);

      // Verify QR code widget exists and is visible
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Verify QR code is within a Card widget
      final cardFinder = find.ancestor(
        of: find.text('QR Code Masuk'),
        matching: find.byType(Card),
      );
      expect(cardFinder, findsOneWidget);

      // Verify slot information is also displayed
      expect(find.text('Lantai 1 - Slot A15'), findsAtLeastNWidgets(1));
    });

    testWidgets('QR code displays for bookings without slot reservation',
        (WidgetTester tester) async {
      final bookingWithoutReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'BKG001|MALL001',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        namaMall: 'Mall Test',
        kodeSlot: 'A01',
        // No idSlot or reservation fields
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithoutReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify QR code is still displayed
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Verify QR code section labels
      expect(find.text('QR Code Masuk'), findsOneWidget);
      expect(find.text('Tunjukkan di gerbang masuk'), findsOneWidget);

      // Verify reserved slot card is NOT displayed
      expect(find.text('Slot Parkir Terkunci'), findsNothing);
      expect(find.text('Slot telah direservasi untuk Anda'), findsNothing);
    });

    testWidgets('QR code configuration is optimal for scanning',
        (WidgetTester tester) async {
      final bookingWithReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'BKG001|MALL001|s15|A15|L1|r123|regular',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        kodeSlot: 'A15',
        idSlot: 's15',
        reservationId: 'r123',
        floorName: 'Lantai 1',
        slotType: 'regular',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find QR code widget
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Get QR code widget
      final qrWidget = tester.widget<QrImageView>(qrFinder);

      // Verify high error correction level for reliability
      expect(qrWidget.errorCorrectionLevel, equals(QrErrorCorrectLevel.H));

      // Verify QR code configuration is optimal for scanning
      expect(qrWidget.version, equals(QrVersions.auto));
      expect(qrWidget.size, equals(200));
      expect(qrWidget.backgroundColor, equals(Colors.white));
    });

    testWidgets('reserved slot info and QR code are both visible together',
        (WidgetTester tester) async {
      final bookingWithReservation = BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: 'MALL001',
        idParkiran: 'PARK001',
        idKendaraan: 'VEH001',
        qrCode: 'BKG001|s15|A15|r123',
        waktuMulai: DateTime(2024, 1, 15, 10, 0),
        waktuSelesai: DateTime(2024, 1, 15, 12, 0),
        durasiBooking: 2,
        status: 'aktif',
        biayaEstimasi: 15000.0,
        dibookingPada: DateTime(2024, 1, 15, 9, 0),
        kodeSlot: 'A15',
        idSlot: 's15',
        reservationId: 'r123',
        floorName: 'Lantai 1',
        slotType: 'regular',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationDialog(
            booking: bookingWithReservation,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify reserved slot card is displayed
      expect(find.text('Slot Parkir Terkunci'), findsOneWidget);
      expect(find.text('Lantai 1 - Slot A15'), findsAtLeastNWidgets(1));
      expect(find.text('Regular Parking'), findsOneWidget);

      // Verify QR code section is displayed
      expect(find.text('QR Code Masuk'), findsOneWidget);
      expect(find.text('Tunjukkan di gerbang masuk'), findsOneWidget);

      // Verify both QR code and slot info are visible
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      final slotCardFinder = find.ancestor(
        of: find.text('Slot Parkir Terkunci'),
        matching: find.byType(Card),
      );
      expect(slotCardFinder, findsOneWidget);

      // Verify slot information appears in booking summary as well
      expect(find.text('Lokasi Parkir'), findsOneWidget);
    });
  });
}
