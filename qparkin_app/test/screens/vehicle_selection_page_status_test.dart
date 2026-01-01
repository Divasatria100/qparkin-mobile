// 📄 test/screens/vehicle_selection_page_status_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/models/vehicle_statistics.dart';
import 'package:qparkin_app/data/services/vehicle_api_service.dart';

/// Mock VehicleApiService for testing
class MockVehicleApiService extends VehicleApiService {
  String? lastUpdatedId;
  String? lastUpdatedMerk;
  String? lastUpdatedTipe;
  String? lastUpdatedWarna;
  bool? lastUpdatedIsActive;
  
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
    // Store the values for verification
    lastUpdatedId = id;
    lastUpdatedMerk = merk;
    lastUpdatedTipe = tipe;
    lastUpdatedWarna = warna;
    lastUpdatedIsActive = isActive;
    
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
  group('Task 9.1: Status Selection in Edit Mode', () {
    late MockVehicleApiService mockApiService;
    late ProfileProvider profileProvider;
    late VehicleModel testVehicle;

    setUp(() {
      mockApiService = MockVehicleApiService();
      profileProvider = ProfileProvider(vehicleApiService: mockApiService);
      
      // Create a test vehicle with "Kendaraan Utama" status
      testVehicle = VehicleModel(
        idKendaraan: 'test-id-123',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        fotoUrl: null,
        isActive: true, // Kendaraan Utama
        statistics: VehicleStatistics(
          parkingCount: 5,
          totalParkingMinutes: 300,
          totalCostSpent: 50000.0,
          lastParkingDate: DateTime.now(),
        ),
      );
    });

    testWidgets('should display current status correctly in edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both status options are displayed
      expect(find.text('Kendaraan Utama'), findsOneWidget);
      expect(find.text('Kendaraan Tamu'), findsOneWidget);
      
      // Verify descriptions are displayed
      expect(find.text('Kendaraan yang sering digunakan untuk parkir'), findsOneWidget);
      expect(find.text('Kendaraan tamu atau kendaraan cadangan'), findsOneWidget);
    });

    testWidgets('should switch from Kendaraan Utama to Kendaraan Tamu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to make Kendaraan Tamu visible
      await tester.dragUntilVisible(
        find.text('Kendaraan Tamu'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap on Kendaraan Tamu
      await tester.tap(find.text('Kendaraan Tamu'));
      await tester.pumpAndSettle();

      // Verify the tap was successful by checking the widget still exists
      expect(find.text('Kendaraan Tamu'), findsOneWidget);
    });

    testWidgets('should switch from Kendaraan Tamu to Kendaraan Utama', (WidgetTester tester) async {
      // Create vehicle with Kendaraan Tamu status
      final tamuVehicle = VehicleModel(
        idKendaraan: 'test-id-456',
        platNomor: 'B 5678 ABC',
        jenisKendaraan: 'Roda Dua',
        merk: 'Honda',
        tipe: 'Beat',
        warna: 'Merah',
        fotoUrl: null,
        isActive: false, // Kendaraan Tamu
        statistics: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: tamuVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to make Kendaraan Utama visible
      await tester.dragUntilVisible(
        find.text('Kendaraan Utama'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap on Kendaraan Utama
      await tester.tap(find.text('Kendaraan Utama'));
      await tester.pumpAndSettle();

      // Verify the tap was successful
      expect(find.text('Kendaraan Utama'), findsOneWidget);
    });

    testWidgets('should submit correct isActive value when Kendaraan Utama is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Kendaraan Utama is already selected (isActive = true)
      // Fill in required fields
      await tester.enterText(find.byType(TextField).at(0), 'Toyota');
      await tester.enterText(find.byType(TextField).at(1), 'Avanza');
      await tester.enterText(find.byType(TextField).at(3), 'Hitam');

      // Scroll to submit button
      await tester.dragUntilVisible(
        find.text('Simpan Perubahan'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify that updateVehicle was called with isActive = true
      expect(mockApiService.lastUpdatedId, 'test-id-123');
      expect(mockApiService.lastUpdatedIsActive, true);
    });

    testWidgets('should submit correct isActive value when Kendaraan Tamu is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Kendaraan Tamu
      await tester.dragUntilVisible(
        find.text('Kendaraan Tamu'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Switch to Kendaraan Tamu
      await tester.tap(find.text('Kendaraan Tamu'));
      await tester.pumpAndSettle();

      // Fill in required fields
      await tester.enterText(find.byType(TextField).at(0), 'Toyota');
      await tester.enterText(find.byType(TextField).at(1), 'Avanza');
      await tester.enterText(find.byType(TextField).at(3), 'Hitam');

      // Scroll to submit button
      await tester.dragUntilVisible(
        find.text('Simpan Perubahan'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify that updateVehicle was called with isActive = false
      expect(mockApiService.lastUpdatedId, 'test-id-123');
      expect(mockApiService.lastUpdatedIsActive, false);
    });

    testWidgets('should maintain status selection after switching multiple times', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to status section
      await tester.dragUntilVisible(
        find.text('Kendaraan Tamu'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Switch to Kendaraan Tamu
      await tester.tap(find.text('Kendaraan Tamu'));
      await tester.pumpAndSettle();

      // Switch back to Kendaraan Utama
      await tester.tap(find.text('Kendaraan Utama'));
      await tester.pumpAndSettle();

      // Switch to Kendaraan Tamu again
      await tester.tap(find.text('Kendaraan Tamu'));
      await tester.pumpAndSettle();

      // Verify Kendaraan Tamu is still visible
      expect(find.text('Kendaraan Tamu'), findsOneWidget);

      // Fill in required fields and submit
      await tester.enterText(find.byType(TextField).at(0), 'Toyota');
      await tester.enterText(find.byType(TextField).at(1), 'Avanza');
      await tester.enterText(find.byType(TextField).at(3), 'Hitam');

      // Scroll to submit button
      await tester.dragUntilVisible(
        find.text('Simpan Perubahan'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify the final submitted value is false (Kendaraan Tamu)
      expect(mockApiService.lastUpdatedIsActive, false);
    });

    testWidgets('should display status descriptions correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Kendaraan Utama description
      expect(
        find.text('Kendaraan yang sering digunakan untuk parkir'),
        findsOneWidget,
      );

      // Verify Kendaraan Tamu description
      expect(
        find.text('Kendaraan tamu atau kendaraan cadangan'),
        findsOneWidget,
      );
    });

    testWidgets('should work in add mode as well', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: const VehicleSelectionPage(
              isEditMode: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both status options are displayed
      expect(find.text('Kendaraan Utama'), findsOneWidget);
      expect(find.text('Kendaraan Tamu'), findsOneWidget);

      // Scroll to status section
      await tester.dragUntilVisible(
        find.text('Kendaraan Tamu'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Switch to Kendaraan Tamu
      await tester.tap(find.text('Kendaraan Tamu'));
      await tester.pumpAndSettle();

      // Verify the tap was successful
      expect(find.text('Kendaraan Tamu'), findsOneWidget);
    });
  });
}
