// 📄 test/screens/vehicle_selection_page_widget_test.dart
/// Comprehensive widget tests for VehicleSelectionPage
/// Task 13: Write widget tests for VehicleSelectionPage
/// 
/// Tests cover:
/// - Widget builds correctly in add mode (Requirement 2.1, 2.2)
/// - Widget builds correctly in edit mode (Requirement 2.1, 2.2)
/// - Read-only fields have correct styling (Requirement 2.1, 2.2)
/// - Editable fields remain enabled in edit mode (Requirement 3.1, 3.2, 3.3)

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

void main() {
  group('VehicleSelectionPage Widget Tests - Task 13', () {
    late MockVehicleApiService mockApiService;

    setUp(() {
      mockApiService = MockVehicleApiService();
    });

    Widget createTestWidget({required bool isEditMode, VehicleModel? vehicle}) {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ProfileProvider(vehicleApiService: mockApiService),
          child: VehicleSelectionPage(
            isEditMode: isEditMode,
            vehicle: vehicle,
          ),
        ),
      );
    }

    final testVehicle = VehicleModel(
      idKendaraan: 'test_vehicle_1',
      platNomor: 'B 1234 XYZ',
      jenisKendaraan: 'Roda Empat',
      merk: 'Toyota',
      tipe: 'Avanza',
      warna: 'Hitam',
      isActive: true,
    );

    group('13.1 - Widget builds correctly in add mode', () {
      testWidgets('Widget renders all essential components in add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Verify page builds
        expect(find.byType(VehicleSelectionPage), findsOneWidget);

        // Verify header
        expect(find.text('Tambah Kendaraan'), findsOneWidget);

        // Verify back button
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Verify photo section
        expect(find.text('Foto Kendaraan (Opsional)'), findsOneWidget);
        expect(find.text('Tambah Foto'), findsOneWidget);

        // Verify vehicle type section
        expect(find.text('Jenis Kendaraan *'), findsOneWidget);
        
        // Verify vehicle type options are interactive (grid)
        expect(find.text('Roda Dua'), findsOneWidget);
        expect(find.text('Roda Tiga'), findsOneWidget);
        expect(find.text('Roda Empat'), findsOneWidget);
        expect(find.text('Lebih dari Enam'), findsOneWidget);

        // Verify information section
        expect(find.text('Informasi Kendaraan'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Merek Kendaraan *'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Tipe/Model Kendaraan *'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Plat Nomor *'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Warna Kendaraan *'), findsOneWidget);

        // Verify status section
        expect(find.text('Status Kendaraan'), findsOneWidget);
        expect(find.text('Kendaraan Utama'), findsOneWidget);
        expect(find.text('Kendaraan Tamu'), findsOneWidget);

        // Scroll to submit button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan'));
        await tester.pumpAndSettle();

        // Verify submit button
        expect(find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan'), findsOneWidget);
      });

      testWidgets('All fields are empty and editable in add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Get text fields
        final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
        final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
        final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');

        // Verify all fields exist
        expect(brandField, findsOneWidget);
        expect(typeField, findsOneWidget);
        expect(plateField, findsOneWidget);
        expect(colorField, findsOneWidget);

        // Get TextField widgets
        final brandTextField = tester.widget<TextField>(brandField);
        final typeTextField = tester.widget<TextField>(typeField);
        final plateTextField = tester.widget<TextField>(plateField);
        final colorTextField = tester.widget<TextField>(colorField);

        // Verify all fields are empty
        expect(brandTextField.controller?.text, isEmpty);
        expect(typeTextField.controller?.text, isEmpty);
        expect(plateTextField.controller?.text, isEmpty);
        expect(colorTextField.controller?.text, isEmpty);

        // Verify all fields are enabled
        expect(brandTextField.enabled ?? true, isTrue);
        expect(typeTextField.enabled ?? true, isTrue);
        expect(plateTextField.enabled ?? true, isTrue);
        expect(colorTextField.enabled ?? true, isTrue);
      });

      testWidgets('Vehicle type grid is interactive in add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Verify vehicle type options are present
        expect(find.text('Roda Dua'), findsOneWidget);
        expect(find.text('Roda Tiga'), findsOneWidget);
        expect(find.text('Roda Empat'), findsOneWidget);
        expect(find.text('Lebih dari Enam'), findsOneWidget);

        // Verify GridView exists (interactive selection)
        expect(find.byType(GridView), findsOneWidget);

        // Verify GestureDetector exists for interaction
        expect(find.byType(GestureDetector), findsWidgets);
      });
    });

    group('13.2 - Widget builds correctly in edit mode', () {
      testWidgets('Widget renders all essential components in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify page builds
        expect(find.byType(VehicleSelectionPage), findsOneWidget);

        // Verify header shows edit mode
        expect(find.text('Edit Kendaraan'), findsOneWidget);
        expect(find.text('Tambah Kendaraan'), findsNothing);

        // Verify back button
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Verify photo section
        expect(find.text('Foto Kendaraan (Opsional)'), findsOneWidget);

        // Verify vehicle type section (read-only in edit mode)
        expect(find.text('Jenis Kendaraan *'), findsOneWidget);

        // Verify information section
        expect(find.text('Informasi Kendaraan'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Merek Kendaraan *'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Tipe/Model Kendaraan *'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Plat Nomor *'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Warna Kendaraan *'), findsOneWidget);

        // Verify status section
        expect(find.text('Status Kendaraan'), findsOneWidget);

        // Scroll to submit button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
        await tester.pumpAndSettle();

        // Verify submit button shows edit mode text
        expect(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'), findsOneWidget);
        expect(find.text('Tambahkan Kendaraan'), findsNothing);
      });

      testWidgets('Fields are prefilled with vehicle data in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify data is prefilled
        expect(find.text('Toyota'), findsOneWidget);
        expect(find.text('Avanza'), findsOneWidget);
        expect(find.text('B 1234 XYZ'), findsOneWidget);
        expect(find.text('Hitam'), findsOneWidget);

        // Verify vehicle type is displayed
        expect(find.text('Roda Empat'), findsOneWidget);

        // Verify status is selected
        expect(find.text('Kendaraan Utama'), findsWidgets);
      });

      testWidgets('Vehicle type is displayed as read-only in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify vehicle type is shown
        expect(find.text('Roda Empat'), findsOneWidget);

        // Verify GridView is NOT present (not interactive)
        expect(find.byType(GridView), findsNothing);

        // Verify lock icon is present (read-only indicator)
        expect(find.byIcon(Icons.lock), findsWidgets);
      });
    });

    group('13.3 - Read-only fields have correct styling', () {
      testWidgets('Vehicle type section has read-only styling in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify lock icon is present
        final lockIcons = find.byIcon(Icons.lock);
        expect(lockIcons, findsWidgets);

        // Verify vehicle type is displayed
        expect(find.text('Roda Empat'), findsOneWidget);

        // Verify "Jenis Kendaraan" label is present
        expect(find.text('Jenis Kendaraan'), findsOneWidget);

        // Verify Container exists for styling
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('Plate number field has read-only styling in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Find plate number field
        final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
        expect(plateField, findsOneWidget);

        // Get TextField widget
        final plateTextField = tester.widget<TextField>(plateField);

        // Verify field is disabled
        expect(plateTextField.enabled, isFalse,
            reason: 'Plate number should be disabled in edit mode');

        // Verify field has filled background
        expect(plateTextField.decoration?.filled, isTrue,
            reason: 'Plate number should have grey background in edit mode');

        // Verify field has lock icon suffix
        expect(plateTextField.decoration?.suffixIcon, isNotNull,
            reason: 'Plate number should have lock icon in edit mode');

        // Verify lock icon is present
        expect(find.byIcon(Icons.lock), findsWidgets);
      });

      testWidgets('Read-only fields have grey background color',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Find plate number field
        final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
        final plateTextField = tester.widget<TextField>(plateField);

        // Verify filled is true (grey background)
        expect(plateTextField.decoration?.filled, isTrue);
        expect(plateTextField.decoration?.fillColor, isNotNull);
      });

      testWidgets('Read-only fields do not have grey styling in add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Find plate number field
        final plateField = find.widgetWithText(TextField, 'Plat Nomor *');
        final plateTextField = tester.widget<TextField>(plateField);

        // Verify field is enabled
        expect(plateTextField.enabled ?? true, isTrue);

        // Verify field does NOT have filled background in add mode
        expect(plateTextField.decoration?.filled ?? false, isFalse);

        // Verify no lock icon in add mode
        expect(plateTextField.decoration?.suffixIcon, isNull);
      });
    });

    group('13.4 - Editable fields remain enabled in edit mode', () {
      testWidgets('Brand field is editable in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Find brand field
        final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        expect(brandField, findsOneWidget);

        // Get TextField widget
        final brandTextField = tester.widget<TextField>(brandField);

        // Verify field is enabled (null or true means enabled)
        expect(brandTextField.enabled ?? true, isTrue,
            reason: 'Brand field should be enabled in edit mode');

        // Verify field does NOT have filled background
        expect(brandTextField.decoration?.filled ?? false, isFalse,
            reason: 'Brand field should not have grey background');

        // Verify field does NOT have lock icon
        expect(brandTextField.decoration?.suffixIcon, isNull,
            reason: 'Brand field should not have lock icon');

        // Verify field is prefilled
        expect(brandTextField.controller?.text, 'Toyota');
      });

      testWidgets('Type field is editable in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Find type field
        final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
        expect(typeField, findsOneWidget);

        // Get TextField widget
        final typeTextField = tester.widget<TextField>(typeField);

        // Verify field is enabled
        expect(typeTextField.enabled ?? true, isTrue,
            reason: 'Type field should be enabled in edit mode');

        // Verify field does NOT have filled background
        expect(typeTextField.decoration?.filled ?? false, isFalse,
            reason: 'Type field should not have grey background');

        // Verify field does NOT have lock icon
        expect(typeTextField.decoration?.suffixIcon, isNull,
            reason: 'Type field should not have lock icon');

        // Verify field is prefilled
        expect(typeTextField.controller?.text, 'Avanza');
      });

      testWidgets('Color field is editable in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Find color field
        final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');
        expect(colorField, findsOneWidget);

        // Get TextField widget
        final colorTextField = tester.widget<TextField>(colorField);

        // Verify field is enabled
        expect(colorTextField.enabled ?? true, isTrue,
            reason: 'Color field should be enabled in edit mode');

        // Verify field does NOT have filled background
        expect(colorTextField.decoration?.filled ?? false, isFalse,
            reason: 'Color field should not have grey background');

        // Verify field does NOT have lock icon
        expect(colorTextField.decoration?.suffixIcon, isNull,
            reason: 'Color field should not have lock icon');

        // Verify field is prefilled
        expect(colorTextField.controller?.text, 'Hitam');
      });

      testWidgets('All editable fields can accept text input in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Find editable fields
        final brandField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        final typeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
        final colorField = find.widgetWithText(TextField, 'Warna Kendaraan *');

        // Test brand field
        await tester.enterText(brandField, 'Honda');
        await tester.pumpAndSettle();
        final brandTextField = tester.widget<TextField>(brandField);
        expect(brandTextField.controller?.text, 'Honda');

        // Test type field
        await tester.enterText(typeField, 'Civic');
        await tester.pumpAndSettle();
        final typeTextField = tester.widget<TextField>(typeField);
        expect(typeTextField.controller?.text, 'Civic');

        // Test color field
        await tester.enterText(colorField, 'Merah');
        await tester.pumpAndSettle();
        final colorTextField = tester.widget<TextField>(colorField);
        expect(colorTextField.controller?.text, 'Merah');
      });

      testWidgets('Status selection is interactive in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify status section exists
        expect(find.text('Status Kendaraan'), findsOneWidget);
        expect(find.text('Kendaraan Utama'), findsWidgets);
        expect(find.text('Kendaraan Tamu'), findsWidgets);

        // Verify InkWell exists for interaction
        expect(find.byType(InkWell), findsWidgets);

        // Verify radio button icons exist
        expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
        expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      });
    });

    group('13.5 - Additional widget structure tests', () {
      testWidgets('Widget has proper scaffold structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Verify Scaffold exists
        expect(find.byType(Scaffold), findsOneWidget);

        // Verify SafeArea exists
        expect(find.byType(SafeArea), findsOneWidget);

        // Verify SingleChildScrollView exists
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Verify Form exists
        expect(find.byType(Form), findsOneWidget);
      });

      testWidgets('Widget has proper navigation structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify back button exists
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);

        // Verify back button is an IconButton
        final iconButton = find.ancestor(
          of: backButton,
          matching: find.byType(IconButton),
        );
        expect(iconButton, findsOneWidget);
      });

      testWidgets('Widget displays all required sections',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Verify all section headers
        expect(find.text('Foto Kendaraan (Opsional)'), findsOneWidget);
        expect(find.text('Jenis Kendaraan *'), findsOneWidget);
        expect(find.text('Informasi Kendaraan'), findsOneWidget);
        expect(find.text('Status Kendaraan'), findsOneWidget);
      });
    });
  });
}
