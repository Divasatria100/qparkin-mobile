import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

/// Tests for feature flag implementation
///
/// Validates that the slot reservation feature flag works correctly
/// at both the model and provider levels.
///
/// Requirements: 17.1-17.9
void main() {
  group('Feature Flag Tests', () {
    test('MallModel parses feature flag correctly from boolean true', () {
      final json = {
        'id': 'mall_001',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 45,
        'has_slot_reservation_enabled': true,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, isTrue);
    });

    test('MallModel parses feature flag correctly from integer 1', () {
      final json = {
        'id': 'mall_002',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 45,
        'has_slot_reservation_enabled': 1,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, isTrue);
    });

    test('MallModel defaults feature flag to false when missing', () {
      final json = {
        'id': 'mall_003',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 45,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, isFalse);
    });

    test('MallModel parses feature flag as false from integer 0', () {
      final json = {
        'id': 'mall_004',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 45,
        'has_slot_reservation_enabled': 0,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, isFalse);
    });

    test('MallModel parses feature flag as false from boolean false', () {
      final json = {
        'id': 'mall_005',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 45,
        'has_slot_reservation_enabled': false,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, isFalse);
    });

    test('BookingProvider.isSlotReservationEnabled returns true when mall has feature enabled', () {
      final provider = BookingProvider();
      
      final mallData = {
        'id': 'mall_001',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'has_slot_reservation_enabled': true,
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, isTrue);
    });

    test('BookingProvider.isSlotReservationEnabled returns false when mall has feature disabled', () {
      final provider = BookingProvider();
      
      final mallData = {
        'id': 'mall_002',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'has_slot_reservation_enabled': false,
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, isFalse);
    });

    test('BookingProvider.isSlotReservationEnabled defaults to false when feature flag missing', () {
      final provider = BookingProvider();
      
      final mallData = {
        'id': 'mall_003',
        'name': 'Test Mall',
        'address': 'Jl. Test',
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, isFalse);
    });

    test('BookingProvider.isSlotReservationEnabled returns false when no mall selected', () {
      final provider = BookingProvider();

      expect(provider.isSlotReservationEnabled, isFalse);
    });

    test('BookingProvider.canConfirmBooking works without slot reservation', () {
      final provider = BookingProvider();
      
      // Initialize with mall that has feature disabled
      final mallData = {
        'id': 'mall_004',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'has_slot_reservation_enabled': false,
        'available': 10,
      };

      provider.initialize(mallData);

      // Select vehicle
      provider.selectVehicle({
        'id_kendaraan': 'v001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
      });

      // Set time and duration
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: 'test_token');
      provider.setDuration(const Duration(hours: 2), token: 'test_token');

      // Should be able to confirm without slot reservation
      expect(provider.canConfirmBooking, isTrue);
      expect(provider.hasReservedSlot, isFalse);
    });

    test('BookingProvider.canConfirmBooking works with slot reservation', () {
      final provider = BookingProvider();
      
      // Initialize with mall that has feature enabled
      final mallData = {
        'id': 'mall_005',
        'name': 'Test Mall',
        'address': 'Jl. Test',
        'has_slot_reservation_enabled': true,
        'available': 10,
      };

      provider.initialize(mallData);

      // Select vehicle
      provider.selectVehicle({
        'id_kendaraan': 'v001',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
      });

      // Set time and duration
      provider.setStartTime(DateTime.now().add(const Duration(hours: 1)), token: 'test_token');
      provider.setDuration(const Duration(hours: 2), token: 'test_token');

      // Should be able to confirm even without slot reservation (optional)
      expect(provider.canConfirmBooking, isTrue);
      expect(provider.hasReservedSlot, isFalse);
    });
  });
}
