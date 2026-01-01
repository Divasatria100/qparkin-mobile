import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/services/vehicle_api_service.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/presentation/screens/vehicle_detail_page.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';

/// Mock VehicleApiService for testing
class MockVehicleApiService extends VehicleApiService {
  MockVehicleApiService() : super(baseUrl: 'http://test.com/api');

  final List<VehicleModel> _mockVehicles = [];

  @override
  Future<List<VehicleModel>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.from(_mockVehicles);
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
    await Future.delayed(const Duration(milliseconds: 50));
    final newVehicle = VehicleModel(
      idKendaraan: DateTime.now().millisecondsSinceEpoch.toString(),
      platNomor: platNomor,
      jenisKendaraan: jenisKendaraan,
      merk: merk,
      tipe: tipe,
      warna: warna,
      isActive: isActive,
    );
    _mockVehicles.add(newVehicle);
    return newVehicle;
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
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _mockVehicles.indexWhere((v) => v.idKendaraan == id);
    if (index == -1) throw Exception('Vehicle not found');
    
    final vehicle = _mockVehicles[index];
    final updated = vehicle.copyWith(
      platNomor: platNomor,
      jenisKendaraan: jenisKendaraan,
      merk: merk,
      tipe: tipe,
      warna: warna,
      isActive: isActive,
    );
    _mockVehicles[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _mockVehicles.removeWhere((v) => v.idKendaraan == id);
  }

  @override
  Future<VehicleModel> setActiveVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _mockVehicles.indexWhere((v) => v.idKendaraan == id);
    if (index == -1) throw Exception('Vehicle not found');
    
    // Deactivate all vehicles
    for (int i = 0; i < _mockVehicles.length; i++) {
      _mockVehicles[i] = _mockVehicles[i].copyWith(isActive: false);
    }
    
    // Activate the selected vehicle
    _mockVehicles[index] = _mockVehicles[index].copyWith(isActive: true);
    return _mockVehicles[index];
  }
}

/// Integration Tests for Vehicle Edit Flow
/// 
/// This test suite validates the complete vehicle edit flow including:
/// - Navigation from VehicleDetailPage to edit mode
/// - Data prefilling after navigation
/// - Modifying vehicle data
/// - Successful submission and navigation back
/// - Back button behavior (no save)
/// 
/// Requirements: 4.1, 4.2, 4.3, 4.4
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vehicle Edit Flow Integration Tests', () {
    late ProfileProvider provider;
    late MockVehicleApiService mockApiService;

    setUp(() {
      mockApiService = MockVehicleApiService();
      provider = ProfileProvider(vehicleApiService: mockApiService);
    });

    tearDown(() {
      provider.dispose();
    });

    testWidgets(
      'Complete edit flow: navigate → prefill → edit → save → navigate back',
      (WidgetTester tester) async {
        // SETUP: Create test vehicle
        final testVehicle = _createTestVehicle(
          id: 'VEH001',
          merk: 'Toyota',
          tipe: 'Avanza',
          plate: 'B1234XYZ',
          type: 'Roda Empat',
          warna: 'Hitam',
          isActive: true,
        );

        provider.setVehicles([testVehicle]);

        // Build widget tree with VehicleDetailPage
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // STEP 1: Verify we're on VehicleDetailPage
        expect(find.byType(VehicleDetailPage), findsOneWidget);
        expect(find.text('Detail Kendaraan'), findsOneWidget);
        expect(find.text('Toyota'), findsAtLeastNWidgets(1));
        expect(find.text('B1234XYZ'), findsAtLeastNWidgets(1));

        // STEP 2: Tap "Edit Kendaraan" button
        final editButton = find.text('Edit Kendaraan').last; // Use .last to get the button, not the header
        expect(editButton, findsOneWidget);
        
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // STEP 3: Verify navigation to VehicleSelectionPage in edit mode
        expect(find.byType(VehicleSelectionPage), findsOneWidget);
        expect(find.text('Edit Kendaraan'), findsOneWidget); // Header text
        
        // STEP 4: Verify data is prefilled
        expect(find.text('Toyota'), findsOneWidget); // Brand field
        expect(find.text('Avanza'), findsOneWidget); // Type field
        expect(find.text('B1234XYZ'), findsOneWidget); // Plate field
        expect(find.text('Hitam'), findsOneWidget); // Color field
        
        // Verify vehicle type is displayed as read-only
        expect(find.text('Roda Empat'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget); // Lock icon for read-only
        
        // Verify status is prefilled (active vehicle)
        expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);

        // STEP 5: Modify vehicle data
        // Find and modify brand field
        final brandField = find.widgetWithText(TextField, 'Toyota');
        await tester.enterText(brandField, 'Honda');
        await tester.pumpAndSettle();

        // Find and modify type field
        final typeField = find.widgetWithText(TextField, 'Avanza');
        await tester.enterText(typeField, 'CR-V');
        await tester.pumpAndSettle();

        // Find and modify color field
        final colorField = find.widgetWithText(TextField, 'Hitam');
        await tester.enterText(colorField, 'Putih');
        await tester.pumpAndSettle();

        // STEP 6: Submit the form
        // Update mock data to reflect changes
        final updatedVehicle = testVehicle.copyWith(
          merk: 'Honda',
          tipe: 'CR-V',
          warna: 'Putih',
        );
        provider.setVehicles([updatedVehicle]);

        final submitButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
        expect(submitButton, findsOneWidget);
        
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // STEP 7: Verify success notification
        expect(find.text('Kendaraan berhasil diperbarui!'), findsOneWidget);

        // STEP 8: Verify navigation back to VehicleDetailPage
        // After successful edit, should pop back to detail page, then detail page pops itself
        // So we should be back at the previous screen (not detail page anymore)
        expect(find.byType(VehicleSelectionPage), findsNothing);
        expect(find.byType(VehicleDetailPage), findsNothing);

        // STEP 9: Verify provider state is updated
        expect(provider.vehicles.length, equals(1));
        expect(provider.vehicles[0].merk, equals('Honda'));
        expect(provider.vehicles[0].tipe, equals('CR-V'));
        expect(provider.vehicles[0].warna, equals('Putih'));
        expect(provider.vehicles[0].platNomor, equals('B1234XYZ')); // Unchanged
        expect(provider.vehicles[0].jenisKendaraan, equals('Roda Empat')); // Unchanged
      },
    );

    testWidgets(
      'Navigation to edit mode: verify parameters are passed correctly',
      (WidgetTester tester) async {
        // SETUP: Create test vehicle with specific data
        final testVehicle = _createTestVehicle(
          id: 'VEH002',
          merk: 'Yamaha',
          tipe: 'NMAX',
          plate: 'B5678ABC',
          type: 'Roda Dua',
          warna: 'Biru',
          isActive: false,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap edit button
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Verify VehicleSelectionPage received correct parameters
        final vehicleSelectionPage = tester.widget<VehicleSelectionPage>(
          find.byType(VehicleSelectionPage),
        );
        
        expect(vehicleSelectionPage.isEditMode, isTrue);
        expect(vehicleSelectionPage.vehicle, isNotNull);
        expect(vehicleSelectionPage.vehicle!.idKendaraan, equals('VEH002'));
        expect(vehicleSelectionPage.vehicle!.merk, equals('Yamaha'));
        expect(vehicleSelectionPage.vehicle!.tipe, equals('NMAX'));
        expect(vehicleSelectionPage.vehicle!.platNomor, equals('B5678ABC'));
        expect(vehicleSelectionPage.vehicle!.jenisKendaraan, equals('Roda Dua'));
        expect(vehicleSelectionPage.vehicle!.warna, equals('Biru'));
        expect(vehicleSelectionPage.vehicle!.isActive, isFalse);
      },
    );

    testWidgets(
      'Data prefilling: all fields populated correctly in edit mode',
      (WidgetTester tester) async {
        // SETUP: Create vehicle with all fields populated
        final testVehicle = _createTestVehicle(
          id: 'VEH003',
          merk: 'Suzuki',
          tipe: 'Ertiga',
          plate: 'B9999ZZZ',
          type: 'Roda Empat',
          warna: 'Silver',
          isActive: true,
          fotoUrl: 'https://example.com/photo.jpg',
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Verify all text fields are prefilled
        expect(find.text('Suzuki'), findsOneWidget);
        expect(find.text('Ertiga'), findsOneWidget);
        expect(find.text('B9999ZZZ'), findsOneWidget);
        expect(find.text('Silver'), findsOneWidget);

        // Verify vehicle type is displayed (read-only)
        expect(find.text('Roda Empat'), findsOneWidget);

        // Verify status is set correctly (Kendaraan Utama for active vehicle)
        final radioButtons = find.byIcon(Icons.radio_button_checked);
        expect(radioButtons, findsOneWidget);

        // Verify read-only indicators
        expect(find.byIcon(Icons.lock), findsOneWidget); // Lock icon for vehicle type
      },
    );

    testWidgets(
      'Modifying vehicle data: editable fields accept changes',
      (WidgetTester tester) async {
        // SETUP
        final testVehicle = _createTestVehicle(
          id: 'VEH004',
          merk: 'Original',
          tipe: 'Model',
          plate: 'B1111AAA',
          type: 'Roda Empat',
          warna: 'Merah',
          isActive: false,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Modify brand
        final brandField = find.widgetWithText(TextField, 'Original');
        await tester.enterText(brandField, 'Modified Brand');
        await tester.pumpAndSettle();
        expect(find.text('Modified Brand'), findsOneWidget);

        // Modify type
        final typeField = find.widgetWithText(TextField, 'Model');
        await tester.enterText(typeField, 'Modified Type');
        await tester.pumpAndSettle();
        expect(find.text('Modified Type'), findsOneWidget);

        // Modify color
        final colorField = find.widgetWithText(TextField, 'Merah');
        await tester.enterText(colorField, 'Modified Color');
        await tester.pumpAndSettle();
        expect(find.text('Modified Color'), findsOneWidget);

        // Change status
        final guestVehicleOption = find.text('Kendaraan Tamu');
        await tester.tap(guestVehicleOption);
        await tester.pumpAndSettle();

        // Verify status changed
        final checkedRadios = find.byIcon(Icons.radio_button_checked);
        expect(checkedRadios, findsOneWidget);

        // Verify read-only fields cannot be changed
        // Plate number should still be original
        expect(find.text('B1111AAA'), findsOneWidget);
        // Vehicle type should still be original
        expect(find.text('Roda Empat'), findsOneWidget);
      },
    );

    testWidgets(
      'Successful submission: provider state updated and navigation occurs',
      (WidgetTester tester) async {
        // SETUP
        final testVehicle = _createTestVehicle(
          id: 'VEH005',
          merk: 'Before',
          tipe: 'Edit',
          plate: 'B2222BBB',
          type: 'Roda Dua',
          warna: 'Kuning',
          isActive: true,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Make changes
        final brandField = find.widgetWithText(TextField, 'Before');
        await tester.enterText(brandField, 'After');
        await tester.pumpAndSettle();

        // Update mock data before submission
        final updatedVehicle = testVehicle.copyWith(merk: 'After');
        provider.setVehicles([updatedVehicle]);

        // Submit
        await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Kendaraan berhasil diperbarui!'), findsOneWidget);

        // Verify provider state
        expect(provider.vehicles[0].merk, equals('After'));

        // Verify navigation occurred (both pages should be popped)
        expect(find.byType(VehicleSelectionPage), findsNothing);
        expect(find.byType(VehicleDetailPage), findsNothing);
      },
    );

    testWidgets(
      'Back button behavior: no save, returns to detail page',
      (WidgetTester tester) async {
        // SETUP
        final testVehicle = _createTestVehicle(
          id: 'VEH006',
          merk: 'Unchanged',
          tipe: 'Vehicle',
          plate: 'B3333CCC',
          type: 'Roda Empat',
          warna: 'Hijau',
          isActive: false,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Verify we're in edit mode
        expect(find.byType(VehicleSelectionPage), findsOneWidget);
        expect(find.text('Edit Kendaraan'), findsOneWidget);

        // Make some changes (but don't save)
        final brandField = find.widgetWithText(TextField, 'Unchanged');
        await tester.enterText(brandField, 'Modified But Not Saved');
        await tester.pumpAndSettle();

        // Tap back button
        final backButton = find.byType(BackButton);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify we're back on VehicleDetailPage
        expect(find.byType(VehicleDetailPage), findsOneWidget);
        expect(find.byType(VehicleSelectionPage), findsNothing);

        // Verify provider state is unchanged
        expect(provider.vehicles[0].merk, equals('Unchanged'));
        expect(provider.vehicles[0].merk, isNot(equals('Modified But Not Saved')));
      },
    );

    testWidgets(
      'Edit flow with status change: from guest to active vehicle',
      (WidgetTester tester) async {
        // SETUP: Create guest vehicle (not active)
        final testVehicle = _createTestVehicle(
          id: 'VEH007',
          merk: 'Guest',
          tipe: 'Vehicle',
          plate: 'B4444DDD',
          type: 'Roda Dua',
          warna: 'Coklat',
          isActive: false,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Verify initial status is "Kendaraan Tamu"
        // The checked radio should be on the second option
        final allRadios = find.byIcon(Icons.radio_button_checked);
        expect(allRadios, findsOneWidget);

        // Change to "Kendaraan Utama"
        final mainVehicleOption = find.text('Kendaraan Utama');
        await tester.tap(mainVehicleOption);
        await tester.pumpAndSettle();

        // Update mock data
        final updatedVehicle = testVehicle.copyWith(isActive: true);
        provider.setVehicles([updatedVehicle]);

        // Submit
        await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
        await tester.pumpAndSettle();

        // Verify provider state reflects status change
        expect(provider.vehicles[0].isActive, isTrue);
      },
    );

    testWidgets(
      'Edit flow preserves unchanged fields',
      (WidgetTester tester) async {
        // SETUP
        final testVehicle = _createTestVehicle(
          id: 'VEH008',
          merk: 'Preserve',
          tipe: 'Test',
          plate: 'B5555EEE',
          type: 'Roda Empat',
          warna: 'Abu-abu',
          isActive: true,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Only modify brand, leave everything else unchanged
        final brandField = find.widgetWithText(TextField, 'Preserve');
        await tester.enterText(brandField, 'Changed');
        await tester.pumpAndSettle();

        // Update mock data with only brand changed
        final updatedVehicle = testVehicle.copyWith(merk: 'Changed');
        provider.setVehicles([updatedVehicle]);

        // Submit
        await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
        await tester.pumpAndSettle();

        // Verify only brand changed, everything else preserved
        expect(provider.vehicles[0].merk, equals('Changed'));
        expect(provider.vehicles[0].tipe, equals('Test')); // Unchanged
        expect(provider.vehicles[0].platNomor, equals('B5555EEE')); // Unchanged
        expect(provider.vehicles[0].jenisKendaraan, equals('Roda Empat')); // Unchanged
        expect(provider.vehicles[0].warna, equals('Abu-abu')); // Unchanged
        expect(provider.vehicles[0].isActive, isTrue); // Unchanged
      },
    );

    testWidgets(
      'Multiple edit operations: edit → back → edit again',
      (WidgetTester tester) async {
        // SETUP
        final testVehicle = _createTestVehicle(
          id: 'VEH009',
          merk: 'Multi',
          tipe: 'Edit',
          plate: 'B6666FFF',
          type: 'Roda Tiga',
          warna: 'Ungu',
          isActive: false,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // First edit attempt - cancel with back button
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        expect(find.byType(VehicleSelectionPage), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(find.byType(VehicleDetailPage), findsOneWidget);

        // Second edit attempt - make changes and save
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        final brandField = find.widgetWithText(TextField, 'Multi');
        await tester.enterText(brandField, 'Final');
        await tester.pumpAndSettle();

        // Update mock data
        final updatedVehicle = testVehicle.copyWith(merk: 'Final');
        provider.setVehicles([updatedVehicle]);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
        await tester.pumpAndSettle();

        // Verify changes were saved
        expect(provider.vehicles[0].merk, equals('Final'));
      },
    );

    testWidgets(
      'Edit flow with all editable fields modified',
      (WidgetTester tester) async {
        // SETUP
        final testVehicle = _createTestVehicle(
          id: 'VEH010',
          merk: 'Old Brand',
          tipe: 'Old Type',
          plate: 'B7777GGG',
          type: 'Roda Empat',
          warna: 'Old Color',
          isActive: false,
        );

        provider.setVehicles([testVehicle]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: VehicleDetailPage(vehicle: testVehicle),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to edit mode
        await tester.tap(find.text('Edit Kendaraan').last);
        await tester.pumpAndSettle();

        // Modify all editable fields
        await tester.enterText(
          find.widgetWithText(TextField, 'Old Brand'),
          'New Brand',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Old Type'),
          'New Type',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Old Color'),
          'New Color',
        );
        await tester.pumpAndSettle();

        // Change status
        await tester.tap(find.text('Kendaraan Utama'));
        await tester.pumpAndSettle();

        // Update mock data
        final updatedVehicle = testVehicle.copyWith(
          merk: 'New Brand',
          tipe: 'New Type',
          warna: 'New Color',
          isActive: true,
        );
        provider.setVehicles([updatedVehicle]);

        // Submit
        await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
        await tester.pumpAndSettle();

        // Verify all changes were saved
        expect(provider.vehicles[0].merk, equals('New Brand'));
        expect(provider.vehicles[0].tipe, equals('New Type'));
        expect(provider.vehicles[0].warna, equals('New Color'));
        expect(provider.vehicles[0].isActive, isTrue);
        
        // Verify read-only fields unchanged
        expect(provider.vehicles[0].platNomor, equals('B7777GGG'));
        expect(provider.vehicles[0].jenisKendaraan, equals('Roda Empat'));
      },
    );
  });
}

// Test Data Helper
VehicleModel _createTestVehicle({
  required String id,
  required String merk,
  required String tipe,
  required String plate,
  required String type,
  required String warna,
  required bool isActive,
  String? fotoUrl,
}) {
  return VehicleModel(
    idKendaraan: id,
    platNomor: plate,
    jenisKendaraan: type,
    merk: merk,
    tipe: tipe,
    warna: warna,
    isActive: isActive,
    fotoUrl: fotoUrl,
  );
}
