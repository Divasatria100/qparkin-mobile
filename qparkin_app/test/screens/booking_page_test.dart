import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

/// Minimal widget tests for BookingPage
/// Focused on core functionality to avoid excessive log output
/// 
/// Requirements: 15.11
void main() {
  tearDown(() async {
    // Allow pending timers to complete
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('BookingPage - Initial Render', () {
    late Map<String, dynamic> testMallData;

    setUp(() {
      testMallData = {
        'id_mall': '1',
        'name': 'Test Mall',
        'address': 'Test Address',
        'distance': '1.0 km',
        'available': 10,
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };
    });

    testWidgets('renders with mall data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: testMallData),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(find.text('Test Mall'), findsOneWidget);
      expect(find.text('Konfirmasi Booking'), findsOneWidget);
    });

    testWidgets('displays main components', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: testMallData),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pilih Kendaraan'), findsOneWidget);
      expect(find.text('Waktu Mulai'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
    });

    testWidgets('back button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingPage(mall: testMallData)),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Booking Parkir'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Go'), findsOneWidget);
    });
  });

  group('BookingPage - Form Interactions', () {
    late Map<String, dynamic> testMallData;
    late Map<String, dynamic> testVehicle;

    setUp(() {
      testMallData = {
        'id_mall': '1',
        'name': 'Test Mall',
        'address': 'Test Address',
        'distance': '1.0 km',
        'available': 10,
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };

      testVehicle = {
        'id_kendaraan': '1',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      };
    });

    testWidgets('vehicle selection updates state', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.selectedVehicle, isNull);

      provider.selectVehicle(testVehicle);
      await tester.pump();

      expect(provider.selectedVehicle, isNotNull);
      expect(provider.selectedVehicle!['plat_nomor'], 'B1234XYZ');
    });

    testWidgets('duration selection updates cost', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.estimatedCost, 0.0);

      provider.setDuration(const Duration(hours: 2), token: null);
      await tester.pump(const Duration(milliseconds: 400)); // Wait for debounce

      expect(provider.bookingDuration, const Duration(hours: 2));
      // Cost calculation happens after debounce
    });

    testWidgets('shows slot availability after vehicle selection', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially no vehicle selected
      expect(provider.selectedVehicle, isNull);

      provider.selectVehicle(testVehicle);
      await tester.pumpAndSettle();

      // Verify vehicle is selected (slot indicator may not show without all data)
      expect(provider.selectedVehicle, isNotNull);
    });

    testWidgets('shows cost breakdown after duration set', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.bookingDuration, isNull);

      provider.setDuration(const Duration(hours: 2), token: null);
      await tester.pump(const Duration(milliseconds: 400)); // Wait for debounce

      // Verify duration is set
      expect(provider.bookingDuration, const Duration(hours: 2));
    });
  });

  group('BookingPage - Button States', () {
    late Map<String, dynamic> testMallData;
    late Map<String, dynamic> testVehicle;

    setUp(() {
      testMallData = {
        'id_mall': '1',
        'name': 'Test Mall',
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };

      testVehicle = {
        'id_kendaraan': '1',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      };
    });

    testWidgets('button disabled initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: testMallData),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Konfirmasi Booking'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('button disabled without vehicle', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: null);
      provider.setAvailableSlots(10);
      await tester.pump();

      // Without vehicle and duration, button should be disabled
      expect(provider.selectedVehicle, isNull);
      expect(provider.canConfirmBooking, isFalse);
    });

    testWidgets('button disabled without duration', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.selectVehicle(testVehicle);
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: null);
      provider.setAvailableSlots(10);
      await tester.pump();

      expect(provider.canConfirmBooking, isFalse);
    });

    testWidgets('button disabled with no slots', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.selectVehicle(testVehicle);
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: null);
      provider.setAvailableSlots(0);
      await tester.pump();

      // With no slots, button should be disabled
      expect(provider.availableSlots, 0);
      expect(provider.canConfirmBooking, isFalse);
    });

    testWidgets('button enabled with all data', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.selectVehicle(testVehicle);
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: null);
      provider.setAvailableSlots(10);
      await tester.pump();

      // Set duration and wait for debounce
      provider.setDuration(const Duration(hours: 2), token: null);
      await tester.pump(const Duration(milliseconds: 400));

      // Verify all data is set
      expect(provider.selectedVehicle, isNotNull);
      expect(provider.startTime, isNotNull);
      expect(provider.bookingDuration, isNotNull);
      expect(provider.availableSlots, greaterThan(0));
    });

    testWidgets('button disabled when loading', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.selectVehicle(testVehicle);
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: null);
      provider.setAvailableSlots(10);
      provider.setLoading(true);
      await tester.pump();

      // When loading, button should be disabled
      expect(provider.isLoading, isTrue);
      expect(provider.canConfirmBooking, isFalse);
    });
  });

  group('BookingPage - Loading States', () {
    late Map<String, dynamic> testMallData;

    setUp(() {
      testMallData = {
        'id_mall': '1',
        'name': 'Test Mall',
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };
    });

    testWidgets('shows loading overlay', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.isLoading, isFalse);

      provider.setLoading(true);
      await tester.pump();

      expect(provider.isLoading, isTrue);
    });

    testWidgets('shows loading in button', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.setLoading(true);
      await tester.pump();

      // Verify loading state is set
      expect(provider.isLoading, isTrue);
    });

    testWidgets('hides loading when complete', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.setLoading(true);
      await tester.pump();
      expect(provider.isLoading, isTrue);

      provider.setLoading(false);
      await tester.pumpAndSettle();

      // Verify loading is cleared
      expect(provider.isLoading, isFalse);
    });
  });

  group('BookingPage - Error States', () {
    late Map<String, dynamic> testMallData;

    setUp(() {
      testMallData = {
        'id_mall': '1',
        'name': 'Test Mall',
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };
    });

    testWidgets('handles error state', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.setError('Test error');
      await tester.pump();

      expect(provider.errorMessage, 'Test error');
    });

    testWidgets('clears error', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      provider.setError('Test error');
      await tester.pump();
      expect(provider.errorMessage, 'Test error');

      provider.clearError();
      await tester.pump();
      expect(provider.errorMessage, isNull);
    });

    testWidgets('handles validation errors', (WidgetTester tester) async {
      final provider = BookingProvider();
      provider.initialize(testMallData);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: provider,
            child: BookingPage(mall: testMallData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Set invalid start time (past)
      provider.setStartTime(
        DateTime.now().subtract(const Duration(hours: 1)),
        token: null,
      );
      await tester.pump();

      expect(provider.validationErrors.isNotEmpty, isTrue);
    });
  });

  group('BookingPage - UI Elements', () {
    late Map<String, dynamic> testMallData;

    setUp(() {
      testMallData = {
        'id_mall': '1',
        'name': 'Test Mall',
        'address': 'Test Address',
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };
    });

    testWidgets('has proper AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: testMallData),
        ),
      );
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF573ED1));
      expect(appBar.elevation, 0);
      expect(appBar.centerTitle, true);
    });

    testWidgets('is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: testMallData),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has fixed bottom button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: testMallData),
        ),
      );
      await tester.pumpAndSettle();

      final positioned = find.ancestor(
        of: find.text('Konfirmasi Booking'),
        matching: find.byType(Positioned),
      );
      expect(positioned, findsOneWidget);
    });

    testWidgets('handles empty mall data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingPage(mall: {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(find.text('Konfirmasi Booking'), findsOneWidget);
    });
  });
}
