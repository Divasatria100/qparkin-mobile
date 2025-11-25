import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/data/models/booking_request.dart';
import 'package:qparkin_app/data/models/booking_response.dart';
import 'package:qparkin_app/data/models/booking_model.dart';

/// Mock BookingService for testing booking conflict detection
class MockBookingService extends BookingService {
  bool _hasActiveBooking = false;
  bool _shouldSucceed = true;

  void setHasActiveBooking(bool value) {
    _hasActiveBooking = value;
  }

  void setShouldSucceed(bool value) {
    _shouldSucceed = value;
  }

  @override
  Future<bool> checkActiveBooking({required String token}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _hasActiveBooking;
  }

  @override
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_shouldSucceed) {
      return BookingResponse.error(
        message: 'Anda sudah memiliki booking aktif',
        errorCode: 'BOOKING_CONFLICT',
      );
    }

    final booking = BookingModel(
      idTransaksi: 'TRX001',
      idBooking: 'BKG001',
      idMall: request.idMall,
      idParkiran: 'PRK001',
      idKendaraan: request.idKendaraan,
      qrCode: 'QR123456',
      waktuMulai: request.waktuMulai,
      waktuSelesai: request.waktuMulai.add(Duration(hours: request.durasiJam)),
      durasiBooking: request.durasiJam,
      status: 'aktif',
      biayaEstimasi: 15000.0,
      dibookingPada: DateTime.now(),
    );

    return BookingResponse.success(
      message: 'Booking berhasil',
      booking: booking,
      qrCode: 'QR123456',
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
}

void main() {
  group('Booking Conflict Detection Tests', () {
    late BookingProvider provider;
    late MockBookingService mockService;

    setUp(() {
      mockService = MockBookingService();
      provider = BookingProvider(bookingService: mockService);
    });

    tearDown(() {
      provider.dispose();
    });

    test('hasActiveBooking returns true when user has active booking', () async {
      // Arrange
      mockService.setHasActiveBooking(true);

      // Act
      final hasActive = await provider.hasActiveBooking(token: 'test_token');

      // Assert
      expect(hasActive, true);
    });

    test('hasActiveBooking returns false when user has no active booking', () async {
      // Arrange
      mockService.setHasActiveBooking(false);

      // Act
      final hasActive = await provider.hasActiveBooking(token: 'test_token');

      // Assert
      expect(hasActive, false);
    });

    test('confirmBooking fails when user has active booking', () async {
      // Arrange
      mockService.setHasActiveBooking(true);
      mockService.setShouldSucceed(false);

      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
        'address': 'Test Address',
        'distance': '1 km',
        'available': 10,
      });

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      });

      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final success = await provider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: false,
      );

      // Assert
      expect(success, false);
      expect(provider.errorMessage, contains('booking aktif'));
    });

    test('confirmBooking succeeds when user has no active booking', () async {
      // Arrange
      mockService.setHasActiveBooking(false);
      mockService.setShouldSucceed(true);

      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
        'address': 'Test Address',
        'distance': '1 km',
        'available': 10,
      });

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      });

      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final success = await provider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: false,
      );

      // Assert
      expect(success, true);
      expect(provider.errorMessage, isNull);
      expect(provider.createdBooking, isNotNull);
    });

    test('confirmBooking can skip active check when skipActiveCheck is true', () async {
      // Arrange
      mockService.setHasActiveBooking(true); // User has active booking
      mockService.setShouldSucceed(true); // But we allow creation

      provider.initialize({
        'id_mall': 'MALL001',
        'name': 'Test Mall',
        'address': 'Test Address',
        'distance': '1 km',
        'available': 10,
      });

      provider.selectVehicle({
        'id_kendaraan': 'VEH001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      });

      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)));
      provider.setDuration(const Duration(hours: 2));
      provider.setAvailableSlots(5);

      // Act
      final success = await provider.confirmBooking(
        token: 'test_token',
        skipActiveCheck: true, // Skip the check
      );

      // Assert
      expect(success, true);
      expect(provider.createdBooking, isNotNull);
    });

    test('hasActiveBooking handles errors gracefully', () async {
      // Arrange
      // Create a service that throws an error
      final errorService = _ErrorThrowingBookingService();
      final errorProvider = BookingProvider(bookingService: errorService);

      // Act
      final hasActive = await errorProvider.hasActiveBooking(token: 'test_token');

      // Assert
      // Should return false on error to allow user to proceed
      expect(hasActive, false);

      errorProvider.dispose();
    });
  });
}

/// Mock service that throws errors for testing error handling
class _ErrorThrowingBookingService extends BookingService {
  @override
  Future<bool> checkActiveBooking({required String token}) async {
    throw Exception('Network error');
  }
}
