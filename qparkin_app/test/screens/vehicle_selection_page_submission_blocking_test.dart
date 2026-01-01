// 📄 test/screens/vehicle_selection_page_submission_blocking_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/services/vehicle_api_service.dart';

/// Mock VehicleApiService that tracks API calls
class MockVehicleApiServiceWithTracking extends VehicleApiService {
  MockVehicleApiServiceWithTracking() : super(baseUrl: 'http://test.com/api');

  int updateVehicleCallCount = 0;
  int addVehicleCallCount = 0;

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
    addVehicleCallCount++;
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
    updateVehicleCallCount++;
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

  void reset() {
    updateVehicleCallCount = 0;
    addVehicleCallCount = 0;
  }
}

void main() {
  group('VehicleSelectionPage Submission Blocking Tests - Edit Mode', () {
    testWidgets('7.2.1 - Empty merek blocks API call in edit mode',
        (WidgetTester tester) async {
      final mockApiService = MockVehicleApiServiceWithTracking();
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
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
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear merek field
      final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
      await tester.enterText(merekField, '');
      await tester.pumpAndSettle();

      // Try to submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify API was NOT called
      expect(mockApiService.updateVehicleCallCount, equals(0),
          reason: 'updateVehicle should not be called with empty merek');

      // Verify error message is shown
      expect(find.text('Masukkan merek kendaraan'), findsOneWidget);
    });

    testWidgets('7.2.2 - Empty tipe blocks API call in edit mode',
        (WidgetTester tester) async {
      final mockApiService = MockVehicleApiServiceWithTracking();
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
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
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear tipe field
      final tipeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
      await tester.enterText(tipeField, '');
      await tester.pumpAndSettle();

      // Try to submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify API was NOT called
      expect(mockApiService.updateVehicleCallCount, equals(0),
          reason: 'updateVehicle should not be called with empty tipe');

      // Verify error message is shown
      expect(find.text('Masukkan tipe kendaraan'), findsOneWidget);
    });

    testWidgets('7.2.3 - Empty warna blocks API call in edit mode',
        (WidgetTester tester) async {
      final mockApiService = MockVehicleApiServiceWithTracking();
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
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
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear warna field
      final warnaField = find.widgetWithText(TextField, 'Warna Kendaraan *');
      await tester.enterText(warnaField, '');
      await tester.pumpAndSettle();

      // Try to submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify API was NOT called
      expect(mockApiService.updateVehicleCallCount, equals(0),
          reason: 'updateVehicle should not be called with empty warna');

      // Verify error message is shown
      expect(find.text('Warna kendaraan wajib diisi'), findsOneWidget);
    });

    testWidgets('7.2.4 - Multiple empty fields show first error and block API',
        (WidgetTester tester) async {
      final mockApiService = MockVehicleApiServiceWithTracking();
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
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
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear all editable fields
      final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
      await tester.enterText(merekField, '');
      
      final tipeField = find.widgetWithText(TextField, 'Tipe/Model Kendaraan *');
      await tester.enterText(tipeField, '');
      
      final warnaField = find.widgetWithText(TextField, 'Warna Kendaraan *');
      await tester.enterText(warnaField, '');
      await tester.pumpAndSettle();

      // Try to submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify API was NOT called
      expect(mockApiService.updateVehicleCallCount, equals(0),
          reason: 'updateVehicle should not be called with multiple empty fields');

      // Verify first error message is shown (merek is checked first)
      expect(find.text('Masukkan merek kendaraan'), findsOneWidget);
    });

    testWidgets('7.2.5 - Valid data allows API call in edit mode',
        (WidgetTester tester) async {
      final mockApiService = MockVehicleApiServiceWithTracking();
      final testVehicle = VehicleModel(
        idKendaraan: '1',
        platNomor: 'B 1234 XYZ',
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
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All fields are already filled from prefill
      // Just submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify API WAS called
      expect(mockApiService.updateVehicleCallCount, equals(1),
          reason: 'updateVehicle should be called with valid data');
    });
  });

  group('VehicleSelectionPage Submission Blocking Tests - Add Mode', () {
    testWidgets('7.2.6 - Validation blocks API call in add mode',
        (WidgetTester tester) async {
      final mockApiService = MockVehicleApiServiceWithTracking();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ProfileProvider(vehicleApiService: mockApiService),
            child: const VehicleSelectionPage(
              isEditMode: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select vehicle type
      final rodaEmpatCard = find.text('Roda Empat');
      await tester.ensureVisible(rodaEmpatCard);
      await tester.pumpAndSettle();
      await tester.tap(rodaEmpatCard);
      await tester.pumpAndSettle();

      // Try to submit without filling required fields
      final submitButton = find.widgetWithText(ElevatedButton, 'Tambahkan Kendaraan');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify API was NOT called
      expect(mockApiService.addVehicleCallCount, equals(0),
          reason: 'addVehicle should not be called with empty fields');

      // Verify error message is shown
      expect(find.text('Masukkan merek kendaraan'), findsOneWidget);
    });
  });
}
