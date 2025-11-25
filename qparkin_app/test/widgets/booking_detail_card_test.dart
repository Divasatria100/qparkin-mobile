import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';
import 'package:qparkin_app/presentation/widgets/booking_detail_card.dart';

void main() {
  group('BookingDetailCard', () {
    late ActiveParkingModel mockParking;
    late ActiveParkingModel mockParkingWithPenalty;

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

      mockParkingWithPenalty = ActiveParkingModel(
        idTransaksi: 'TRX002',
        idBooking: 'BK002',
        qrCode: 'QR789012',
        namaMall: 'One Batam Mall',
        lokasiMall: 'Nagoya',
        idParkiran: 'P002',
        kodeSlot: 'B-05',
        platNomor: 'BP 5678 AB',
        jenisKendaraan: 'Motor',
        merkKendaraan: 'Honda',
        tipeKendaraan: 'Beat',
        waktuMasuk: DateTime.now().subtract(const Duration(hours: 3)),
        waktuSelesaiEstimas: DateTime.now().subtract(const Duration(hours: 1)),
        isBooking: true,
        biayaPerJam: 3000,
        biayaJamPertama: 3000,
        penalty: 10000,
        statusParkir: 'aktif',
      );
    });

    testWidgets('displays mall location correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      expect(find.text('Mega Mall Batam'), findsOneWidget);
      expect(find.text('Area: A-12'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays vehicle information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      expect(find.text('BP 1234 XY'), findsOneWidget);
      expect(find.text('Mobil - Toyota - Avanza'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('displays time information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      expect(find.text('Waktu Masuk'), findsOneWidget);
      expect(find.text('Estimasi Selesai'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('displays parking cost correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      expect(find.text('Biaya Berjalan'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      
      // Verify currency format (Rp)
      expect(find.textContaining('Rp'), findsWidgets);
    });

    testWidgets('displays penalty when applicable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParkingWithPenalty),
          ),
        ),
      );

      expect(find.text('Penalty'), findsOneWidget);
      expect(find.text('Rp 10.000'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('highlights penalty in warning color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParkingWithPenalty),
          ),
        ),
      );

      // Find the penalty text widget
      final penaltyTextFinder = find.text('Penalty');
      expect(penaltyTextFinder, findsOneWidget);

      // Verify warning color is applied
      final textWidget = tester.widget<Text>(penaltyTextFinder);
      expect(textWidget.style?.color, const Color(0xFFF44336));
    });

    testWidgets('does not display penalty when not applicable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      expect(find.text('Penalty'), findsNothing);
      expect(find.byIcon(Icons.warning), findsNothing);
    });

    testWidgets('handles empty vehicle information gracefully', (WidgetTester tester) async {
      final parkingWithEmptyVehicle = ActiveParkingModel(
        idTransaksi: 'TRX003',
        idBooking: 'BK003',
        qrCode: 'QR111',
        namaMall: 'Test Mall',
        lokasiMall: 'Test Location',
        idParkiran: 'P003',
        kodeSlot: 'C-01',
        platNomor: 'BP 9999 ZZ',
        jenisKendaraan: '',
        merkKendaraan: '',
        tipeKendaraan: '',
        waktuMasuk: DateTime.now(),
        waktuSelesaiEstimas: null,
        isBooking: false,
        biayaPerJam: 5000,
        biayaJamPertama: 5000,
        penalty: null,
        statusParkir: 'aktif',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: parkingWithEmptyVehicle),
          ),
        ),
      );

      // Should display plate number
      expect(find.text('BP 9999 ZZ'), findsOneWidget);
      
      // Should display fallback text for empty vehicle info
      expect(find.text('Kendaraan'), findsOneWidget);
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Mega Mall Batam'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('has proper semantic labels for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      // Verify main semantic label
      final semantics = tester.getSemantics(find.byType(BookingDetailCard));
      expect(semantics.label, contains('Detail parkir'));
    });

    testWidgets('displays all required icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      // Verify all icons are present
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('formats currency correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: mockParking),
          ),
        ),
      );

      // Verify Indonesian Rupiah format is displayed
      final currencyTexts = find.textContaining('Rp');
      expect(currencyTexts, findsWidgets);
      
      // Verify currency format uses Rp prefix
      bool foundRpFormat = false;
      for (final textFinder in currencyTexts.evaluate()) {
        final widget = textFinder.widget;
        if (widget is Text) {
          final text = widget.data ?? '';
          if (text.startsWith('Rp')) {
            foundRpFormat = true;
            break;
          }
        }
      }
      expect(foundRpFormat, true);
    });

    testWidgets('displays estimated end time only for bookings', (WidgetTester tester) async {
      final nonBookingParking = ActiveParkingModel(
        idTransaksi: 'TRX004',
        idBooking: '',
        qrCode: 'QR222',
        namaMall: 'Test Mall',
        lokasiMall: 'Test',
        idParkiran: 'P004',
        kodeSlot: 'D-01',
        platNomor: 'BP 1111 AA',
        jenisKendaraan: 'Mobil',
        merkKendaraan: 'Honda',
        tipeKendaraan: 'Civic',
        waktuMasuk: DateTime.now(),
        waktuSelesaiEstimas: null,
        isBooking: false,
        biayaPerJam: 5000,
        biayaJamPertama: 5000,
        penalty: null,
        statusParkir: 'aktif',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingDetailCard(activeParking: nonBookingParking),
          ),
        ),
      );

      // Should not display estimated end time for non-booking
      expect(find.text('Estimasi Selesai'), findsNothing);
      expect(find.byIcon(Icons.timer), findsNothing);
    });
  });
}
