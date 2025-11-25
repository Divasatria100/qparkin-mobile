import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/timer_state.dart';

void main() {
  group('TimerState Progress Calculation', () {
    test('calculateProgress returns correct value for booking mode', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final endTime = DateTime(2024, 1, 15, 12, 0); // 2 hours booking
      final elapsed = const Duration(hours: 1); // 1 hour elapsed

      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: const Duration(hours: 1),
        endTime: endTime,
        startTime: startTime,
      );

      expect(progress, equals(0.5)); // 50% complete
    });

    test('calculateProgress returns 1.0 when booking time exceeded', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final endTime = DateTime(2024, 1, 15, 12, 0);
      final elapsed = const Duration(hours: 3); // Exceeded by 1 hour

      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: Duration.zero,
        endTime: endTime,
        startTime: startTime,
      );

      expect(progress, equals(1.0));
    });

    test('calculateProgress handles non-booking mode with 24-hour cycle', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final elapsed = const Duration(hours: 6); // 6 hours elapsed

      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: null,
        endTime: null,
        startTime: startTime,
      );

      expect(progress, equals(0.25)); // 6/24 = 0.25
    });

    test('calculateProgress wraps around in non-booking mode after 24 hours', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final elapsed = const Duration(hours: 30); // 30 hours

      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: null,
        endTime: null,
        startTime: startTime,
      );

      expect(progress, equals(0.25)); // (30 % 24) / 24 = 6/24 = 0.25
    });

    test('calculateProgress returns 0.0 at start', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final endTime = DateTime(2024, 1, 15, 12, 0);
      final elapsed = Duration.zero;

      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: const Duration(hours: 2),
        endTime: endTime,
        startTime: startTime,
      );

      expect(progress, equals(0.0));
    });

    test('calculateProgress clamps negative values to 0.0', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final endTime = DateTime(2024, 1, 15, 10, 0); // Same as start
      final elapsed = Duration.zero;

      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: Duration.zero,
        endTime: endTime,
        startTime: startTime,
      );

      expect(progress, greaterThanOrEqualTo(0.0));
    });
  });

  group('TimerState Duration Formatting', () {
    test('getFormattedElapsed formats duration correctly', () {
      final state = TimerState(
        elapsed: const Duration(hours: 2, minutes: 30, seconds: 45),
        progress: 0.5,
        isOvertime: false,
        currentCost: 10000,
      );

      expect(state.getFormattedElapsed(), equals('02:30:45'));
    });

    test('getFormattedRemaining formats duration correctly', () {
      final state = TimerState(
        elapsed: const Duration(hours: 1),
        remaining: const Duration(hours: 1, minutes: 15, seconds: 30),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
      );

      expect(state.getFormattedRemaining(), equals('01:15:30'));
    });

    test('getFormattedRemaining returns null when no remaining time', () {
      final state = TimerState(
        elapsed: const Duration(hours: 2),
        remaining: null,
        progress: 0.5,
        isOvertime: false,
        currentCost: 10000,
      );

      expect(state.getFormattedRemaining(), isNull);
    });

    test('formats single digit values with leading zeros', () {
      final state = TimerState(
        elapsed: const Duration(hours: 1, minutes: 5, seconds: 9),
        progress: 0.1,
        isOvertime: false,
        currentCost: 5000,
      );

      expect(state.getFormattedElapsed(), equals('01:05:09'));
    });

    test('formats zero duration correctly', () {
      final state = TimerState(
        elapsed: Duration.zero,
        progress: 0.0,
        isOvertime: false,
        currentCost: 0,
      );

      expect(state.getFormattedElapsed(), equals('00:00:00'));
    });
  });

  group('TimerState JSON Serialization', () {
    test('fromJson creates state with all fields', () {
      final json = {
        'elapsed_seconds': 3600,
        'remaining_seconds': 1800,
        'progress': 0.5,
        'is_overtime': false,
        'current_cost': 10000.0,
        'penalty_amount': 2000.0,
      };

      final state = TimerState.fromJson(json);

      expect(state.elapsed.inSeconds, equals(3600));
      expect(state.remaining?.inSeconds, equals(1800));
      expect(state.progress, equals(0.5));
      expect(state.isOvertime, isFalse);
      expect(state.currentCost, equals(10000.0));
      expect(state.penaltyAmount, equals(2000.0));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'elapsed_seconds': 3600,
        'progress': 0.5,
        'is_overtime': false,
        'current_cost': 10000.0,
      };

      final state = TimerState.fromJson(json);

      expect(state.remaining, isNull);
      expect(state.penaltyAmount, isNull);
    });

    test('fromJson parses cost from string', () {
      final json = {
        'elapsed_seconds': 3600,
        'progress': 0.5,
        'is_overtime': false,
        'current_cost': '10000',
      };

      final state = TimerState.fromJson(json);

      expect(state.currentCost, equals(10000.0));
    });

    test('toJson creates correct JSON structure', () {
      final state = TimerState(
        elapsed: const Duration(hours: 1),
        remaining: const Duration(minutes: 30),
        progress: 0.5,
        isOvertime: false,
        currentCost: 10000.0,
        penaltyAmount: 2000.0,
      );

      final json = state.toJson();

      expect(json['elapsed_seconds'], equals(3600));
      expect(json['remaining_seconds'], equals(1800));
      expect(json['progress'], equals(0.5));
      expect(json['is_overtime'], isFalse);
      expect(json['current_cost'], equals(10000.0));
      expect(json['penalty_amount'], equals(2000.0));
    });

    test('toJson and fromJson round trip preserves data', () {
      final original = TimerState(
        elapsed: const Duration(hours: 2, minutes: 15),
        remaining: const Duration(minutes: 45),
        progress: 0.75,
        isOvertime: true,
        currentCost: 15000.0,
        penaltyAmount: 3000.0,
      );

      final json = original.toJson();
      final restored = TimerState.fromJson(json);

      expect(restored.elapsed, equals(original.elapsed));
      expect(restored.remaining, equals(original.remaining));
      expect(restored.progress, equals(original.progress));
      expect(restored.isOvertime, equals(original.isOvertime));
      expect(restored.currentCost, equals(original.currentCost));
      expect(restored.penaltyAmount, equals(original.penaltyAmount));
    });
  });

  group('TimerState Factory and Helpers', () {
    test('initial creates state with zero values', () {
      final state = TimerState.initial();

      expect(state.elapsed, equals(Duration.zero));
      expect(state.remaining, isNull);
      expect(state.progress, equals(0.0));
      expect(state.isOvertime, isFalse);
      expect(state.currentCost, equals(0.0));
      expect(state.penaltyAmount, isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = TimerState(
        elapsed: const Duration(hours: 1),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
      );

      final updated = original.copyWith(
        elapsed: const Duration(hours: 2),
        isOvertime: true,
      );

      expect(updated.elapsed.inHours, equals(2));
      expect(updated.isOvertime, isTrue);
      expect(updated.progress, equals(0.5)); // Unchanged
      expect(updated.currentCost, equals(5000)); // Unchanged
    });

    test('copyWith preserves unchanged fields', () {
      final original = TimerState(
        elapsed: const Duration(hours: 1),
        remaining: const Duration(minutes: 30),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
        penaltyAmount: 1000,
      );

      final updated = original.copyWith(progress: 0.75);

      expect(updated.elapsed, equals(original.elapsed));
      expect(updated.remaining, equals(original.remaining));
      expect(updated.isOvertime, equals(original.isOvertime));
      expect(updated.currentCost, equals(original.currentCost));
      expect(updated.penaltyAmount, equals(original.penaltyAmount));
    });
  });

  group('TimerState Equality and HashCode', () {
    test('equal states have same hashCode', () {
      final state1 = TimerState(
        elapsed: const Duration(hours: 1),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
      );

      final state2 = TimerState(
        elapsed: const Duration(hours: 1),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
      );

      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('equal states are equal', () {
      final state1 = TimerState(
        elapsed: const Duration(hours: 1),
        remaining: const Duration(minutes: 30),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
        penaltyAmount: 1000,
      );

      final state2 = TimerState(
        elapsed: const Duration(hours: 1),
        remaining: const Duration(minutes: 30),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
        penaltyAmount: 1000,
      );

      expect(state1, equals(state2));
    });

    test('different states are not equal', () {
      final state1 = TimerState(
        elapsed: const Duration(hours: 1),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
      );

      final state2 = TimerState(
        elapsed: const Duration(hours: 2),
        progress: 0.5,
        isOvertime: false,
        currentCost: 5000,
      );

      expect(state1, isNot(equals(state2)));
    });
  });

  group('TimerState toString', () {
    test('toString includes all relevant information', () {
      final state = TimerState(
        elapsed: const Duration(hours: 2, minutes: 30),
        remaining: const Duration(minutes: 45),
        progress: 0.75,
        isOvertime: false,
        currentCost: 15000,
        penaltyAmount: 3000,
      );

      final str = state.toString();

      expect(str, contains('02:30:00'));
      expect(str, contains('00:45:00'));
      expect(str, contains('75.0%'));
      expect(str, contains('15000'));
      expect(str, contains('3000'));
    });
  });
}
