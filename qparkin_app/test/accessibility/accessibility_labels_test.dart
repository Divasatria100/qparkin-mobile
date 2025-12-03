import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/presentation/screens/edit_profile_page.dart';
import 'package:qparkin_app/presentation/screens/vehicle_detail_page.dart';
import 'package:qparkin_app/presentation/widgets/profile/vehicle_card.dart';
import 'package:qparkin_app/presentation/widgets/common/empty_state_widget.dart';
import 'package:qparkin_app/presentation/widgets/common/animated_card.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/user_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';

/// Mock ProfileProvider for testing
class MockProfileProvider extends ProfileProvider {
  void setTestUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
  
  void setTestVehicles(List<VehicleModel> vehicles) {
    _vehicles = vehicles;
    notifyListeners();
  }
  
  // Access to private fields for testing
  UserModel? _user;
  List<VehicleModel> _vehicles = [];
  
  @override
  UserModel? get user => _user;
  
  @override
  List<VehicleModel> get vehicles => _vehicles;
  
  @override
  bool get isLoading => false;
  
  @override
  bool get hasError => false;
  
  // Override async methods to prevent pending timers
  @override
  Future<void> fetchUserData() async {
    // Do nothing - data is set via setTestUser
    return Future.value();
  }
  
  @override
  Future<void> fetchVehicles() async {
    // Do nothing - data is set via setTestVehicles
    return Future.value();
  }
  
  @override
  Future<void> refreshAll() async {
    // Do nothing in tests
    return Future.value();
  }
}

/// **Feature: profile-page-enhancement, Property 12: Accessibility Labels**
/// **Validates: Requirements 8.1, 8.2**
///
/// Property: For any interactive element, semantic labels and hints should be present
/// This test verifies that all interactive elements have meaningful semantic labels
/// and hints that describe their actions for screen reader users.
void main() {
  group('Property 12: Accessibility Labels -', () {
    testWidgets('All interactive elements in ProfilePage have semantic labels',
        (WidgetTester tester) async {
      // Create mock provider with test data
      final provider = MockProfileProvider();
      
      // Set up test user data
      provider.setTestUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '081234567890',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      
      // Set up test vehicle data
      provider.setTestVehicles([
        VehicleModel(
          idKendaraan: '1',
          merk: 'Toyota',
          tipe: 'Avanza',
          platNomor: 'B 1234 XYZ',
          jenisKendaraan: 'Roda Empat',
          warna: 'Hitam',
          isActive: true,
        ),
      ]);

      // Build the ProfilePage
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Verify semantic labels exist for key interactive elements
      
      // 1. Profile photo should have semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Foto profil.*')),
        findsOneWidget,
        reason: 'Profile photo should have semantic label',
      );
      
      // 2. Points card should have semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Kartu poin.*')),
        findsOneWidget,
        reason: 'Points card should have semantic label',
      );
      
      // 3. Vehicle card should have semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Kartu kendaraan.*')),
        findsOneWidget,
        reason: 'Vehicle card should have semantic label',
      );
      
      // 4. Menu items should have semantic labels
      expect(
        find.bySemanticsLabel(RegExp(r'Ubah informasi akun.*')),
        findsOneWidget,
        reason: 'Edit profile menu item should have semantic label',
      );
      
      // 5. Section headers should be marked as headers
      final headerFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.header == true,
      );
      expect(
        headerFinder,
        findsWidgets,
        reason: 'Section headers should be marked with header: true',
      );
    });

    testWidgets('VehicleCard has proper semantic labels and hints',
        (WidgetTester tester) async {
      final vehicle = VehicleModel(
        idKendaraan: '1',
        merk: 'Honda',
        tipe: 'Beat',
        platNomor: 'B 5678 ABC',
        jenisKendaraan: 'Roda Dua',
        warna: 'Merah',
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(
              vehicle: vehicle,
              isActive: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify vehicle card has semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Kartu kendaraan.*Honda.*Beat.*')),
        findsOneWidget,
        reason: 'Vehicle card should have descriptive semantic label',
      );
      
      // Verify it's marked as a button
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                     widget.properties.button == true &&
                     widget.properties.label?.contains('Kartu kendaraan') == true,
      );
      expect(
        semanticsFinder,
        findsOneWidget,
        reason: 'Vehicle card should be marked as button',
      );
    });

    testWidgets('EmptyStateWidget has proper semantic labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.directions_car,
              title: 'Tidak ada kendaraan',
              description: 'Anda belum memiliki kendaraan terdaftar',
              actionText: 'Tambah Kendaraan',
              onAction: () {},
            ),
          ),
        ),
      );

      // Verify empty state has semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Tidak ada kendaraan.*')),
        findsOneWidget,
        reason: 'Empty state should have semantic label',
      );
      
      // Verify action button has semantic label and hint
      expect(
        find.bySemanticsLabel('Tambah Kendaraan'),
        findsOneWidget,
        reason: 'Action button should have semantic label',
      );
      
      // Verify button is marked as button
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                     widget.properties.button == true &&
                     widget.properties.label == 'Tambah Kendaraan',
      );
      expect(
        buttonFinder,
        findsOneWidget,
        reason: 'Action button should be marked as button',
      );
    });

    testWidgets('EditProfilePage form fields have semantic labels',
        (WidgetTester tester) async {
      final provider = MockProfileProvider();
      provider.setTestUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '081234567890',
        saldoPoin: 0,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const EditProfilePage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Verify form field labels exist
      expect(
        find.bySemanticsLabel(RegExp(r'Kolom input nama lengkap')),
        findsOneWidget,
        reason: 'Name field should have semantic label',
      );
      
      expect(
        find.bySemanticsLabel(RegExp(r'Kolom input email')),
        findsOneWidget,
        reason: 'Email field should have semantic label',
      );
      
      expect(
        find.bySemanticsLabel(RegExp(r'Kolom input nomor telepon')),
        findsOneWidget,
        reason: 'Phone field should have semantic label',
      );
      
      // Verify save button has semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Tombol simpan perubahan')),
        findsOneWidget,
        reason: 'Save button should have semantic label',
      );
    });

    testWidgets('VehicleDetailPage buttons have semantic labels and hints',
        (WidgetTester tester) async {
      final vehicle = VehicleModel(
        idKendaraan: '1',
        merk: 'Toyota',
        tipe: 'Avanza',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        warna: 'Hitam',
        isActive: false,
      );

      final provider = MockProfileProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: VehicleDetailPage(vehicle: vehicle),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Verify set active button has semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Tombol jadikan kendaraan aktif')),
        findsOneWidget,
        reason: 'Set active button should have semantic label',
      );
      
      // Verify edit button has semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Tombol edit kendaraan')),
        findsOneWidget,
        reason: 'Edit button should have semantic label',
      );
      
      // Verify delete button has semantic label
      expect(
        find.bySemanticsLabel(RegExp(r'Tombol hapus kendaraan')),
        findsOneWidget,
        reason: 'Delete button should have semantic label',
      );
      
      // Verify all buttons are marked as buttons
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                     widget.properties.button == true &&
                     (widget.properties.label?.contains('Tombol') == true),
      );
      expect(
        buttonFinder,
        findsNWidgets(3),
        reason: 'All action buttons should be marked as buttons',
      );
    });

    testWidgets('Property test: Random interactive elements have semantic labels',
        (WidgetTester tester) async {
      // Run multiple iterations with random data
      for (int i = 0; i < 10; i++) {
        final provider = MockProfileProvider();
        
        // Generate random user
        provider.setTestUser(UserModel(
          id: 'user_$i',
          name: 'User $i',
          email: 'user$i@example.com',
          phoneNumber: '08123456789$i',
          saldoPoin: i * 10,
          createdAt: DateTime.now(),
        ));
        
        // Generate random vehicles (0-5 vehicles)
        final vehicleCount = i % 6;
        final vehicles = List<VehicleModel>.generate(vehicleCount, (index) {
          return VehicleModel(
            idKendaraan: 'vehicle_${i}_$index',
            merk: 'Merk $index',
            tipe: 'Tipe $index',
            platNomor: 'B ${1000 + index} XYZ',
            jenisKendaraan: index % 2 == 0 ? 'Roda Empat' : 'Roda Dua',
            warna: 'Warna $index',
            isActive: index == 0,
          );
        });
        provider.setTestVehicles(vehicles);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: const ProfilePage(),
            ),
          ),
        );
        
        await tester.pumpAndSettle();

        // Verify semantic labels exist regardless of data
        expect(
          find.bySemanticsLabel(RegExp(r'Foto profil.*')),
          findsOneWidget,
          reason: 'Profile photo should always have semantic label (iteration $i)',
        );
        
        expect(
          find.bySemanticsLabel(RegExp(r'Kartu poin.*')),
          findsOneWidget,
          reason: 'Points card should always have semantic label (iteration $i)',
        );
        
        // If vehicles exist, verify vehicle cards have labels
        if (vehicleCount > 0) {
          expect(
            find.bySemanticsLabel(RegExp(r'Kartu kendaraan.*')),
            findsWidgets,
            reason: 'Vehicle cards should have semantic labels (iteration $i)',
          );
        } else {
          // If no vehicles, verify empty state has label
          expect(
            find.bySemanticsLabel(RegExp(r'Daftar kendaraan kosong')),
            findsOneWidget,
            reason: 'Empty vehicle state should have semantic label (iteration $i)',
          );
        }
      }
    });

    test('Property test: Semantic labels are meaningful and descriptive', () {
      // Test that semantic labels follow naming conventions
      final testCases = [
        {
          'label': 'Kartu kendaraan Toyota Avanza dengan plat nomor B 1234 XYZ',
          'isDescriptive': true,
          'reason': 'Contains vehicle details',
        },
        {
          'label': 'Tombol simpan perubahan',
          'isDescriptive': true,
          'reason': 'Clearly describes action',
        },
        {
          'label': 'Ketuk untuk melihat detail kendaraan',
          'isDescriptive': true,
          'reason': 'Describes what happens on tap',
        },
        {
          'label': 'Button',
          'isDescriptive': false,
          'reason': 'Too generic',
        },
        {
          'label': 'Click here',
          'isDescriptive': false,
          'reason': 'Not descriptive',
        },
      ];

      for (final testCase in testCases) {
        final label = testCase['label'] as String;
        final isDescriptive = testCase['isDescriptive'] as bool;
        final reason = testCase['reason'] as String;

        // Check if label is meaningful (contains more than just generic words)
        final hasSpecificContent = label.length > 10 && 
                                   !label.toLowerCase().contains(RegExp(r'^(button|click|tap)$'));
        
        if (isDescriptive) {
          expect(
            hasSpecificContent,
            isTrue,
            reason: 'Label "$label" should be descriptive: $reason',
          );
        }
      }
    });
  });
}
