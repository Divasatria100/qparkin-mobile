import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/booking_validator.dart';

void main() {
  group('BookingValidator - validateStartTime', () {
    group('Null and Invalid Cases', () {
      test('returns error for null start time', () {
        final error = BookingValidator.validateStartTime(null);
        expect(error, equals('Waktu mulai wajib dipilih'));
      });
    });

    group('Past Time Validation', () {
      test('returns error for time in the past', () {
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));
        final error = BookingValidator.validateStartTime(pastTime);
        expect(error, equals('Waktu mulai tidak boleh di masa lalu'));
      });

      test('returns error for time 1 minute in the past', () {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
        final error = BookingValidator.validateStartTime(pastTime);
        expect(error, equals('Waktu mulai tidak boleh di masa lalu'));
      });

      test('returns error for time 1 day in the past', () {
        final pastTime = DateTime.now().subtract(const Duration(days: 1));
        final error = BookingValidator.validateStartTime(pastTime);
        expect(error, equals('Waktu mulai tidak boleh di masa lalu'));
      });
    });

    group('Minimum Buffer Time Validation', () {
      test('returns error for time less than 15 minutes from now', () {
        final tooSoon = DateTime.now().add(const Duration(minutes: 10));
        final error = BookingValidator.validateStartTime(tooSoon);
        expect(
          error,
          equals('Booking harus dilakukan minimal 15 menit sebelum waktu mulai'),
        );
      });

      test('returns error for time exactly 14 minutes from now', () {
        final tooSoon = DateTime.now().add(const Duration(minutes: 14));
        final error = BookingValidator.validateStartTime(tooSoon);
        expect(
          error,
          equals('Booking harus dilakukan minimal 15 menit sebelum waktu mulai'),
        );
      });

      test('returns error for time 5 minutes from now', () {
        final tooSoon = DateTime.now().add(const Duration(minutes: 5));
        final error = BookingValidator.validateStartTime(tooSoon);
        expect(
          error,
          equals('Booking harus dilakukan minimal 15 menit sebelum waktu mulai'),
        );
      });
    });

    group('Maximum Future Time Validation', () {
      test('returns error for time more than 7 days in the future', () {
        final tooFar = DateTime.now().add(const Duration(days: 8));
        final error = BookingValidator.validateStartTime(tooFar);
        expect(
          error,
          equals('Booking hanya dapat dilakukan maksimal 7 hari ke depan'),
        );
      });

      test('returns error for time 10 days in the future', () {
        final tooFar = DateTime.now().add(const Duration(days: 10));
        final error = BookingValidator.validateStartTime(tooFar);
        expect(
          error,
          equals('Booking hanya dapat dilakukan maksimal 7 hari ke depan'),
        );
      });

      test('returns error for time 30 days in the future', () {
        final tooFar = DateTime.now().add(const Duration(days: 30));
        final error = BookingValidator.validateStartTime(tooFar);
        expect(
          error,
          equals('Booking hanya dapat dilakukan maksimal 7 hari ke depan'),
        );
      });
    });

    group('Valid Start Time Cases', () {
      test('returns null for time exactly 15 minutes from now', () {
        final validTime = DateTime.now().add(const Duration(minutes: 15));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });

      test('returns null for time 30 minutes from now', () {
        final validTime = DateTime.now().add(const Duration(minutes: 30));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });

      test('returns null for time 1 hour from now', () {
        final validTime = DateTime.now().add(const Duration(hours: 1));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });

      test('returns null for time 2 hours from now', () {
        final validTime = DateTime.now().add(const Duration(hours: 2));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });

      test('returns null for time 1 day from now', () {
        final validTime = DateTime.now().add(const Duration(days: 1));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });

      test('returns null for time 3 days from now', () {
        final validTime = DateTime.now().add(const Duration(days: 3));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });

      test('returns null for time exactly 7 days from now', () {
        final validTime = DateTime.now().add(const Duration(days: 7));
        final error = BookingValidator.validateStartTime(validTime);
        expect(error, isNull);
      });
    });
  });

  group('BookingValidator - validateDuration', () {
    group('Null and Invalid Cases', () {
      test('returns error for null duration', () {
        final error = BookingValidator.validateDuration(null);
        expect(error, equals('Durasi booking wajib dipilih'));
      });
    });

    group('Minimum Duration Validation', () {
      test('returns error for duration less than 30 minutes', () {
        final tooShort = const Duration(minutes: 15);
        final error = BookingValidator.validateDuration(tooShort);
        expect(error, equals('Durasi booking minimal 30 menit'));
      });

      test('returns error for duration of 29 minutes', () {
        final tooShort = const Duration(minutes: 29);
        final error = BookingValidator.validateDuration(tooShort);
        expect(error, equals('Durasi booking minimal 30 menit'));
      });

      test('returns error for duration of 10 minutes', () {
        final tooShort = const Duration(minutes: 10);
        final error = BookingValidator.validateDuration(tooShort);
        expect(error, equals('Durasi booking minimal 30 menit'));
      });

      test('returns error for duration of 1 minute', () {
        final tooShort = const Duration(minutes: 1);
        final error = BookingValidator.validateDuration(tooShort);
        expect(error, equals('Durasi booking minimal 30 menit'));
      });

      test('returns error for zero duration', () {
        final tooShort = Duration.zero;
        final error = BookingValidator.validateDuration(tooShort);
        expect(error, equals('Durasi booking minimal 30 menit'));
      });
    });

    group('Maximum Duration Validation', () {
      test('returns error for duration more than 12 hours', () {
        final tooLong = const Duration(hours: 13);
        final error = BookingValidator.validateDuration(tooLong);
        expect(error, equals('Durasi booking maksimal 12 jam'));
      });

      test('returns error for duration of 15 hours', () {
        final tooLong = const Duration(hours: 15);
        final error = BookingValidator.validateDuration(tooLong);
        expect(error, equals('Durasi booking maksimal 12 jam'));
      });

      test('returns error for duration of 24 hours', () {
        final tooLong = const Duration(hours: 24);
        final error = BookingValidator.validateDuration(tooLong);
        expect(error, equals('Durasi booking maksimal 12 jam'));
      });

      test('returns error for duration of 12 hours 1 minute', () {
        final tooLong = const Duration(hours: 12, minutes: 1);
        final error = BookingValidator.validateDuration(tooLong);
        expect(error, equals('Durasi booking maksimal 12 jam'));
      });
    });

    group('Valid Duration Cases', () {
      test('returns null for duration of exactly 30 minutes', () {
        final validDuration = const Duration(minutes: 30);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of 45 minutes', () {
        final validDuration = const Duration(minutes: 45);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of 1 hour', () {
        final validDuration = const Duration(hours: 1);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of 2 hours', () {
        final validDuration = const Duration(hours: 2);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of 2 hours 30 minutes', () {
        final validDuration = const Duration(hours: 2, minutes: 30);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of 6 hours', () {
        final validDuration = const Duration(hours: 6);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of exactly 12 hours', () {
        final validDuration = const Duration(hours: 12);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });

      test('returns null for duration of 11 hours 59 minutes', () {
        final validDuration = const Duration(hours: 11, minutes: 59);
        final error = BookingValidator.validateDuration(validDuration);
        expect(error, isNull);
      });
    });
  });

  group('BookingValidator - validateVehicle', () {
    group('Null and Empty Cases', () {
      test('returns error for null vehicle ID', () {
        final error = BookingValidator.validateVehicle(null);
        expect(error, equals('Kendaraan wajib dipilih'));
      });

      test('returns error for empty string vehicle ID', () {
        final error = BookingValidator.validateVehicle('');
        expect(error, equals('Kendaraan wajib dipilih'));
      });

      test('returns error for whitespace-only vehicle ID', () {
        final error = BookingValidator.validateVehicle('   ');
        expect(error, equals('Kendaraan wajib dipilih'));
      });

      test('returns error for tab-only vehicle ID', () {
        final error = BookingValidator.validateVehicle('\t');
        expect(error, equals('Kendaraan wajib dipilih'));
      });

      test('returns error for newline-only vehicle ID', () {
        final error = BookingValidator.validateVehicle('\n');
        expect(error, equals('Kendaraan wajib dipilih'));
      });
    });

    group('Valid Vehicle ID Cases', () {
      test('returns null for valid vehicle ID', () {
        final error = BookingValidator.validateVehicle('VH123');
        expect(error, isNull);
      });

      test('returns null for numeric vehicle ID', () {
        final error = BookingValidator.validateVehicle('12345');
        expect(error, isNull);
      });

      test('returns null for UUID-like vehicle ID', () {
        final error = BookingValidator.validateVehicle(
          '550e8400-e29b-41d4-a716-446655440000',
        );
        expect(error, isNull);
      });

      test('returns null for alphanumeric vehicle ID', () {
        final error = BookingValidator.validateVehicle('ABC123XYZ');
        expect(error, isNull);
      });

      test('returns null for vehicle ID with special characters', () {
        final error = BookingValidator.validateVehicle('VH-123_456');
        expect(error, isNull);
      });

      test('returns null for single character vehicle ID', () {
        final error = BookingValidator.validateVehicle('A');
        expect(error, isNull);
      });

      test('returns null for vehicle ID with leading/trailing spaces (trimmed)', () {
        final error = BookingValidator.validateVehicle('  VH123  ');
        expect(error, isNull);
      });
    });
  });

  group('BookingValidator - validateAll', () {
    test('returns empty map when all inputs are valid', () {
      final validStartTime = DateTime.now().add(const Duration(hours: 2));
      final validDuration = const Duration(hours: 2);
      const validVehicleId = 'VH123';

      final errors = BookingValidator.validateAll(
        startTime: validStartTime,
        duration: validDuration,
        vehicleId: validVehicleId,
      );

      expect(errors, isEmpty);
    });

    test('returns all errors when all inputs are invalid', () {
      final invalidStartTime = DateTime.now().subtract(const Duration(hours: 1));
      final invalidDuration = const Duration(minutes: 10);
      const invalidVehicleId = '';

      final errors = BookingValidator.validateAll(
        startTime: invalidStartTime,
        duration: invalidDuration,
        vehicleId: invalidVehicleId,
      );

      expect(errors, hasLength(3));
      expect(errors['startTime'], equals('Waktu mulai tidak boleh di masa lalu'));
      expect(errors['duration'], equals('Durasi booking minimal 30 menit'));
      expect(errors['vehicleId'], equals('Kendaraan wajib dipilih'));
    });

    test('returns only startTime error when only startTime is invalid', () {
      final invalidStartTime = DateTime.now().subtract(const Duration(hours: 1));
      final validDuration = const Duration(hours: 2);
      const validVehicleId = 'VH123';

      final errors = BookingValidator.validateAll(
        startTime: invalidStartTime,
        duration: validDuration,
        vehicleId: validVehicleId,
      );

      expect(errors, hasLength(1));
      expect(errors['startTime'], equals('Waktu mulai tidak boleh di masa lalu'));
      expect(errors.containsKey('duration'), isFalse);
      expect(errors.containsKey('vehicleId'), isFalse);
    });

    test('returns only duration error when only duration is invalid', () {
      final validStartTime = DateTime.now().add(const Duration(hours: 2));
      final invalidDuration = const Duration(minutes: 10);
      const validVehicleId = 'VH123';

      final errors = BookingValidator.validateAll(
        startTime: validStartTime,
        duration: invalidDuration,
        vehicleId: validVehicleId,
      );

      expect(errors, hasLength(1));
      expect(errors['duration'], equals('Durasi booking minimal 30 menit'));
      expect(errors.containsKey('startTime'), isFalse);
      expect(errors.containsKey('vehicleId'), isFalse);
    });

    test('returns only vehicleId error when only vehicleId is invalid', () {
      final validStartTime = DateTime.now().add(const Duration(hours: 2));
      final validDuration = const Duration(hours: 2);
      const invalidVehicleId = '';

      final errors = BookingValidator.validateAll(
        startTime: validStartTime,
        duration: validDuration,
        vehicleId: invalidVehicleId,
      );

      expect(errors, hasLength(1));
      expect(errors['vehicleId'], equals('Kendaraan wajib dipilih'));
      expect(errors.containsKey('startTime'), isFalse);
      expect(errors.containsKey('duration'), isFalse);
    });

    test('returns multiple errors when multiple inputs are invalid', () {
      final invalidStartTime = DateTime.now().add(const Duration(minutes: 5));
      final invalidDuration = const Duration(hours: 15);
      const validVehicleId = 'VH123';

      final errors = BookingValidator.validateAll(
        startTime: invalidStartTime,
        duration: invalidDuration,
        vehicleId: validVehicleId,
      );

      expect(errors, hasLength(2));
      expect(
        errors['startTime'],
        equals('Booking harus dilakukan minimal 15 menit sebelum waktu mulai'),
      );
      expect(errors['duration'], equals('Durasi booking maksimal 12 jam'));
      expect(errors.containsKey('vehicleId'), isFalse);
    });

    test('handles null values for all inputs', () {
      final errors = BookingValidator.validateAll(
        startTime: null,
        duration: null,
        vehicleId: null,
      );

      expect(errors, hasLength(3));
      expect(errors['startTime'], equals('Waktu mulai wajib dipilih'));
      expect(errors['duration'], equals('Durasi booking wajib dipilih'));
      expect(errors['vehicleId'], equals('Kendaraan wajib dipilih'));
    });
  });

  group('BookingValidator - isValid', () {
    test('returns true when all inputs are valid', () {
      final validStartTime = DateTime.now().add(const Duration(hours: 2));
      final validDuration = const Duration(hours: 2);
      const validVehicleId = 'VH123';

      final isValid = BookingValidator.isValid(
        startTime: validStartTime,
        duration: validDuration,
        vehicleId: validVehicleId,
      );

      expect(isValid, isTrue);
    });

    test('returns false when any input is invalid', () {
      final invalidStartTime = DateTime.now().subtract(const Duration(hours: 1));
      final validDuration = const Duration(hours: 2);
      const validVehicleId = 'VH123';

      final isValid = BookingValidator.isValid(
        startTime: invalidStartTime,
        duration: validDuration,
        vehicleId: validVehicleId,
      );

      expect(isValid, isFalse);
    });

    test('returns false when all inputs are invalid', () {
      final invalidStartTime = DateTime.now().subtract(const Duration(hours: 1));
      final invalidDuration = const Duration(minutes: 10);
      const invalidVehicleId = '';

      final isValid = BookingValidator.isValid(
        startTime: invalidStartTime,
        duration: invalidDuration,
        vehicleId: invalidVehicleId,
      );

      expect(isValid, isFalse);
    });

    test('returns false when all inputs are null', () {
      final isValid = BookingValidator.isValid(
        startTime: null,
        duration: null,
        vehicleId: null,
      );

      expect(isValid, isFalse);
    });
  });

  group('BookingValidator - formatDuration', () {
    test('formats duration with only hours', () {
      final formatted = BookingValidator.formatDuration(
        const Duration(hours: 2),
      );
      expect(formatted, equals('2 jam'));
    });

    test('formats duration with only minutes', () {
      final formatted = BookingValidator.formatDuration(
        const Duration(minutes: 30),
      );
      expect(formatted, equals('30 menit'));
    });

    test('formats duration with hours and minutes', () {
      final formatted = BookingValidator.formatDuration(
        const Duration(hours: 2, minutes: 30),
      );
      expect(formatted, equals('2 jam 30 menit'));
    });

    test('formats duration of 1 hour', () {
      final formatted = BookingValidator.formatDuration(
        const Duration(hours: 1),
      );
      expect(formatted, equals('1 jam'));
    });

    test('formats duration of 1 hour 1 minute', () {
      final formatted = BookingValidator.formatDuration(
        const Duration(hours: 1, minutes: 1),
      );
      expect(formatted, equals('1 jam 1 menit'));
    });

    test('formats duration of 12 hours', () {
      final formatted = BookingValidator.formatDuration(
        const Duration(hours: 12),
      );
      expect(formatted, equals('12 jam'));
    });
  });

  group('BookingValidator - validateEndTime', () {
    test('returns null when both startTime and duration are null', () {
      final error = BookingValidator.validateEndTime(null, null);
      expect(error, isNull);
    });

    test('returns null when startTime is null', () {
      final error = BookingValidator.validateEndTime(
        null,
        const Duration(hours: 2),
      );
      expect(error, isNull);
    });

    test('returns null when duration is null', () {
      final validStartTime = DateTime.now().add(const Duration(hours: 2));
      final error = BookingValidator.validateEndTime(validStartTime, null);
      expect(error, isNull);
    });

    test('returns null for valid end time within limits', () {
      final validStartTime = DateTime.now().add(const Duration(hours: 2));
      final validDuration = const Duration(hours: 2);
      final error = BookingValidator.validateEndTime(
        validStartTime,
        validDuration,
      );
      expect(error, isNull);
    });

    test('returns null for end time at maximum limit (7 days + 12 hours)', () {
      final validStartTime = DateTime.now().add(const Duration(days: 7));
      final validDuration = const Duration(hours: 12);
      final error = BookingValidator.validateEndTime(
        validStartTime,
        validDuration,
      );
      expect(error, isNull);
    });

    test('returns error when end time exceeds maximum limit', () {
      final startTime = DateTime.now().add(const Duration(days: 7));
      final duration = const Duration(hours: 13);
      final error = BookingValidator.validateEndTime(startTime, duration);
      expect(error, equals('Waktu selesai booking melebihi batas maksimal'));
    });

    test('returns error when end time is far beyond maximum limit', () {
      final startTime = DateTime.now().add(const Duration(days: 10));
      final duration = const Duration(hours: 12);
      final error = BookingValidator.validateEndTime(startTime, duration);
      expect(error, equals('Waktu selesai booking melebihi batas maksimal'));
    });
  });
}
