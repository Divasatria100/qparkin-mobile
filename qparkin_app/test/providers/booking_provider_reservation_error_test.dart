import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';

/// Test suite for booking provider reservation error handling
///
/// Tests Requirements: 15.1-15.10 (Error Handling for Slot Reservation)
/// Validates: Task 12.4 - Add reservation errors
void main() {
  group('BookingProvider Reservation Error Handling', () {
    late BookingProvider provider;

    setUp(() {
      provider = BookingProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('getReservationErrorDetails returns correct details for NO_SLOTS_AVAILABLE', () {
      // Arrange
      provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Slot Tidak Tersedia');
      expect(details['message'], contains('Lantai 1'));
      expect(details['message'], contains('sudah terisi'));
      expect(details['floorName'], 'Lantai 1');
    });

    test('getReservationErrorDetails returns correct details for RESERVATION_TIMEOUT', () {
      // Arrange
      provider.setError('RESERVATION_TIMEOUT:Lantai 2');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Waktu Reservasi Habis');
      expect(details['message'], contains('Reservasi slot Anda telah berakhir'));
      expect(details['message'], contains('Lantai 2'));
      expect(details['floorName'], 'Lantai 2');
    });

    test('getReservationErrorDetails returns correct details for RESERVATION_EXPIRED', () {
      // Arrange
      provider.setError('RESERVATION_EXPIRED:Waktu reservasi telah habis');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Reservasi Kadaluarsa');
      expect(details['message'], contains('Waktu reservasi telah habis'));
    });

    test('getReservationErrorDetails returns correct details for RESERVATION_ERROR', () {
      // Arrange
      provider.setError('RESERVATION_ERROR:Koneksi bermasalah');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Gagal Mereservasi Slot');
      expect(details['message'], 'Koneksi bermasalah');
    });

    test('getReservationErrorDetails returns correct details for AUTH_ERROR', () {
      // Arrange
      provider.setError('AUTH_ERROR:Token expired');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Sesi Berakhir');
      expect(details['message'], contains('Sesi Anda telah berakhir'));
    });

    test('getReservationErrorDetails returns correct details for TIMEOUT_ERROR', () {
      // Arrange
      provider.setError('TIMEOUT_ERROR:Request timeout');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Koneksi Timeout');
      expect(details['message'], contains('Permintaan timeout'));
    });

    test('getReservationErrorDetails returns correct details for NETWORK_ERROR', () {
      // Arrange
      provider.setError('NETWORK_ERROR:No internet');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Koneksi Bermasalah');
      expect(details['message'], contains('Koneksi internet bermasalah'));
    });

    test('getReservationErrorDetails returns correct details for SERVER_ERROR', () {
      // Arrange
      provider.setError('SERVER_ERROR:Internal server error');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Kesalahan Server');
      expect(details['message'], contains('Terjadi kesalahan server'));
    });

    test('hasReservationError returns true for reservation errors', () {
      // Test NO_SLOTS_AVAILABLE
      provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');
      expect(provider.hasReservationError, true);

      // Test RESERVATION_TIMEOUT
      provider.setError('RESERVATION_TIMEOUT:Lantai 2');
      expect(provider.hasReservationError, true);

      // Test RESERVATION_EXPIRED
      provider.setError('RESERVATION_EXPIRED:Expired');
      expect(provider.hasReservationError, true);

      // Test RESERVATION_ERROR
      provider.setError('RESERVATION_ERROR:Failed');
      expect(provider.hasReservationError, true);
    });

    test('hasReservationError returns false for non-reservation errors', () {
      // Test null error
      provider.setError(null);
      expect(provider.hasReservationError, false);

      // Test other error
      provider.setError('NETWORK_ERROR:Connection failed');
      expect(provider.hasReservationError, false);
    });

    test('isReservationTimeout returns true for timeout errors', () {
      // Test RESERVATION_TIMEOUT
      provider.setError('RESERVATION_TIMEOUT:Lantai 1');
      expect(provider.isReservationTimeout, true);

      // Test RESERVATION_EXPIRED
      provider.setError('RESERVATION_EXPIRED:Expired');
      expect(provider.isReservationTimeout, true);
    });

    test('isReservationTimeout returns false for non-timeout errors', () {
      // Test null error
      provider.setError(null);
      expect(provider.isReservationTimeout, false);

      // Test other error
      provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');
      expect(provider.isReservationTimeout, false);
    });

    test('isNoSlotsAvailable returns true for no slots error', () {
      // Arrange
      provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');

      // Assert
      expect(provider.isNoSlotsAvailable, true);
    });

    test('isNoSlotsAvailable returns false for other errors', () {
      // Test null error
      provider.setError(null);
      expect(provider.isNoSlotsAvailable, false);

      // Test other error
      provider.setError('RESERVATION_TIMEOUT:Lantai 1');
      expect(provider.isNoSlotsAvailable, false);
    });

    test('reserveRandomSlot sets error when no floor selected', () async {
      // Arrange - no floor selected
      
      // Act
      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'user123',
      );

      // Assert
      expect(result, false);
      expect(provider.errorMessage, contains('RESERVATION_ERROR'));
      expect(provider.errorMessage, contains('pilih lantai'));
    });

    test('reserveRandomSlot sets error when no vehicle selected', () async {
      // Arrange
      final floor = ParkingFloorModel(
        idFloor: 'f1',
        idMall: 'm1',
        floorNumber: 1,
        floorName: 'Lantai 1',
        totalSlots: 50,
        availableSlots: 10,
        occupiedSlots: 40,
        reservedSlots: 0,
        lastUpdated: DateTime.now(),
      );
      
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
      provider.selectFloor(floor);

      // Act
      final result = await provider.reserveRandomSlot(
        token: 'test_token',
        userId: 'user123',
      );

      // Assert
      expect(result, false);
      expect(provider.errorMessage, contains('RESERVATION_ERROR'));
      expect(provider.errorMessage, contains('pilih kendaraan'));
    });

    test('selectFloor validates floor availability', () {
      // Arrange
      final floorNoSlots = ParkingFloorModel(
        idFloor: 'f1',
        idMall: 'm1',
        floorNumber: 1,
        floorName: 'Lantai 1',
        totalSlots: 50,
        availableSlots: 0, // No available slots
        occupiedSlots: 50,
        reservedSlots: 0,
        lastUpdated: DateTime.now(),
      );
      
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});

      // Act
      provider.selectFloor(floorNoSlots);

      // Assert
      expect(provider.selectedFloor, isNull); // Floor should not be selected
      expect(provider.errorMessage, contains('tidak memiliki slot tersedia'));
      expect(provider.errorMessage, contains('Lantai 1'));
    });

    test('getReservationErrorDetails handles unknown error codes', () {
      // Arrange
      provider.setError('UNKNOWN_CODE:Some error');

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Terjadi Kesalahan');
      expect(details['message'], 'UNKNOWN_CODE:Some error');
    });

    test('getReservationErrorDetails handles null error', () {
      // Arrange
      provider.setError(null);

      // Act
      final details = provider.getReservationErrorDetails();

      // Assert
      expect(details['title'], 'Error');
      expect(details['message'], contains('tidak diketahui'));
    });
  });
}
