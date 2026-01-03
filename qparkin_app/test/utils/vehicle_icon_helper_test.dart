// 📄 test/utils/vehicle_icon_helper_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/vehicle_icon_helper.dart';

void main() {
  group('VehicleIconHelper', () {
    group('getIcon', () {
      test('returns two_wheeler icon for Roda Dua', () {
        expect(
          VehicleIconHelper.getIcon('Roda Dua'),
          equals(Icons.two_wheeler),
        );
      });

      test('returns two_wheeler icon for roda dua (lowercase)', () {
        expect(
          VehicleIconHelper.getIcon('roda dua'),
          equals(Icons.two_wheeler),
        );
      });

      test('returns electric_rickshaw icon for Roda Tiga', () {
        expect(
          VehicleIconHelper.getIcon('Roda Tiga'),
          equals(Icons.electric_rickshaw),
        );
      });

      test('returns directions_car icon for Roda Empat', () {
        expect(
          VehicleIconHelper.getIcon('Roda Empat'),
          equals(Icons.directions_car),
        );
      });

      test('returns local_shipping icon for unknown type', () {
        expect(
          VehicleIconHelper.getIcon('Lebih dari Enam'),
          equals(Icons.local_shipping),
        );
      });

      test('returns local_shipping icon for empty string', () {
        expect(
          VehicleIconHelper.getIcon(''),
          equals(Icons.local_shipping),
        );
      });
    });

    group('getColor', () {
      test('returns teal for Roda Dua', () {
        expect(
          VehicleIconHelper.getColor('Roda Dua'),
          equals(const Color(0xFF009688)),
        );
      });

      test('returns orange for Roda Tiga', () {
        expect(
          VehicleIconHelper.getColor('Roda Tiga'),
          equals(const Color(0xFFFF9800)),
        );
      });

      test('returns blue for Roda Empat', () {
        expect(
          VehicleIconHelper.getColor('Roda Empat'),
          equals(const Color(0xFF1872B3)),
        );
      });

      test('returns grey for unknown type', () {
        expect(
          VehicleIconHelper.getColor('Lebih dari Enam'),
          equals(const Color(0xFF757575)),
        );
      });

      test('is case-insensitive', () {
        expect(
          VehicleIconHelper.getColor('RODA DUA'),
          equals(const Color(0xFF009688)),
        );
      });
    });

    group('getBackgroundColor', () {
      test('returns light teal background for Roda Dua', () {
        final bgColor = VehicleIconHelper.getBackgroundColor('Roda Dua');
        final expectedColor = const Color(0xFF009688).withOpacity(0.1);
        
        expect(bgColor.red, equals(expectedColor.red));
        expect(bgColor.green, equals(expectedColor.green));
        expect(bgColor.blue, equals(expectedColor.blue));
        expect(bgColor.opacity, closeTo(0.1, 0.01));
      });

      test('returns light orange background for Roda Tiga', () {
        final bgColor = VehicleIconHelper.getBackgroundColor('Roda Tiga');
        
        expect(bgColor.opacity, closeTo(0.1, 0.01));
      });

      test('returns light blue background for Roda Empat', () {
        final bgColor = VehicleIconHelper.getBackgroundColor('Roda Empat');
        final expectedColor = const Color(0xFF1872B3).withOpacity(0.1);
        
        expect(bgColor.red, equals(expectedColor.red));
        expect(bgColor.green, equals(expectedColor.green));
        expect(bgColor.blue, equals(expectedColor.blue));
        expect(bgColor.opacity, closeTo(0.1, 0.01));
      });
    });

    group('consistency', () {
      test('all vehicle types have matching icon and color', () {
        final vehicleTypes = [
          'Roda Dua',
          'Roda Tiga',
          'Roda Empat',
          'Lebih dari Enam',
        ];

        for (final type in vehicleTypes) {
          // Should not throw
          expect(() => VehicleIconHelper.getIcon(type), returnsNormally);
          expect(() => VehicleIconHelper.getColor(type), returnsNormally);
          expect(() => VehicleIconHelper.getBackgroundColor(type), returnsNormally);
        }
      });

      test('case variations produce same results', () {
        final variations = [
          'Roda Dua',
          'roda dua',
          'RODA DUA',
          'RoDa DuA',
        ];

        final expectedIcon = Icons.two_wheeler;
        final expectedColor = const Color(0xFF009688);

        for (final variation in variations) {
          expect(VehicleIconHelper.getIcon(variation), equals(expectedIcon));
          expect(VehicleIconHelper.getColor(variation), equals(expectedColor));
        }
      });
    });
  });
}
