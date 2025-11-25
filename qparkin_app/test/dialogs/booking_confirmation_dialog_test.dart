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
      expect(find.text('Slot'), findsOneWidget);
      expect(find.text('Kendaraan'), findsOneWidget);
      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('Estimasi Biaya'), findsOneWidget);
    });
  });
}
