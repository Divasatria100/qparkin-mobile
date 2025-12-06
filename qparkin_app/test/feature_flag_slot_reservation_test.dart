import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

/// Test suite for slot reservation feature flag functionality
///
/// Verifies that:
/// - MallModel correctly parses has_slot_reservation_enabled field
/// - BookingProvider correctly checks feature flag
/// - UI behavior matches feature flag state
///
/// Requirements: 17.1-17.9
void main() {
  group('MallModel Feature Flag', () {
    test('should parse has_slot_reservation_enabled as true from boolean', () {
      final json = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'lokasi': 'Test Location',
        'latitude': 1.0,
        'longitude': 104.0,
        'kapasitas': 100,
        'has_slot_reservation_enabled': true,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, true);
    });

    test('should parse has_slot_reservation_enabled as true from int 1', () {
      final json = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'lokasi': 'Test Location',
        'latitude': 1.0,
        'longitude': 104.0,
        'kapasitas': 100,
        'has_slot_reservation_enabled': 1,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, true);
    });

    test('should parse has_slot_reservation_enabled as false from boolean', () {
      final json = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'lokasi': 'Test Location',
        'latitude': 1.0,
        'longitude': 104.0,
        'kapasitas': 100,
        'has_slot_reservation_enabled': false,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, false);
    });

    test('should parse has_slot_reservation_enabled as false from int 0', () {
      final json = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'lokasi': 'Test Location',
        'latitude': 1.0,
        'longitude': 104.0,
        'kapasitas': 100,
        'has_slot_reservation_enabled': 0,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, false);
    });

    test('should default to false when field is missing', () {
      final json = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'lokasi': 'Test Location',
        'latitude': 1.0,
        'longitude': 104.0,
        'kapasitas': 100,
        // has_slot_reservation_enabled is missing
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, false);
    });

    test('should default to false when field is null', () {
      final json = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'lokasi': 'Test Location',
        'latitude': 1.0,
        'longitude': 104.0,
        'kapasitas': 100,
        'has_slot_reservation_enabled': null,
      };

      final mall = MallModel.fromJson(json);

      expect(mall.hasSlotReservationEnabled, false);
    });

    test('should include feature flag in toJson', () {
      final mall = MallModel(
        id: '1',
        name: 'Test Mall',
        address: 'Test Location',
        latitude: 1.0,
        longitude: 104.0,
        availableSlots: 100,
        hasSlotReservationEnabled: true,
      );

      final json = mall.toJson();

      expect(json['has_slot_reservation_enabled'], true);
    });

    test('should preserve feature flag in copyWith', () {
      final mall = MallModel(
        id: '1',
        name: 'Test Mall',
        address: 'Test Location',
        latitude: 1.0,
        longitude: 104.0,
        availableSlots: 100,
        hasSlotReservationEnabled: true,
      );

      final copied = mall.copyWith(availableSlots: 50);

      expect(copied.hasSlotReservationEnabled, true);
      expect(copied.availableSlots, 50);
    });

    test('should update feature flag in copyWith', () {
      final mall = MallModel(
        id: '1',
        name: 'Test Mall',
        address: 'Test Location',
        latitude: 1.0,
        longitude: 104.0,
        availableSlots: 100,
        hasSlotReservationEnabled: false,
      );

      final copied = mall.copyWith(hasSlotReservationEnabled: true);

      expect(copied.hasSlotReservationEnabled, true);
    });
  });

  group('BookingProvider Feature Flag', () {
    test('should return false when mall is null', () {
      final provider = BookingProvider();

      expect(provider.isSlotReservationEnabled, false);
    });

    test('should return true when mall has feature enabled (boolean)', () {
      final provider = BookingProvider();
      final mallData = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'has_slot_reservation_enabled': true,
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, true);
    });

    test('should return true when mall has feature enabled (int 1)', () {
      final provider = BookingProvider();
      final mallData = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'has_slot_reservation_enabled': 1,
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, true);
    });

    test('should return false when mall has feature disabled (boolean)', () {
      final provider = BookingProvider();
      final mallData = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'has_slot_reservation_enabled': false,
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, false);
    });

    test('should return false when mall has feature disabled (int 0)', () {
      final provider = BookingProvider();
      final mallData = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'has_slot_reservation_enabled': 0,
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, false);
    });

    test('should return false when field is missing', () {
      final provider = BookingProvider();
      final mallData = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        // has_slot_reservation_enabled is missing
      };

      provider.initialize(mallData);

      expect(provider.isSlotReservationEnabled, false);
    });

    test('should allow booking even when feature is disabled', () {
      final provider = BookingProvider();
      final mallData = {
        'id_mall': '1',
        'nama_mall': 'Test Mall',
        'has_slot_reservation_enabled': false,
      };

      provider.initialize(mallData);

      // Feature disabled but booking should still be possible
      expect(provider.isSlotReservationEnabled, false);
      
      // canConfirmBooking should not require slot reservation
      // (it's optional based on feature flag)
      expect(provider.selectedMall, isNotNull);
    });
  });

  group('Feature Flag Integration', () {
    test('should handle mall data from API format', () {
      // Simulate API response format
      final apiResponse = {
        'id_mall': 1,
        'nama_mall': 'Mega Mall Batam Centre',
        'lokasi': 'Jl. Engku Putri no.1, Batam Centre',
        'kapasitas': 200,
        'alamat_gmaps': 'https://maps.google.com/?q=1.1191,104.0538',
        'has_slot_reservation_enabled': true,
      };

      final mall = MallModel.fromJson(apiResponse);

      expect(mall.id, '1');
      expect(mall.name, 'Mega Mall Batam Centre');
      expect(mall.hasSlotReservationEnabled, true);
    });

    test('should handle mall data from home page format', () {
      // Simulate home page mock data format
      final homePageData = {
        'id_mall': '1',
        'name': 'Mega Mall Batam Centre',
        'nama_mall': 'Mega Mall Batam Centre',
        'address': 'Jl. Engku Putri no.1, Batam Centre',
        'alamat': 'Jl. Engku Putri no.1, Batam Centre',
        'available': 45,
        'has_slot_reservation_enabled': true,
      };

      final provider = BookingProvider();
      provider.initialize(homePageData);

      expect(provider.isSlotReservationEnabled, true);
      expect(provider.selectedMall, isNotNull);
    });

    test('should handle gradual rollout scenario', () {
      // Mall 1: Feature enabled
      final mall1Data = {
        'id_mall': '1',
        'nama_mall': 'Mega Mall Batam Centre',
        'has_slot_reservation_enabled': true,
      };

      // Mall 2: Feature disabled
      final mall2Data = {
        'id_mall': '2',
        'nama_mall': 'SNL Food Bengkong',
        'has_slot_reservation_enabled': false,
      };

      final provider1 = BookingProvider();
      provider1.initialize(mall1Data);

      final provider2 = BookingProvider();
      provider2.initialize(mall2Data);

      expect(provider1.isSlotReservationEnabled, true);
      expect(provider2.isSlotReservationEnabled, false);
    });
  });

  group('Backward Compatibility', () {
    test('should handle old mall data without feature flag', () {
      // Old mall data format (before feature flag was added)
      final oldMallData = {
        'id_mall': '1',
        'nama_mall': 'Old Mall',
        'lokasi': 'Old Location',
        'kapasitas': 100,
        // No has_slot_reservation_enabled field
      };

      final provider = BookingProvider();
      provider.initialize(oldMallData);

      // Should default to false (feature disabled)
      expect(provider.isSlotReservationEnabled, false);
      
      // But booking should still work
      expect(provider.selectedMall, isNotNull);
    });

    test('should handle mixed data sources', () {
      // Some malls have feature flag, some don't
      final malls = [
        {
          'id_mall': '1',
          'nama_mall': 'New Mall',
          'has_slot_reservation_enabled': true,
        },
        {
          'id_mall': '2',
          'nama_mall': 'Old Mall',
          // No feature flag
        },
      ];

      final provider1 = BookingProvider();
      provider1.initialize(malls[0]);

      final provider2 = BookingProvider();
      provider2.initialize(malls[1]);

      expect(provider1.isSlotReservationEnabled, true);
      expect(provider2.isSlotReservationEnabled, false);
    });
  });
}
