// 📄 test/screens/vehicle_selection_page_api_error_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';

/// Mock ProfileProvider that simulates API errors
class MockProfileProviderWithErrors extends ChangeNotifier implements ProfileProvider {
  String? errorToThrow;
  int updateCallCount = 0;
  
  @override
  Future<void> updateVehicle({
    required String id,
    String? platNomor,
    String? jenisKendaraan,
    String? merk,
    String? tipe,
    String? warna,
    bool? isActive,
    dynamic foto,
  }) async {
    updateCallCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    if (errorToThrow != null) {
      throw Exception(errorToThrow);
    }
  }
  
  @override
  Future<void> addVehicle({
    required String platNomor,
    required String jenisKendaraan,
    required String merk,
    required String tipe,
    String? warna,
    bool isActive = false,
    dynamic foto,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (errorToThrow != null) {
      throw Exception(errorToThrow);
    }
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('API Error Handling in Edit Mode', () {
    testWidgets('displays user-friendly error for timeout', (WidgetTester tester) async {
      final mockProvider = MockProfileProviderWithErrors();
      mockProvider.errorToThrow = 'Connection timeout';
      
      final testVehicle = VehicleModel(
        idKendaraan: '123',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: mockProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Modify brand field
      await tester.enterText(find.byType(TextField).first, 'Honda');
      await tester.pumpAndSettle();

      // Scroll to submit button
      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Tap submit button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify user-friendly error message
      expect(
        find.text('Koneksi internet bermasalah. Silakan periksa koneksi Anda dan coba lagi.'),
        findsOneWidget,
      );
      
      // Verify page did not navigate away
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('does not navigate away on error', (WidgetTester tester) async {
      final mockProvider = MockProfileProviderWithErrors();
      mockProvider.errorToThrow = 'Network error';
      
      final testVehicle = VehicleModel(
        idKendaraan: '123',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: mockProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Modify field
      await tester.enterText(find.byType(TextField).first, 'Honda');
      await tester.pumpAndSettle();

      // Scroll to submit button
      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify still on same page
      expect(find.text('Edit Kendaraan'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets('allows retry after error', (WidgetTester tester) async {
      final mockProvider = MockProfileProviderWithErrors();
      mockProvider.errorToThrow = 'Network error';
      
      final testVehicle = VehicleModel(
        idKendaraan: '123',
        platNomor: 'B 1234 XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: mockProvider,
            child: VehicleSelectionPage(
              isEditMode: true,
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Modify field
      await tester.enterText(find.byType(TextField).first, 'Honda');
      await tester.pumpAndSettle();

      // Scroll to submit button
      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // First attempt - fails
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(mockProvider.updateCallCount, 1);

      // Clear error for retry
      mockProvider.errorToThrow = null;

      // Wait for snackbar to disappear (3 seconds duration + extra time)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Scroll to button again
      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Second attempt - succeeds
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify retry was attempted
      expect(mockProvider.updateCallCount, 2);
    });
  });
}
