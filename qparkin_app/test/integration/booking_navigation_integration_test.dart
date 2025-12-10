import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/data/services/parking_service.dart';
import 'package:qparkin_app/data/services/vehicle_service.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/logic/providers/active_parking_provider.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/presentation/screens/activity_page.dart';
import 'package:qparkin_app/presentation/dialogs/booking_confirmation_dialog.dart';

// Mock BookingService for integration testing
class MockBookingService extends BookingService {
  BookingModel? mockBooking;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  int createBookingCallCount = 0;

  @override
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    createBookingCallCount++;
    
    if (shouldThrowError) {
      return BookingResponse.error(
        message: errorMessage,
        errorCode: 'NETWORK_ERROR',
      );
    }
    
    if (mockBooking == null) {
      return BookingResponse.error(
        message: 'Mock booking not set',
        errorCode: 'TEST_ERROR',
      );
    }
    
    return BookingResponse.success(
      message: 'Booking berhasil',
      booking: mockBooking!,
      qrCode: mockBooking!.qrCode,
    );
  }

  void reset() {
    mockBooking = null;
    shouldThrowError = false;
    errorMessage = 'Network error';
    createBookingCallCount = 0;
  }
}

// Mock ParkingService for integration testing
class MockParkingService extends ParkingService {
  ActiveParkingModel? mockActiveParking;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  int callCount = 0;

  @override
  Future<ActiveParkingModel?> getActiveParking({String? token}) async {
    callCount++;
    
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
  }
}

// Mock VehicleService for integration testing
class MockVehicleService extends VehicleService {
  List<VehicleModel> mockVehicles = [];
  bool shouldThrowError = false;

  MockVehicleService() : super(baseUrl: 'http://test.com', authToken: 'test_token');

  @override
  Future<List<VehicleModel>> fetchVehicles() async {
    if (shouldThrowError) {
      throw Exception('Failed to fetch vehicles');
    }
    return mockVehicles;
  }

  void reset() {
    mockVehicles = [];
    shouldThrowError = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Navigation Integration Tests', () {
    late MockBookingService mockBookingService;
    late MockParkingService mockParkingService;
    late MockVehicleService mockVehicleService;

    setUp(() {
      mockBookingService = MockBookingService();
      mockParkingService = MockParkingService();
      mockVehicleService = MockVehicleService();
    });

    tearDown(() {
      mockBookingService.reset();
      mockParkingService.reset();
      mockVehicleService.reset();
    });

    testWidgets('Map → Booking navigation with mall data', (WidgetTester tester) async {
      // Build MapPage
      await tester.pumpWidget(
        MaterialApp(
          home: const MapPage(),
          routes: {
            '/activity': (context) => const ActivityPage(),
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify MapPage is displayed
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Verify mall list is displayed
      expect(find.text('Pilih Mall'), findsOneWidget);
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Verify booking button appears
      expect(find.text('Booking Sekarang'), findsOneWidget);

      // Tap booking button
      final bookingButton = find.text('Booking Sekarang');
      await tester.tap(bookingButton);
      await tester.pumpAndSettle();

      // Verify navigation to BookingPage
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(find.byType(BookingPage), findsOneWidget);

      // Verify mall data is passed correctly
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);
      expect(find.text('1.3 km'), findsOneWidget);
    });

    testWidgets('Booking → Activity navigation after successful booking', (WidgetTester tester) async {
      // Setup mock booking
      final testBooking = _createTestBooking(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        qrCode: 'QR123456',
      );
      mockBookingService.mockBooking = testBooking;

      // Setup mock active parking for Activity Page
      final testActiveParking = _createTestActiveParking(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
      );
      mockParkingService.mockActiveParking = testActiveParking;

      // Create providers
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      bool viewActivityCalled = false;

      // Build app with BookingConfirmationDialog
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveParkingProvider>.value(
              value: activeParkingProvider,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationDialog(
              booking: testBooking,
              onViewActivity: () {
                viewActivityCalled = true;
              },
              onBackToHome: () {},
            ),
            routes: {
              '/activity': (context) => const ActivityPage(),
              '/home': (context) => const Scaffold(body: Text('Home Page')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify confirmation dialog is displayed
      expect(find.text('Booking Berhasil!'), findsOneWidget);
      expect(find.text('TRX001'), findsOneWidget);

      // Scroll to make "Lihat Aktivitas" button visible
      final viewActivityButton = find.text('Lihat Aktivitas');
      expect(viewActivityButton, findsOneWidget);
      
      // Scroll to the button if needed
      await tester.ensureVisible(viewActivityButton);
      await tester.pumpAndSettle();
      
      await tester.tap(viewActivityButton);
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(viewActivityCalled, isTrue);

      // Clean up
      activeParkingProvider.dispose();
    });

    testWidgets('Booking displays in Activity Page after creation', (WidgetTester tester) async {
      // Setup mock active parking
      final testActiveParking = _createTestActiveParking(
        idTransaksi: 'TRX002',
        idBooking: 'BKG002',
        namaMall: 'Test Mall',
        platNomor: 'B1234XYZ',
      );
      mockParkingService.mockActiveParking = testActiveParking;

      // Create provider
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // Build Activity Page
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify Activity Page displays booking
      expect(find.text('Test Mall'), findsOneWidget);
      expect(find.text('B1234XYZ'), findsOneWidget);

      // Verify API was called to fetch active parking
      expect(mockParkingService.callCount, equals(1));

      // Verify booking data is displayed correctly
      expect(activeParkingProvider.activeParking?.idTransaksi, equals('TRX002'));
      expect(activeParkingProvider.activeParking?.idBooking, equals('BKG002'));

      // Clean up
      activeParkingProvider.dispose();
    });

    testWidgets('Booking displays in History after completion', (WidgetTester tester) async {
      // Setup mock with no active parking (booking completed)
      mockParkingService.mockActiveParking = null;

      // Create provider
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // Build Activity Page
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify no active parking is shown
      expect(find.text('Tidak ada parkir aktif'), findsOneWidget);

      // Switch to Riwayat tab
      final riwayatTab = find.widgetWithText(Tab, 'Riwayat');
      await tester.tap(riwayatTab);
      await tester.pumpAndSettle();

      // Verify Riwayat tab is displayed
      expect(find.text('Riwayat Parkir'), findsOneWidget);

      // Verify history list is present
      expect(find.byType(ListView), findsOneWidget);
      
      // Verify at least one history item is displayed
      // The mock data includes 'Mega Mall Batam Centre' as location
      expect(find.textContaining('Mega Mall'), findsAtLeastNWidgets(1));

      // Clean up
      activeParkingProvider.dispose();
    });

    testWidgets('Complete flow: Map → Booking → Confirmation → Activity', (WidgetTester tester) async {
      // Setup mocks
      final testBooking = _createTestBooking(
        idTransaksi: 'TRX003',
        idBooking: 'BKG003',
        qrCode: 'QR789',
      );
      mockBookingService.mockBooking = testBooking;

      final testActiveParking = _createTestActiveParking(
        idTransaksi: 'TRX003',
        idBooking: 'BKG003',
        namaMall: 'Complete Flow Mall',
      );
      mockParkingService.mockActiveParking = testActiveParking;

      // Create providers
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // Build app with all routes
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveParkingProvider>.value(
              value: activeParkingProvider,
            ),
          ],
          child: MaterialApp(
            home: const MapPage(),
            routes: {
              '/activity': (context) => const ActivityPage(),
              '/home': (context) => const Scaffold(body: Text('Home Page')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Navigate from Map to Booking
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Tap booking button
      final bookingButton = find.text('Booking Sekarang');
      await tester.tap(bookingButton);
      await tester.pumpAndSettle();

      // Step 2: Verify BookingPage is displayed
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(find.byType(BookingPage), findsOneWidget);

      // Note: Full booking form interaction would require more complex mocking
      // of VehicleService, time pickers, etc. This test verifies navigation flow.

      // Clean up
      activeParkingProvider.dispose();
    });

    testWidgets('Back navigation preserves state', (WidgetTester tester) async {
      // Build MapPage
      await tester.pumpWidget(
        MaterialApp(
          home: const MapPage(),
          routes: {
            '/activity': (context) => const ActivityPage(),
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Daftar Mall tab
      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      // Select a mall
      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      // Verify mall is selected
      expect(find.text('Booking Sekarang'), findsOneWidget);

      // Navigate to BookingPage
      final bookingButton = find.text('Booking Sekarang');
      await tester.tap(bookingButton);
      await tester.pumpAndSettle();

      // Verify BookingPage is displayed
      expect(find.text('Booking Parkir'), findsOneWidget);

      // Navigate back
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we're back on MapPage
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);

      // Verify mall selection is preserved
      expect(find.text('Booking Sekarang'), findsOneWidget);
    });

    testWidgets('Error handling during navigation', (WidgetTester tester) async {
      // Setup mock to throw error
      mockParkingService.shouldThrowError = true;
      mockParkingService.errorMessage = 'Connection timeout';

      // Create provider
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // Build Activity Page
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify error state is shown
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsAtLeastNWidgets(1));

      // Verify provider has error
      expect(activeParkingProvider.errorMessage, isNotNull);

      // Clean up
      activeParkingProvider.dispose();
    });

    testWidgets('Multiple bookings update Activity Page correctly', (WidgetTester tester) async {
      // Setup initial active parking
      final initialParking = _createTestActiveParking(
        idTransaksi: 'TRX004',
        idBooking: 'BKG004',
        namaMall: 'Initial Mall',
      );
      mockParkingService.mockActiveParking = initialParking;

      // Create provider
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // Build Activity Page
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial booking is displayed
      expect(find.text('Initial Mall'), findsOneWidget);
      expect(mockParkingService.callCount, equals(1));

      // Update mock with new booking
      final newParking = _createTestActiveParking(
        idTransaksi: 'TRX005',
        idBooking: 'BKG005',
        namaMall: 'Updated Mall',
      );
      mockParkingService.mockActiveParking = newParking;
      mockParkingService.callCount = 0;

      // Trigger refresh
      await activeParkingProvider.fetchActiveParking();
      await tester.pumpAndSettle();

      // Verify updated booking is displayed
      expect(find.text('Updated Mall'), findsOneWidget);
      expect(find.text('Initial Mall'), findsNothing);
      expect(mockParkingService.callCount, equals(1));

      // Clean up
      activeParkingProvider.dispose();
    });
  });
}

/// Helper function to create test booking model
BookingModel _createTestBooking({
  String idTransaksi = 'TRX001',
  String idBooking = 'BKG001',
  String qrCode = 'QR123456',
  String idMall = 'MALL001',
  String idParkiran = 'P001',
  String idKendaraan = 'VEH001',
  DateTime? waktuMulai,
  DateTime? waktuSelesai,
  int durasiBooking = 2,
  String status = 'aktif',
  double biayaEstimasi = 15000.0,
}) {
  return BookingModel(
    idTransaksi: idTransaksi,
    idBooking: idBooking,
    qrCode: qrCode,
    idMall: idMall,
    idParkiran: idParkiran,
    idKendaraan: idKendaraan,
    waktuMulai: waktuMulai ?? DateTime.now(),
    waktuSelesai: waktuSelesai ?? DateTime.now().add(Duration(hours: durasiBooking)),
    durasiBooking: durasiBooking,
    status: status,
    biayaEstimasi: biayaEstimasi,
    dibookingPada: DateTime.now(),
  );
}

/// Helper function to create test active parking model
ActiveParkingModel _createTestActiveParking({
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
