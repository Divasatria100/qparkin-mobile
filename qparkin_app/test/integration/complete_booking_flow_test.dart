import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

/// Complete Booking Flow Integration Tests
/// 
/// Tests the complete booking flow including:
/// 1. Booking WITH slot selection (new flow)
/// 2. Booking WITHOUT slot selection (legacy flow)
/// 3. Error scenarios
/// 
/// Requirements: 16.1-16.10
/// Task: 17.1 Test complete booking flow
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Booking Flow - WITH Slot Selection', () {
    late MockBookingService mockBookingService;

    setUp(() {
      mockBookingService = MockBookingService();
    });

    tearDown(() {
      mockBookingService.reset();
    });

    test('SUCCESS: Complete booking with slot reservation', () async {
      // Setup test data
      final testFloors = _createTestFloors();
      final testSlots = _createTestSlots();
      final testReservation = _createTestReservation();
      final testBooking = _createTestBooking();
      
      mockBookingService.mockFloors = testFloors;
      mockBookingService.mockSlots = testSlots;
      mockBookingService.mockReservation = testReservation;
      mockBookingService.mockBooking = testBooking;

      // Create provider
      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      // Initialize booking
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());

      // STEP 1: Fetch floors
      await bookingProvider.fetchFloors(token: 'test_token');
      expect(bookingProvider.floors.length, equals(2));

      // STEP 2: Select floor
      bookingProvider.selectFloor(testFloors[0], token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bookingProvider.selectedFloor, isNotNull);

      // STEP 3: Reserve slot
      final reservationSuccess = await bookingProvider.reserveRandomSlot(
        token: 'test_token',
        userId: 'user123',
      );
      expect(reservationSuccess, isTrue);
      expect(bookingProvider.hasReservedSlot, isTrue);

      // STEP 4: Set time and duration
      final startTime = DateTime.now().add(const Duration(hours: 1));
      bookingProvider.setStartTime(startTime);
      bookingProvider.setDuration(const Duration(hours: 2));

      // STEP 5: Confirm booking
      final bookingSuccess = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      // Verify booking was successful
      expect(bookingSuccess, isTrue);
      expect(bookingProvider.createdBooking, isNotNull);
      expect(bookingProvider.createdBooking?.idBooking, equals('BKG001'));

      // Verify booking includes slot information
      expect(mockBookingService.lastBookingRequest, isNotNull);
      expect(mockBookingService.lastBookingRequest?.idSlot, equals('slot1'));
      expect(mockBookingService.lastBookingRequest?.reservationId, equals('res123'));

      bookingProvider.dispose();
    });

    test('SUCCESS: Slot visualization updates correctly', () async {
      final testFloors = _createTestFloors();
      final testSlots = _createTestSlots();
      
      mockBookingService.mockFloors = testFloors;
      mockBookingService.mockSlots = testSlots;

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      bookingProvider.initialize(testMall);

      // Fetch floors
      await bookingProvider.fetchFloors(token: 'test_token');

      // Select floor and verify slots load
      bookingProvider.selectFloor(testFloors[0], token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bookingProvider.slotsVisualization.length, greaterThan(0));
      expect(mockBookingService.getSlotsCallCount, equals(1));

      bookingProvider.dispose();
    });

    test('SUCCESS: Floor change clears previous reservation', () async {
      final testFloors = _createTestFloors();
      final testSlots = _createTestSlots();
      final testReservation = _createTestReservation();
      
      mockBookingService.mockFloors = testFloors;
      mockBookingService.mockSlots = testSlots;
      mockBookingService.mockReservation = testReservation;

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());

      // Reserve slot on floor 1
      await bookingProvider.fetchFloors(token: 'test_token');
      bookingProvider.selectFloor(testFloors[0], token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 100));

      await bookingProvider.reserveRandomSlot(
        token: 'test_token',
        userId: 'user123',
      );
      expect(bookingProvider.hasReservedSlot, isTrue);

      // Change to floor 2
      bookingProvider.selectFloor(testFloors[1], token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify reservation is cleared
      expect(bookingProvider.reservedSlot, isNull);
      expect(bookingProvider.hasReservedSlot, isFalse);

      bookingProvider.dispose();
    });
  });

  group('Complete Booking Flow - WITHOUT Slot Selection', () {
    late MockBookingService mockBookingService;

    setUp(() {
      mockBookingService = MockBookingService();
    });

    tearDown(() {
      mockBookingService.reset();
    });

    test('SUCCESS: Complete booking without slot reservation (legacy)', () async {
      final testBooking = _createTestBooking();
      mockBookingService.mockBooking = testBooking;

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      // Initialize booking
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());

      // Set time and duration (no slot selection)
      final startTime = DateTime.now().add(const Duration(hours: 1));
      bookingProvider.setStartTime(startTime);
      bookingProvider.setDuration(const Duration(hours: 2));
      bookingProvider.setAvailableSlots(10);

      // Confirm booking without slot reservation
      final bookingSuccess = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      // Verify booking was successful
      expect(bookingSuccess, isTrue);
      expect(bookingProvider.createdBooking, isNotNull);

      // Verify booking request does NOT include slot information
      expect(mockBookingService.lastBookingRequest, isNotNull);
      expect(mockBookingService.lastBookingRequest?.idSlot, isNull);
      expect(mockBookingService.lastBookingRequest?.reservationId, isNull);

      bookingProvider.dispose();
    });

    test('SUCCESS: Backward compatibility with old booking format', () async {
      final testBooking = _createTestBooking();
      mockBookingService.mockBooking = testBooking;

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));
      bookingProvider.setAvailableSlots(10);

      final success = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      expect(success, isTrue);
      expect(mockBookingService.createBookingCallCount, equals(1));

      bookingProvider.dispose();
    });
  });

  group('Complete Booking Flow - Error Scenarios', () {
    late MockBookingService mockBookingService;

    setUp(() {
      mockBookingService = MockBookingService();
    });

    tearDown(() {
      mockBookingService.reset();
    });

    test('ERROR: No slots available for reservation', () async {
      final testFloors = _createTestFloors();
      // Set floor with no available slots
      testFloors[0] = ParkingFloorModel(
        idFloor: 'floor1',
        idMall: 'mall1',
        floorNumber: 1,
        floorName: 'Lantai 1',
        totalSlots: 50,
        availableSlots: 0,
        occupiedSlots: 50,
        reservedSlots: 0,
        lastUpdated: DateTime.now(),
      );
      
      mockBookingService.mockFloors = testFloors;
      mockBookingService.mockReservation = null;

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      bookingProvider.initialize(testMall);

      await bookingProvider.fetchFloors(token: 'test_token');
      bookingProvider.selectFloor(testFloors[0], token: 'test_token');

      // Verify error message
      expect(bookingProvider.errorMessage, isNotNull);
      expect(bookingProvider.errorMessage, contains('tidak memiliki slot tersedia'));

      bookingProvider.dispose();
    });

    test('ERROR: Reservation expires before booking confirmation', () async {
      final testFloors = _createTestFloors();
      final testSlots = _createTestSlots();
      final expiredReservation = SlotReservationModel(
        reservationId: 'res123',
        slotId: 'slot1',
        slotCode: 'A12',
        floorName: 'Lantai 1',
        floorNumber: '1',
        slotType: SlotType.regular,
        reservedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isActive: false,
      );
      
      mockBookingService.mockFloors = testFloors;
      mockBookingService.mockSlots = testSlots;
      mockBookingService.mockReservation = expiredReservation;

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());

      await bookingProvider.fetchFloors(token: 'test_token');
      bookingProvider.selectFloor(testFloors[0], token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 100));

      await bookingProvider.reserveRandomSlot(
        token: 'test_token',
        userId: 'user123',
      );

      // Verify reservation is expired
      expect(bookingProvider.reservedSlot?.isExpired, isTrue);
      expect(bookingProvider.hasReservedSlot, isFalse);

      // Try to confirm booking
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));

      final success = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      expect(success, isFalse);
      expect(bookingProvider.errorMessage, isNotNull);
      expect(bookingProvider.errorMessage, contains('berakhir'));

      bookingProvider.dispose();
    });

    test('ERROR: Network failure during floor fetch', () async {
      mockBookingService.shouldThrowError = true;
      mockBookingService.errorMessage = 'Network connection failed';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      bookingProvider.initialize(testMall);

      await bookingProvider.fetchFloors(token: 'test_token');

      expect(bookingProvider.errorMessage, isNotNull);
      expect(bookingProvider.errorMessage, contains('Gagal memuat data lantai'));
      expect(bookingProvider.floors.isEmpty, isTrue);

      bookingProvider.dispose();
    });

    test('ERROR: Network failure during slot reservation', () async {
      final testFloors = _createTestFloors();
      mockBookingService.mockFloors = testFloors;
      mockBookingService.shouldThrowErrorOnReservation = true;
      mockBookingService.errorMessage = 'Reservation failed';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      bookingProvider.initialize(testMall);

      await bookingProvider.fetchFloors(token: 'test_token');
      bookingProvider.selectFloor(testFloors[0], token: 'test_token');
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await bookingProvider.reserveRandomSlot(
        token: 'test_token',
        userId: 'user123',
      );

      expect(success, isFalse);
      expect(bookingProvider.errorMessage, isNotNull);
      expect(bookingProvider.hasReservedSlot, isFalse);

      bookingProvider.dispose();
    });

    test('ERROR: Booking validation fails without required data', () async {
      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      bookingProvider.initialize(testMall);

      // Don't set vehicle, time, or duration
      final success = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      expect(success, isFalse);
      expect(bookingProvider.errorMessage, isNotNull);
      expect(mockBookingService.createBookingCallCount, equals(0));

      bookingProvider.dispose();
    });

    test('ERROR: Booking fails with network error', () async {
      mockBookingService.shouldThrowErrorOnBooking = true;
      mockBookingService.errorMessage = 'Booking creation failed';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));
      bookingProvider.setAvailableSlots(10);

      final success = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      expect(success, isFalse);
      expect(bookingProvider.errorMessage, isNotNull);

      bookingProvider.dispose();
    });

    test('ERROR: Slot unavailable during booking confirmation', () async {
      mockBookingService.shouldThrowErrorOnBooking = true;
      mockBookingService.errorMessage = 'Slot tidak tersedia';
      mockBookingService.errorCode = 'SLOT_UNAVAILABLE';

      final bookingProvider = BookingProvider(
        bookingService: mockBookingService,
      );

      final testMall = _createTestMall();
      final testVehicle = _createTestVehicle();
      
      bookingProvider.initialize(testMall);
      bookingProvider.selectVehicle(testVehicle.toJson());
      bookingProvider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      bookingProvider.setDuration(const Duration(hours: 2));
      bookingProvider.setAvailableSlots(10);

      final success = await bookingProvider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      expect(success, isFalse);
      expect(bookingProvider.errorMessage, contains('tidak tersedia'));

      bookingProvider.dispose();
    });
  });
}

// Mock BookingService
class MockBookingService extends BookingService {
  List<ParkingFloorModel> mockFloors = [];
  List<ParkingSlotModel> mockSlots = [];
  SlotReservationModel? mockReservation;
  BookingModel? mockBooking;
  BookingRequest? lastBookingRequest;
  
  bool shouldThrowError = false;
  bool shouldThrowErrorOnReservation = false;
  bool shouldThrowErrorOnBooking = false;
  String errorMessage = 'Network error';
  String errorCode = 'NETWORK_ERROR';
  
  int getFloorsCallCount = 0;
  int getSlotsCallCount = 0;
  int reserveSlotCallCount = 0;
  int createBookingCallCount = 0;

  @override
  Future<List<ParkingFloorModel>> getFloorsWithRetry({
    required String mallId,
    required String token,
    int maxRetries = 2,
  }) async {
    getFloorsCallCount++;
    
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    return mockFloors;
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
    
    if (shouldThrowErrorOnReservation) {
      throw Exception(errorMessage);
    }
    
    return mockReservation;
  }

  @override
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    createBookingCallCount++;
    lastBookingRequest = request;
    
    if (shouldThrowErrorOnBooking) {
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

  @override
  Future<BookingResponse> createBookingWithRetry({
    required BookingRequest request,
    required String token,
    int maxRetries = 3,
  }) async {
    return createBooking(request: request, token: token);
  }

  void reset() {
    mockFloors = [];
    mockSlots = [];
    mockReservation = null;
    mockBooking = null;
    lastBookingRequest = null;
    shouldThrowError = false;
    shouldThrowErrorOnReservation = false;
    shouldThrowErrorOnBooking = false;
    errorMessage = 'Network error';
    errorCode = 'NETWORK_ERROR';
    getFloorsCallCount = 0;
    getSlotsCallCount = 0;
    reserveSlotCallCount = 0;
    createBookingCallCount = 0;
  }
}

// Test Data Helpers
List<ParkingFloorModel> _createTestFloors() {
  return [
    ParkingFloorModel(
      idFloor: 'floor1',
      idMall: 'mall1',
      floorNumber: 1,
      floorName: 'Lantai 1',
      totalSlots: 50,
      availableSlots: 12,
      occupiedSlots: 35,
      reservedSlots: 3,
      lastUpdated: DateTime.now(),
    ),
    ParkingFloorModel(
      idFloor: 'floor2',
      idMall: 'mall1',
      floorNumber: 2,
      floorName: 'Lantai 2',
      totalSlots: 60,
      availableSlots: 25,
      occupiedSlots: 30,
      reservedSlots: 5,
      lastUpdated: DateTime.now(),
    ),
  ];
}

List<ParkingSlotModel> _createTestSlots() {
  return [
    ParkingSlotModel(
      idSlot: 'slot1',
      idFloor: 'floor1',
      slotCode: 'A01',
      status: SlotStatus.available,
      slotType: SlotType.regular,
      positionX: 0,
      positionY: 0,
      lastUpdated: DateTime.now(),
    ),
    ParkingSlotModel(
      idSlot: 'slot2',
      idFloor: 'floor1',
      slotCode: 'A02',
      status: SlotStatus.occupied,
      slotType: SlotType.regular,
      positionX: 1,
      positionY: 0,
      lastUpdated: DateTime.now(),
    ),
    ParkingSlotModel(
      idSlot: 'slot3',
      idFloor: 'floor1',
      slotCode: 'A03',
      status: SlotStatus.available,
      slotType: SlotType.disableFriendly,
      positionX: 2,
      positionY: 0,
      lastUpdated: DateTime.now(),
    ),
  ];
}

SlotReservationModel _createTestReservation() {
  return SlotReservationModel(
    reservationId: 'res123',
    slotId: 'slot1',
    slotCode: 'A12',
    floorName: 'Lantai 1',
    floorNumber: '1',
    slotType: SlotType.regular,
    reservedAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    isActive: true,
  );
}

Map<String, dynamic> _createTestMall() {
  return {
    'id_mall': 'mall1',
    'name': 'Test Mall',
    'lokasi': 'Test Location',
    'alamat_gmaps': 'Test Address',
    'latitude': 1.1234,
    'longitude': 104.1234,
    'available': 50,
    'firstHourRate': 5000.0,
    'additionalHourRate': 3000.0,
  };
}

VehicleModel _createTestVehicle() {
  return VehicleModel(
    idKendaraan: 'veh1',
    platNomor: 'B1234XYZ',
    jenisKendaraan: 'Mobil',
    merk: 'Toyota',
    tipe: 'Avanza',
  );
}

BookingModel _createTestBooking() {
  return BookingModel(
    idTransaksi: 'TRX001',
    idBooking: 'BKG001',
    qrCode: 'QR123456',
    idMall: 'mall1',
    idParkiran: 'P001',
    idKendaraan: 'veh1',
    waktuMulai: DateTime.now().add(const Duration(hours: 1)),
    waktuSelesai: DateTime.now().add(const Duration(hours: 3)),
    durasiBooking: 2,
    status: 'aktif',
    biayaEstimasi: 11000.0,
    dibookingPada: DateTime.now(),
  );
}
