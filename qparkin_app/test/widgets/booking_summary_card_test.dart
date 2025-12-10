import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/booking_summary_card.dart';

void main() {
  group('BookingSummaryCard', () {
    late DateTime testStartTime;
    late DateTime testEndTime;
    late Duration testDuration;

    setUp(() {
      testStartTime = DateTime(2024, 1, 15, 10, 0);
      testDuration = const Duration(hours: 2, minutes: 30);
      testEndTime = testStartTime.add(testDuration);
    });

    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Ringkasan Booking'), findsOneWidget);
    });

    testWidgets('displays mall information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Mega Mall Batam'), findsOneWidget);
      expect(find.text('Jl. Engku Putri, Batam Centre'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays vehicle information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Kendaraan'), findsOneWidget);
      expect(find.text('BP 1234 XY'), findsOneWidget);
      expect(find.text('Roda Empat - Toyota Avanza'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('displays time information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('10:00, 15 Jan 2024'), findsOneWidget);
      expect(find.text('2 jam 30 menit'), findsOneWidget);
      expect(find.text('12:30, 15 Jan 2024'), findsOneWidget);
    });

    testWidgets('displays total cost', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Total Estimasi'), findsOneWidget);
      expect(find.text('Rp 15.000'), findsOneWidget);
      expect(find.byIcon(Icons.payments), findsOneWidget);
    });

    testWidgets('total cost has purple color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final costText = find.text('Rp 15.000');
      final textWidget = tester.widget<Text>(costText);
      
      expect(textWidget.style?.color, const Color(0xFF573ED1));
      expect(textWidget.style?.fontSize, 18);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('has purple border', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      
      expect(shape.side.color, const Color(0xFF573ED1));
      expect(shape.side.width, 2);
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4);
      expect(card.color, Colors.white);
      
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('displays dividers between sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(3));
    });

    testWidgets('displays all time icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.schedule), findsNWidgets(2)); // Section icon + time row icon
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);
    });

    testWidgets('formats duration with hours only', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: const Duration(hours: 3),
              endTime: testStartTime.add(const Duration(hours: 3)),
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('3 jam'), findsOneWidget);
    });

    testWidgets('formats duration with hours and minutes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: const Duration(hours: 1, minutes: 45),
              endTime: testStartTime.add(const Duration(hours: 1, minutes: 45)),
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('1 jam 45 menit'), findsOneWidget);
    });

    testWidgets('formats currency with thousand separators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 125000,
            ),
          ),
        ),
      );

      expect(find.text('Rp 125.000'), findsOneWidget);
    });

    testWidgets('handles large cost values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 1500000,
            ),
          ),
        ),
      );

      expect(find.text('Rp 1.500.000'), findsOneWidget);
    });

    testWidgets('all section icons have purple color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      final locationIcon = tester.widget<Icon>(find.byIcon(Icons.location_on));
      expect(locationIcon.color, const Color(0xFF573ED1));

      final carIcon = tester.widget<Icon>(find.byIcon(Icons.directions_car));
      expect(carIcon.color, const Color(0xFF573ED1));

      final paymentsIcon = tester.widget<Icon>(find.byIcon(Icons.payments));
      expect(paymentsIcon.color, const Color(0xFF573ED1));
    });

    testWidgets('displays formatted date and time correctly', (WidgetTester tester) async {
      final specificTime = DateTime(2024, 12, 25, 14, 30);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: specificTime,
              duration: const Duration(hours: 2),
              endTime: specificTime.add(const Duration(hours: 2)),
              totalCost: 15000,
            ),
          ),
        ),
      );

      expect(find.text('14:30, 25 Dec 2024'), findsOneWidget);
      expect(find.text('16:30, 25 Dec 2024'), findsOneWidget);
    });

    testWidgets('layout has proper organization', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingSummaryCard(
              mallName: 'Mega Mall Batam',
              mallAddress: 'Jl. Engku Putri, Batam Centre',
              vehiclePlat: 'BP 1234 XY',
              vehicleType: 'Roda Empat',
              vehicleBrand: 'Toyota Avanza',
              startTime: testStartTime,
              duration: testDuration,
              endTime: testEndTime,
              totalCost: 15000,
            ),
          ),
        ),
      );

      // Verify main column structure
      final column = find.byType(Column);
      expect(column, findsWidgets);
      
      // Verify all sections are present
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Kendaraan'), findsOneWidget);
      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('Total Estimasi'), findsOneWidget);
    });
  });
}
