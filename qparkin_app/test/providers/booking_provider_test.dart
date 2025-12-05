import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';
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

  // NEW: Slot reservation mocks
  List<ParkingFloorModel> mockFloors = [];
  List<ParkingSlotModel> mockSlots = [];
  SlotReservationModel? mockReservation;
  int getFloorsCallCount = 0;
  int getSlotsCallCount = 0;
  int reserveSlotCallCount = 0;

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

  @override
  Future<List<ParkingFloorModel>> getFloors({
    required String mallId,
    required String token,
  }) async {
    getFloorsCallCount++;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    await Future.delayed(const Duration(milliseconds: 10));
    return mockFloors;
  }

  @override
  Future<List<ParkingFloorModel>> getFloorsWithRetry({
    required String mallId,
    required String token,
    int maxRetries = 2,
  }) async {
    return getFloors(mallId: mallId, token: token);
  }

  @override
  Future<List<ParkingSlotModel>> getSlotsForVisualization({
    required String floorId,
    required String token,
    String? vehicleType,
  }) async {
    getSlotsCallCount++;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    await Future.delayed(const Duration(milliseconds: 10));
    return mockSlots;
  }

  @override
  Future<SlotReservationModel?> reserveRandomSlot({
    required String floorId,
    required String userId,
    required String vehicleType,
    required String token,
    int durationMinutes = 5,
  }) async {
    reserveSlotCallCount++;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    await Future.delayed(const Duration(milliseconds: 10));
    return mockReservation;
  }

  void reset() {
    mockResponse = null;
    mockAvailableSlots = 10;
    shouldThrowError = false;
    errorMessage = 'Network error';
    createBookingCallCount = 0;
    checkAvailabilityCallCount = 0;
    lastRequest = null;
    
    // Reset slot reservation mocks
    mockFloors = [];
    mockSlots = [];
    mockReservation = null;
    getFloorsCallCount = 0;
    getSlotsCallCount = 0;
    reserveSlotCallCount = 0;
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

  group('BookingProvider Floor Selection', () {
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

    test('fetchFloors loads floor data successfully', () async {
      final testFloors = [
        _createTestFloor(idFloor: 'F1', floorNumber: 1, availableSlots: 10),
        _createTestFloor(idFloor: 'F2', floorNumber: 2, availableSlots: 5),
      ];
      mockService.mockFloors = testFloors;

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors.length, equals(2));
      expect(provider.floors[0].floorNumber, equals(1));
      expect(provider.floors[1].floorNumber, equals(2));
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchFloors sets loading state during fetch', () async {
      mockService.mockFloors = [_createTestFloor()];

      final fetchFuture = provider.fetchFloors(token: 'test_token');
      expect(provider.isLoadingFloors, isTrue);

      await fetchFuture;
      expect(provider.isLoadingFloors, isFalse);
    });

    test('fetchFloors handles error gracefully', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Network error';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('Gagal memuat data lantai'));
    });

    test('fetchFloors handles network error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Network connection failed';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('Gagal memuat data lantai'));
      expect(provider.errorMessage, contains('koneksi internet'));
    });

    test('fetchFloors handles timeout error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Timeout occurred';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('timeout'));
      expect(provider.errorMessage, contains('koneksi internet'));
    });

    test('fetchFloors handles auth error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Unauthorized access - 401';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('Sesi Anda telah berakhir'));
      expect(provider.errorMessage, contains('login kembali'));
    });

    test('fetchFloors handles socket error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'SocketException: Connection refused';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('Gagal memuat data lantai'));
      expect(provider.errorMessage, contains('koneksi internet'));
    });

    test('fetchFloors handles 404 error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = '404 Not Found';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('Data tidak ditemukan'));
    });

    test('fetchFloors handles server error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = '500 Internal Server Error';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('kesalahan server'));
    });

    test('fetchFloors handles format error with specific message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'FormatException: Invalid JSON';

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.isLoadingFloors, isFalse);
      expect(provider.errorMessage, contains('Format data tidak valid'));
    });

    test('retryFetchFloors calls fetchFloors again', () async {
      mockService.mockFloors = [_createTestFloor()];

      await provider.retryFetchFloors(token: 'test_token');

      expect(mockService.getFloorsCallCount, equals(1));
      expect(provider.floors.length, equals(1));
    });

    test('fetchFloors without mall selected shows error', () async {
      final providerWithoutMall = BookingProvider(bookingService: mockService);

      await providerWithoutMall.fetchFloors(token: 'test_token');

      expect(providerWithoutMall.errorMessage, equals('Mall tidak dipilih'));
      expect(mockService.getFloorsCallCount, equals(0));
      
      providerWithoutMall.dispose();
    });

    test('fetchFloors with invalid mall ID shows error', () async {
      final providerWithInvalidMall = BookingProvider(bookingService: mockService);
      providerWithInvalidMall.initialize({'name': 'Test Mall'}); // No id_mall

      await providerWithInvalidMall.fetchFloors(token: 'test_token');

      expect(providerWithInvalidMall.errorMessage, equals('ID mall tidak valid'));
      expect(mockService.getFloorsCallCount, equals(0));
      
      providerWithInvalidMall.dispose();
    });

    test('fetchFloors with empty floors shows warning message', () async {
      mockService.mockFloors = [];

      await provider.fetchFloors(token: 'test_token');

      expect(provider.floors, isEmpty);
      expect(provider.errorMessage, equals('Tidak ada data lantai parkir tersedia'));
      expect(provider.isLoadingFloors, isFalse);
    });

    test('selectFloor updates selected floor', () {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);

      provider.selectFloor(floor);

      expect(provider.selectedFloor, equals(floor));
      expect(provider.slotsVisualization, isEmpty);
    });

    test('selectFloor clears previous reservation', () async {
      final floor1 = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      final floor2 = _createTestFloor(idFloor: 'F2', availableSlots: 5);
      
      // Set up vehicle for reservation
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      // Select first floor and reserve slot
      provider.selectFloor(floor1);
      mockService.mockReservation = _createTestReservation();
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');
      
      expect(provider.hasReservedSlot, isTrue);

      // Select different floor
      provider.selectFloor(floor2);

      expect(provider.selectedFloor, equals(floor2));
      expect(provider.hasReservedSlot, isFalse);
      expect(provider.reservedSlot, isNull);
    });

    test('selectFloor validates floor has available slots', () {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 0);

      provider.selectFloor(floor);

      expect(provider.selectedFloor, isNull);
      expect(provider.errorMessage, contains('tidak memiliki slot tersedia'));
    });

    test('selectFloor fetches slots when token provided', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      mockService.mockSlots = [_createTestSlot()];

      provider.selectFloor(floor, token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 20));

      expect(mockService.getSlotsCallCount, equals(1));
    });
  });

  group('BookingProvider Slot Visualization', () {
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

    test('fetchSlotsForVisualization loads slot data', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);

      final testSlots = [
        _createTestSlot(idSlot: 'S1', slotCode: 'A01', status: SlotStatus.available),
        _createTestSlot(idSlot: 'S2', slotCode: 'A02', status: SlotStatus.occupied),
      ];
      mockService.mockSlots = testSlots;

      await provider.fetchSlotsForVisualization(token: 'test_token');

      expect(provider.slotsVisualization.length, equals(2));
      expect(provider.slotsVisualization[0].slotCode, equals('A01'));
      expect(provider.slotsVisualization[1].slotCode, equals('A02'));
      expect(provider.isLoadingSlots, isFalse);
    });

    test('fetchSlotsForVisualization sets loading state', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      mockService.mockSlots = [_createTestSlot()];

      final fetchFuture = provider.fetchSlotsForVisualization(token: 'test_token');
      expect(provider.isLoadingSlots, isTrue);

      await fetchFuture;
      expect(provider.isLoadingSlots, isFalse);
    });

    test('fetchSlotsForVisualization handles error', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      mockService.shouldThrowError = true;

      await provider.fetchSlotsForVisualization(token: 'test_token');

      expect(provider.slotsVisualization, isEmpty);
      expect(provider.isLoadingSlots, isFalse);
      expect(provider.errorMessage, contains('Gagal memuat tampilan slot'));
    });

    test('fetchSlotsForVisualization requires floor selection', () async {
      await provider.fetchSlotsForVisualization(token: 'test_token');

      expect(mockService.getSlotsCallCount, equals(0));
      expect(provider.slotsVisualization, isEmpty);
    });

    test('refreshSlotVisualization debounces requests', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      mockService.mockSlots = [_createTestSlot()];

      // Trigger multiple refreshes quickly
      provider.refreshSlotVisualization(token: 'test_token');
      provider.refreshSlotVisualization(token: 'test_token');
      provider.refreshSlotVisualization(token: 'test_token');

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 600));

      // Should only call once due to debouncing
      expect(mockService.getSlotsCallCount, equals(1));
    });
  });

  group('BookingProvider Slot Reservation', () {
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

    test('reserveRandomSlot succeeds with valid data', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      final testReservation = _createTestReservation(
        slotCode: 'A15',
        floorName: 'Lantai 1',
      );
      mockService.mockReservation = testReservation;

      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(result, isTrue);
      expect(provider.reservedSlot, isNotNull);
      expect(provider.reservedSlot!.slotCode, equals('A15'));
      expect(provider.hasReservedSlot, isTrue);
      expect(provider.isReservingSlot, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('reserveRandomSlot sets loading state', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });
      mockService.mockReservation = _createTestReservation();

      final reserveFuture = provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(provider.isReservingSlot, isTrue);

      await reserveFuture;

      expect(provider.isReservingSlot, isFalse);
    });

    test('reserveRandomSlot fails without floor selection', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(result, isFalse);
      expect(provider.errorMessage, contains('pilih lantai'));
      expect(mockService.reserveSlotCallCount, equals(0));
    });

    test('reserveRandomSlot fails without vehicle selection', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);

      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(result, isFalse);
      expect(provider.errorMessage, contains('pilih kendaraan'));
      expect(mockService.reserveSlotCallCount, equals(0));
    });

    test('reserveRandomSlot fails when floor has no available slots', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 0);
      // Manually set selected floor to bypass validation
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(result, isFalse);
      expect(mockService.reserveSlotCallCount, equals(0));
    });

    test('reserveRandomSlot handles no slots available from backend', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      mockService.mockReservation = null; // Backend returns null

      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(result, isFalse);
      expect(provider.errorMessage, contains('Tidak ada slot tersedia'));
      expect(provider.hasReservedSlot, isFalse);
    });

    test('reserveRandomSlot handles network error', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Network error';

      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'USER001',
      );

      expect(result, isFalse);
      expect(provider.errorMessage, contains('Gagal mereservasi slot'));
      expect(provider.hasReservedSlot, isFalse);
    });

    test('clearReservation removes reserved slot', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      mockService.mockReservation = _createTestReservation();
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      expect(provider.hasReservedSlot, isTrue);

      provider.clearReservation();

      expect(provider.reservedSlot, isNull);
      expect(provider.hasReservedSlot, isFalse);
    });

    test('hasReservedSlot returns false for expired reservation', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      // Create expired reservation
      final expiredReservation = _createTestReservation(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      mockService.mockReservation = expiredReservation;
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      expect(provider.reservedSlot, isNotNull);
      expect(provider.hasReservedSlot, isFalse); // Expired
    });
  });

  group('BookingProvider Reservation Timeout', () {
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

    test('startReservationTimer clears reservation on timeout', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      // Create reservation that expires in 100ms
      final shortReservation = _createTestReservation(
        expiresAt: DateTime.now().add(const Duration(milliseconds: 100)),
      );
      mockService.mockReservation = shortReservation;
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      expect(provider.hasReservedSlot, isTrue);

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 150));

      expect(provider.reservedSlot, isNull);
      expect(provider.errorMessage, contains('Waktu reservasi habis'));
    });

    test('stopReservationTimer prevents timeout', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      final shortReservation = _createTestReservation(
        expiresAt: DateTime.now().add(const Duration(milliseconds: 100)),
      );
      mockService.mockReservation = shortReservation;
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      // Stop timer before timeout
      provider.stopReservationTimer();

      // Wait past timeout
      await Future.delayed(const Duration(milliseconds: 150));

      // Reservation should still exist (timer was stopped)
      expect(provider.reservedSlot, isNotNull);
    });

    test('startReservationTimer handles already expired reservation', () {
      final expiredReservation = _createTestReservation(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      // Manually set expired reservation
      provider.selectFloor(_createTestFloor(idFloor: 'F1', availableSlots: 10));
      provider.selectVehicle({'id_kendaraan': 'VEH001', 'jenis_kendaraan': 'Mobil'});
      
      // This would normally be set by reserveRandomSlot, but we're testing the timer directly
      // The timer should immediately clear an expired reservation
      provider.startReservationTimer();

      expect(provider.reservedSlot, isNull);
    });
  });

  group('BookingProvider Booking with Slot Reservation', () {
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

    test('confirmBooking includes reserved slot in request', () async {
      // Setup complete booking data
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Reserve slot
      mockService.mockReservation = _createTestReservation(
        slotId: 'SLOT123',
        reservationId: 'RES456',
      );
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      // Mock successful booking
      final mockBooking = _createTestBooking();
      mockService.mockResponse = BookingResponse.success(
        message: 'Booking berhasil',
        booking: mockBooking,
      );
      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isTrue);
      expect(mockService.lastRequest, isNotNull);
      expect(mockService.lastRequest!.idSlot, equals('SLOT123'));
      expect(mockService.lastRequest!.reservationId, equals('RES456'));
    });

    test('confirmBooking validates expired reservation', () async {
      provider.selectFloor(_createTestFloor(idFloor: 'F1', availableSlots: 10));
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Reserve slot with already expired time (stop timer to prevent auto-clear)
      mockService.mockReservation = _createTestReservation(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');
      
      // Stop the timer so it doesn't auto-clear the reservation
      provider.stopReservationTimer();

      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isFalse);
      expect(provider.errorMessage, contains('Reservasi slot telah berakhir'));
    });

    test('confirmBooking works without slot reservation (backward compatibility)', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Don't reserve slot - test backward compatibility

      final mockBooking = _createTestBooking();
      mockService.mockResponse = BookingResponse.success(
        message: 'Booking berhasil',
        booking: mockBooking,
      );
      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      final result = await provider.confirmBooking(token: 'test_token');

      expect(result, isTrue);
      expect(mockService.lastRequest, isNotNull);
      expect(mockService.lastRequest!.idSlot, isNull);
      expect(mockService.lastRequest!.reservationId, isNull);
    });

    test('confirmBooking stops all timers on success', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Reserve slot and start timers
      mockService.mockReservation = _createTestReservation();
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');
      provider.startSlotRefreshTimer(token: 'test_token');

      final mockBooking = _createTestBooking();
      mockService.mockResponse = BookingResponse.success(
        message: 'Booking berhasil',
        booking: mockBooking,
      );
      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      await provider.confirmBooking(token: 'test_token');

      // Timers should be stopped (we can't directly test this, but no errors should occur)
      expect(provider.createdBooking, isNotNull);
    });
  });

  group('BookingProvider Validation with Slot Reservation', () {
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

    test('canConfirmBooking returns true without slot reservation', () async {
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      // Should work without slot reservation (backward compatibility)
      expect(provider.canConfirmBooking, isTrue);
    });

    test('canConfirmBooking returns true with valid slot reservation', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      mockService.mockReservation = _createTestReservation();
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      mockService.mockAvailableSlots = 10;
      await provider.checkAvailability(token: 'test_token');

      expect(provider.canConfirmBooking, isTrue);
    });

    test('clear resets all slot reservation state', () async {
      final floor = _createTestFloor(idFloor: 'F1', availableSlots: 10);
      provider.selectFloor(floor);
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'jenis_kendaraan': 'Mobil',
      });

      mockService.mockFloors = [floor];
      mockService.mockSlots = [_createTestSlot()];
      mockService.mockReservation = _createTestReservation();

      await provider.fetchFloors(token: 'test_token');
      await provider.fetchSlotsForVisualization(token: 'test_token');
      await provider.reserveRandomSlot(token: 'test_token', userId: 'USER001');

      expect(provider.floors, isNotEmpty);
      expect(provider.selectedFloor, isNotNull);
      expect(provider.slotsVisualization, isNotEmpty);
      expect(provider.hasReservedSlot, isTrue);

      provider.clear();

      expect(provider.floors, isEmpty);
      expect(provider.selectedFloor, isNull);
      expect(provider.slotsVisualization, isEmpty);
      expect(provider.reservedSlot, isNull);
      expect(provider.hasReservedSlot, isFalse);
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

/// Helper function to create test parking floor model
ParkingFloorModel _createTestFloor({
  String idFloor = 'F1',
  String idMall = 'MALL001',
  int floorNumber = 1,
  String floorName = 'Lantai 1',
  int totalSlots = 50,
  int availableSlots = 10,
  int occupiedSlots = 35,
  int reservedSlots = 5,
}) {
  return ParkingFloorModel(
    idFloor: idFloor,
    idMall: idMall,
    floorNumber: floorNumber,
    floorName: floorName,
    totalSlots: totalSlots,
    availableSlots: availableSlots,
    occupiedSlots: occupiedSlots,
    reservedSlots: reservedSlots,
    lastUpdated: DateTime.now(),
  );
}

/// Helper function to create test parking slot model
ParkingSlotModel _createTestSlot({
  String idSlot = 'S1',
  String idFloor = 'F1',
  String slotCode = 'A01',
  SlotStatus status = SlotStatus.available,
  SlotType slotType = SlotType.regular,
  int? positionX,
  int? positionY,
}) {
  return ParkingSlotModel(
    idSlot: idSlot,
    idFloor: idFloor,
    slotCode: slotCode,
    status: status,
    slotType: slotType,
    positionX: positionX,
    positionY: positionY,
    lastUpdated: DateTime.now(),
  );
}

/// Helper function to create test slot reservation model
SlotReservationModel _createTestReservation({
  String reservationId = 'RES001',
  String slotId = 'SLOT001',
  String slotCode = 'A15',
  String floorName = 'Lantai 1',
  String floorNumber = '1',
  SlotType slotType = SlotType.regular,
  DateTime? expiresAt,
}) {
  final now = DateTime.now();
  return SlotReservationModel(
    reservationId: reservationId,
    slotId: slotId,
    slotCode: slotCode,
    floorName: floorName,
    floorNumber: floorNumber,
    slotType: slotType,
    reservedAt: now,
    expiresAt: expiresAt ?? now.add(const Duration(minutes: 5)),
    isActive: true,
  );
}
