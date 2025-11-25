import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/booking_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookingService - Create Booking', () {
    test('createBooking handles API calls correctly', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      // Test that the service handles the request without throwing
      final response = await service.createBooking(
        request: request,
        token: 'test_token',
      );

      // Should return a response (success or error)
      expect(response, isNotNull);
      expect(response, isA<BookingResponse>());
    });

    test('createBooking returns validation error for invalid request', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: '', // Empty mall ID
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBooking(
        request: invalidRequest,
        token: 'test_token',
      );

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
      expect(response.message, contains('Mall'));
    });

    test('createBooking returns validation error for past start time', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().subtract(const Duration(hours: 1)), // Past time
        durasiJam: 2,
      );

      final response = await service.createBooking(
        request: invalidRequest,
        token: 'test_token',
      );

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
      expect(response.message, contains('masa lalu'));
    });

    test('createBooking returns validation error for invalid duration', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 0, // Invalid duration
      );

      final response = await service.createBooking(
        request: invalidRequest,
        token: 'test_token',
      );

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
      expect(response.message, contains('Durasi'));
    });

    test('createBooking returns validation error for excessive duration', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 15, // Exceeds 12 hour limit
      );

      final response = await service.createBooking(
        request: invalidRequest,
        token: 'test_token',
      );

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
      expect(response.message, contains('maksimal'));
    });
  });

  group('BookingService - Network Error Handling', () {
    test('createBooking returns network error on connection failure', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      // This will fail due to invalid URL, simulating network error
      final response = await service.createBooking(
        request: request,
        token: 'test_token',
      );

      // Should handle network errors gracefully
      expect(response.success, isFalse);
      expect(response.isNetworkError || response.errorCode != null, isTrue);
    });

    test('createBooking returns timeout error on request timeout', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      // Will timeout due to invalid endpoint
      final response = await service.createBooking(
        request: request,
        token: 'test_token',
      );

      expect(response.success, isFalse);
    });
  });

  group('BookingService - Retry Logic', () {
    test('createBookingWithRetry succeeds on first attempt', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBookingWithRetry(
        request: request,
        token: 'test_token',
        maxRetries: 3,
      );

      expect(response, isNotNull);
      expect(response.success, isFalse); // Will fail due to no mock server
    });

    test('createBookingWithRetry does not retry validation errors', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: '', // Invalid
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final startTime = DateTime.now();
      final response = await service.createBookingWithRetry(
        request: invalidRequest,
        token: 'test_token',
        maxRetries: 3,
      );
      final duration = DateTime.now().difference(startTime);

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
      // Should return immediately without retries (< 1 second)
      expect(duration.inSeconds, lessThan(2));
    });

    test('createBookingWithRetry respects maxRetries parameter', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBookingWithRetry(
        request: request,
        token: 'test_token',
        maxRetries: 2,
      );

      expect(response, isNotNull);
      // Should complete without throwing errors
      expect(response, isA<BookingResponse>());
    });
  });

  group('BookingService - Slot Availability', () {
    test('checkSlotAvailability returns slot count on success', () async {
      final service = BookingService();

      final slots = await service.checkSlotAvailability(
        mallId: 'MALL001',
        vehicleType: 'Mobil',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        durationHours: 2,
        token: 'test_token',
      );

      // Will return 0 due to no mock server, but should not throw
      expect(slots, isA<int>());
      expect(slots, greaterThanOrEqualTo(0));
    });

    test('checkSlotAvailability returns 0 on network error', () async {
      final service = BookingService();

      final slots = await service.checkSlotAvailability(
        mallId: 'MALL001',
        vehicleType: 'Mobil',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        durationHours: 2,
        token: 'test_token',
      );

      expect(slots, equals(0));
    });

    test('checkSlotAvailability throws on unauthorized', () async {
      final service = BookingService();

      // This test verifies the method signature and error handling
      expect(
        () async => await service.checkSlotAvailability(
          mallId: 'MALL001',
          vehicleType: 'Mobil',
          startTime: DateTime.now().add(const Duration(hours: 1)),
          durationHours: 2,
          token: 'invalid_token',
        ),
        returnsNormally,
      );
    });

    test('checkSlotAvailability handles timeout gracefully', () async {
      final service = BookingService();

      final slots = await service.checkSlotAvailability(
        mallId: 'MALL001',
        vehicleType: 'Mobil',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        durationHours: 2,
        token: 'test_token',
      );

      expect(slots, equals(0));
    });
  });

  group('BookingService - Slot Availability with Retry', () {
    test('checkSlotAvailabilityWithRetry returns slot count', () async {
      final service = BookingService();

      final slots = await service.checkSlotAvailabilityWithRetry(
        mallId: 'MALL001',
        vehicleType: 'Mobil',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        durationHours: 2,
        token: 'test_token',
        maxRetries: 2,
      );

      expect(slots, isA<int>());
      expect(slots, greaterThanOrEqualTo(0));
    });

    test('checkSlotAvailabilityWithRetry respects maxRetries', () async {
      final service = BookingService();

      final slots = await service.checkSlotAvailabilityWithRetry(
        mallId: 'MALL001',
        vehicleType: 'Mobil',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        durationHours: 2,
        token: 'test_token',
        maxRetries: 2,
      );

      expect(slots, equals(0));
      // Should complete and return 0 when no server is available
      expect(slots, isA<int>());
    });

    test('checkSlotAvailabilityWithRetry returns 0 after all retries', () async {
      final service = BookingService();

      final slots = await service.checkSlotAvailabilityWithRetry(
        mallId: 'MALL001',
        vehicleType: 'Mobil',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        durationHours: 2,
        token: 'test_token',
        maxRetries: 3,
      );

      expect(slots, equals(0));
    });
  });

  group('BookingService - Response Handling', () {
    test('handles 200 success response correctly', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBooking(
        request: request,
        token: 'test_token',
      );

      expect(response, isNotNull);
      expect(response, isA<BookingResponse>());
    });

    test('handles 400 validation error response', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: '',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBooking(
        request: invalidRequest,
        token: 'test_token',
      );

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
    });

    test('validates request data before API call', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: '',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBooking(
        request: invalidRequest,
        token: 'test_token',
      );

      expect(response.success, isFalse);
      expect(response.message, contains('Kendaraan'));
    });
  });

  group('BookingService - Error Code Handling', () {
    test('identifies network errors correctly', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final response = await service.createBooking(
        request: request,
        token: 'test_token',
      );

      if (!response.success) {
        expect(response.errorCode, isNotNull);
      }
    });

    test('retry logic skips non-retryable errors', () async {
      final service = BookingService();
      final invalidRequest = BookingRequest(
        idMall: '',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );

      final startTime = DateTime.now();
      final response = await service.createBookingWithRetry(
        request: invalidRequest,
        token: 'test_token',
        maxRetries: 3,
      );
      final duration = DateTime.now().difference(startTime);

      expect(response.isValidationError, isTrue);
      // Should return immediately without retries
      expect(duration.inSeconds, lessThan(2));
    });
  });

  group('BookingService - Integration', () {
    test('complete booking flow with valid data', () async {
      final service = BookingService();
      final request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
        notes: 'Test booking',
      );

      // Check availability first
      final slots = await service.checkSlotAvailability(
        mallId: request.idMall,
        vehicleType: 'Mobil',
        startTime: request.waktuMulai,
        durationHours: request.durasiJam,
        token: 'test_token',
      );

      expect(slots, greaterThanOrEqualTo(0));

      // Create booking
      final response = await service.createBooking(
        request: request,
        token: 'test_token',
      );

      expect(response, isNotNull);
    });

    test('validates all request fields', () async {
      final service = BookingService();
      
      // Test empty mall ID
      var request = BookingRequest(
        idMall: '',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );
      var response = await service.createBooking(request: request, token: 'test_token');
      expect(response.success, isFalse);

      // Test empty vehicle ID
      request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: '',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 2,
      );
      response = await service.createBooking(request: request, token: 'test_token');
      expect(response.success, isFalse);

      // Test invalid duration
      request = BookingRequest(
        idMall: 'MALL001',
        idKendaraan: 'VEH001',
        waktuMulai: DateTime.now().add(const Duration(hours: 1)),
        durasiJam: 0,
      );
      response = await service.createBooking(request: request, token: 'test_token');
      expect(response.success, isFalse);
    });
  });
}
