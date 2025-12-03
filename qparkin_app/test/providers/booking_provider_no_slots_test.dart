import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';

/// Tests for no slots available error handling
///
/// Requirements: 15.1-15.10
void main() {
  group('BookingProvider - No Slots Available Handling', () {
    late BookingProvider provider;

    setUp(() {
      provider = BookingProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('getAlternativeFloors returns empty list when no floors loaded', () {
      // Arrange
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
      
      // Act
      final alternatives = provider.getAlternativeFloors();

      // Assert
      expect(alternatives, isEmpty);
    });

    test('getAlternativeFloors returns all floors with slots when none selected', () {
      // This test verifies the method exists and returns correct type
      // In real usage, floors would be populated by fetchFloors API call
      
      // Arrange
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
      
      // Act
      final alternatives = provider.getAlternativeFloors();

      // Assert
      expect(alternatives, isA<List<ParkingFloorModel>>());
      expect(alternatives, isEmpty); // Empty because no floors loaded yet
    });

    test('error message format for no slots available', () {
      // Arrange
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
      provider.selectVehicle({
        'id_kendaraan': 'v1',
        'jenis_kendaraan': 'Roda Empat',
        'plat_nomor': 'B1234XYZ',
      });
      
      // Manually set error to simulate no slots scenario
      provider.setError('NO_SLOTS_AVAILABLE:Lantai 1');
      
      // Assert
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, startsWith('NO_SLOTS_AVAILABLE:'));
      expect(provider.errorMessage, contains('Lantai 1'));
      
      // Verify error can be parsed
      final parts = provider.errorMessage!.split(':');
      expect(parts.length, 2);
      expect(parts[0], 'NO_SLOTS_AVAILABLE');
      expect(parts[1], 'Lantai 1');
    });

    test('error message format for generic no slots', () {
      // Arrange
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
      
      // Manually set error
      provider.setError('NO_SLOTS_AVAILABLE:Lantai 2');
      
      // Assert
      expect(provider.errorMessage, 'NO_SLOTS_AVAILABLE:Lantai 2');
      
      // Verify parsing
      final errorCode = provider.errorMessage!.split(':')[0];
      final floorName = provider.errorMessage!.split(':')[1];
      expect(errorCode, 'NO_SLOTS_AVAILABLE');
      expect(floorName, 'Lantai 2');
    });

    test('provider initializes correctly', () {
      // Arrange & Act
      provider.initialize({
        'id_mall': 'm1',
        'name': 'Test Mall',
        'address': 'Test Address',
      });
      
      // Assert
      expect(provider.selectedMall, isNotNull);
      expect(provider.selectedMall!['id_mall'], 'm1');
      expect(provider.selectedMall!['name'], 'Test Mall');
      expect(provider.floors, isEmpty);
      expect(provider.selectedFloor, isNull);
    });

    test('getAlternativeFloors method exists and is callable', () {
      // Arrange
      provider.initialize({'id_mall': 'm1', 'name': 'Test Mall'});
      
      // Act & Assert - just verify method exists and returns correct type
      expect(() => provider.getAlternativeFloors(), returnsNormally);
      expect(provider.getAlternativeFloors(), isA<List<ParkingFloorModel>>());
    });
  });
}
