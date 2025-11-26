import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

/// Comprehensive test suite for booking error scenarios
///
/// Tests all error handling paths including:
/// - Network errors (connection failures, timeouts)
/// - Slot unavailability scenarios
/// - Validation error display
/// - Booking conflict handling
///
/// Requirements: 15.11

// Mock service for network error simulation
class NetworkErrorMockService extends BookingService {
  bool shouldTimeout = false;
  bool shouldFailConnection = false;
  String? customErrorCode;

  @override
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    if (shouldTimeout) {
      await Future.delayed(const Duration(seconds: 2));
      return BookingResponse.error(
        message: 'Request timeout',
        errorCode: 'TIMEOUT_ERROR',
      );
    }

    if (shouldFailConnection) {
      return BookingResponse.error(
        message: 'Connection failed',
        errorCode: 'NETWORK_ERROR',
      );
    }

    if (customErrorCode != null) {
      return BookingResponse.error(
        message: 'Custom error',
        errorCode: customErrorCode!,
      );
    }

    return BookingResponse.success(
      message: 'Success',
      booking: _createMockBooking(request),
    );
  }

  @override
  Future<int> checkSlotAvailability({
    required String mallId,
    required String vehicleType,
    required DateTime startTime,
    required int durationHours,
    required String token,
  }) async {
    if (shouldFailConnection) {
      throw Exception('Network error');
    }
    return 0;
  }

  BookingModel _createMockBooking(BookingRequest request) {
    return BookingModel(
      idTransaksi: 'TRX001',
      idBooking: 'BKG001',
      idMall: request.idMall,
      idParkiran: 'P001',
      idKendaraan: request.idKendaraan,
      qrCode: 'QR123',
      waktuMulai: request.waktuMulai,
      waktuSelesai: request.waktuMulai.add(Duration(hours: request.durasiJam)),
      durasiBooking: request.durasiJam,
      status: 'aktif',
      biayaEstimasi: 10000.0,
      dibookingPada: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Network Error Handling Tests', () {
    late NetworkErrorMockService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = NetworkErrorMockService();
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
    });

    test('handles connection failure with user-friendly message', () async {
      // Arrange
      mockService.shouldFailConnection = true;
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5); // Set slots to pass availability check

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
      // Error message should be user-friendly (not technical)
      expect(provider.errorMessage, isNot(contains('Exception')));
      expect(provider.errorMessage, isNot(contains('Error:')));
    });

    test('handles timeout error gracefully', () async {
      // Arrange
      mockService.shouldTimeout = true;
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('slot availability check handles network errors', () async {
      // Arrange
      mockService.shouldFailConnection = true;
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Act
      await provider.checkAvailability(token: 'test_token');

      // Assert - should not crash, error message should not be set for availability checks
      expect(provider.errorMessage, isNull);
      expect(provider.isCheckingAvailability, isFalse);
    });

    test('provides retry capability after network error', () async {
      // Arrange
      mockService.shouldFailConnection = true;
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Act - First attempt fails
      var result = await provider.confirmBooking(token: 'test_token');
      expect(result, isFalse);

      // Fix network and retry
      mockService.shouldFailConnection = false;
      provider.setAvailableSlots(5); // Simulate slots available
      result = await provider.confirmBooking(token: 'test_token');

      // Assert - Should succeed after retry
      expect(result, isTrue);
      expect(provider.createdBooking, isNotNull);
    });
  });

  group('Slot Unavailability Handling Tests', () {
    late NetworkErrorMockService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = NetworkErrorMockService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
      });
    });

    tearDown(() {
      provider.dispose();
    });

    test('detects when no slots are available', () async {
      // Arrange
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(0); // No slots available

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isFalse);
      expect(provider.errorMessage, contains('tidak tersedia'));
      expect(provider.canConfirmBooking, isFalse);
    });

    test('handles slot becoming unavailable during booking', () async {
      // Arrange
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5); // Initially available

      // Simulate slot becoming unavailable
      mockService.customErrorCode = 'SLOT_UNAVAILABLE';

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('displays appropriate message for full parking', () async {
      // Arrange
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(0);

      // Act
      final canConfirm = provider.canConfirmBooking;

      // Assert
      expect(canConfirm, isFalse);
      // When trying to confirm, should show error
      await provider.confirmBooking(token: 'test_token');
      expect(provider.errorMessage, isNotNull);
    });

    test('allows booking when slots become available again', () async {
      // Arrange
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(0);

      // Act - First attempt fails
      var result = await provider.confirmBooking(token: 'test_token');
      expect(result, isFalse);

      // Slots become available
      provider.setAvailableSlots(5);
      result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isTrue);
      expect(provider.createdBooking, isNotNull);
    });
  });

  group('Validation Error Display Tests', () {
    late NetworkErrorMockService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = NetworkErrorMockService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
      });
    });

    tearDown(() {
      provider.dispose();
    });

    test('validates missing vehicle selection', () async {
      // Arrange - Don't select vehicle
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isFalse);
      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['vehicleId'], isNotNull);
    });

    test('validates past start time', () {
      // Arrange
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));

      // Act
      provider.setStartTime(pastTime);

      // Assert
      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['startTime'], isNotNull);
      expect(
        provider.validationErrors['startTime']!.contains('masa lalu'),
        isTrue,
      );
    });

    test('validates minimum duration', () {
      // Arrange & Act
      provider.setDuration(const Duration(minutes: 15)); // Too short

      // Assert
      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['duration'], isNotNull);
      expect(
        provider.validationErrors['duration']!.contains('minimal'),
        isTrue,
      );
    });

    test('validates maximum duration', () {
      // Arrange & Act
      provider.setDuration(const Duration(hours: 15)); // Too long

      // Assert
      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['duration'], isNotNull);
      expect(
        provider.validationErrors['duration']!.contains('maksimal'),
        isTrue,
      );
    });

    test('clears validation errors when corrected', () {
      // Arrange - Create error
      provider.setDuration(const Duration(minutes: 15));
      expect(provider.hasValidationErrors, isTrue);

      // Act - Correct the error
      provider.setDuration(const Duration(hours: 2));

      // Assert
      expect(provider.hasValidationErrors, isFalse);
      expect(provider.validationErrors['duration'], isNull);
    });

    test('displays multiple validation errors simultaneously', () {
      // Arrange & Act
      provider.setStartTime(DateTime.now().subtract(const Duration(hours: 1)));
      provider.setDuration(const Duration(minutes: 15));

      // Assert
      expect(provider.hasValidationErrors, isTrue);
      expect(provider.validationErrors['startTime'], isNotNull);
      expect(provider.validationErrors['duration'], isNotNull);
      expect(provider.validationErrors.length, greaterThanOrEqualTo(2));
    });

    test('prevents booking submission with validation errors', () async {
      // Arrange
      provider.setDuration(const Duration(minutes: 15)); // Invalid

      // Act
      final canConfirm = provider.canConfirmBooking;
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(canConfirm, isFalse);
      expect(result, isFalse);
    });
  });

  group('Booking Conflict Handling Tests', () {
    late BookingConflictMockService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = BookingConflictMockService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
      });
    });

    tearDown(() {
      provider.dispose();
    });

    test('detects existing active booking', () async {
      // Arrange
      mockService.hasActiveBooking = true;

      // Act
      final hasActive = await provider.hasActiveBooking(token: 'test_token');

      // Assert
      expect(hasActive, isTrue);
    });

    test('prevents new booking when active booking exists', () async {
      // Arrange
      mockService.hasActiveBooking = true;
      mockService.shouldFailOnConflict = true;

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final result = await provider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: false,
      );

      // Assert
      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(
        provider.errorMessage!.toLowerCase().contains('booking') ||
            provider.errorMessage!.toLowerCase().contains('aktif'),
        isTrue,
      );
    });

    test('displays conflict error message', () async {
      // Arrange
      mockService.hasActiveBooking = true;
      mockService.shouldFailOnConflict = true;

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(provider.errorMessage, contains('booking aktif'));
    });

    test('allows booking when no active booking exists', () async {
      // Arrange
      mockService.hasActiveBooking = false;

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isTrue);
      expect(provider.createdBooking, isNotNull);
    });

    test('can skip active booking check when explicitly requested', () async {
      // Arrange
      mockService.hasActiveBooking = true;
      mockService.shouldFailOnConflict = false; // Allow creation

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final result = await provider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true,
      );

      // Assert
      expect(result, isTrue);
      expect(provider.createdBooking, isNotNull);
    });
  });

  group('Combined Error Scenarios Tests', () {
    late NetworkErrorMockService mockService;
    late BookingProvider provider;

    setUp(() {
      mockService = NetworkErrorMockService();
      provider = BookingProvider(bookingService: mockService);
      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
      });
    });

    tearDown(() {
      provider.dispose();
    });

    test('handles validation error before network call', () async {
      // Arrange - Invalid data
      provider.setDuration(const Duration(minutes: 15));
      mockService.shouldFailConnection = true;

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert - Should fail on validation, not reach network call
      expect(result, isFalse);
      expect(provider.hasValidationErrors, isTrue);
    });

    test('handles slot unavailability before network call', () async {
      // Arrange
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(0); // No slots
      mockService.shouldFailConnection = true;

      // Act
      final result = await provider.confirmBooking(token: 'test_token');

      // Assert - Should fail on slot check, not reach network call
      expect(result, isFalse);
      expect(provider.errorMessage, contains('tidak tersedia'));
    });

    test('recovers from error state after correction', () async {
      // Arrange - Create error
      provider.setDuration(const Duration(minutes: 15));
      await provider.confirmBooking(token: 'test_token');
      expect(provider.hasValidationErrors, isTrue);

      // Act - Correct all issues
      provider.clearValidationErrors();
      provider.clearError();
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      final result = await provider.confirmBooking(token: 'test_token');

      // Assert
      expect(result, isTrue);
      expect(provider.hasValidationErrors, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('maintains error state until explicitly cleared', () async {
      // Arrange
      mockService.shouldFailConnection = true;
      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
      });
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));

      // Act
      await provider.confirmBooking(token: 'test_token');
      final errorAfterFail = provider.errorMessage;

      // Assert - Error persists
      expect(errorAfterFail, isNotNull);

      // Clear error
      provider.clearError();
      expect(provider.errorMessage, isNull);
    });
  });
}

/// Mock service for booking conflict testing
class BookingConflictMockService extends BookingService {
  bool hasActiveBooking = false;
  bool shouldFailOnConflict = false;

  @override
  Future<bool> checkActiveBooking({required String token}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return hasActiveBooking;
  }

  @override
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (hasActiveBooking && shouldFailOnConflict) {
      return BookingResponse.error(
        message: 'Anda sudah memiliki booking aktif',
        errorCode: 'BOOKING_CONFLICT',
      );
    }

    return BookingResponse.success(
      message: 'Success',
      booking: BookingModel(
        idTransaksi: 'TRX001',
        idBooking: 'BKG001',
        idMall: request.idMall,
        idParkiran: 'P001',
        idKendaraan: request.idKendaraan,
        qrCode: 'QR123',
        waktuMulai: request.waktuMulai,
        waktuSelesai: request.waktuMulai.add(Duration(hours: request.durasiJam)),
        durasiBooking: request.durasiJam,
        status: 'aktif',
        biayaEstimasi: 10000.0,
        dibookingPada: DateTime.now(),
      ),
    );
  }
}
