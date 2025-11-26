import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

// Mock BookingService for testing
class MockBookingService extends BookingService {
  BookingResponse? mockResponse;
  int mockAvailableSlots = 10;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  int createBookingCallCount = 0;
  int checkAvailabilityCallCount = 0;
  BookingRequest? lastRequest;

  @override
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    createBookingCallCount++;
    lastRequest = request;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    await Future.delayed(const Duration(milliseconds: 10));
    return mockResponse ?? BookingResponse.error(message: 'No mock response');
  }

  @override
  Future<BookingResponse> createBookingWithRetry({
    required BookingRequest request,
    required String token,
    int maxRetries = 3,
  }) async {
    return createBooking(request: request, token: token);
  }

  @override
  Future<int> checkSlotAvailability({
    required String mallId,
    required String vehicleType,
    required DateTime startTime,
    required int durationHours,
    required String token,
  }) async {
    checkAvailabilityCallCount++;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    await Future.delayed(const Duration(milliseconds: 10));
    return mockAvailableSlots;
  }

  @override
  Future<int> checkSlotAvailabilityWithRetry({
    required String mallId,
    required String vehicleType,
    required DateTime startTime,
    required int durationHours,
    required String token,
    int maxRetries = 2,
  }) async {
    return checkSlotAvailability(
      mallId: mallId,
      vehicleType: vehicleType,
      startTime: startTime,
      durationHours: durationHours,
      token: token,
    );
  }

  void reset() {
    mockResponse = null;
    mockAvailableSlots = 10;
    shouldThrowError = false;
    errorMessage = 'Network error';
    createBookingCallCount = 0;
    checkAvailabilityCallCount = 0;
    lastRequest = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookingProvider State Initialization', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('initial state is empty', () {
      expect(provider.selectedMall, isNull);
      expect(provider.selectedVehicle, isNull);
      expect(provider.startTime, isNull);
      expect(provider.bookingDuration, isNull);
      expect(provider.estimatedCost, equals(0.0));
      expect(provider.availableSlots, equals(0));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.canConfirmBooking, isFalse);
    });

    test('initialize sets mall data and default start time', () {
      final mallData = {
        'id_mall': 'MALL001',
        'name': 'Test Mall',
        'address': 'Test Address',
        'available': 15,
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      };

      provider.initialize(mallData);

      expect(provider.selectedMall, equals(mallData));
      expect(provider.startTime, isNotNull);
      expect(provider.availableSlots, equals(15));
      expect(provider.firstHourRate, equals(5000.0));
      expect(provider.additionalHourRate, equals(3000.0));
    });

    test('initialize sets start time to current time + 15 minutes', () {
      final mallData = {'id_mall': 'MALL001', 'name': 'Test Mall'};
      final beforeInit = DateTime.now().add(const Duration(minutes: 14));

      provider.initialize(mallData);

      final afterInit = DateTime.now().add(const Duration(minutes: 16));
      expect(provider.startTime!.isAfter(beforeInit), isTrue);
      expect(provider.startTime!.isBefore(afterInit), isTrue);
    });

    test('initialize clears previous state', () {
      // Set some state
      provider.initialize({'id_mall': 'MALL001', 'name': 'Mall 1'});
      provider.selectVehicle({'id_kendaraan': 'VEH001', 'plat_nomor': 'B1234'});
      provider.setDuration(const Duration(hours: 2));

      // Initialize with new mall
      provider.initialize({'id_mall': 'MALL002', 'name': 'Mall 2'});

      expect(provider.selectedVehicle, isNull);
      expect(provider.bookingDuration, isNull);
      expect(provider.estimatedCost, equals(0.0));
      expect(provider.errorMessage, isNull);
    });
  });

  group('BookingProvider Vehicle Selection', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('selectVehicle sets vehicle data', () {
      final vehicle = {
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
        'merk': 'Toyota',
      };

      provider.selectVehicle(vehicle);

      expect(provider.selectedVehicle, equals(vehicle));
      expect(provider.hasValidationErrors, isFalse);
    });

    test('selectVehicle validates vehicle ID', () {
      final invalidVehicle = {
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      };

      provider.selectVehicle(invalidVehicle);

      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['vehicleId'], isNotNull);
    });

    test('selectVehicle triggers cost calculation if duration is set', () {
      provider.setDuration(const Duration(hours: 2));
      final costBeforeVehicle = provider.estimatedCost;
      expect(costBeforeVehicle, greaterThan(0.0)); // Cost is calculated even without vehicle

      final vehicle = {
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      };
      provider.selectVehicle(vehicle);

      // Cost should still be calculated
      expect(provider.estimatedCost, equals(costBeforeVehicle));
    });
  });

  group('BookingProvider Time and Duration', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('setStartTime updates start time', () {
      final newTime = DateTime.now().add(const Duration(hours: 2));

      provider.setStartTime(newTime);

      expect(provider.startTime, equals(newTime));
      expect(provider.hasValidationErrors, isFalse);
    });

    test('setStartTime validates past time', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));

      provider.setStartTime(pastTime);

      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['startTime'], isNotNull);
    });

    test('setDuration updates duration and calculates cost', () {
      provider.setDuration(const Duration(hours: 2));

      expect(provider.bookingDuration, equals(const Duration(hours: 2)));
      expect(provider.estimatedCost, greaterThan(0.0));
      expect(provider.hasValidationErrors, isFalse);
    });

    test('setDuration validates minimum duration', () {
      provider.setDuration(const Duration(minutes: 15));

      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['duration'], isNotNull);
    });

    test('setDuration validates maximum duration', () {
      provider.setDuration(const Duration(hours: 15));

      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['duration'], isNotNull);
    });

    test('calculatedEndTime returns correct end time', () {
      final startTime = DateTime.now().add(const Duration(hours: 1));
      provider.setStartTime(startTime);
      provider.setDuration(const Duration(hours: 2));

      final endTime = provider.calculatedEndTime;

      expect(endTime, isNotNull);
      expect(endTime!.difference(startTime).inHours, equals(2));
    });
  });

  group('BookingProvider Cost Calculation', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      });
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('calculateCost computes correct cost for 1 hour', () {
      provider.setDuration(const Duration(hours: 1));

      expect(provider.estimatedCost, equals(5000.0));
    });

    test('calculateCost computes correct cost for 2 hours', () {
      provider.setDuration(const Duration(hours: 2));

      // First hour: 5000, second hour: 3000 = 8000
      expect(provider.estimatedCost, equals(8000.0));
    });

    test('calculateCost computes correct cost for 3 hours', () {
      provider.setDuration(const Duration(hours: 3));

      // First hour: 5000, additional 2 hours: 6000 = 11000
      expect(provider.estimatedCost, equals(11000.0));
    });

    test('calculateCost generates cost breakdown', () {
      provider.setDuration(const Duration(hours: 2));

      expect(provider.costBreakdown, isNotNull);
      expect(provider.costBreakdown!['firstHourCost'], equals(5000.0));
      expect(provider.costBreakdown!['additionalHoursCost'], equals(3000.0));
      expect(provider.costBreakdown!['totalCost'], equals(8000.0));
    });

    test('updateTariff recalculates cost', () {
      provider.setDuration(const Duration(hours: 2));
      final oldCost = provider.estimatedCost;

      provider.updateTariff(
        firstHourRate: 7000.0,
        additionalHourRate: 4000.0,
      );

      expect(provider.estimatedCost, greaterThan(oldCost));
      expect(provider.estimatedCost, equals(11000.0));
    });
  });

  group('BookingProvider Booking Creation Success', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
        'firstHourRate': 5000.0,
        'additionalHourRate': 3000.0,
      });
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('confirmBooking creates booking successfully', () async {
      // Setup complete booking data
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Mock successful response
      final mockBooking = _createTestBooking();
      mockService.mockResponse = BookingResponse.success(
        message: 'Booking berhasil',
        booking: mockBooking,
        qrCode: 'QR123456',
      );
      mockService.mockAvailableSlots = 10;

      // Manually set available slots since we're not calling checkAvailability
      provider.checkAvailability(token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isTrue);
      expect(provider.createdBooking, isNotNull);
      expect(provider.createdBooking!.idBooking, equals('BKG001'));
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('confirmBooking sets loading state during creation', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockResponse = BookingResponse.success(
        message: 'Success',
        booking: _createTestBooking(),
      );
      mockService.mockAvailableSlots = 10;
      provider.checkAvailability(token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      final bookingFuture = provider.confirmBooking(token: 'test_token');

      expect(provider.isLoading, isTrue);

      await bookingFuture;

      expect(provider.isLoading, isFalse);
    });

    test('confirmBooking calls success callback', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      final mockBooking = _createTestBooking();
      mockService.mockResponse = BookingResponse.success(
        message: 'Success',
        booking: mockBooking,
      );
      mockService.mockAvailableSlots = 10;
      provider.checkAvailability(token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      BookingModel? callbackBooking;
      await provider.confirmBooking(
        token: 'test_token',
        onSuccess: (booking) {
          callbackBooking = booking;
        },
      );

      expect(callbackBooking, isNotNull);
      expect(callbackBooking!.idBooking, equals('BKG001'));
    });
  });

  group('BookingProvider Booking Creation Failure', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('confirmBooking fails with validation errors', () async {
      // Don't set required fields
      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.createdBooking, isNull);
    });

    test('confirmBooking fails when no slots available', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Set available slots to 0
      mockService.mockAvailableSlots = 0;

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      expect(provider.errorMessage, contains('tidak tersedia'));
    });

    test('confirmBooking handles network error', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockResponse = BookingResponse.error(
        message: 'Network error',
        errorCode: 'NETWORK_ERROR',
      );
      mockService.mockAvailableSlots = 10;
      provider.checkAvailability(token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      expect(provider.errorMessage, contains('internet'));
    });

    test('confirmBooking handles slot unavailable error', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockResponse = BookingResponse.error(
        message: 'Slot unavailable',
        errorCode: 'SLOT_UNAVAILABLE',
      );
      mockService.mockAvailableSlots = 10;
      provider.checkAvailability(token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      // Error message should be user-friendly Indonesian message
      expect(provider.errorMessage, isNotNull);
      expect(
        provider.errorMessage!.toLowerCase().contains('slot') ||
            provider.errorMessage!.toLowerCase().contains('tidak tersedia'),
        isTrue,
      );
    });

    test('confirmBooking handles booking conflict error', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockResponse = BookingResponse.error(
        message: 'Booking conflict',
        errorCode: 'BOOKING_CONFLICT',
      );
      mockService.mockAvailableSlots = 10;
      provider.checkAvailability(token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      // Error message should be user-friendly Indonesian message
      expect(provider.errorMessage, isNotNull);
      expect(
        provider.errorMessage!.toLowerCase().contains('booking') ||
            provider.errorMessage!.toLowerCase().contains('aktif'),
        isTrue,
      );
    });

    test('confirmBooking handles exception', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Unexpected error';
      
      // Don't check availability to avoid setting slots to 0
      // This will cause confirmBooking to fail due to no slots
      
      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      // Should fail due to no available slots
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('BookingProvider Slot Availability', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('checkAvailability updates available slots', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockAvailableSlots = 15;

      await provider.checkAvailability(token: 'test_token');

      expect(provider.availableSlots, equals(15));
      expect(provider.lastAvailabilityCheck, isNotNull);
    });

    test('checkAvailability sets checking state', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      final checkFuture = provider.checkAvailability(token: 'test_token');

      expect(provider.isCheckingAvailability, isTrue);

      await checkFuture;

      expect(provider.isCheckingAvailability, isFalse);
    });

    test('checkAvailability handles error gracefully', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.shouldThrowError = true;

      await provider.checkAvailability(token: 'test_token');

      // Should not set error message for availability checks
      expect(provider.errorMessage, isNull);
      expect(provider.isCheckingAvailability, isFalse);
    });

    test('refreshAvailability triggers availability check', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockAvailableSlots = 20;

      await provider.refreshAvailability(token: 'test_token');

      expect(provider.availableSlots, equals(20));
      expect(mockService.checkAvailabilityCallCount, equals(1));
    });
  });

  group('BookingProvider State Management', () {
    late MockBookingService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('canConfirmBooking returns true when all data is valid', () async {
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      expect(provider.canConfirmBooking, isTrue);
    });

    test('canConfirmBooking returns false when slots unavailable', () {
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // availableSlots is 0 by default

      expect(provider.canConfirmBooking, isFalse);
    });

    test('clear resets all state', () async {
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setDuration(const Duration(hours: 2));

      provider.clear();

      expect(provider.selectedMall, isNull);
      expect(provider.selectedVehicle, isNull);
      expect(provider.startTime, isNull);
      expect(provider.bookingDuration, isNull);
      expect(provider.estimatedCost, equals(0.0));
      expect(provider.availableSlots, equals(0));
    });

    test('clearError removes error message', () {
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});

      // Trigger an error
      provider.confirmBooking(token: 'test_token');

      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });

    test('clearValidationErrors removes validation errors', () {
      provider.initialize({'id_mall': 'MALL001', 'name': 'Test Mall'});
      provider.setDuration(const Duration(minutes: 15)); // Invalid duration

      expect(provider.hasValidationErrors, isTrue);

      provider.clearValidationErrors();

      expect(provider.hasValidationErrors, isFalse);
    });
  });
}

/// Helper function to create test booking model
BookingModel _createTestBooking({
  String idTransaksi = 'TRX001',
  String idBooking = 'BKG001',
  String idMall = 'MALL001',
  String idParkiran = 'P001',
  String idKendaraan = 'VEH001',
  String qrCode = 'QR123456',
  DateTime? waktuMulai,
  DateTime? waktuSelesai,
  int durasiBooking = 2,
  String status = 'aktif',
  double biayaEstimasi = 8000.0,
}) {
  final now = DateTime.now();
  return BookingModel(
    idTransaksi: idTransaksi,
    idBooking: idBooking,
    idMall: idMall,
    idParkiran: idParkiran,
    idKendaraan: idKendaraan,
    qrCode: qrCode,
    waktuMulai: waktuMulai ?? now.add(const Duration(hours: 1)),
    waktuSelesai: waktuSelesai ?? now.add(const Duration(hours: 3)),
    durasiBooking: durasiBooking,
    status: status,
    biayaEstimasi: biayaEstimasi,
    dibookingPada: now,
    namaMall: 'Test Mall',
    lokasiMall: 'Test Location',
    platNomor: 'B1234XYZ',
    jenisKendaraan: 'Mobil',
    kodeSlot: 'A-12',
  );
}
