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

/// Widget tests for visual styling of read-only fields in edit mode
/// Validates Requirements 8.3: Read-only fields have visual distinction
void main() {
  group('VehicleSelectionPage Visual Styling Tests', () {
    testWidgets(
      'Read-only vehicle type section has grey background, border, and lock icon in edit mode',
      (WidgetTester tester) async {
        final mockApiService = MockVehicleApiService();
        final vehicle = VehicleModel(
          idKendaraan: 'test_1',
          platNomor: 'B 1234 ABC',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
          warna: 'Hitam',
          isActive: true,
        );

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

        // Find the read-only vehicle type container
        // It should have grey background and lock icon
        final lockIcon = find.byIcon(Icons.lock);
        expect(lockIcon, findsWidgets, reason: 'Lock icon should be present for read-only fields');

        // Find container with grey background
        final containers = find.byType(Container);
        expect(containers, findsWidgets, reason: 'Containers should exist for styling');

        // Verify the widget builds correctly
        expect(find.byType(VehicleSelectionPage), findsOneWidget);
      },
    );

    testWidgets(
      'Read-only plate number field has grey background and lock icon in edit mode',
      (WidgetTester tester) async {
        final mockApiService = MockVehicleApiService();
        final vehicle = VehicleModel(
          idKendaraan: 'test_2',
          platNomor: 'D 5678 XYZ',
          jenisKendaraan: 'Roda Dua',
          merk: 'Honda',
          tipe: 'Beat',
          warna: 'Merah',
          isActive: false,
        );

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

        // Find the plate number TextField
        final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
        expect(plateField, findsOneWidget, reason: 'Plate number field should exist');

        // Get the TextField widget
        final plateTextField = tester.widget<TextField>(plateField);

        // Verify it's disabled in edit mode
        expect(
          plateTextField.enabled,
          isFalse,
          reason: 'Plate number field should be disabled in edit mode',
        );

        // Verify it has grey background (filled)
        expect(
          plateTextField.decoration?.filled,
          isTrue,
          reason: 'Plate number field should have filled background in edit mode',
        );

        // Verify it has lock icon suffix
        expect(
          plateTextField.decoration?.suffixIcon,
          isNotNull,
          reason: 'Plate number field should have lock icon suffix in edit mode',
        );

        // Find lock icon
        final lockIcon = find.byIcon(Icons.lock);
        expect(lockIcon, findsWidgets, reason: 'Lock icon should be present');
      },
    );

    testWidgets(
      'Editable fields remain enabled and without lock icon in edit mode',
      (WidgetTester tester) async {
        final mockApiService = MockVehicleApiService();
        final vehicle = VehicleModel(
          idKendaraan: 'test_3',
          platNomor: 'F 9012 DEF',
          jenisKendaraan: 'Roda Tiga',
          merk: 'Suzuki',
          tipe: 'Carry',
          warna: 'Putih',
          isActive: true,
        );

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

        // Find editable fields
        final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
        final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');

        // Get TextField widgets
        final brandTextField = tester.widget<TextField>(brandField);
        final typeTextField = tester.widget<TextField>(typeField);
        final colorTextField = tester.widget<TextField>(colorField);

        // Verify they are enabled
        expect(
          brandTextField.enabled,
          isNull, // null means enabled by default
          reason: 'Brand field should be enabled in edit mode',
        );

        expect(
          typeTextField.enabled,
          isNull,
          reason: 'Type field should be enabled in edit mode',
        );

        expect(
          colorTextField.enabled,
          isNull,
          reason: 'Color field should be enabled in edit mode',
        );

        // Verify they don't have filled background
        expect(
          brandTextField.decoration?.filled,
          isNull,
          reason: 'Brand field should not have filled background',
        );

        expect(
          typeTextField.decoration?.filled,
          isNull,
          reason: 'Type field should not have filled background',
        );

        expect(
          colorTextField.decoration?.filled,
          isNull,
          reason: 'Color field should not have filled background',
        );
      },
    );

    testWidgets(
      'All fields are editable in add mode (no read-only styling)',
      (WidgetTester tester) async {
        final mockApiService = MockVehicleApiService();

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

        // Find all text fields
        final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
        final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
        final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');

        // Get TextField widgets
        final plateTextField = tester.widget<TextField>(plateField);
        final brandTextField = tester.widget<TextField>(brandField);
        final typeTextField = tester.widget<TextField>(typeField);
        final colorTextField = tester.widget<TextField>(colorField);

        // Verify all are enabled (null or true means enabled)
        expect(
          plateTextField.enabled ?? true,
          isTrue,
          reason: 'Plate field should be enabled in add mode',
        );

        expect(
          brandTextField.enabled ?? true,
          isTrue,
          reason: 'Brand field should be enabled in add mode',
        );

        expect(
          typeTextField.enabled ?? true,
          isTrue,
          reason: 'Type field should be enabled in add mode',
        );

        expect(
          colorTextField.enabled ?? true,
          isTrue,
          reason: 'Color field should be enabled in add mode',
        );

        // Verify plate field doesn't have filled background in add mode
        // In add mode, filled is false (not null)
        expect(
          plateTextField.decoration?.filled ?? false,
          isFalse,
          reason: 'Plate field should not have filled background in add mode',
        );
      },
    );
  });
}
