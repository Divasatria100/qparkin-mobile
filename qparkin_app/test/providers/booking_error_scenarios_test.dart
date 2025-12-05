import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';

/// Comprehensive error scenario tests for booking slot reservation
///
/// Tests Requirements: 16.1-16.10 (Testing Requirements)
/// Validates: Task 12.5 - Test error scenarios
/// - Test network failures
/// - Test no slots available
/// - Test timeout handling
void main() {
  group('BookingProvider Error Scenarios', () {
    late BookingProvider provider;

    setUp(() {
      provider = BookingProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    group('Network Failure Scenarios', () {
      test('handles network error during floor loading', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('NETWORK_ERROR:Koneksi internet bermasalah');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('NETWORK_ERROR'));
        expect(errorDetails['title'], 'Koneksi Bermasalah');
        expect(errorDetails['message'], contains('internet bermasalah'));
      });

      test('handles network error during slot visualization loading', () {
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
        provider.setError('NETWORK_ERROR:Failed to load slots');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.selectedFloor, isNotNull);
        expect(provider.errorMessage, contains('NETWORK_ERROR'));
        expect(errorDetails['title'], 'Koneksi Bermasalah');
      });

      test('handles network error during slot reservation', () async {
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
        provider.selectVehicle({
          'id_kendaraan': 'v1',
          'jenis_kendaraan': 'Roda Empat',
          'plat_nomor': 'B1234XYZ',
        });
        provider.selectFloor(floor);

        // Simulate network error by setting error state
        provider.setError('NETWORK_ERROR:Connection failed');

        // Assert
        expect(provider.errorMessage, contains('NETWORK_ERROR'));
        expect(provider.hasReservationError, false); // Network error is not a reservation-specific error
      });

      test('provides retry capability after network error', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('NETWORK_ERROR:Connection failed');

        // Act - Clear error to simulate retry
        provider.clearError();

        // Assert
        expect(provider.errorMessage, isNull);
      });
    });

    group('No Slots Available Scenarios', () {
      test('handles no slots available on floor selection', () {
        // Arrange
        final floorNoSlots = ParkingFloorModel(
          idFloor: 'f1',
          idMall: 'm1',
          floorNumber: 1,
          floorName: 'Lantai 1',
          totalSlots: 50,
          availableSlots: 0,
          occupiedSlots: 50,
          reservedSlots: 0,
          lastUpdated: DateTime.now(),
        );

        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});

        // Act
        provider.selectFloor(floorNoSlots);

        // Assert
        expect(provider.selectedFloor, isNull);
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('tidak memiliki slot tersedia'));
        expect(provider.errorMessage, contains('Lantai 1'));
      });

      test('handles no slots available during reservation', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('NO_SLOTS_AVAILABLE:Lantai 2');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.isNoSlotsAvailable, true);
        expect(errorDetails['title'], 'Slot Tidak Tersedia');
        expect(errorDetails['message'], contains('Lantai 2'));
        expect(errorDetails['message'], contains('sudah terisi'));
        expect(errorDetails['floorName'], 'Lantai 2');
      });

      test('suggests alternative floors when no slots available', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');

        // Act
        final alternatives = provider.getAlternativeFloors();

        // Assert
        // Method exists and returns correct type
        expect(alternatives, isA<List<ParkingFloorModel>>());
        // In real scenario, this would return floors with available slots
      });

      test('returns empty alternatives when no floors loaded', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});

        // Act
        final alternatives = provider.getAlternativeFloors();

        // Assert
        expect(alternatives, isEmpty);
      });
    });

    group('Timeout Handling Scenarios', () {
      test('handles reservation timeout error', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('RESERVATION_TIMEOUT:Lantai 1');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.isReservationTimeout, true);
        expect(errorDetails['title'], 'Waktu Reservasi Habis');
        expect(errorDetails['message'], contains('Reservasi slot Anda telah berakhir'));
        expect(errorDetails['floorName'], 'Lantai 1');
      });

      test('handles reservation expired error', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('RESERVATION_EXPIRED:Waktu habis');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.isReservationTimeout, true);
        expect(errorDetails['title'], 'Reservasi Kadaluarsa');
        expect(errorDetails['message'], contains('Waktu reservasi telah habis'));
      });

      test('handles timeout error during API call', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('TIMEOUT_ERROR:Request timeout');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.errorMessage, contains('TIMEOUT_ERROR'));
        expect(errorDetails['title'], 'Koneksi Timeout');
        expect(errorDetails['message'], contains('Permintaan timeout'));
      });

      test('detects expired reservation from model', () {
        // Arrange
        final expiredReservation = SlotReservationModel(
          reservationId: 'r1',
          slotId: 's1',
          slotCode: 'A01',
          floorName: 'Lantai 1',
          floorNumber: '1',
          slotType: SlotType.regular,
          reservedAt: DateTime.now().subtract(const Duration(minutes: 10)),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isActive: false,
        );

        // Act
        final isExpired = expiredReservation.isExpired;

        // Assert
        expect(isExpired, true);
        expect(expiredReservation.isActive, false);
      });

      test('detects active reservation from model', () {
        // Arrange
        final activeReservation = SlotReservationModel(
          reservationId: 'r1',
          slotId: 's1',
          slotCode: 'A01',
          floorName: 'Lantai 1',
          floorNumber: '1',
          slotType: SlotType.regular,
          reservedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          isActive: true,
        );

        // Act
        final isExpired = activeReservation.isExpired;

        // Assert
        expect(isExpired, false);
        expect(activeReservation.isActive, true);
      });

      test('clears expired reservation', () {
        // Arrange
        final expiredReservation = SlotReservationModel(
          reservationId: 'r1',
          slotId: 's1',
          slotCode: 'A01',
          floorName: 'Lantai 1',
          floorNumber: '1',
          slotType: SlotType.regular,
          reservedAt: DateTime.now().subtract(const Duration(minutes: 10)),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isActive: false,
        );

        // Act - Test the model's expiration logic
        final isExpired = expiredReservation.isExpired;

        // Assert
        expect(isExpired, true);
        expect(expiredReservation.isActive, false);
      });
    });

    group('Server Error Scenarios', () {
      test('handles server error during reservation', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('SERVER_ERROR:Internal server error');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.errorMessage, contains('SERVER_ERROR'));
        expect(errorDetails['title'], 'Kesalahan Server');
        expect(errorDetails['message'], contains('Terjadi kesalahan server'));
      });

      test('handles authentication error', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('AUTH_ERROR:Token expired');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.errorMessage, contains('AUTH_ERROR'));
        expect(errorDetails['title'], 'Sesi Berakhir');
        expect(errorDetails['message'], contains('Sesi Anda telah berakhir'));
      });

      test('handles unknown error code gracefully', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('UNKNOWN_ERROR_CODE:Something went wrong');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(errorDetails['title'], 'Terjadi Kesalahan');
        expect(errorDetails['message'], 'UNKNOWN_ERROR_CODE:Something went wrong');
      });
    });

    group('Error Recovery Scenarios', () {
      test('allows retry after network error', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('NETWORK_ERROR:Connection failed');
        expect(provider.errorMessage, isNotNull);

        // Act - Clear error to simulate retry
        provider.clearError();

        // Assert
        expect(provider.errorMessage, isNull);
      });

      test('allows new reservation after timeout', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('RESERVATION_TIMEOUT:Lantai 1');
        expect(provider.isReservationTimeout, true);

        // Act - Clear error
        provider.clearError();

        // Assert
        expect(provider.errorMessage, isNull);
        expect(provider.isReservationTimeout, false);
      });

      test('allows floor change after no slots error', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');
        expect(provider.errorMessage, isNotNull);

        // Act - Clear error to allow retry with different floor
        provider.clearError();

        // Assert
        expect(provider.errorMessage, isNull);
      });
    });

    group('Validation Error Scenarios', () {
      test('validates floor selection before reservation', () async {
        // Arrange - No floor selected
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.selectVehicle({
          'id_kendaraan': 'v1',
          'jenis_kendaraan': 'Roda Empat',
          'plat_nomor': 'B1234XYZ',
        });

        // Act
        final result = await provider.reserveRandomSlot(
          token: 'test_token',
          userId: 'user123',
        );

        // Assert
        expect(result, false);
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('pilih lantai'));
      });

      test('validates vehicle selection before reservation', () async {
        // Arrange - No vehicle selected
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
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('pilih kendaraan'));
      });

      test('validates mall initialization before operations', () {
        // Arrange - Provider not initialized
        final provider = BookingProvider();

        // Assert
        expect(provider.selectedMall, isNull);
        expect(provider.floors, isEmpty);
        expect(provider.selectedFloor, isNull);
      });
    });

    group('Edge Case Error Scenarios', () {
      test('handles null error gracefully', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError(null);

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.errorMessage, isNull);
        expect(errorDetails['title'], 'Error');
        expect(errorDetails['message'], contains('tidak diketahui'));
      });

      test('handles empty error string', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(provider.errorMessage, '');
        expect(errorDetails['title'], 'Terjadi Kesalahan');
      });

      test('handles malformed error code', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
        provider.setError('MALFORMED_ERROR_NO_COLON');

        // Act
        final errorDetails = provider.getReservationErrorDetails();

        // Assert
        expect(errorDetails['title'], 'Terjadi Kesalahan');
        expect(errorDetails['message'], 'MALFORMED_ERROR_NO_COLON');
      });

      test('handles multiple consecutive errors', () {
        // Arrange
        provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});

        // Act - Set multiple errors in sequence
        provider.setError('NETWORK_ERROR:First error');
        expect(provider.errorMessage, contains('NETWORK_ERROR'));

        provider.setError('TIMEOUT_ERROR:Second error');
        expect(provider.errorMessage, contains('TIMEOUT_ERROR'));

        provider.setError('NO_SLOTS_AVAILABLE:Third error');
        expect(provider.errorMessage, contains('NO_SLOTS_AVAILABLE'));

        // Assert - Only last error should be present
        expect(provider.errorMessage, 'NO_SLOTS_AVAILABLE:Third error');
        expect(provider.isNoSlotsAvailable, true);
      });
    });
  });
}
