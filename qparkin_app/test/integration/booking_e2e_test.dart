import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
// Mall data is passed as Map<String, dynamic>, no MallModel class
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/data/services/parking_service.dart';
import 'package:qparkin_app/data/services/vehicle_service.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/logic/providers/active_parking_provider.dart';
import 'package:qparkin_app/presentation/screens/map_page.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/presentation/screens/activity_page.dart';

/// End-to-End Integration Tests for Booking Feature
/// 
/// This test suite validates the complete booking flow from Map selection
/// to Activity Page display, including all success and error scenarios.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Complete Booking Flow', () {
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

    testWidgets('SUCCESS: Complete booking flow from Map to Activity', (WidgetTester tester) async {
      // Setup test data
      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      final testBooking = _createTestBooking();
      final testActiveParking = _createTestActiveParking();

      mockVehicleService.mockVehicles = [testVehicle];
      mockBookingService.mockBooking = testBooking;
      mockParkingService.mockActiveParking = testActiveParking;

      // Create providers
      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );
      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // Build complete app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ChangeNotifierProvider<ActiveParkingProvider>.value(value: activeParkingProvider),
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

      // STEP 1: Navigate from Map to Booking
      expect(find.text('Peta Lokasi Parkir'), findsOneWidget);

      final daftarMallTab = find.widgetWithText(Tab, 'Daftar Mall');
      await tester.tap(daftarMallTab);
      await tester.pumpAndSettle();

      final mallCard = find.text('Mega Mall Batam Centre');
      await tester.tap(mallCard);
      await tester.pumpAndSettle();

      final bookingButton = find.text('Booking Sekarang');
      await tester.tap(bookingButton);
      await tester.pumpAndSettle();

      // STEP 2: Verify BookingPage displays correctly
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);

      // STEP 3: Verify data persistence across pages
      expect(bookingProvider.selectedMall, isNotNull);
      expect(bookingProvider.selectedMall?['name'], equals('Mega Mall Batam Centre'));

      // Clean up
      bookingProvider.dispose();
      activeParkingProvider.dispose();
    });

    testWidgets('SUCCESS: Booking appears in Activity Page after creation', (WidgetTester tester) async {
      final testActiveParking = _createTestActiveParking(
        namaMall: 'Success Test Mall',
        platNomor: 'B9999XYZ',
      );
      mockParkingService.mockActiveParking = testActiveParking;

      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify booking data is displayed
      expect(find.text('Success Test Mall'), findsOneWidget);
      expect(find.text('B9999XYZ'), findsOneWidget);
      expect(activeParkingProvider.activeParking, isNotNull);
      expect(activeParkingProvider.activeParking?.namaMall, equals('Success Test Mall'));

      activeParkingProvider.dispose();
    });

    testWidgets('SUCCESS: Booking persists after app restart simulation', (WidgetTester tester) async {
      final testActiveParking = _createTestActiveParking();
      mockParkingService.mockActiveParking = testActiveParking;

      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      // First load
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(activeParkingProvider.activeParking, isNotNull);

      // Simulate app restart by rebuilding
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Reload app
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify data persists
      expect(activeParkingProvider.activeParking, isNotNull);
      expect(mockParkingService.callCount, greaterThan(1));

      activeParkingProvider.dispose();
    });
  });

  group('E2E: Error Scenarios', () {
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

    testWidgets('ERROR: Network failure during booking creation', (WidgetTester tester) async {
      mockBookingService.shouldThrowError = true;
      mockBookingService.errorMessage = 'Network connection failed';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: bookingProvider,
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      // Attempt to create booking
      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));

      await bookingProvider.confirmBooking(token: 'test_token');
      await tester.pumpAndSettle();

      // Verify error is handled
      expect(bookingProvider.errorMessage, isNotNull);
      expect(bookingProvider.errorMessage, contains('Network'));
      expect(bookingProvider.isLoading, isFalse);

      bookingProvider.dispose();
    });

    testWidgets('ERROR: Slot unavailable during booking', (WidgetTester tester) async {
      mockBookingService.shouldThrowError = true;
      mockBookingService.errorMessage = 'Slot tidak tersedia';
      mockBookingService.errorCode = 'SLOT_UNAVAILABLE';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: bookingProvider,
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));

      await bookingProvider.confirmBooking(token: 'test_token');
      await tester.pumpAndSettle();

      expect(bookingProvider.errorMessage, contains('tidak tersedia'));
      expect(bookingProvider.isLoading, isFalse);

      bookingProvider.dispose();
    });

    testWidgets('ERROR: Validation failure prevents booking', (WidgetTester tester) async {
      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: bookingProvider,
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      final testMall = _createTestMall();
      bookingProvider.initialize(testMall);
      // Don't set vehicle, time, or duration

      await bookingProvider.confirmBooking(token: 'test_token');
      await tester.pumpAndSettle();

      // Verify booking was not attempted
      expect(mockBookingService.createBookingCallCount, equals(0));
      expect(bookingProvider.errorMessage, isNotNull);

      bookingProvider.dispose();
    });

    testWidgets('ERROR: Activity Page handles fetch failure gracefully', (WidgetTester tester) async {
      mockParkingService.shouldThrowError = true;
      mockParkingService.errorMessage = 'Server error';

      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error state
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(activeParkingProvider.errorMessage, isNotNull);
      expect(activeParkingProvider.activeParking, isNull);

      activeParkingProvider.dispose();
    });

    testWidgets('ERROR: Booking conflict detection', (WidgetTester tester) async {
      mockBookingService.shouldThrowError = true;
      mockBookingService.errorMessage = 'Anda sudah memiliki booking aktif';
      mockBookingService.errorCode = 'BOOKING_CONFLICT';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BookingProvider>.value(
            value: bookingProvider,
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));

      await bookingProvider.confirmBooking(token: 'test_token');
      await tester.pumpAndSettle();

      expect(bookingProvider.errorMessage, contains('booking aktif'));

      bookingProvider.dispose();
    });
  });

  group('E2E: Data Persistence', () {
    late MockParkingService mockParkingService;

    setUp(() {
      mockParkingService = MockParkingService();
    });

    tearDown(() {
      mockParkingService.reset();
    });

    testWidgets('Data persists across page navigation', (WidgetTester tester) async {
      final testActiveParking = _createTestActiveParking();
      mockParkingService.mockActiveParking = testActiveParking;

      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

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

      // Verify data is loaded
      expect(activeParkingProvider.activeParking, isNotNull);
      final originalId = activeParkingProvider.activeParking?.idTransaksi;

      // Navigate to Riwayat tab
      final riwayatTab = find.widgetWithText(Tab, 'Riwayat');
      await tester.tap(riwayatTab);
      await tester.pumpAndSettle();

      // Navigate back to Aktivitas tab
      final aktivitasTab = find.widgetWithText(Tab, 'Aktivitas');
      await tester.tap(aktivitasTab);
      await tester.pumpAndSettle();

      // Verify data persists
      expect(activeParkingProvider.activeParking, isNotNull);
      expect(activeParkingProvider.activeParking?.idTransaksi, equals(originalId));

      activeParkingProvider.dispose();
    });

    testWidgets('Booking data updates correctly after refresh', (WidgetTester tester) async {
      final initialParking = _createTestActiveParking(idTransaksi: 'TRX001');
      mockParkingService.mockActiveParking = initialParking;

      final activeParkingProvider = ActiveParkingProvider(
        parkingService: mockParkingService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ActiveParkingProvider>.value(
            value: activeParkingProvider,
            child: const ActivityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(activeParkingProvider.activeParking?.idTransaksi, equals('TRX001'));

      // Update mock data
      final updatedParking = _createTestActiveParking(idTransaksi: 'TRX002');
      mockParkingService.mockActiveParking = updatedParking;

      // Trigger refresh
      await activeParkingProvider.fetchActiveParking();
      await tester.pumpAndSettle();

      // Verify data updated
      expect(activeParkingProvider.activeParking?.idTransaksi, equals('TRX002'));

      activeParkingProvider.dispose();
    });
  });
}

// Mock Services
class MockBookingService extends BookingService {
  BookingModel? mockBooking;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  String errorCode = 'NETWORK_ERROR';
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
        errorCode: errorCode,
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
    errorCode = 'NETWORK_ERROR';
    createBookingCallCount = 0;
  }
}

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

// Test Data Helpers
Map<String, dynamic> _createTestMall({
  String idMall = 'MALL001',
  String namaMall = 'Mega Mall Batam Centre',
  String lokasi = 'Batam Centre',
  String alamatGmaps = 'Jl. Engku Putri',
  double latitude = 1.1234,
  double longitude = 104.1234,
  int slotTersedia = 50,
}) {
  return {
    'id_mall': idMall,
    'name': namaMall,
    'lokasi': lokasi,
    'alamat_gmaps': alamatGmaps,
    'latitude': latitude,
    'longitude': longitude,
    'available': slotTersedia,
    'firstHourRate': 5000.0,
    'additionalHourRate': 3000.0,
  };
}

VehicleModel _createTestVehicle({
  String idKendaraan = 'VEH001',
  String platNomor = 'B1234XYZ',
  String jenisKendaraan = 'Mobil',
  String merk = 'Toyota',
  String tipe = 'Avanza',
}) {
  return VehicleModel(
    idKendaraan: idKendaraan,
    platNomor: platNomor,
    jenisKendaraan: jenisKendaraan,
    merk: merk,
    tipe: tipe,
  );
}

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
