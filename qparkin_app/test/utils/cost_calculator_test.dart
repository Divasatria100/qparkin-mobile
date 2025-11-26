import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/cost_calculator.dart';

void main() {
  group('CostCalculator - estimateCost', () {
    group('First Hour Calculation', () {
      test('charges first hour rate for exactly 1 hour', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 1.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        expect(cost, equals(5000));
      });

      test('charges first hour rate for less than 1 hour', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 0.5,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        expect(cost, equals(5000));
      });

      test('charges first hour rate for 0.25 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 0.25,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        expect(cost, equals(5000));
      });
    });

    group('Additional Hours Calculation', () {
      test('calculates cost for exactly 2 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 2.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 1 additional hour (3000) = 8000
        expect(cost, equals(8000));
      });

      test('calculates cost for exactly 3 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 3.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 2 additional hours (6000) = 11000
        expect(cost, equals(11000));
      });

      test('rounds up fractional hours for 2.5 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 2.5,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 2 additional hours (6000) = 11000
        // 1.5 hours rounds up to 2 hours
        expect(cost, equals(11000));
      });

      test('rounds up fractional hours for 2.1 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 2.1,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 2 additional hours (6000) = 11000
        // 1.1 hours rounds up to 2 hours
        expect(cost, equals(11000));
      });

      test('calculates cost for 5 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 5.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 4 additional hours (12000) = 17000
        expect(cost, equals(17000));
      });
    });

    group('Different Vehicle Types (via tariff rates)', () {
      test('calculates cost for motorcycle rates', () {
        // Motorcycle: typically lower rates
        final cost = CostCalculator.estimateCost(
          durationHours: 3.0,
          firstHourRate: 2000,
          additionalHourRate: 1000,
        );

        // First hour (2000) + 2 additional hours (2000) = 4000
        expect(cost, equals(4000));
      });

      test('calculates cost for car rates', () {
        // Car: medium rates
        final cost = CostCalculator.estimateCost(
          durationHours: 3.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 2 additional hours (6000) = 11000
        expect(cost, equals(11000));
      });

      test('calculates cost for truck rates', () {
        // Truck: higher rates
        final cost = CostCalculator.estimateCost(
          durationHours: 3.0,
          firstHourRate: 10000,
          additionalHourRate: 7000,
        );

        // First hour (10000) + 2 additional hours (14000) = 24000
        expect(cost, equals(24000));
      });

      test('handles different rate structures', () {
        // Test with different first hour vs additional hour rates
        final cost = CostCalculator.estimateCost(
          durationHours: 4.0,
          firstHourRate: 8000,
          additionalHourRate: 4000,
        );

        // First hour (8000) + 3 additional hours (12000) = 20000
        expect(cost, equals(20000));
      });
    });

    group('Edge Cases', () {
      test('returns 0 for 0 hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 0.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        expect(cost, equals(0.0));
      });

      test('returns 0 for negative duration', () {
        final cost = CostCalculator.estimateCost(
          durationHours: -1.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        expect(cost, equals(0.0));
      });

      test('handles very small fractional hours', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 0.01,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        expect(cost, equals(5000));
      });

      test('handles maximum duration (12 hours)', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 12.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 11 additional hours (33000) = 38000
        expect(cost, equals(38000));
      });

      test('handles large duration beyond typical maximum', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 24.0,
          firstHourRate: 5000,
          additionalHourRate: 3000,
        );

        // First hour (5000) + 23 additional hours (69000) = 74000
        expect(cost, equals(74000));
      });

      test('handles zero rates', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 3.0,
          firstHourRate: 0,
          additionalHourRate: 0,
        );

        expect(cost, equals(0.0));
      });

      test('handles fractional rates', () {
        final cost = CostCalculator.estimateCost(
          durationHours: 2.0,
          firstHourRate: 5500.50,
          additionalHourRate: 3200.75,
        );

        // First hour (5500.50) + 1 additional hour (3200.75) = 8701.25
        expect(cost, equals(8701.25));
      });
    });
  });

  group('CostCalculator - formatCurrency', () {
    test('formats thousands correctly', () {
      final formatted = CostCalculator.formatCurrency(5000);
      expect(formatted, equals('Rp 5.000'));
    });

    test('formats tens of thousands correctly', () {
      final formatted = CostCalculator.formatCurrency(15000);
      expect(formatted, equals('Rp 15.000'));
    });

    test('formats hundreds of thousands correctly', () {
      final formatted = CostCalculator.formatCurrency(150000);
      expect(formatted, equals('Rp 150.000'));
    });

    test('formats millions correctly', () {
      final formatted = CostCalculator.formatCurrency(1500000);
      expect(formatted, equals('Rp 1.500.000'));
    });

    test('formats zero correctly', () {
      final formatted = CostCalculator.formatCurrency(0);
      expect(formatted, equals('Rp 0'));
    });

    test('formats decimals when showDecimals is true', () {
      final formatted = CostCalculator.formatCurrency(5000.50, showDecimals: true);
      expect(formatted, equals('Rp 5.000,50'));
    });

    test('hides decimals when showDecimals is false', () {
      final formatted = CostCalculator.formatCurrency(5000.50, showDecimals: false);
      expect(formatted, equals('Rp 5.000'));
    });

    test('handles negative amounts', () {
      final formatted = CostCalculator.formatCurrency(-5000);
      expect(formatted, equals('-Rp 5.000'));
    });
  });

  group('CostCalculator - generateCostBreakdown', () {
    test('generates breakdown for 1 hour', () {
      final breakdown = CostCalculator.generateCostBreakdown(
        durationHours: 1.0,
        firstHourRate: 5000,
        additionalHourRate: 3000,
      );

      expect(breakdown['firstHourCost'], equals(5000.0));
      expect(breakdown['additionalHoursCost'], equals(0.0));
      expect(breakdown['additionalHoursCount'], equals(0));
      expect(breakdown['totalCost'], equals(5000.0));
      expect(breakdown['formattedFirstHour'], equals('Rp 5.000'));
      expect(breakdown['formattedAdditionalHours'], equals('Rp 0'));
      expect(breakdown['formattedTotal'], equals('Rp 5.000'));
    });

    test('generates breakdown for 3 hours', () {
      final breakdown = CostCalculator.generateCostBreakdown(
        durationHours: 3.0,
        firstHourRate: 5000,
        additionalHourRate: 3000,
      );

      expect(breakdown['firstHourCost'], equals(5000.0));
      expect(breakdown['additionalHoursCost'], equals(6000.0));
      expect(breakdown['additionalHoursCount'], equals(2));
      expect(breakdown['totalCost'], equals(11000.0));
      expect(breakdown['formattedFirstHour'], equals('Rp 5.000'));
      expect(breakdown['formattedAdditionalHours'], equals('Rp 6.000'));
      expect(breakdown['formattedTotal'], equals('Rp 11.000'));
    });

    test('generates breakdown for fractional hours', () {
      final breakdown = CostCalculator.generateCostBreakdown(
        durationHours: 2.5,
        firstHourRate: 5000,
        additionalHourRate: 3000,
      );

      expect(breakdown['firstHourCost'], equals(5000.0));
      expect(breakdown['additionalHoursCost'], equals(6000.0));
      expect(breakdown['additionalHoursCount'], equals(2)); // Rounded up
      expect(breakdown['totalCost'], equals(11000.0));
    });

    test('generates breakdown for 0 hours', () {
      final breakdown = CostCalculator.generateCostBreakdown(
        durationHours: 0.0,
        firstHourRate: 5000,
        additionalHourRate: 3000,
      );

      expect(breakdown['firstHourCost'], equals(0.0));
      expect(breakdown['additionalHoursCost'], equals(0.0));
      expect(breakdown['additionalHoursCount'], equals(0));
      expect(breakdown['totalCost'], equals(0.0));
      expect(breakdown['formattedTotal'], equals('Rp 0'));
    });
  });

  group('CostCalculator - minutesToHours', () {
    test('converts 60 minutes to 1 hour', () {
      final hours = CostCalculator.minutesToHours(60);
      expect(hours, equals(1.0));
    });

    test('converts 90 minutes to 1.5 hours', () {
      final hours = CostCalculator.minutesToHours(90);
      expect(hours, equals(1.5));
    });

    test('converts 150 minutes to 2.5 hours', () {
      final hours = CostCalculator.minutesToHours(150);
      expect(hours, equals(2.5));
    });

    test('converts 0 minutes to 0 hours', () {
      final hours = CostCalculator.minutesToHours(0);
      expect(hours, equals(0.0));
    });
  });

  group('CostCalculator - durationToHours', () {
    test('converts Duration of 1 hour', () {
      final hours = CostCalculator.durationToHours(const Duration(hours: 1));
      expect(hours, equals(1.0));
    });

    test('converts Duration of 2 hours 30 minutes', () {
      final hours = CostCalculator.durationToHours(
        const Duration(hours: 2, minutes: 30),
      );
      expect(hours, equals(2.5));
    });

    test('converts Duration of 0', () {
      final hours = CostCalculator.durationToHours(Duration.zero);
      expect(hours, equals(0.0));
    });
  });

  group('CostCalculator - formatDuration', () {
    test('formats 1 hour', () {
      final formatted = CostCalculator.formatDuration(1.0);
      expect(formatted, equals('1 jam'));
    });

    test('formats 2.5 hours', () {
      final formatted = CostCalculator.formatDuration(2.5);
      expect(formatted, equals('2 jam 30 menit'));
    });

    test('formats 0.5 hours', () {
      final formatted = CostCalculator.formatDuration(0.5);
      expect(formatted, equals('30 menit'));
    });

    test('formats 0 hours', () {
      final formatted = CostCalculator.formatDuration(0.0);
      expect(formatted, equals('0 menit'));
    });

    test('formats 3 hours exactly', () {
      final formatted = CostCalculator.formatDuration(3.0);
      expect(formatted, equals('3 jam'));
    });
  });
}
