// 📄 test/screens/vehicle_selection_page_validation_test.dart
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
  group('VehicleSelectionPage Validation Tests - Edit Mode', () {
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

    testWidgets('7.1.1 - Merek validation shows error when empty in edit mode',
        (WidgetTester tester) async {
      // Create a test vehicle
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(
        isEditMode: true,
        vehicle: testVehicle,
      ));
      await tester.pumpAndSettle();

      // Find the merek field and clear it
      final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
      expect(merekField, findsOneWidget);

      await tester.enterText(merekField, '');
      await tester.pumpAndSettle();

      // Scroll to submit button
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      expect(submitButton, findsOneWidget);
      
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for SnackBar

      // Verify error message is shown in SnackBar
      expect(find.text('Masukkan merek kendaraan'), findsOneWidget);
    });

    testWidgets('7.1.2 - Tipe validation shows error when empty in edit mode',
        (WidgetTester tester) async {
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(
        isEditMode: true,
        vehicle: testVehicle,
      ));
      await tester.pumpAndSettle();

      // Find the tipe field and clear it
      final tipeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
      expect(tipeField, findsOneWidget);

      await tester.enterText(tipeField, '');
      await tester.pumpAndSettle();

      // Scroll to and tap submit button
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify error message is shown
      expect(find.text('Masukkan tipe kendaraan'), findsOneWidget);
    });

    testWidgets('7.1.3 - Warna validation shows error when empty in edit mode',
        (WidgetTester tester) async {
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(
        isEditMode: true,
        vehicle: testVehicle,
      ));
      await tester.pumpAndSettle();

      // Find the warna field and clear it
      final warnaField = find.widgetWithText(TextField, 'Warna Kendaraan *');
      expect(warnaField, findsOneWidget);

      await tester.enterText(warnaField, '');
      await tester.pumpAndSettle();

      // Scroll to and tap submit button
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify error message is shown
      expect(find.text('Warna kendaraan wajib diisi'), findsOneWidget);
    });

    testWidgets('7.1.4 - All editable fields accept valid input in edit mode',
        (WidgetTester tester) async {
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(
        isEditMode: true,
        vehicle: testVehicle,
      ));
      await tester.pumpAndSettle();

      // Update merek
      final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
      await tester.enterText(merekField, 'Honda');
      await tester.pumpAndSettle();

      // Update tipe
      final tipeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
      await tester.enterText(tipeField, 'Civic');
      await tester.pumpAndSettle();

      // Update warna
      final warnaField = find.widgetWithText(TextField, 'Warna Kendaraan *');
      await tester.enterText(warnaField, 'Putih');
      await tester.pumpAndSettle();

      // Verify fields contain new values
      expect(find.text('Honda'), findsOneWidget);
      expect(find.text('Civic'), findsOneWidget);
      expect(find.text('Putih'), findsOneWidget);
    });

    testWidgets('7.1.5 - Whitespace-only input is treated as empty',
        (WidgetTester tester) async {
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(
        isEditMode: true,
        vehicle: testVehicle,
      ));
      await tester.pumpAndSettle();

      // Enter whitespace in merek field
      final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
      await tester.enterText(merekField, '   ');
      await tester.pumpAndSettle();

      // Scroll to and tap submit button
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify error message is shown (whitespace is trimmed)
      expect(find.text('Masukkan merek kendaraan'), findsOneWidget);
    });
  });

  group('VehicleSelectionPage Validation Tests - Add Mode', () {
    Widget createTestWidget() {
      final mockApiService = MockVehicleApiService();
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ProfileProvider(vehicleApiService: mockApiService),
          child: const VehicleSelectionPage(
            isEditMode: false,
          ),
        ),
      );
    }

    testWidgets('7.1.6 - Validation works in add mode as well',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to vehicle type section
      final rodaEmpatCard = find.text('Roda Empat');
      await tester.ensureVisible(rodaEmpatCard);
      await tester.pumpAndSettle();
      
      // Select vehicle type first
      await tester.tap(rodaEmpatCard);
      await tester.pumpAndSettle();

      // Scroll to and tap submit button without filling required fields
      final submitButton = find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should show merek error first
      expect(find.text('Masukkan merek kendaraan'), findsOneWidget);
    });
  });
}
