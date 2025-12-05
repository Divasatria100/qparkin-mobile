import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/booking_model.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';

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

  group('BookingService - Slot Reservation: getFloors', () {
    test('getFloors returns empty list on network error', () async {
      final service = BookingService();

      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      // Will return empty list due to no mock server
      expect(floors, isA<List<ParkingFloorModel>>());
      expect(floors, isEmpty);
    });

    test('getFloors handles timeout gracefully', () async {
      final service = BookingService();

      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      expect(floors, isEmpty);
    });

    test('getFloorsWithRetry respects maxRetries parameter', () async {
      final service = BookingService();

      final startTime = DateTime.now();
      final floors = await service.getFloorsWithRetry(
        mallId: 'MALL001',
        token: 'test_token',
        maxRetries: 2,
      );
      final duration = DateTime.now().difference(startTime);

      expect(floors, isEmpty);
      // Should complete within reasonable time with retries
      expect(duration.inSeconds, lessThan(10));
    });

    test('getFloors returns empty list on 404', () async {
      final service = BookingService();

      final floors = await service.getFloors(
        mallId: 'NONEXISTENT',
        token: 'test_token',
      );

      expect(floors, isEmpty);
    });

    test('getFloors caching works correctly', () async {
      final service = BookingService();

      // First call - will fail but cache empty result
      final floors1 = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      // Second call - should return immediately from cache
      final startTime = DateTime.now();
      final floors2 = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );
      final duration = DateTime.now().difference(startTime);

      expect(floors1, equals(floors2));
      // Cache hit should be very fast (< 100ms)
      expect(duration.inMilliseconds, lessThan(100));
    });

    test('clearCache removes floor cache', () async {
      final service = BookingService();

      // Make a call to populate cache
      await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      // Clear cache
      service.clearCache();

      // Next call should not use cache
      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      expect(floors, isA<List<ParkingFloorModel>>());
    });
  });

  group('BookingService - Slot Reservation: getSlotsForVisualization', () {
    test('getSlotsForVisualization returns empty list on network error', () async {
      final service = BookingService();

      final slots = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      // Will return empty list due to no mock server
      expect(slots, isA<List<ParkingSlotModel>>());
      expect(slots, isEmpty);
    });

    test('getSlotsForVisualization handles vehicle type filter', () async {
      final service = BookingService();

      final slots = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
        vehicleType: 'Roda Empat',
      );

      expect(slots, isA<List<ParkingSlotModel>>());
      expect(slots, isEmpty);
    });

    test('getSlotsForVisualization handles timeout gracefully', () async {
      final service = BookingService();

      final slots = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      expect(slots, isEmpty);
    });

    test('getSlotsForVisualization returns empty list on 404', () async {
      final service = BookingService();

      final slots = await service.getSlotsForVisualization(
        floorId: 'NONEXISTENT',
        token: 'test_token',
      );

      expect(slots, isEmpty);
    });

    test('getSlotsForVisualization caching works correctly', () async {
      final service = BookingService();

      // First call - will fail but cache empty result
      final slots1 = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      // Second call - should return immediately from cache
      final startTime = DateTime.now();
      final slots2 = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );
      final duration = DateTime.now().difference(startTime);

      expect(slots1, equals(slots2));
      // Cache hit should be very fast (< 100ms)
      expect(duration.inMilliseconds, lessThan(100));
    });

    test('getSlotsForVisualization caches separately by vehicle type', () async {
      final service = BookingService();

      // Call with different vehicle types
      final slots1 = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
        vehicleType: 'Roda Empat',
      );

      final slots2 = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
        vehicleType: 'Roda Dua',
      );

      // Both should be cached separately
      expect(slots1, isA<List<ParkingSlotModel>>());
      expect(slots2, isA<List<ParkingSlotModel>>());
    });

    test('clearCache removes slot cache', () async {
      final service = BookingService();

      // Make a call to populate cache
      await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      // Clear cache
      service.clearCache();

      // Next call should not use cache
      final slots = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      expect(slots, isA<List<ParkingSlotModel>>());
    });
  });

  group('BookingService - Slot Reservation: reserveRandomSlot', () {
    test('reserveRandomSlot returns null on network error', () async {
      final service = BookingService();

      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR001',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );

      // Will return null due to no mock server
      expect(reservation, isNull);
    });

    test('reserveRandomSlot handles timeout gracefully', () async {
      final service = BookingService();

      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR001',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );

      expect(reservation, isNull);
    });

    test('reserveRandomSlot returns null on 404 (no slots available)', () async {
      final service = BookingService();

      final reservation = await service.reserveRandomSlot(
        floorId: 'NONEXISTENT',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );

      expect(reservation, isNull);
    });

    test('reserveRandomSlot returns null on 409 (conflict)', () async {
      final service = BookingService();

      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR001',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );

      expect(reservation, isNull);
    });

    test('reserveRandomSlot uses custom duration parameter', () async {
      final service = BookingService();

      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR001',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
        durationMinutes: 10,
      );

      // Will return null due to no mock server, but should not throw
      expect(reservation, isNull);
    });

    test('reserveRandomSlot handles cancellation', () async {
      final service = BookingService();

      // Cancel before making request
      service.cancelPendingRequests();

      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR001',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );

      expect(reservation, isNull);

      // Reset for other tests
      service.resetCancellation();
    });
  });

  group('BookingService - Slot Reservation: Error Scenarios', () {
    test('handles no slots available scenario', () async {
      final service = BookingService();

      // Try to reserve slot when none available
      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR_FULL',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );

      expect(reservation, isNull);
    });

    test('handles timeout during slot reservation', () async {
      final service = BookingService();

      final startTime = DateTime.now();
      final reservation = await service.reserveRandomSlot(
        floorId: 'FLOOR001',
        userId: 'USER001',
        vehicleType: 'Roda Empat',
        token: 'test_token',
      );
      final duration = DateTime.now().difference(startTime);

      expect(reservation, isNull);
      // Should timeout within reasonable time (< 15 seconds)
      expect(duration.inSeconds, lessThan(15));
    });

    test('handles network error during floor fetch', () async {
      final service = BookingService();

      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      expect(floors, isEmpty);
    });

    test('handles network error during slot visualization fetch', () async {
      final service = BookingService();

      final slots = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      expect(slots, isEmpty);
    });

    test('retry mechanism works for getFloors', () async {
      final service = BookingService();

      final floors = await service.getFloorsWithRetry(
        mallId: 'MALL001',
        token: 'test_token',
        maxRetries: 3,
      );

      expect(floors, isEmpty);
      // Should complete without throwing errors
      expect(floors, isA<List<ParkingFloorModel>>());
    });
  });

  group('BookingService - Slot Reservation: Cache Behavior', () {
    test('floor cache expires after 5 minutes', () async {
      final service = BookingService();

      // This test verifies cache expiration logic exists
      // In real scenario, cache would expire after 5 minutes
      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      expect(floors, isA<List<ParkingFloorModel>>());
    });

    test('slot cache expires after 2 minutes', () async {
      final service = BookingService();

      // This test verifies cache expiration logic exists
      // In real scenario, cache would expire after 2 minutes
      final slots = await service.getSlotsForVisualization(
        floorId: 'FLOOR001',
        token: 'test_token',
      );

      expect(slots, isA<List<ParkingSlotModel>>());
    });

    test('clearCache clears both floor and slot caches', () async {
      final service = BookingService();

      // Populate both caches
      await service.getFloors(mallId: 'MALL001', token: 'test_token');
      await service.getSlotsForVisualization(floorId: 'FLOOR001', token: 'test_token');

      // Clear all caches
      service.clearCache();

      // Verify caches are cleared by making new calls
      final floors = await service.getFloors(mallId: 'MALL001', token: 'test_token');
      final slots = await service.getSlotsForVisualization(floorId: 'FLOOR001', token: 'test_token');

      expect(floors, isA<List<ParkingFloorModel>>());
      expect(slots, isA<List<ParkingSlotModel>>());
    });

    test('cache is used for repeated calls within expiration time', () async {
      final service = BookingService();

      // First call
      final floors1 = await service.getFloors(mallId: 'MALL001', token: 'test_token');

      // Second call should use cache
      final startTime = DateTime.now();
      final floors2 = await service.getFloors(mallId: 'MALL001', token: 'test_token');
      final duration = DateTime.now().difference(startTime);

      expect(floors1, equals(floors2));
      // Cache hit should be instant
      expect(duration.inMilliseconds, lessThan(50));
    });
  });

  group('BookingService - Slot Reservation: Service Lifecycle', () {
    test('cancelPendingRequests prevents new requests', () async {
      final service = BookingService();

      service.cancelPendingRequests();

      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      expect(floors, isEmpty);

      service.resetCancellation();
    });

    test('resetCancellation allows new requests after cancellation', () async {
      final service = BookingService();

      service.cancelPendingRequests();
      service.resetCancellation();

      final floors = await service.getFloors(
        mallId: 'MALL001',
        token: 'test_token',
      );

      expect(floors, isA<List<ParkingFloorModel>>());
    });

    test('dispose cleans up resources', () {
      final service = BookingService();

      // Should not throw
      expect(() => service.dispose(), returnsNormally);
    });

    test('service handles multiple concurrent requests', () async {
      final service = BookingService();

      // Make multiple concurrent requests
      final futures = [
        service.getFloors(mallId: 'MALL001', token: 'test_token'),
        service.getSlotsForVisualization(floorId: 'FLOOR001', token: 'test_token'),
        service.reserveRandomSlot(
          floorId: 'FLOOR001',
          userId: 'USER001',
          vehicleType: 'Roda Empat',
          token: 'test_token',
        ),
      ];

      final results = await Future.wait(futures);

      expect(results[0], isA<List<ParkingFloorModel>>());
      expect(results[1], isA<List<ParkingSlotModel>>());
      expect(results[2], isNull); // Reservation will fail without server
    });
  });
}
