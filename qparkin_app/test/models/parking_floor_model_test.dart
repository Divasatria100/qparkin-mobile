import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/parking_floor_model.dart';

void main() {
  group('ParkingFloorModel Computed Properties', () {
    test('hasAvailableSlots returns true when slots available', () {
      final model = _createTestModel(availableSlots: 10);

      expect(model.hasAvailableSlots, isTrue);
    });

    test('hasAvailableSlots returns false when no slots available', () {
      final model = _createTestModel(availableSlots: 0);

      expect(model.hasAvailableSlots, isFalse);
    });

    test('occupancyRate calculates correctly', () {
      final model = _createTestModel(
        totalSlots: 100,
        occupiedSlots: 60,
        reservedSlots: 20,
        availableSlots: 20,
      );

      expect(model.occupancyRate, equals(0.8));
    });

    test('occupancyRate returns 0 when totalSlots is 0', () {
      final model = _createTestModel(
        totalSlots: 0,
        occupiedSlots: 0,
        reservedSlots: 0,
        availableSlots: 0,
      );

      expect(model.occupancyRate, equals(0.0));
    });

    test('availabilityText formats correctly', () {
      final model = _createTestModel(availableSlots: 15);

      expect(model.availabilityText, equals('15 slot tersedia'));
    });

    test('occupancyPercentage formats correctly', () {
      final model = _createTestModel(
        totalSlots: 100,
        occupiedSlots: 75,
        reservedSlots: 0,
        availableSlots: 25,
      );

      expect(model.occupancyPercentage, equals('75%'));
    });
  });

  group('ParkingFloorModel Validation', () {
    test('validate returns true for valid data', () {
      final model = _createTestModel();

      expect(model.validate(), isTrue);
    });

    test('validate returns false when idFloor is empty', () {
      final model = _createTestModel(idFloor: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when idMall is empty', () {
      final model = _createTestModel(idMall: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when floorNumber is negative', () {
      final model = _createTestModel(floorNumber: -1);

      expect(model.validate(), isFalse);
    });

    test('validate returns false when floorName is empty', () {
      final model = _createTestModel(floorName: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when totalSlots is negative', () {
      final model = _createTestModel(totalSlots: -1);

      expect(model.validate(), isFalse);
    });

    test('validate returns false when availableSlots is negative', () {
      final model = _createTestModel(availableSlots: -1);

      expect(model.validate(), isFalse);
    });

    test('validate returns false when sum exceeds total', () {
      final model = _createTestModel(
        totalSlots: 50,
        availableSlots: 30,
        occupiedSlots: 20,
        reservedSlots: 10,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns true when sum equals total', () {
      final model = _createTestModel(
        totalSlots: 50,
        availableSlots: 20,
        occupiedSlots: 20,
        reservedSlots: 10,
      );

      expect(model.validate(), isTrue);
    });
  });

  group('ParkingFloorModel JSON Serialization', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id_floor': 'f1',
        'id_mall': 'm1',
        'floor_number': 2,
        'floor_name': 'Lantai 2',
        'total_slots': 100,
        'available_slots': 25,
        'occupied_slots': 60,
        'reserved_slots': 15,
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingFloorModel.fromJson(json);

      expect(model.idFloor, equals('f1'));
      expect(model.idMall, equals('m1'));
      expect(model.floorNumber, equals(2));
      expect(model.floorName, equals('Lantai 2'));
      expect(model.totalSlots, equals(100));
      expect(model.availableSlots, equals(25));
      expect(model.occupiedSlots, equals(60));
      expect(model.reservedSlots, equals(15));
    });

    test('fromJson handles string numbers', () {
      final json = {
        'id_floor': 'f1',
        'id_mall': 'm1',
        'floor_number': '2',
        'floor_name': 'Lantai 2',
        'total_slots': '100',
        'available_slots': '25',
        'occupied_slots': '60',
        'reserved_slots': '15',
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingFloorModel.fromJson(json);

      expect(model.floorNumber, equals(2));
      expect(model.totalSlots, equals(100));
      expect(model.availableSlots, equals(25));
    });

    test('fromJson handles double numbers', () {
      final json = {
        'id_floor': 'f1',
        'id_mall': 'm1',
        'floor_number': 2.0,
        'floor_name': 'Lantai 2',
        'total_slots': 100.0,
        'available_slots': 25.0,
        'occupied_slots': 60.0,
        'reserved_slots': 15.0,
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingFloorModel.fromJson(json);

      expect(model.floorNumber, equals(2));
      expect(model.totalSlots, equals(100));
    });

    test('fromJson handles null values with defaults', () {
      final json = {
        'id_floor': 'f1',
        'id_mall': 'm1',
        'floor_name': 'Lantai 2',
      };

      final model = ParkingFloorModel.fromJson(json);

      expect(model.floorNumber, equals(0));
      expect(model.totalSlots, equals(0));
      expect(model.availableSlots, equals(0));
    });

    test('toJson creates correct JSON structure', () {
      final model = _createTestModel(
        idFloor: 'f1',
        idMall: 'm1',
        floorNumber: 2,
        floorName: 'Lantai 2',
      );

      final json = model.toJson();

      expect(json['id_floor'], equals('f1'));
      expect(json['id_mall'], equals('m1'));
      expect(json['floor_number'], equals(2));
      expect(json['floor_name'], equals('Lantai 2'));
      expect(json['last_updated'], isA<String>());
    });

    test('toJson and fromJson round trip preserves data', () {
      final original = _createTestModel(
        idFloor: 'f1',
        floorNumber: 3,
        totalSlots: 150,
      );

      final json = original.toJson();
      final restored = ParkingFloorModel.fromJson(json);

      expect(restored.idFloor, equals(original.idFloor));
      expect(restored.floorNumber, equals(original.floorNumber));
      expect(restored.totalSlots, equals(original.totalSlots));
    });
  });

  group('ParkingFloorModel copyWith', () {
    test('copyWith creates new instance with updated fields', () {
      final original = _createTestModel(availableSlots: 10);

      final updated = original.copyWith(availableSlots: 5);

      expect(updated.availableSlots, equals(5));
      expect(original.availableSlots, equals(10));
    });

    test('copyWith preserves unchanged fields', () {
      final original = _createTestModel(
        idFloor: 'f1',
        floorName: 'Lantai 1',
        totalSlots: 100,
      );

      final updated = original.copyWith(availableSlots: 20);

      expect(updated.idFloor, equals('f1'));
      expect(updated.floorName, equals('Lantai 1'));
      expect(updated.totalSlots, equals(100));
    });
  });

  group('ParkingFloorModel Equality', () {
    test('equality based on idFloor', () {
      final model1 = _createTestModel(idFloor: 'f1');
      final model2 = _createTestModel(idFloor: 'f1');

      expect(model1, equals(model2));
    });

    test('inequality when idFloor differs', () {
      final model1 = _createTestModel(idFloor: 'f1');
      final model2 = _createTestModel(idFloor: 'f2');

      expect(model1, isNot(equals(model2)));
    });

    test('hashCode based on idFloor', () {
      final model1 = _createTestModel(idFloor: 'f1');
      final model2 = _createTestModel(idFloor: 'f1');

      expect(model1.hashCode, equals(model2.hashCode));
    });
  });
}

/// Helper function to create test model with default values
ParkingFloorModel _createTestModel({
  String idFloor = 'f1',
  String idMall = 'm1',
  int floorNumber = 1,
  String floorName = 'Lantai 1',
  int totalSlots = 100,
  int availableSlots = 50,
  int occupiedSlots = 40,
  int reservedSlots = 10,
  DateTime? lastUpdated,
}) {
  return ParkingFloorModel(
    idFloor: idFloor,
    idMall: idMall,
    floorNumber: floorNumber,
    floorName: floorName,
    totalSlots: totalSlots,
    availableSlots: availableSlots,
    occupiedSlots: occupiedSlots,
    reservedSlots: reservedSlots,
    lastUpdated: lastUpdated ?? DateTime.now(),
  );
}
