import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/services/vehicle_api_service.dart';

/// Mock VehicleApiService for testing
class MockVehicleApiService extends VehicleApiService {
  MockVehicleApiService() : super(baseUrl: 'http://test.com/api');

  @override
  Future<List<VehicleModel>> getVehicles() async {
    return [];
  }

  @override
  Future<VehicleModel> addVehicle({
    required String platNomor,
    required String jenisKendaraan,
    required String merk,
    required String tipe,
    String? warna,
    bool isActive = false,
    dynamic foto,
  }) async {
    return VehicleModel(
      idKendaraan: '1',
      platNomor: platNomor,
      jenisKendaraan: jenisKendaraan,
      merk: merk,
      tipe: tipe,
      warna: warna,
      isActive: isActive,
    );
  }

  @override
  Future<VehicleModel> updateVehicle({
    required String id,
    String? platNomor,
    String? jenisKendaraan,
    String? merk,
    String? tipe,
    String? warna,
    bool? isActive,
    dynamic foto,
  }) async {
    return VehicleModel(
      idKendaraan: id,
      platNomor: platNomor ?? 'B 1234 ABC',
      jenisKendaraan: jenisKendaraan ?? 'Roda Empat',
      merk: merk ?? 'Toyota',
      tipe: tipe ?? 'Avanza',
      warna: warna,
      isActive: isActive ?? false,
    );
  }

  @override
  Future<void> deleteVehicle(String id) async {}

  @override
  Future<VehicleModel> setActiveVehicle(String id) async {
    return VehicleModel(
      idKendaraan: id,
      platNomor: 'B 1234 ABC',
      jenisKendaraan: 'Roda Empat',
      merk: 'Toyota',
      tipe: 'Avanza',
      isActive: true,
    );
  }
}

/// Property-based test for VehicleSelectionPage edit mode data prefilling
/// Tests universal properties that should hold across all valid inputs
/// 
/// **Feature: vehicle-edit-feature, Property 1: Edit mode initialization with data prefilling**
/// **Validates: Requirements 1.1, 1.2**
void main() {
  group('VehicleSelectionPage Edit Mode Property Tests', () {
    testWidgets(
      'Property 1: Edit mode initialization with data prefilling - '
      'For any VehicleModel object, when VehicleSelectionPage is initialized '
      'with isEditMode=true and that vehicle object, all form fields should be '
      'prefilled with the corresponding values from the vehicle object',
      (WidgetTester tester) async {
        // Run property test with 100 iterations as specified in design
        const int iterations = 100;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          // Generate random vehicle
          final vehicle = _generateRandomVehicle(i);
          final mockApiService = MockVehicleApiService();

          // Create widget with edit mode
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider(
                create: (_) => ProfileProvider(vehicleApiService: mockApiService),
                child: VehicleSelectionPage(
                  isEditMode: true,
                  vehicle: vehicle,
                ),
              ),
            ),
          );

          // Wait for widget to build
          await tester.pumpAndSettle();

          // Verify header shows "Tambah Kendaraan" (edit mode header will be implemented in later task)
          // For now, we verify the widget builds without error
          expect(find.byType(VehicleSelectionPage), findsOneWidget);

          // Verify text fields contain the correct values
          // Find TextFields by their label text
          final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
          final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
          final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
          final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');

          expect(brandField, findsOneWidget);
          expect(typeField, findsOneWidget);
          expect(plateField, findsOneWidget);
          expect(colorField, findsOneWidget);

          // Get the TextField widgets and verify their controllers have correct text
          final brandTextField = tester.widget<TextField>(brandField);
          final typeTextField = tester.widget<TextField>(typeField);
          final plateTextField = tester.widget<TextField>(plateField);
          final colorTextField = tester.widget<TextField>(colorField);

          expect(
            brandTextField.controller?.text,
            equals(vehicle.merk),
            reason: 'Iteration $i: Brand field should be prefilled with vehicle merk "${vehicle.merk}"',
          );

          expect(
            typeTextField.controller?.text,
            equals(vehicle.tipe),
            reason: 'Iteration $i: Type field should be prefilled with vehicle tipe "${vehicle.tipe}"',
          );

          expect(
            plateTextField.controller?.text,
            equals(vehicle.platNomor),
            reason: 'Iteration $i: Plate field should be prefilled with vehicle platNomor "${vehicle.platNomor}"',
          );

          expect(
            colorTextField.controller?.text,
            equals(vehicle.warna ?? ''),
            reason: 'Iteration $i: Color field should be prefilled with vehicle warna "${vehicle.warna ?? ''}"',
          );

          successCount++;
          
          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }

        // All iterations should succeed
        expect(
          successCount,
          equals(iterations),
          reason: 'All data prefilling tests should succeed',
        );
      },
    );

    testWidgets(
      'Property: Add mode should not prefill data',
      (WidgetTester tester) async {
        // Test with 50 iterations
        const int iterations = 50;

        for (int i = 0; i < iterations; i++) {
          final mockApiService = MockVehicleApiService();

          // Create widget in add mode (isEditMode=false, no vehicle)
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider(
                create: (_) => ProfileProvider(vehicleApiService: mockApiService),
                child: const VehicleSelectionPage(
                  isEditMode: false,
                  vehicle: null,
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify text fields are empty
          final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
          final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
          final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
          final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');

          final brandTextField = tester.widget<TextField>(brandField);
          final typeTextField = tester.widget<TextField>(typeField);
          final plateTextField = tester.widget<TextField>(plateField);
          final colorTextField = tester.widget<TextField>(colorField);

          expect(
            brandTextField.controller?.text,
            isEmpty,
            reason: 'Iteration $i: Brand field should be empty in add mode',
          );

          expect(
            typeTextField.controller?.text,
            isEmpty,
            reason: 'Iteration $i: Type field should be empty in add mode',
          );

          expect(
            plateTextField.controller?.text,
            isEmpty,
            reason: 'Iteration $i: Plate field should be empty in add mode',
          );

          expect(
            colorTextField.controller?.text,
            isEmpty,
            reason: 'Iteration $i: Color field should be empty in add mode',
          );
          
          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'Property: Edit mode with null vehicle should handle gracefully',
      (WidgetTester tester) async {
        // Test edge case: edit mode with null vehicle
        // This shouldn't happen in normal flow, but we test robustness
        const int iterations = 20;

        for (int i = 0; i < iterations; i++) {
          final mockApiService = MockVehicleApiService();

          // Create widget with edit mode but null vehicle
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider(
                create: (_) => ProfileProvider(vehicleApiService: mockApiService),
                child: const VehicleSelectionPage(
                  isEditMode: true,
                  vehicle: null,
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Should not crash, widget should build
          expect(find.byType(VehicleSelectionPage), findsOneWidget);

          // Fields should be empty
          final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
          final brandTextField = tester.widget<TextField>(brandField);

          expect(
            brandTextField.controller?.text,
            isEmpty,
            reason: 'Iteration $i: Should handle null vehicle gracefully',
          );
          
          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'Property: Prefilled data should handle special characters',
      (WidgetTester tester) async {
        // Test with 30 iterations of vehicles with special characters
        const int iterations = 30;

        for (int i = 0; i < iterations; i++) {
          final mockApiService = MockVehicleApiService();
          // Generate vehicle with special characters
          final vehicle = _generateVehicleWithSpecialCharacters(i);

          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider(
                create: (_) => ProfileProvider(vehicleApiService: mockApiService),
                child: VehicleSelectionPage(
                  isEditMode: true,
                  vehicle: vehicle,
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify special characters are preserved
          final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
          final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
          final plateField = find.widgetWithText(TextField, 'Plat Nomor *');

          final brandTextField = tester.widget<TextField>(brandField);
          final typeTextField = tester.widget<TextField>(typeField);
          final plateTextField = tester.widget<TextField>(plateField);

          expect(
            brandTextField.controller?.text,
            equals(vehicle.merk),
            reason: 'Iteration $i: Special characters in brand should be preserved',
          );

          expect(
            typeTextField.controller?.text,
            equals(vehicle.tipe),
            reason: 'Iteration $i: Special characters in type should be preserved',
          );

          expect(
            plateTextField.controller?.text,
            equals(vehicle.platNomor),
            reason: 'Iteration $i: Special characters in plate should be preserved',
          );
          
          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      },
    );
  });
}

/// Generate a random vehicle for testing
VehicleModel _generateRandomVehicle(int seed) {
  final random = Random(seed);
  
  // Vehicle types matching the app
  final vehicleTypes = [
    "Roda Dua",
    "Roda Tiga",
    "Roda Empat",
    "Lebih dari Enam",
  ];

  // Random brands
  final brands = [
    "Toyota",
    "Honda",
    "Yamaha",
    "Suzuki",
    "Daihatsu",
    "Mitsubishi",
    "Kawasaki",
    "Mazda",
  ];

  // Random types
  final types = [
    "Avanza",
    "Beat",
    "Vario",
    "Xenia",
    "Brio",
    "Jazz",
    "Ninja",
    "CX-5",
  ];

  // Random colors
  final colors = [
    "Hitam",
    "Putih",
    "Merah",
    "Biru",
    "Silver",
    "Abu-abu",
    null, // Test null color
  ];

  // Generate random plate number
  final plateLetters = ['B', 'D', 'F', 'E', 'H', 'L', 'N', 'T'];
  final plateNumber = random.nextInt(9999) + 1;
  final plateSuffix = String.fromCharCode(65 + random.nextInt(26)) +
      String.fromCharCode(65 + random.nextInt(26)) +
      String.fromCharCode(65 + random.nextInt(26));
  final platNomor = '${plateLetters[random.nextInt(plateLetters.length)]} $plateNumber $plateSuffix';

  // Random photo URL (50% chance of having photo)
  final fotoUrl = random.nextBool()
      ? 'https://example.com/photos/vehicle_${seed}.jpg'
      : null;

  return VehicleModel(
    idKendaraan: 'vehicle_$seed',
    platNomor: platNomor,
    jenisKendaraan: vehicleTypes[random.nextInt(vehicleTypes.length)],
    merk: brands[random.nextInt(brands.length)],
    tipe: types[random.nextInt(types.length)],
    warna: colors[random.nextInt(colors.length)],
    fotoUrl: fotoUrl,
    isActive: random.nextBool(),
  );
}

/// Generate a vehicle with special characters for testing
VehicleModel _generateVehicleWithSpecialCharacters(int seed) {
  final random = Random(seed);
  
  final specialBrands = [
    "Mer©edes-Benz",
    "BMW & Co.",
    "Audi (Premium)",
    "Volks'wagen",
    "Peugeot/Citroën",
  ];

  final specialTypes = [
    "C-Class 2023",
    "X5 (M-Sport)",
    "A4 Avant",
    "Golf GTI",
    "308 GT-Line",
  ];

  final specialPlates = [
    "B 1234 ABC",
    "D 5678 XYZ",
    "F 9012 DEF",
  ];

  return VehicleModel(
    idKendaraan: 'special_$seed',
    platNomor: specialPlates[random.nextInt(specialPlates.length)],
    jenisKendaraan: "Roda Empat",
    merk: specialBrands[random.nextInt(specialBrands.length)],
    tipe: specialTypes[random.nextInt(specialTypes.length)],
    warna: "Hitam Metalik",
    fotoUrl: null,
    isActive: random.nextBool(),
  );
}
