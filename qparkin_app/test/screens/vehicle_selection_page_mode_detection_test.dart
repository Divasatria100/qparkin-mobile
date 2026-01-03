// 📄 test/screens/vehicle_selection_page_mode_detection_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
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
  group('VehicleSelectionPage Mode Detection and UI Changes', () {
    Widget createTestWidget({required bool isEditMode, VehicleModel? vehicle}) {
      final mockApiService = MockVehicleApiService();
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
      idKendaraan: '1',
      platNomor: 'B 1234 XYZ',
      jenisKendaraan: 'Roda Empat',
      merk: 'Toyota',
      tipe: 'Avanza',
      warna: 'Hitam',
      isActive: true,
    );

    group('Mode Detection Tests', () {
      testWidgets('12.1 - isEditMode=true sets internal state to edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Verify edit mode by checking header text
        expect(find.text('Edit Kendaraan'), findsOneWidget);
        
        // Verify edit mode by checking button text
        final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
        expect(submitButton, findsOneWidget);
      });

      testWidgets('12.2 - isEditMode=false sets internal state to add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Verify add mode by checking header text
        expect(find.text('Tambah Kendaraan'), findsOneWidget);
        
        // Verify add mode by checking button text
        final submitButton = find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan');
        expect(submitButton, findsOneWidget);
      });

      testWidgets('12.3 - null isEditMode defaults to add mode',
          (WidgetTester tester) async {
        // Create widget without explicitly setting isEditMode (defaults to false)
        final mockApiService = MockVehicleApiService();
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider(
              create: (_) => ProfileProvider(vehicleApiService: mockApiService),
              child: const VehicleSelectionPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify defaults to add mode
        expect(find.text('Tambah Kendaraan'), findsOneWidget);
        expect(find.text('Tambahkan Kendaraan'), findsOneWidget);
      });

      testWidgets('12.4 - Edit mode with vehicle parameter prefills data',
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
      });
    });

    group('Header Text Tests', () {
      testWidgets('12.5 - Header shows "Edit Kendaraan" in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Edit Kendaraan'), findsOneWidget);
        expect(find.text('Tambah Kendaraan'), findsNothing);
      });

      testWidgets('12.6 - Header shows "Tambah Kendaraan" in add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Tambah Kendaraan'), findsOneWidget);
        expect(find.text('Edit Kendaraan'), findsNothing);
      });
    });

    group('Button Text Tests', () {
      testWidgets('12.7 - Button shows "Simpan Perubahan" in edit mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Scroll to button to ensure it's visible
        final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
        await tester.ensureVisible(submitButton);
        await tester.pumpAndSettle();

        expect(submitButton, findsOneWidget);
        expect(find.text('Tambahkan Kendaraan'), findsNothing);
      });

      testWidgets('12.8 - Button shows "Tambahkan Kendaraan" in add mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Scroll to button to ensure it's visible
        final submitButton = find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan');
        await tester.ensureVisible(submitButton);
        await tester.pumpAndSettle();

        expect(submitButton, findsOneWidget);
        expect(find.text('Simpan Perubahan'), findsNothing);
      });
    });

    group('Mode Consistency Tests', () {
      testWidgets('12.9 - Edit mode maintains consistency across all UI elements',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: true,
          vehicle: testVehicle,
        ));
        await tester.pumpAndSettle();

        // Check header
        expect(find.text('Edit Kendaraan'), findsOneWidget);
        
        // Scroll to and check button
        final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
        await tester.ensureVisible(submitButton);
        await tester.pumpAndSettle();
        expect(submitButton, findsOneWidget);
        
        // Verify data is prefilled (mode is working correctly)
        expect(find.text('Toyota'), findsOneWidget);
        expect(find.text('Avanza'), findsOneWidget);
      });

      testWidgets('12.10 - Add mode maintains consistency across all UI elements',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: null,
        ));
        await tester.pumpAndSettle();

        // Check header
        expect(find.text('Tambah Kendaraan'), findsOneWidget);
        
        // Scroll to and check button
        final submitButton = find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan');
        await tester.ensureVisible(submitButton);
        await tester.pumpAndSettle();
        expect(submitButton, findsOneWidget);
        
        // Verify fields are empty (add mode behavior)
        final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        expect(merekField, findsOneWidget);
        
        // Get the TextField widget and check its controller value
        final TextField merekTextField = tester.widget(merekField);
        expect(merekTextField.controller?.text, isEmpty);
      });
    });



    group('Edge Cases', () {
      testWidgets('12.11 - Add mode with vehicle parameter ignores vehicle data',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          isEditMode: false,
          vehicle: testVehicle, // Providing vehicle but in add mode
        ));
        await tester.pumpAndSettle();

        // Should show add mode UI
        expect(find.text('Tambah Kendaraan'), findsOneWidget);
        
        // Fields should be empty (vehicle data should be ignored in add mode)
        final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
        final TextField merekTextField = tester.widget(merekField);
        expect(merekTextField.controller?.text, isEmpty);
      });
    });
  });
}
