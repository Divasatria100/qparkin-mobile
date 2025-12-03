import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/mall_model.dart';

void main() {
  group('MallModel Property-Based Tests', () {
    // Property 2: Round trip consistency
    // Feature: osm-map-integration, Property 2: Round trip consistency
    // Validates: Requirements 7.3
    test('Round trip consistency - serializing then deserializing should produce equivalent object', () {
      // Run 100 iterations as specified in the design document
      for (int i = 0; i < 100; i++) {
        // Generate random mall model
        final original = _generateRandomMall();

        // Serialize to JSON
        final json = original.toJson();

        // Deserialize back to model
        final restored = MallModel.fromJson(json);

        // Verify all fields are preserved
        expect(restored.id, equals(original.id),
            reason: 'ID should be preserved in round trip');
        expect(restored.name, equals(original.name),
            reason: 'Name should be preserved in round trip');
        expect(restored.address, equals(original.address),
            reason: 'Address should be preserved in round trip');
        expect(restored.latitude, equals(original.latitude),
            reason: 'Latitude should be preserved in round trip');
        expect(restored.longitude, equals(original.longitude),
            reason: 'Longitude should be preserved in round trip');
        expect(restored.availableSlots, equals(original.availableSlots),
            reason: 'Available slots should be preserved in round trip');
        expect(restored.distance, equals(original.distance),
            reason: 'Distance should be preserved in round trip');

        // Verify equality operator works
        expect(restored, equals(original),
            reason: 'Restored model should equal original model');

        // Verify geoPoint is correctly computed
        expect(restored.geoPoint.latitude, equals(original.geoPoint.latitude),
            reason: 'GeoPoint latitude should match');
        expect(restored.geoPoint.longitude, equals(original.geoPoint.longitude),
            reason: 'GeoPoint longitude should match');
      }
    });
  });

  group('MallModel Unit Tests', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id': 'mall_001',
        'name': 'Test Mall',
        'address': 'Jl. Test No. 123',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 45,
        'distance': '2.5 km',
      };

      final model = MallModel.fromJson(json);

      expect(model.id, equals('mall_001'));
      expect(model.name, equals('Test Mall'));
      expect(model.address, equals('Jl. Test No. 123'));
      expect(model.latitude, equals(1.1191));
      expect(model.longitude, equals(104.0538));
      expect(model.availableSlots, equals(45));
      expect(model.distance, equals('2.5 km'));
    });

    test('fromJson handles backend field names (id_mall, nama_mall, lokasi, kapasitas)', () {
      final json = {
        'id_mall': 'mall_002',
        'nama_mall': 'Backend Mall',
        'lokasi': 'Jl. Backend No. 456',
        'latitude': 1.1304,
        'longitude': 104.0534,
        'kapasitas': 32,
      };

      final model = MallModel.fromJson(json);

      expect(model.id, equals('mall_002'));
      expect(model.name, equals('Backend Mall'));
      expect(model.address, equals('Jl. Backend No. 456'));
      expect(model.availableSlots, equals(32));
    });

    test('fromJson parses double from string', () {
      final json = {
        'id': 'mall_003',
        'name': 'String Mall',
        'address': 'Jl. String',
        'latitude': '1.1191',
        'longitude': '104.0538',
        'available_slots': '45',
      };

      final model = MallModel.fromJson(json);

      expect(model.latitude, equals(1.1191));
      expect(model.longitude, equals(104.0538));
      expect(model.availableSlots, equals(45));
    });

    test('fromJson parses double from int', () {
      final json = {
        'id': 'mall_004',
        'name': 'Int Mall',
        'address': 'Jl. Int',
        'latitude': 1,
        'longitude': 104,
        'available_slots': 45,
      };

      final model = MallModel.fromJson(json);

      expect(model.latitude, equals(1.0));
      expect(model.longitude, equals(104.0));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'mall_005',
        'name': 'Minimal Mall',
        'address': 'Jl. Minimal',
        'latitude': 1.1191,
        'longitude': 104.0538,
        'available_slots': 0,
      };

      final model = MallModel.fromJson(json);

      expect(model.distance, equals(''));
    });

    test('toJson creates correct JSON structure', () {
      final model = MallModel(
        id: 'mall_006',
        name: 'JSON Mall',
        address: 'Jl. JSON',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
        distance: '3.2 km',
      );

      final json = model.toJson();

      expect(json['id'], equals('mall_006'));
      expect(json['name'], equals('JSON Mall'));
      expect(json['address'], equals('Jl. JSON'));
      expect(json['latitude'], equals(1.1191));
      expect(json['longitude'], equals(104.0538));
      expect(json['available_slots'], equals(45));
      expect(json['distance'], equals('3.2 km'));
    });

    test('geoPoint getter returns correct GeoPoint', () {
      final model = MallModel(
        id: 'mall_007',
        name: 'GeoPoint Mall',
        address: 'Jl. GeoPoint',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      final geoPoint = model.geoPoint;

      expect(geoPoint.latitude, equals(1.1191));
      expect(geoPoint.longitude, equals(104.0538));
    });

    test('hasAvailableSlots returns true when slots > 0', () {
      final model = MallModel(
        id: 'mall_008',
        name: 'Available Mall',
        address: 'Jl. Available',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 10,
      );

      expect(model.hasAvailableSlots, isTrue);
    });

    test('hasAvailableSlots returns false when slots = 0', () {
      final model = MallModel(
        id: 'mall_009',
        name: 'Full Mall',
        address: 'Jl. Full',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 0,
      );

      expect(model.hasAvailableSlots, isFalse);
    });

    test('formattedAvailableSlots returns "Penuh" when slots = 0', () {
      final model = MallModel(
        id: 'mall_010',
        name: 'Full Mall',
        address: 'Jl. Full',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 0,
      );

      expect(model.formattedAvailableSlots, equals('Penuh'));
    });

    test('formattedAvailableSlots returns "1 slot tersedia" when slots = 1', () {
      final model = MallModel(
        id: 'mall_011',
        name: 'One Slot Mall',
        address: 'Jl. One',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 1,
      );

      expect(model.formattedAvailableSlots, equals('1 slot tersedia'));
    });

    test('formattedAvailableSlots returns correct format when slots > 1', () {
      final model = MallModel(
        id: 'mall_012',
        name: 'Many Slots Mall',
        address: 'Jl. Many',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.formattedAvailableSlots, equals('45 slot tersedia'));
    });

    test('validate returns true for valid mall data', () {
      final model = MallModel(
        id: 'mall_013',
        name: 'Valid Mall',
        address: 'Jl. Valid',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.validate(), isTrue);
    });

    test('validate returns false for empty id', () {
      final model = MallModel(
        id: '',
        name: 'Invalid Mall',
        address: 'Jl. Invalid',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for empty name', () {
      final model = MallModel(
        id: 'mall_014',
        name: '',
        address: 'Jl. Invalid',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for empty address', () {
      final model = MallModel(
        id: 'mall_015',
        name: 'Invalid Mall',
        address: '',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for invalid latitude (< -90)', () {
      final model = MallModel(
        id: 'mall_016',
        name: 'Invalid Mall',
        address: 'Jl. Invalid',
        latitude: -91.0,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for invalid latitude (> 90)', () {
      final model = MallModel(
        id: 'mall_017',
        name: 'Invalid Mall',
        address: 'Jl. Invalid',
        latitude: 91.0,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for invalid longitude (< -180)', () {
      final model = MallModel(
        id: 'mall_018',
        name: 'Invalid Mall',
        address: 'Jl. Invalid',
        latitude: 1.1191,
        longitude: -181.0,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for invalid longitude (> 180)', () {
      final model = MallModel(
        id: 'mall_019',
        name: 'Invalid Mall',
        address: 'Jl. Invalid',
        latitude: 1.1191,
        longitude: 181.0,
        availableSlots: 45,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns false for negative available slots', () {
      final model = MallModel(
        id: 'mall_020',
        name: 'Invalid Mall',
        address: 'Jl. Invalid',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: -1,
      );

      expect(model.validate(), isFalse);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = MallModel(
        id: 'mall_021',
        name: 'Original Mall',
        address: 'Jl. Original',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
        distance: '2.5 km',
      );

      final updated = original.copyWith(
        availableSlots: 30,
        distance: '3.0 km',
      );

      expect(updated.id, equals('mall_021'));
      expect(updated.name, equals('Original Mall'));
      expect(updated.availableSlots, equals(30));
      expect(updated.distance, equals('3.0 km'));
      expect(original.availableSlots, equals(45));
    });

    test('equality operator works correctly', () {
      final mall1 = MallModel(
        id: 'mall_022',
        name: 'Equal Mall',
        address: 'Jl. Equal',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      final mall2 = MallModel(
        id: 'mall_022',
        name: 'Equal Mall',
        address: 'Jl. Equal',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(mall1, equals(mall2));
    });

    test('equality operator returns false for different malls', () {
      final mall1 = MallModel(
        id: 'mall_023',
        name: 'Mall A',
        address: 'Jl. A',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      final mall2 = MallModel(
        id: 'mall_024',
        name: 'Mall B',
        address: 'Jl. B',
        latitude: 1.1304,
        longitude: 104.0534,
        availableSlots: 32,
      );

      expect(mall1, isNot(equals(mall2)));
    });

    test('hashCode is consistent with equality', () {
      final mall1 = MallModel(
        id: 'mall_025',
        name: 'Hash Mall',
        address: 'Jl. Hash',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      final mall2 = MallModel(
        id: 'mall_025',
        name: 'Hash Mall',
        address: 'Jl. Hash',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
      );

      expect(mall1.hashCode, equals(mall2.hashCode));
    });

    test('toString returns formatted string', () {
      final model = MallModel(
        id: 'mall_026',
        name: 'String Mall',
        address: 'Jl. String',
        latitude: 1.1191,
        longitude: 104.0538,
        availableSlots: 45,
        distance: '2.5 km',
      );

      final str = model.toString();

      expect(str, contains('mall_026'));
      expect(str, contains('String Mall'));
      expect(str, contains('1.1191'));
      expect(str, contains('104.0538'));
      expect(str, contains('45'));
    });
  });
}

/// Generator for random mall data for property-based testing
/// Generates malls with realistic Batam area coordinates (lat 1.0-1.2, lng 103.9-104.1)
MallModel _generateRandomMall() {
  final random = Random();

  // Generate random ID
  final id = 'mall_${random.nextInt(10000)}';

  // Generate random name
  final names = ['Mega Mall', 'BCS Mall', 'Harbour Bay', 'Grand Mall', 'Kepri Mall', 'City Mall', 'Plaza'];
  final name = '${names[random.nextInt(names.length)]} ${random.nextInt(100)}';

  // Generate random address
  final streets = ['Jl. Engku Putri', 'Jl. Raja Fisabilillah', 'Jl. Ahmad Yani', 'Jl. Duyung', 'Jl. Sudirman'];
  final address = '${streets[random.nextInt(streets.length)]} No. ${random.nextInt(200) + 1}';

  // Generate random coordinates in Batam area (lat 1.0-1.2, lng 103.9-104.1)
  final latitude = 1.0 + random.nextDouble() * 0.2;
  final longitude = 103.9 + random.nextDouble() * 0.2;

  // Generate random available slots (0-100)
  final availableSlots = random.nextInt(101);

  // Generate random distance (sometimes empty)
  final distance = random.nextBool() ? '${(random.nextDouble() * 10).toStringAsFixed(1)} km' : '';

  return MallModel(
    id: id,
    name: name,
    address: address,
    latitude: latitude,
    longitude: longitude,
    availableSlots: availableSlots,
    distance: distance,
  );
}
