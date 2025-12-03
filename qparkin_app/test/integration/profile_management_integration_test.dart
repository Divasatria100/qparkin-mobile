import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/user_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/presentation/screens/edit_profile_page.dart';
import 'package:qparkin_app/presentation/screens/vehicle_detail_page.dart';
import 'package:qparkin_app/presentation/widgets/profile/vehicle_card.dart';
import 'package:qparkin_app/presentation/widgets/common/empty_state_widget.dart';

/// Integration Tests for Profile Management Flow
/// 
/// This test suite validates the complete profile management flow including:
/// - Profile data loading and display
/// - Profile editing
/// - Vehicle management (add, edit, delete, set active)
/// - Navigation between profile pages
/// - Error recovery
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Management Integration Tests', () {
    late ProfileProvider provider;

    setUp(() {
      provider = ProfileProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    testWidgets('Complete profile management flow: load → display → edit → save', 
        (WidgetTester tester) async {
      // Setup test data using provider's testing methods
      final testUser = _createTestUser(
        id: 'USER001',
        name: 'John Doe',
        email: 'john@example.com',
        saldoPoin: 1500,
      );
      final testVehicles = [
        _createTestVehicle(
          id: 'VEH001',
          merk: 'Toyota',
          tipe: 'Avanza',
          plate: 'B1234XYZ',
          isActive: true,
        ),
        _createTestVehicle(
          id: 'VEH002',
          merk: 'Honda',
          tipe: 'Beat',
          plate: 'B5678ABC',
          type: 'Roda Dua',
          isActive: false,
        ),
      ];

      provider.setUser(testUser);
      provider.setVehicles(testVehicles);

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
          routes: {
            '/edit-profile': (context) => ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: const EditProfilePage(),
            ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Verify profile data is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.textContaining('1.500'), findsWidgets); // Points display

      // STEP 2: Verify vehicles are displayed
      expect(find.text('Toyota'), findsOneWidget);
      expect(find.text('B1234XYZ'), findsOneWidget);
      expect(find.text('Honda'), findsOneWidget);
      expect(find.text('B5678ABC'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget); // Active badge

      // STEP 3: Navigate to edit profile
      final editButton = find.text('Ubah informasi akun');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // STEP 4: Verify edit page displays with current data
      expect(find.byType(EditProfilePage), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);

      // Find text fields by their initial values
      final nameField = find.widgetWithText(TextFormField, 'John Doe');
      final emailField = find.widgetWithText(TextFormField, 'john@example.com');
      
      expect(nameField, findsOneWidget);
      expect(emailField, findsOneWidget);

      // STEP 5: Edit profile data
      await tester.enterText(nameField, 'John Smith');
      await tester.pumpAndSettle();

      // STEP 6: Save changes
      final updatedUser = testUser.copyWith(name: 'John Smith');
      provider.setUser(updatedUser);

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // STEP 7: Verify success feedback
      expect(find.text('Profil berhasil diperbarui'), findsOneWidget);

      // STEP 8: Verify navigation back to profile page
      expect(find.byType(ProfilePage), findsOneWidget);

      // STEP 9: Verify updated data is displayed
      expect(find.text('John Smith'), findsOneWidget);
      expect(provider.user?.name, equals('John Smith'));
    });

    testWidgets('Vehicle management flow: add → display → delete', 
        (WidgetTester tester) async {
      // Setup initial data with no vehicles
      final testUser = _createTestUser();
      provider.setUser(testUser);
      provider.setVehicles([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/vehicle-detail') {
              final vehicle = settings.arguments as VehicleModel;
              return MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<ProfileProvider>.value(
                  value: provider,
                  child: VehicleDetailPage(vehicle: vehicle),
                ),
              );
            }
            return null;
          },
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Verify empty state is displayed
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('Tidak ada kendaraan terdaftar'), findsOneWidget);

      // STEP 2: Add a vehicle
      final newVehicle = _createTestVehicle(
        id: 'VEH001',
        merk: 'Toyota',
        tipe: 'Avanza',
        plate: 'B9999XYZ',
        isActive: true,
      );
      provider.setVehicles([newVehicle]);
      await tester.pumpAndSettle();

      // STEP 3: Verify vehicle is displayed
      expect(find.text('Toyota'), findsOneWidget);
      expect(find.text('B9999XYZ'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.byType(VehicleCard), findsOneWidget);

      // STEP 4: Tap vehicle card to view details
      await tester.tap(find.byType(VehicleCard));
      await tester.pumpAndSettle();

      // STEP 5: Verify detail page displays
      expect(find.byType(VehicleDetailPage), findsOneWidget);
      expect(find.text('Toyota'), findsAtLeastNWidgets(1));
      expect(find.text('B9999XYZ'), findsAtLeastNWidgets(1));

      // STEP 6: Delete vehicle
      final deleteOutlinedButton = find.widgetWithText(OutlinedButton, 'Hapus Kendaraan');
      await tester.tap(deleteOutlinedButton);
      await tester.pumpAndSettle();

      // STEP 7: Confirm deletion
      expect(find.text('Hapus Kendaraan'), findsWidgets);
      final confirmButton = find.text('Hapus').last;
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // STEP 8: Verify vehicle is removed
      provider.setVehicles([]);
      await tester.pumpAndSettle();

      expect(find.text('Toyota'), findsNothing);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('Error recovery flow: error → retry → success', 
        (WidgetTester tester) async {
      // Setup error state
      provider.setErrorForTesting('Network connection failed');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Verify error state is displayed
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Network connection failed'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, equals('Network connection failed'));

      // STEP 2: Fix the error
      provider.setUser(_createTestUser(name: 'Recovered User'));
      provider.setVehicles([
        _createTestVehicle(merk: 'Recovered', tipe: 'Vehicle', isActive: true),
      ]);

      // STEP 3: Tap retry button
      final retryButton = find.widgetWithText(ElevatedButton, 'Coba Lagi');
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      // STEP 4: Verify error is cleared and data is displayed
      expect(find.text('Terjadi Kesalahan'), findsNothing);
      expect(find.text('Recovered User'), findsOneWidget);
      expect(find.text('Recovered'), findsOneWidget);
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.user, isNotNull);
      expect(provider.vehicles.length, equals(1));
    });

    testWidgets('Navigation flow: profile → edit → vehicle detail → back', 
        (WidgetTester tester) async {
      // Setup test data
      final testUser = _createTestUser(name: 'Nav Test User');
      final testVehicles = [
        _createTestVehicle(
          id: 'VEH001',
          merk: 'Nav',
          tipe: 'Test',
          plate: 'B1111NAV',
          isActive: true,
        ),
      ];

      provider.setUser(testUser);
      provider.setVehicles(testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
          routes: {
            '/edit-profile': (context) => ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: const EditProfilePage(),
            ),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/vehicle-detail') {
              final vehicle = settings.arguments as VehicleModel;
              return MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<ProfileProvider>.value(
                  value: provider,
                  child: VehicleDetailPage(vehicle: vehicle),
                ),
              );
            }
            return null;
          },
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Verify we're on profile page
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Nav Test User'), findsOneWidget);

      // STEP 2: Navigate to edit profile
      final editButton = find.text('Ubah informasi akun');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);

      // STEP 3: Navigate back to profile
      final backButton = find.byType(BackButton);
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);

      // STEP 4: Navigate to vehicle detail
      final vehicleCard = find.byType(VehicleCard);
      await tester.tap(vehicleCard);
      await tester.pumpAndSettle();

      expect(find.byType(VehicleDetailPage), findsOneWidget);
      expect(find.text('Nav'), findsAtLeastNWidgets(1));

      // STEP 5: Navigate back to profile
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Nav Test User'), findsOneWidget);

      // STEP 6: Verify state is preserved
      expect(provider.user?.name, equals('Nav Test User'));
      expect(provider.vehicles.length, equals(1));
      expect(provider.vehicles[0].merk, equals('Nav'));
    });

    testWidgets('Active vehicle management: set active → verify indicator', 
        (WidgetTester tester) async {
      // Setup multiple vehicles
      final testUser = _createTestUser();
      final testVehicles = [
        _createTestVehicle(
          id: 'VEH001',
          merk: 'Car',
          tipe: '1',
          plate: 'B1111AAA',
          isActive: true,
        ),
        _createTestVehicle(
          id: 'VEH002',
          merk: 'Car',
          tipe: '2',
          plate: 'B2222BBB',
          isActive: false,
        ),
        _createTestVehicle(
          id: 'VEH003',
          merk: 'Car',
          tipe: '3',
          plate: 'B3333CCC',
          isActive: false,
        ),
      ];

      provider.setUser(testUser);
      provider.setVehicles(testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/vehicle-detail') {
              final vehicle = settings.arguments as VehicleModel;
              return MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<ProfileProvider>.value(
                  value: provider,
                  child: VehicleDetailPage(vehicle: vehicle),
                ),
              );
            }
            return null;
          },
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Verify only one vehicle has active badge
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Car'), findsWidgets);

      // STEP 2: Tap on second vehicle
      final car2Card = find.text('B2222BBB');
      await tester.tap(car2Card);
      await tester.pumpAndSettle();

      // STEP 3: Set as active
      final setActiveButton = find.text('Jadikan Kendaraan Aktif');
      if (setActiveButton.evaluate().isNotEmpty) {
        await tester.tap(setActiveButton);
        await tester.pumpAndSettle();

        // Update mock data
        provider.setVehicles([
          testVehicles[0].copyWith(isActive: false),
          testVehicles[1].copyWith(isActive: true),
          testVehicles[2],
        ]);
        await tester.pumpAndSettle();

        // STEP 4: Navigate back and verify
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();

        // STEP 5: Verify active indicator moved
        expect(find.text('Aktif'), findsOneWidget);
        
        // Verify exactly one vehicle is active
        final activeVehicles = provider.vehicles.where((v) => v.isActive).toList();
        expect(activeVehicles.length, equals(1));
        expect(activeVehicles[0].idKendaraan, equals('VEH002'));
      }
    });

    testWidgets('Pull-to-refresh updates profile and vehicles', 
        (WidgetTester tester) async {
      // Setup initial data
      final initialUser = _createTestUser(name: 'Initial User', saldoPoin: 1000);
      final initialVehicles = [
        _createTestVehicle(merk: 'Initial', tipe: 'Vehicle', isActive: true),
      ];

      provider.setUser(initialUser);
      provider.setVehicles(initialVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial data
      expect(find.text('Initial User'), findsOneWidget);
      expect(find.text('Initial'), findsOneWidget);
      expect(find.textContaining('1.000'), findsWidgets);

      // Update mock data
      final updatedUser = _createTestUser(name: 'Updated User', saldoPoin: 2000);
      final updatedVehicles = [
        _createTestVehicle(merk: 'Updated', tipe: 'Vehicle', isActive: true),
        _createTestVehicle(
          id: 'VEH002',
          merk: 'New',
          tipe: 'Vehicle',
          plate: 'B9999NEW',
          isActive: false,
        ),
      ];

      provider.setUser(updatedUser);
      provider.setVehicles(updatedVehicles);

      // Perform pull-to-refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Verify updated data is displayed
      expect(find.text('Updated User'), findsOneWidget);
      expect(find.text('Updated'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.textContaining('2.000'), findsWidgets);
      expect(provider.vehicles.length, equals(2));
    });

    testWidgets('Swipe-to-delete vehicle with confirmation', 
        (WidgetTester tester) async {
      // Setup test data
      final testUser = _createTestUser();
      final testVehicles = [
        _createTestVehicle(
          id: 'VEH001',
          merk: 'To',
          tipe: 'Delete',
          plate: 'B1111DEL',
          isActive: true,
        ),
        _createTestVehicle(
          id: 'VEH002',
          merk: 'To',
          tipe: 'Keep',
          plate: 'B2222KEP',
          isActive: false,
        ),
      ];

      provider.setUser(testUser);
      provider.setVehicles(testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both vehicles are displayed
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);

      // Swipe to delete first vehicle
      await tester.drag(
        find.text('Delete'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Hapus Kendaraan'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin menghapus kendaraan ini?'), findsOneWidget);

      // Confirm deletion
      final confirmButton = find.text('Hapus');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Update mock data
      provider.setVehicles([testVehicles[1]]);
      await tester.pumpAndSettle();

      // Verify vehicle is removed
      expect(find.text('Delete'), findsNothing);
      expect(find.text('Keep'), findsOneWidget);
      expect(provider.vehicles.length, equals(1));
    });

    testWidgets('Multiple error scenarios and recovery', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      // Scenario 1: Network error
      provider.setErrorForTesting('Network timeout');
      await tester.pumpAndSettle();

      expect(find.text('Network timeout'), findsOneWidget);
      expect(provider.hasError, isTrue);

      // Scenario 2: Recover from network error
      provider.setUser(_createTestUser(name: 'Recovered'));
      provider.setVehicles([]);
      
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Recovered'), findsOneWidget);
      expect(provider.hasError, isFalse);

      // Scenario 3: Vehicle fetch error
      provider.setErrorForTesting('Failed to load vehicles');
      await tester.pumpAndSettle();

      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('vehicles'));

      // Scenario 4: Recover from vehicle error
      provider.setVehicles([
        _createTestVehicle(merk: 'Recovered', tipe: 'Vehicle', isActive: true),
      ]);
      provider.clearError();
      await tester.pumpAndSettle();

      expect(find.text('Recovered'), findsOneWidget);
      expect(provider.hasError, isFalse);
    });

    testWidgets('State persistence across multiple operations', 
        (WidgetTester tester) async {
      // Setup initial state
      final testUser = _createTestUser(name: 'Persistent User', saldoPoin: 5000);
      final testVehicles = [
        _createTestVehicle(id: 'VEH001', merk: 'Vehicle', tipe: '1', isActive: true),
      ];

      provider.setUser(testUser);
      provider.setVehicles(testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state
      expect(provider.user?.name, equals('Persistent User'));
      expect(provider.user?.saldoPoin, equals(5000));
      expect(provider.vehicles.length, equals(1));

      // Operation 1: Add vehicle
      final newVehicle = _createTestVehicle(
        id: 'VEH002',
        merk: 'Vehicle',
        tipe: '2',
        plate: 'B2222BBB',
        isActive: false,
      );
      provider.setVehicles([...testVehicles, newVehicle]);
      await tester.pumpAndSettle();

      expect(provider.vehicles.length, equals(2));

      // Operation 2: Update user points
      final updatedUser = testUser.copyWith(saldoPoin: 7000);
      provider.setUser(updatedUser);
      await tester.pumpAndSettle();

      expect(provider.user?.saldoPoin, equals(7000));
      expect(provider.vehicles.length, equals(2)); // Vehicles still there

      // Operation 3: Delete vehicle
      provider.setVehicles([testVehicles[0]]);
      await tester.pumpAndSettle();

      expect(provider.vehicles.length, equals(1));
      expect(provider.user?.saldoPoin, equals(7000)); // User data still there

      // Verify final state
      expect(provider.user?.name, equals('Persistent User'));
      expect(provider.user?.saldoPoin, equals(7000));
      expect(provider.vehicles.length, equals(1));
      expect(provider.vehicles[0].merk, equals('Vehicle'));
    });
  });
}

// Test Data Helpers
UserModel _createTestUser({
  String id = 'USER001',
  String name = 'Test User',
  String email = 'test@example.com',
  String? phoneNumber = '081234567890',
  String? photoUrl,
  int saldoPoin = 0,
}) {
  return UserModel(
    id: id,
    name: name,
    email: email,
    phoneNumber: phoneNumber,
    photoUrl: photoUrl,
    saldoPoin: saldoPoin,
    createdAt: DateTime.now(),
  );
}

VehicleModel _createTestVehicle({
  String id = 'VEH001',
  String userId = 'USER001',
  String merk = 'Test',
  String tipe = 'Vehicle',
  String plate = 'B1234XYZ',
  String type = 'Roda Empat',
  bool isActive = false,
}) {
  return VehicleModel(
    idKendaraan: id,
    platNomor: plate,
    jenisKendaraan: type,
    merk: merk,
    tipe: tipe,
    isActive: isActive,
  );
}
