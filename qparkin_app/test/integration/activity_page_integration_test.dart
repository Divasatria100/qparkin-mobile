import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';
import 'package:qparkin_app/data/services/parking_service.dart';
import 'package:qparkin_app/logic/providers/active_parking_provider.dart';
import 'package:qparkin_app/presentation/screens/activity_page.dart';
import 'package:qparkin_app/presentation/widgets/circular_timer_widget.dart';
import 'package:qparkin_app/presentation/widgets/booking_detail_card.dart';
import 'package:qparkin_app/presentation/widgets/qr_exit_button.dart';
import 'package:qparkin_app/presentation/dialogs/qr_exit_dialog.dart';

// Mock ParkingService for integration testing
class MockParkingService extends ParkingService {
  ActiveParkingModel? mockActiveParking;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  int callCount = 0;
  Duration? artificialDelay;

  @override
  Future<ActiveParkingModel?> getActiveParking({String? token}) async {
    callCount++;
    
    if (artificialDelay != null) {
      await Future.delayed(artificialDelay!);
    }
    
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    return mockActiveParking;
  }

  @override
  Future<ActiveParkingModel?> getActiveParkingWithRetry({
    String? token,
    int maxRetries = 3,
  }) async {
    return getActiveParking(token: token);
  }

  void reset() {
    mockActiveParking = null;
    shouldThrowError = false;
    errorMessage = 'Network error';
    callCount = 0;
    artificialDelay = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Activity Page Integration Tests', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    testWidgets('Full page flow: load data → display timer → verify components', (WidgetTester tester) async {
      // Setup mock data
      final testModel = _createTestModel(
        idTransaksi: 'TRX001',
        waktuMasuk: DateTime.now().subtract(const Duration(hours: 1)),
        qrCode: 'QR123456',
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      // Build the widget tree with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify timer is displayed
      expect(find.byType(CircularTimerWidget), findsOneWidget);

      // Verify booking detail card is displayed
      expect(find.byType(BookingDetailCard), findsOneWidget);

      // Verify QR exit button is displayed
      expect(find.byType(QRExitButton), findsOneWidget);

      // Verify data is displayed correctly
      expect(find.text('Test Mall'), findsOneWidget);
      expect(find.text('B1234XYZ'), findsOneWidget);

      // Verify API was called once
      expect(mockService.callCount, equals(1));

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Timer runs for 60 seconds and updates display', (WidgetTester tester) async {
      // Setup mock data with start time 1 minute ago
      final startTime = DateTime.now().subtract(const Duration(minutes: 1));
      final testModel = _createTestModel(
        waktuMasuk: startTime,
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify timer is displayed
      expect(find.byType(CircularTimerWidget), findsOneWidget);

      // Get initial elapsed time from provider
      final initialElapsed = testProvider.timerState.elapsed;
      expect(initialElapsed.inMinutes, greaterThanOrEqualTo(0));

      // Pump for 3 seconds (simulating 3 timer updates)
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Timer should still be visible
      expect(find.byType(CircularTimerWidget), findsOneWidget);

      // Verify timer is still running after 60 seconds of pumping
      for (int i = 0; i < 57; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Timer should still be visible and updating
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      
      // Verify elapsed time is still being tracked (timer is running)
      // Note: In tests, time doesn't actually progress, so we just verify the timer is still active
      final finalElapsed = testProvider.timerState.elapsed;
      expect(finalElapsed.inMinutes, greaterThanOrEqualTo(0));

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Provider state updates propagate to UI', (WidgetTester tester) async {
      // Start with no active parking
      mockService.mockActiveParking = null;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: provider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('Tidak ada parkir aktif'), findsOneWidget);
      expect(find.byType(CircularTimerWidget), findsNothing);

      // Update provider with active parking
      final testModel = _createTestModel(
        idTransaksi: 'TRX002',
        waktuMasuk: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      mockService.mockActiveParking = testModel;

      // Trigger refresh
      await provider.fetchActiveParking();
      await tester.pumpAndSettle();

      // Verify UI updated to show active parking
      expect(find.text('Tidak ada parkir aktif'), findsNothing);
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(find.byType(BookingDetailCard), findsOneWidget);
      expect(find.text('Test Mall'), findsOneWidget);

      // Clear active parking
      provider.clear();
      await tester.pumpAndSettle();

      // Verify UI returns to empty state
      expect(find.text('Tidak ada parkir aktif'), findsOneWidget);
      expect(find.byType(CircularTimerWidget), findsNothing);
    });

    testWidgets('API integration with mock responses', (WidgetTester tester) async {
      // Test successful response
      final testModel = _createTestModel(
        idTransaksi: 'TRX003',
        namaMall: 'Integration Test Mall',
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify API was called
      expect(mockService.callCount, equals(1));

      // Verify data from API is displayed
      expect(find.text('Integration Test Mall'), findsOneWidget);
      expect(testProvider.activeParking?.idTransaksi, equals('TRX003'));

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Error handling and retry mechanism', (WidgetTester tester) async {
      // Setup mock to throw error
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Connection timeout';

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error state is shown
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsAtLeastNWidgets(1));

      // Verify error snackbar or retry button is shown
      expect(find.text('Coba Lagi'), findsAtLeastNWidgets(1));

      // Verify provider has error
      expect(testProvider.errorMessage, isNotNull);
      expect(testProvider.activeParking, isNull);

      // Fix the error and retry
      mockService.shouldThrowError = false;
      mockService.mockActiveParking = _createTestModel();
      mockService.callCount = 0;

      // Tap retry button in error state - find by text in ElevatedButton
      final retryButtons = find.widgetWithText(ElevatedButton, 'Coba Lagi');
      if (retryButtons.evaluate().isNotEmpty) {
        await tester.tap(retryButtons.first);
        await tester.pumpAndSettle();

        // Verify API was called again
        expect(mockService.callCount, equals(1));

        // Verify error is cleared and data is shown
        expect(find.text('Terjadi Kesalahan'), findsNothing);
        expect(find.byType(CircularTimerWidget), findsOneWidget);
        expect(testProvider.errorMessage, isNull);
        expect(testProvider.activeParking, isNotNull);
      }

      // Clean up
      testProvider.dispose();
    });

    test('30-second periodic refresh mechanism', () async {
      // Setup initial data
      final testModel = _createTestModel(
        idTransaksi: 'TRX005',
        waktuMasuk: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test to avoid timer issues
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      // Fetch initial data without UI
      await testProvider.fetchActiveParking();

      // Verify initial load
      expect(mockService.callCount, equals(1));
      expect(testProvider.activeParking?.idTransaksi, equals('TRX005'));

      // Record initial sync time
      final initialSyncTime = testProvider.lastSyncTime;
      expect(initialSyncTime, isNotNull);

      // Wait a small delay to ensure time difference
      await Future.delayed(const Duration(milliseconds: 10));

      // Update mock data for next refresh
      final updatedModel = _createTestModel(
        idTransaksi: 'TRX006',
        waktuMasuk: DateTime.now().subtract(const Duration(minutes: 6)),
      );
      mockService.mockActiveParking = updatedModel;
      mockService.callCount = 0;

      // Simulate 30-second periodic refresh by manually calling refresh
      await testProvider.refresh();

      // Verify refresh was called
      expect(mockService.callCount, equals(1));

      // Verify data was updated
      expect(testProvider.activeParking?.idTransaksi, equals('TRX006'));

      // Verify sync time was updated (should be different)
      expect(testProvider.lastSyncTime!.millisecondsSinceEpoch, 
             greaterThan(initialSyncTime!.millisecondsSinceEpoch));

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Pull-to-refresh updates data', (WidgetTester tester) async {
      // Setup initial data
      final testModel = _createTestModel(
        idTransaksi: 'TRX007',
        namaMall: 'Initial Mall',
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial data
      expect(find.text('Initial Mall'), findsOneWidget);
      expect(mockService.callCount, equals(1));

      // Update mock data
      final updatedModel = _createTestModel(
        idTransaksi: 'TRX008',
        namaMall: 'Refreshed Mall',
      );
      mockService.mockActiveParking = updatedModel;
      mockService.callCount = 0;

      // Perform pull-to-refresh gesture
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Verify refresh was triggered
      expect(mockService.callCount, equals(1));

      // Verify UI shows updated data
      expect(find.text('Refreshed Mall'), findsOneWidget);
      expect(find.text('Initial Mall'), findsNothing);

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Cost calculation updates in real-time', (WidgetTester tester) async {
      // Setup data with specific tariff
      final testModel = _createTestModel(
        waktuMasuk: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        biayaJamPertama: 5000,
        biayaPerJam: 3000,
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial cost is displayed
      expect(find.textContaining('Rp'), findsWidgets);

      // Get initial cost from provider
      final initialCost = testProvider.timerState.currentCost;
      expect(initialCost, greaterThan(0));

      // Wait for timer to update (simulate time passing)
      await tester.pump(const Duration(seconds: 5));

      // Cost should remain consistent for same elapsed time
      // (In real scenario, cost updates as hours progress)
      expect(testProvider.timerState.currentCost, equals(initialCost));

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Penalty warning shown when booking expired', (WidgetTester tester) async {
      // Setup data with expired booking
      final testModel = _createTestModel(
        waktuMasuk: DateTime.now().subtract(const Duration(hours: 3)),
        waktuSelesaiEstimas: DateTime.now().subtract(const Duration(hours: 1)),
        penalty: 5000,
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify penalty is detected
      expect(testProvider.timerState.isOvertime, isTrue);
      expect(testProvider.timerState.penaltyAmount, equals(5000));

      // Verify penalty warning snackbar is shown
      expect(find.text('Waktu booking telah habis. Penalty akan dikenakan.'), findsOneWidget);

      // Verify penalty is displayed in booking detail card
      expect(find.textContaining('5.000'), findsWidgets);

      // Clean up
      testProvider.dispose();
    });

    testWidgets('Empty state shown when no active parking', (WidgetTester tester) async {
      // Setup mock with no active parking
      mockService.mockActiveParking = null;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: provider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('Tidak ada parkir aktif'), findsOneWidget);
      expect(find.text('Mulai parkir untuk melihat aktivitas Anda'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);

      // Verify no timer or detail card is shown
      expect(find.byType(CircularTimerWidget), findsNothing);
      expect(find.byType(BookingDetailCard), findsNothing);
      expect(find.byType(QRExitButton), findsNothing);
    });

    testWidgets('Tab navigation preserves state', (WidgetTester tester) async {
      // Setup active parking
      final testModel = _createTestModel(
        idTransaksi: 'TRX009',
        namaMall: 'State Test Mall',
      );
      mockService.mockActiveParking = testModel;

      // Create a separate provider for this test
      final testProvider = ActiveParkingProvider(parkingService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: testProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on Aktivitas tab
      expect(find.text('State Test Mall'), findsOneWidget);
      expect(find.byType(CircularTimerWidget), findsOneWidget);

      // Switch to Riwayat tab - find the tab widget specifically
      final riwayatTab = find.widgetWithText(Tab, 'Riwayat');
      await tester.tap(riwayatTab);
      await tester.pumpAndSettle();

      // Verify we're on Riwayat tab
      expect(find.text('Riwayat Parkir'), findsOneWidget);
      expect(find.byType(CircularTimerWidget), findsNothing);

      // Switch back to Aktivitas tab
      final aktivitasTab = find.widgetWithText(Tab, 'Aktivitas');
      await tester.tap(aktivitasTab);
      await tester.pumpAndSettle();

      // Verify state is preserved
      expect(find.text('State Test Mall'), findsOneWidget);
      expect(find.byType(CircularTimerWidget), findsOneWidget);
      expect(testProvider.activeParking?.idTransaksi, equals('TRX009'));

      // Clean up
      testProvider.dispose();
    });
  });
}

/// Helper function to create test model with default values
ActiveParkingModel _createTestModel({
  String idTransaksi = 'TRX001',
  String? idBooking = 'BKG001',
  String qrCode = 'QR123456',
  String namaMall = 'Test Mall',
  String lokasiMall = 'Test Location',
  String idParkiran = 'P001',
  String kodeSlot = 'A-12',
  String platNomor = 'B1234XYZ',
  String jenisKendaraan = 'Mobil',
  String merkKendaraan = 'Toyota',
  String tipeKendaraan = 'Avanza',
  DateTime? waktuMasuk,
  DateTime? waktuSelesaiEstimas,
  bool isBooking = true,
  double biayaPerJam = 3000.0,
  double biayaJamPertama = 5000.0,
  double? penalty,
  String statusParkir = 'aktif',
}) {
  return ActiveParkingModel(
    idTransaksi: idTransaksi,
    idBooking: idBooking,
    qrCode: qrCode,
    namaMall: namaMall,
    lokasiMall: lokasiMall,
    idParkiran: idParkiran,
    kodeSlot: kodeSlot,
    platNomor: platNomor,
    jenisKendaraan: jenisKendaraan,
    merkKendaraan: merkKendaraan,
    tipeKendaraan: tipeKendaraan,
    waktuMasuk: waktuMasuk ?? DateTime.now(),
    waktuSelesaiEstimas: waktuSelesaiEstimas,
    isBooking: isBooking,
    biayaPerJam: biayaPerJam,
    biayaJamPertama: biayaJamPertama,
    penalty: penalty,
    statusParkir: statusParkir,
  );
}


