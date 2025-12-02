import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';

void main() {
  group('SlotStatus Enum', () {
    test('fromString parses available status', () {
      expect(SlotStatus.fromString('available'), equals(SlotStatus.available));
      expect(SlotStatus.fromString('tersedia'), equals(SlotStatus.available));
    });

    test('fromString parses occupied status', () {
      expect(SlotStatus.fromString('occupied'), equals(SlotStatus.occupied));
      expect(SlotStatus.fromString('terisi'), equals(SlotStatus.occupied));
    });

    test('fromString parses reserved status', () {
      expect(SlotStatus.fromString('reserved'), equals(SlotStatus.reserved));
      expect(SlotStatus.fromString('direservasi'), equals(SlotStatus.reserved));
    });

    test('fromString parses disabled status', () {
      expect(SlotStatus.fromString('disabled'), equals(SlotStatus.disabled));
      expect(SlotStatus.fromString('nonaktif'), equals(SlotStatus.disabled));
    });

    test('fromString defaults to available for unknown status', () {
      expect(SlotStatus.fromString('unknown'), equals(SlotStatus.available));
    });

    test('toStringValue returns correct string', () {
      expect(SlotStatus.available.toStringValue(), equals('available'));
      expect(SlotStatus.occupied.toStringValue(), equals('occupied'));
      expect(SlotStatus.reserved.toStringValue(), equals('reserved'));
      expect(SlotStatus.disabled.toStringValue(), equals('disabled'));
    });
  });

  group('SlotType Enum', () {
    test('fromString parses disable-friendly type', () {
      expect(SlotType.fromString('disable_friendly'), equals(SlotType.disableFriendly));
      expect(SlotType.fromString('disable-friendly'), equals(SlotType.disableFriendly));
      expect(SlotType.fromString('disablefriendly'), equals(SlotType.disableFriendly));
    });

    test('fromString parses regular type', () {
      expect(SlotType.fromString('regular'), equals(SlotType.regular));
    });

    test('fromString defaults to regular for unknown type', () {
      expect(SlotType.fromString('unknown'), equals(SlotType.regular));
    });

    test('toStringValue returns correct string', () {
      expect(SlotType.regular.toStringValue(), equals('regular'));
      expect(SlotType.disableFriendly.toStringValue(), equals('disable_friendly'));
    });
  });

  group('ParkingSlotModel Computed Properties', () {
    test('statusColor returns green for available', () {
      final model = _createTestModel(status: SlotStatus.available);

      expect(model.statusColor, equals(const Color(0xFF4CAF50)));
    });

    test('statusColor returns grey for occupied', () {
      final model = _createTestModel(status: SlotStatus.occupied);

      expect(model.statusColor, equals(const Color(0xFF9E9E9E)));
    });

    test('statusColor returns orange for reserved', () {
      final model = _createTestModel(status: SlotStatus.reserved);

      expect(model.statusColor, equals(const Color(0xFFFF9800)));
    });

    test('statusColor returns red for disabled', () {
      final model = _createTestModel(status: SlotStatus.disabled);

      expect(model.statusColor, equals(const Color(0xFFF44336)));
    });

    test('typeIcon returns accessible icon for disable-friendly', () {
      final model = _createTestModel(slotType: SlotType.disableFriendly);

      expect(model.typeIcon, equals(Icons.accessible));
    });

    test('typeIcon returns parking icon for regular', () {
      final model = _createTestModel(slotType: SlotType.regular);

      expect(model.typeIcon, equals(Icons.local_parking));
    });

    test('typeLabel returns correct label for disable-friendly', () {
      final model = _createTestModel(slotType: SlotType.disableFriendly);

      expect(model.typeLabel, equals('Disable-Friendly'));
    });

    test('typeLabel returns correct label for regular', () {
      final model = _createTestModel(slotType: SlotType.regular);

      expect(model.typeLabel, equals('Regular'));
    });

    test('statusLabel returns correct Indonesian labels', () {
      expect(_createTestModel(status: SlotStatus.available).statusLabel, equals('Tersedia'));
      expect(_createTestModel(status: SlotStatus.occupied).statusLabel, equals('Terisi'));
      expect(_createTestModel(status: SlotStatus.reserved).statusLabel, equals('Direservasi'));
      expect(_createTestModel(status: SlotStatus.disabled).statusLabel, equals('Nonaktif'));
    });

    test('isAvailable returns true only for available status', () {
      expect(_createTestModel(status: SlotStatus.available).isAvailable, isTrue);
      expect(_createTestModel(status: SlotStatus.occupied).isAvailable, isFalse);
      expect(_createTestModel(status: SlotStatus.reserved).isAvailable, isFalse);
      expect(_createTestModel(status: SlotStatus.disabled).isAvailable, isFalse);
    });
  });

  group('ParkingSlotModel Validation', () {
    test('validate returns true for valid data', () {
      final model = _createTestModel();

      expect(model.validate(), isTrue);
    });

    test('validate returns false when idSlot is empty', () {
      final model = _createTestModel(idSlot: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when idFloor is empty', () {
      final model = _createTestModel(idFloor: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when slotCode is empty', () {
      final model = _createTestModel(slotCode: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when positionX is negative', () {
      final model = _createTestModel(positionX: -1);

      expect(model.validate(), isFalse);
    });

    test('validate returns false when positionY is negative', () {
      final model = _createTestModel(positionY: -1);

      expect(model.validate(), isFalse);
    });

    test('validate returns true when positions are null', () {
      final model = _createTestModel(positionX: null, positionY: null);

      expect(model.validate(), isTrue);
    });

    test('validate returns true when positions are zero', () {
      final model = _createTestModel(positionX: 0, positionY: 0);

      expect(model.validate(), isTrue);
    });
  });

  group('ParkingSlotModel JSON Serialization', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id_slot': 's1',
        'id_floor': 'f1',
        'slot_code': 'A01',
        'status': 'available',
        'slot_type': 'regular',
        'position_x': 0,
        'position_y': 0,
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingSlotModel.fromJson(json);

      expect(model.idSlot, equals('s1'));
      expect(model.idFloor, equals('f1'));
      expect(model.slotCode, equals('A01'));
      expect(model.status, equals(SlotStatus.available));
      expect(model.slotType, equals(SlotType.regular));
      expect(model.positionX, equals(0));
      expect(model.positionY, equals(0));
    });

    test('fromJson handles Indonesian status values', () {
      final json = {
        'id_slot': 's1',
        'id_floor': 'f1',
        'slot_code': 'A01',
        'status': 'terisi',
        'slot_type': 'regular',
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingSlotModel.fromJson(json);

      expect(model.status, equals(SlotStatus.occupied));
    });

    test('fromJson handles disable-friendly type variations', () {
      final variations = ['disable_friendly', 'disable-friendly', 'disablefriendly'];

      for (final variation in variations) {
        final json = {
          'id_slot': 's1',
          'id_floor': 'f1',
          'slot_code': 'A01',
          'status': 'available',
          'slot_type': variation,
          'last_updated': '2024-01-15T10:00:00.000Z',
        };

        final model = ParkingSlotModel.fromJson(json);
        expect(model.slotType, equals(SlotType.disableFriendly));
      }
    });

    test('fromJson handles null positions', () {
      final json = {
        'id_slot': 's1',
        'id_floor': 'f1',
        'slot_code': 'A01',
        'status': 'available',
        'slot_type': 'regular',
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingSlotModel.fromJson(json);

      expect(model.positionX, isNull);
      expect(model.positionY, isNull);
    });

    test('fromJson handles string positions', () {
      final json = {
        'id_slot': 's1',
        'id_floor': 'f1',
        'slot_code': 'A01',
        'status': 'available',
        'slot_type': 'regular',
        'position_x': '5',
        'position_y': '10',
        'last_updated': '2024-01-15T10:00:00.000Z',
      };

      final model = ParkingSlotModel.fromJson(json);

      expect(model.positionX, equals(5));
      expect(model.positionY, equals(10));
    });

    test('toJson creates correct JSON structure', () {
      final model = _createTestModel(
        idSlot: 's1',
        slotCode: 'A01',
        status: SlotStatus.available,
        slotType: SlotType.regular,
      );

      final json = model.toJson();

      expect(json['id_slot'], equals('s1'));
      expect(json['slot_code'], equals('A01'));
      expect(json['status'], equals('available'));
      expect(json['slot_type'], equals('regular'));
      expect(json['last_updated'], isA<String>());
    });

    test('toJson and fromJson round trip preserves data', () {
      final original = _createTestModel(
        idSlot: 's1',
        status: SlotStatus.reserved,
        slotType: SlotType.disableFriendly,
        positionX: 5,
        positionY: 10,
      );

      final json = original.toJson();
      final restored = ParkingSlotModel.fromJson(json);

      expect(restored.idSlot, equals(original.idSlot));
      expect(restored.status, equals(original.status));
      expect(restored.slotType, equals(original.slotType));
      expect(restored.positionX, equals(original.positionX));
      expect(restored.positionY, equals(original.positionY));
    });
  });

  group('ParkingSlotModel copyWith', () {
    test('copyWith creates new instance with updated fields', () {
      final original = _createTestModel(status: SlotStatus.available);

      final updated = original.copyWith(status: SlotStatus.occupied);

      expect(updated.status, equals(SlotStatus.occupied));
      expect(original.status, equals(SlotStatus.available));
    });

    test('copyWith preserves unchanged fields', () {
      final original = _createTestModel(
        idSlot: 's1',
        slotCode: 'A01',
        slotType: SlotType.regular,
      );

      final updated = original.copyWith(status: SlotStatus.occupied);

      expect(updated.idSlot, equals('s1'));
      expect(updated.slotCode, equals('A01'));
      expect(updated.slotType, equals(SlotType.regular));
    });
  });

  group('ParkingSlotModel Equality', () {
    test('equality based on idSlot', () {
      final model1 = _createTestModel(idSlot: 's1');
      final model2 = _createTestModel(idSlot: 's1');

      expect(model1, equals(model2));
    });

    test('inequality when idSlot differs', () {
      final model1 = _createTestModel(idSlot: 's1');
      final model2 = _createTestModel(idSlot: 's2');

      expect(model1, isNot(equals(model2)));
    });

    test('hashCode based on idSlot', () {
      final model1 = _createTestModel(idSlot: 's1');
      final model2 = _createTestModel(idSlot: 's1');

      expect(model1.hashCode, equals(model2.hashCode));
    });
  });
}

/// Helper function to create test model with default values
ParkingSlotModel _createTestModel({
  String idSlot = 's1',
  String idFloor = 'f1',
  String slotCode = 'A01',
  SlotStatus status = SlotStatus.available,
  SlotType slotType = SlotType.regular,
  int? positionX = 0,
  int? positionY = 0,
  DateTime? lastUpdated,
}) {
  return ParkingSlotModel(
    idSlot: idSlot,
    idFloor: idFloor,
    slotCode: slotCode,
    status: status,
    slotType: slotType,
    positionX: positionX,
    positionY: positionY,
    lastUpdated: lastUpdated ?? DateTime.now(),
  );
}
