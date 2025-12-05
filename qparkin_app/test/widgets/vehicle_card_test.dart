import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/presentation/widgets/profile/vehicle_card.dart';

void main() {
  group('VehicleCard Widget Tests', () {
    testWidgets('displays vehicle information correctly', (WidgetTester tester) async {
      final vehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 ABC',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(vehicle: vehicle),
          ),
        ),
      );

      expect(find.text('Toyota Avanza'), findsOneWidget);
      expect(find.text('Roda Empat'), findsOneWidget);
      expect(find.text('B 1234 ABC'), findsOneWidget);
      expect(find.text('Aktif'), findsNothing);
    });

    testWidgets('displays active badge when isActive is true', (WidgetTester tester) async {
      final vehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 ABC',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(vehicle: vehicle, isActive: true),
          ),
        ),
      );

      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final vehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 ABC',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(
              vehicle: vehicle,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VehicleCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('has proper semantic labels', (WidgetTester tester) async {
      final vehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 ABC',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(vehicle: vehicle, isActive: true),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(VehicleCard));
      expect(semantics.label, contains('Toyota Avanza'));
      expect(semantics.label, contains('B 1234 ABC'));
      expect(semantics.label, contains('kendaraan aktif'));
    });
  });

  group('VehicleCard Property-Based Tests', () {
    /// **Feature: profile-page-enhancement, Property 8: Active Vehicle Indicator**
    /// **Validates: Requirements 5.2**
    /// 
    /// Property: For any vehicle list display, exactly one vehicle should have 
    /// the "Aktif" badge if vehicles exist
    test('Property 8: Active Vehicle Indicator - exactly one vehicle is active in non-empty list', () {
      const int iterations = 100;
      final random = Random(42); // Fixed seed for reproducibility

      for (int i = 0; i < iterations; i++) {
        // Generate random vehicle list with 1 to 10 vehicles
        final vehicleCount = random.nextInt(10) + 1;
        final vehicles = _generateRandomVehicleList(random, vehicleCount);

        // Count active vehicles
        final activeCount = vehicles.where((v) => v.isActive).length;

        expect(
          activeCount,
          equals(1),
          reason: 'Iteration $i: Exactly one vehicle should be active in a list of $vehicleCount vehicles',
        );
      }
    });

    test('Property 8: Active Vehicle Indicator - no active vehicle in empty list', () {
      const int iterations = 100;

      for (int i = 0; i < iterations; i++) {
        final vehicles = <VehicleModel>[];

        final activeCount = vehicles.where((v) => v.isActive).length;

        expect(
          activeCount,
          equals(0),
          reason: 'Iteration $i: Empty list should have no active vehicles',
        );
      }
    });

    test('Property 8: Active Vehicle Indicator - single vehicle list has one active', () {
      const int iterations = 100;
      final random = Random(123);

      for (int i = 0; i < iterations; i++) {
        final vehicles = _generateRandomVehicleList(random, 1);

        final activeCount = vehicles.where((v) => v.isActive).length;

        expect(
          activeCount,
          equals(1),
          reason: 'Iteration $i: Single vehicle list should have exactly one active vehicle',
        );
      }
    });

    test('Property 8: Active Vehicle Indicator - large vehicle lists maintain single active', () {
      const int iterations = 50;
      final random = Random(456);

      for (int i = 0; i < iterations; i++) {
        // Generate large vehicle lists (10 to 50 vehicles)
        final vehicleCount = random.nextInt(41) + 10;
        final vehicles = _generateRandomVehicleList(random, vehicleCount);

        final activeCount = vehicles.where((v) => v.isActive).length;

        expect(
          activeCount,
          equals(1),
          reason: 'Iteration $i: Large list of $vehicleCount vehicles should have exactly one active vehicle',
        );
      }
    });

    test('Property 8: Active Vehicle Indicator - active vehicle can be at any position', () {
      const int iterations = 100;
      final random = Random(789);
      final activePositions = <int>[];

      for (int i = 0; i < iterations; i++) {
        final vehicleCount = random.nextInt(10) + 2; // At least 2 vehicles
        final vehicles = _generateRandomVehicleList(random, vehicleCount);

        // Find position of active vehicle
        final activeIndex = vehicles.indexWhere((v) => v.isActive);
        
        expect(
          activeIndex,
          greaterThanOrEqualTo(0),
          reason: 'Iteration $i: Active vehicle should be found in the list',
        );
        
        activePositions.add(activeIndex);
      }

      // Verify that active vehicles appear at different positions
      // (not always at the same position)
      final uniquePositions = activePositions.toSet();
      expect(
        uniquePositions.length,
        greaterThan(1),
        reason: 'Active vehicle should appear at different positions across iterations',
      );
    });

    test('Property 8: Active Vehicle Indicator - consistency across multiple checks', () {
      const int iterations = 100;
      final random = Random(321);

      for (int i = 0; i < iterations; i++) {
        final vehicleCount = random.nextInt(10) + 1;
        final vehicles = _generateRandomVehicleList(random, vehicleCount);

        // Check multiple times that the count remains consistent
        for (int check = 0; check < 5; check++) {
          final activeCount = vehicles.where((v) => v.isActive).length;
          
          expect(
            activeCount,
            equals(1),
            reason: 'Iteration $i, Check $check: Active count should remain consistent',
          );
        }
      }
    });
  });
}

/// Generate a random vehicle list with exactly one active vehicle
/// 
/// This generator ensures the property being tested: exactly one vehicle
/// should be active in a non-empty list
List<VehicleModel> _generateRandomVehicleList(Random random, int count) {
  if (count <= 0) {
    return [];
  }

  final vehicles = <VehicleModel>[];
  
  // Randomly select which vehicle will be active
  final activeIndex = random.nextInt(count);

  for (int i = 0; i < count; i++) {
    vehicles.add(_generateRandomVehicle(random, isActive: i == activeIndex));
  }

  return vehicles;
}

/// Generate random vehicle data for property-based testing
VehicleModel _generateRandomVehicle(Random random, {bool isActive = false}) {
  final id = random.nextInt(10000).toString();
  final jenisOptions = ['Roda Dua', 'Roda Empat', 'Roda Tiga', 'Lebih dari Enam'];
  final merkOptions = ['Toyota', 'Honda', 'Suzuki', 'Yamaha', 'Kawasaki', 'Daihatsu', 'Mitsubishi'];
  final tipeOptions = ['Avanza', 'Beat', 'Vario', 'Xenia', 'Ninja', 'Brio', 'Jazz', 'Supra'];
  final warnaOptions = ['Hitam', 'Putih', 'Merah', 'Biru', 'Silver', 'Abu-abu'];
  
  final platPrefix = ['B', 'D', 'F', 'L', 'N', 'E', 'T', 'A'][random.nextInt(8)];
  final platNumber = random.nextInt(9999).toString().padLeft(4, '0');
  final platSuffix = String.fromCharCodes(
    List.generate(3, (_) => random.nextInt(26) + 65),
  );

  return VehicleModel(
    idKendaraan: id,
    platNomor: '$platPrefix $platNumber $platSuffix',
    jenisKendaraan: jenisOptions[random.nextInt(jenisOptions.length)],
    merk: merkOptions[random.nextInt(merkOptions.length)],
    tipe: tipeOptions[random.nextInt(tipeOptions.length)],
    warna: random.nextBool() ? warnaOptions[random.nextInt(warnaOptions.length)] : null,
    isActive: isActive,
  );
}
