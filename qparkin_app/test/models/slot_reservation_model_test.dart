import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/slot_reservation_model.dart';
import 'package:qparkin_app/data/models/parking_slot_model.dart';

void main() {
  group('SlotReservationModel Computed Properties', () {
    test('isExpired returns false before expiration', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final model = _createTestModel(expiresAt: expiresAt);

      expect(model.isExpired, isFalse);
    });

    test('isExpired returns true after expiration', () {
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      final model = _createTestModel(expiresAt: expiresAt);

      expect(model.isExpired, isTrue);
    });

    test('timeRemaining returns correct duration before expiration', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final model = _createTestModel(expiresAt: expiresAt);

      final remaining = model.timeRemaining;

      expect(remaining.inMinutes, greaterThanOrEqualTo(4));
      expect(remaining.inMinutes, lessThanOrEqualTo(5));
    });

    test('timeRemaining returns zero after expiration', () {
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      final model = _createTestModel(expiresAt: expiresAt);

      expect(model.timeRemaining, equals(Duration.zero));
    });

    test('displayName formats correctly', () {
      final model = _createTestModel(
        floorName: 'Lantai 2',
        slotCode: 'A15',
      );

      expect(model.displayName, equals('Lantai 2 - Slot A15'));
    });

    test('typeLabel returns correct label for regular', () {
      final model = _createTestModel(slotType: SlotType.regular);

      expect(model.typeLabel, equals('Regular Parking'));
    });

    test('typeLabel returns correct label for disable-friendly', () {
      final model = _createTestModel(slotType: SlotType.disableFriendly);

      expect(model.typeLabel, equals('Disable-Friendly'));
    });

    test('formattedExpirationTime formats correctly', () {
      final expiresAt = DateTime(2024, 1, 15, 14, 45);
      final model = _createTestModel(expiresAt: expiresAt);

      expect(model.formattedExpirationTime, equals('14:45'));
    });

    test('formattedExpirationTime pads single digits', () {
      final expiresAt = DateTime(2024, 1, 15, 9, 5);
      final model = _createTestModel(expiresAt: expiresAt);

      expect(model.formattedExpirationTime, equals('09:05'));
    });

    test('formattedRemainingTime shows minutes and seconds', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 4, seconds: 30));
      final model = _createTestModel(expiresAt: expiresAt);

      final formatted = model.formattedRemainingTime;

      expect(formatted, contains('4 menit'));
      expect(formatted, contains('detik'));
    });

    test('formattedRemainingTime shows only seconds when less than 1 minute', () {
      final expiresAt = DateTime.now().add(const Duration(seconds: 45));
      final model = _createTestModel(expiresAt: expiresAt);

      final formatted = model.formattedRemainingTime;

      expect(formatted, contains('detik'));
      expect(formatted, isNot(contains('menit')));
    });

    test('formattedRemainingTime shows "Habis" when expired', () {
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      final model = _createTestModel(expiresAt: expiresAt);

      expect(model.formattedRemainingTime, equals('Habis'));
    });

    test('isValid returns true when active and not expired', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final model = _createTestModel(isActive: true, expiresAt: expiresAt);

      expect(model.isValid, isTrue);
    });

    test('isValid returns false when not active', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final model = _createTestModel(isActive: false, expiresAt: expiresAt);

      expect(model.isValid, isFalse);
    });

    test('isValid returns false when expired', () {
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      final model = _createTestModel(isActive: true, expiresAt: expiresAt);

      expect(model.isValid, isFalse);
    });
  });

  group('SlotReservationModel Validation', () {
    test('validate returns true for valid data', () {
      final model = _createTestModel();

      expect(model.validate(), isTrue);
    });

    test('validate returns false when reservationId is empty', () {
      final model = _createTestModel(reservationId: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when slotId is empty', () {
      final model = _createTestModel(slotId: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when slotCode is empty', () {
      final model = _createTestModel(slotCode: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when floorName is empty', () {
      final model = _createTestModel(floorName: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when floorNumber is empty', () {
      final model = _createTestModel(floorNumber: '');

      expect(model.validate(), isFalse);
    });

    test('validate returns false when expiresAt is before reservedAt', () {
      final reservedAt = DateTime.now();
      final expiresAt = reservedAt.subtract(const Duration(minutes: 1));
      final model = _createTestModel(
        reservedAt: reservedAt,
        expiresAt: expiresAt,
      );

      expect(model.validate(), isFalse);
    });

    test('validate returns true when expiresAt equals reservedAt', () {
      final time = DateTime.now();
      final model = _createTestModel(
        reservedAt: time,
        expiresAt: time,
      );

      expect(model.validate(), isTrue);
    });
  });

  group('SlotReservationModel JSON Serialization', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'reservation_id': 'r123',
        'slot_id': 's15',
        'slot_code': 'A15',
        'floor_name': 'Lantai 1',
        'floor_number': '1',
        'slot_type': 'regular',
        'reserved_at': '2024-01-15T14:30:00.000Z',
        'expires_at': '2024-01-15T14:35:00.000Z',
        'is_active': true,
      };

      final model = SlotReservationModel.fromJson(json);

      expect(model.reservationId, equals('r123'));
      expect(model.slotId, equals('s15'));
      expect(model.slotCode, equals('A15'));
      expect(model.floorName, equals('Lantai 1'));
      expect(model.floorNumber, equals('1'));
      expect(model.slotType, equals(SlotType.regular));
      expect(model.isActive, isTrue);
    });

    test('fromJson handles disable-friendly slot type', () {
      final json = {
        'reservation_id': 'r123',
        'slot_id': 's15',
        'slot_code': 'A15',
        'floor_name': 'Lantai 1',
        'floor_number': '1',
        'slot_type': 'disable_friendly',
        'reserved_at': '2024-01-15T14:30:00.000Z',
        'expires_at': '2024-01-15T14:35:00.000Z',
        'is_active': true,
      };

      final model = SlotReservationModel.fromJson(json);

      expect(model.slotType, equals(SlotType.disableFriendly));
    });

    test('fromJson handles is_active as integer', () {
      final json = {
        'reservation_id': 'r123',
        'slot_id': 's15',
        'slot_code': 'A15',
        'floor_name': 'Lantai 1',
        'floor_number': '1',
        'slot_type': 'regular',
        'reserved_at': '2024-01-15T14:30:00.000Z',
        'expires_at': '2024-01-15T14:35:00.000Z',
        'is_active': 1,
      };

      final model = SlotReservationModel.fromJson(json);

      expect(model.isActive, isTrue);
    });

    test('fromJson handles is_active as false', () {
      final json = {
        'reservation_id': 'r123',
        'slot_id': 's15',
        'slot_code': 'A15',
        'floor_name': 'Lantai 1',
        'floor_number': '1',
        'slot_type': 'regular',
        'reserved_at': '2024-01-15T14:30:00.000Z',
        'expires_at': '2024-01-15T14:35:00.000Z',
        'is_active': false,
      };

      final model = SlotReservationModel.fromJson(json);

      expect(model.isActive, isFalse);
    });

    test('fromJson uses defaults for missing dates', () {
      final json = {
        'reservation_id': 'r123',
        'slot_id': 's15',
        'slot_code': 'A15',
        'floor_name': 'Lantai 1',
        'floor_number': '1',
        'slot_type': 'regular',
        'is_active': true,
      };

      final model = SlotReservationModel.fromJson(json);

      expect(model.reservedAt, isA<DateTime>());
      expect(model.expiresAt, isA<DateTime>());
    });

    test('toJson creates correct JSON structure', () {
      final reservedAt = DateTime(2024, 1, 15, 14, 30);
      final expiresAt = DateTime(2024, 1, 15, 14, 35);
      final model = _createTestModel(
        reservationId: 'r123',
        slotCode: 'A15',
        slotType: SlotType.regular,
        reservedAt: reservedAt,
        expiresAt: expiresAt,
        isActive: true,
      );

      final json = model.toJson();

      expect(json['reservation_id'], equals('r123'));
      expect(json['slot_code'], equals('A15'));
      expect(json['slot_type'], equals('regular'));
      expect(json['is_active'], isTrue);
      expect(json['reserved_at'], isA<String>());
      expect(json['expires_at'], isA<String>());
    });

    test('toJson handles disable-friendly type', () {
      final model = _createTestModel(slotType: SlotType.disableFriendly);

      final json = model.toJson();

      expect(json['slot_type'], equals('disable_friendly'));
    });

    test('toJson and fromJson round trip preserves data', () {
      final original = _createTestModel(
        reservationId: 'r123',
        slotId: 's15',
        slotCode: 'A15',
        slotType: SlotType.disableFriendly,
        isActive: true,
      );

      final json = original.toJson();
      final restored = SlotReservationModel.fromJson(json);

      expect(restored.reservationId, equals(original.reservationId));
      expect(restored.slotId, equals(original.slotId));
      expect(restored.slotCode, equals(original.slotCode));
      expect(restored.slotType, equals(original.slotType));
      expect(restored.isActive, equals(original.isActive));
    });
  });

  group('SlotReservationModel copyWith', () {
    test('copyWith creates new instance with updated fields', () {
      final original = _createTestModel(isActive: true);

      final updated = original.copyWith(isActive: false);

      expect(updated.isActive, isFalse);
      expect(original.isActive, isTrue);
    });

    test('copyWith preserves unchanged fields', () {
      final original = _createTestModel(
        reservationId: 'r123',
        slotCode: 'A15',
        floorName: 'Lantai 1',
      );

      final updated = original.copyWith(isActive: false);

      expect(updated.reservationId, equals('r123'));
      expect(updated.slotCode, equals('A15'));
      expect(updated.floorName, equals('Lantai 1'));
    });
  });

  group('SlotReservationModel Equality', () {
    test('equality based on reservationId', () {
      final model1 = _createTestModel(reservationId: 'r123');
      final model2 = _createTestModel(reservationId: 'r123');

      expect(model1, equals(model2));
    });

    test('inequality when reservationId differs', () {
      final model1 = _createTestModel(reservationId: 'r123');
      final model2 = _createTestModel(reservationId: 'r456');

      expect(model1, isNot(equals(model2)));
    });

    test('hashCode based on reservationId', () {
      final model1 = _createTestModel(reservationId: 'r123');
      final model2 = _createTestModel(reservationId: 'r123');

      expect(model1.hashCode, equals(model2.hashCode));
    });
  });
}

/// Helper function to create test model with default values
SlotReservationModel _createTestModel({
  String reservationId = 'r123',
  String slotId = 's15',
  String slotCode = 'A15',
  String floorName = 'Lantai 1',
  String floorNumber = '1',
  SlotType slotType = SlotType.regular,
  DateTime? reservedAt,
  DateTime? expiresAt,
  bool isActive = true,
}) {
  return SlotReservationModel(
    reservationId: reservationId,
    slotId: slotId,
    slotCode: slotCode,
    floorName: floorName,
    floorNumber: floorNumber,
    slotType: slotType,
    reservedAt: reservedAt ?? DateTime.now(),
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 5)),
    isActive: isActive,
  );
}
