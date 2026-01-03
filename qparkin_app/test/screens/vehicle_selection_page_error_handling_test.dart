// 📄 test/screens/vehicle_selection_page_error_handling_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/tambah_kendaraan.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/services/vehicle_api_service.dart';

/// Mock VehicleApiService that throws errors for testing
class MockErrorVehicleApiService extends VehicleApiService {
  final String errorType;
  
  MockErrorVehicleApiService({required this.errorType}) 
      : super(baseUrl: 'http://test.com/api');

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
    throw Exception(_getErrorMessage());
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
    throw Exception(_getErrorMessage());
  }

  String _getErrorMessage() {
    switch (errorType) {
      case 'timeout':
        return 'Connection timeout';
      case 'unauthorized':
        return 'Unauthorized 401';
      case 'not_found':
        return 'Not found 404';
      case 'validation':
        return 'Validation error 422';
      case 'server':
        return 'Server error 500';
      case 'network':
        return 'Network error';
      default:
        return 'Unknown error';
    }
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
  group('VehicleSelectionPage Error Handling Tests - Edit Mode', () {
    final testVehicle = VehicleModel(
      idKendaraan: '1',
      platNomor: 'B 1234 XYZ',
      jenisKendaraan: 'Roda Empat',
      merk: 'Toyota',
      tipe: 'Avanza',
      warna: 'Hitam',
      isActive: true,
    );

    Widget createTestWidget({required String errorType}) {
      final mockApiService = MockErrorVehicleApiService(errorType: errorType);
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ProfileProvider(vehicleApiService: mockApiService),
          child: VehicleSelectionPage(
            isEditMode: true,
            vehicle: testVehicle,
          ),
        ),
      );
    }

    testWidgets('10.1.1 - Timeout error shows user-friendly message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'timeout'));
      await tester.pumpAndSettle();

      // Find and tap submit button
      final submitButton = find.text('Simpan Perubahan');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify user-friendly error message is shown
      expect(
        find.text('Koneksi internet bermasalah. Silakan periksa koneksi Anda dan coba lagi.'),
        findsOneWidget,
      );

      // Verify we're still on the same page (not navigated away)
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('10.1.2 - Unauthorized error shows session expired message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'unauthorized'));
      await tester.pumpAndSettle();

      // Find and tap submit button
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify user-friendly error message is shown
      expect(
        find.text('Sesi Anda telah berakhir. Silakan login kembali.'),
        findsOneWidget,
      );

      // Verify we're still on the same page
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('10.1.3 - Not found error shows appropriate message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'not_found'));
      await tester.pumpAndSettle();

      // Find and tap submit button
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify user-friendly error message is shown
      expect(
        find.text('Kendaraan tidak ditemukan. Data mungkin sudah dihapus.'),
        findsOneWidget,
      );

      // Verify we're still on the same page
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('10.1.4 - Validation error shows appropriate message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'validation'));
      await tester.pumpAndSettle();

      // Find and tap submit button
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify user-friendly error message is shown
      expect(
        find.text('Data yang dimasukkan tidak valid. Periksa kembali informasi kendaraan.'),
        findsOneWidget,
      );

      // Verify we're still on the same page
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('10.1.5 - Server error shows appropriate message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'server'));
      await tester.pumpAndSettle();

      // Find and tap submit button
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify user-friendly error message is shown
      expect(
        find.text('Server sedang bermasalah. Silakan coba beberapa saat lagi.'),
        findsOneWidget,
      );

      // Verify we're still on the same page
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('10.1.6 - Network error shows appropriate message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'network'));
      await tester.pumpAndSettle();

      // Find and tap submit button
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify user-friendly error message is shown
      expect(
        find.text('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'),
        findsOneWidget,
      );

      // Verify we're still on the same page
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('10.1.7 - User can retry after error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'network'));
      await tester.pumpAndSettle();

      // First attempt - should fail
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(
        find.text('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'),
        findsOneWidget,
      );

      // Verify submit button is still available for retry
      expect(submitButton, findsOneWidget);
      
      // Verify form fields are still editable (not disabled)
      final merekField = find.widgetWithText(TextField, 'Merek Kendaraan *');
      expect(merekField, findsOneWidget);
      
      // User can modify data and retry
      await tester.enterText(merekField, 'Honda');
      await tester.pumpAndSettle();
      
      // Submit button should still be tappable
      expect(submitButton, findsOneWidget);
    });

    testWidgets('10.1.8 - Loading state is cleared after error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'server'));
      await tester.pumpAndSettle();

      // Tap submit button
      final submitButton = find.text('Simpan Perubahan');
      await tester.tap(submitButton);
      
      // During loading, button should show loading indicator
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // After error, loading should be cleared
      await tester.pumpAndSettle();
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      
      // Loading overlay should not be visible
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('VehicleSelectionPage Error Handling Tests - Add Mode', () {
    Widget createTestWidget({required String errorType}) {
      final mockApiService = MockErrorVehicleApiService(errorType: errorType);
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ProfileProvider(vehicleApiService: mockApiService),
          child: const VehicleSelectionPage(
            isEditMode: false,
          ),
        ),
      );
    }

    testWidgets('10.1.9 - Add mode shows appropriate error messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(errorType: 'network'));
      await tester.pumpAndSettle();

      // Select vehicle type
      final rodaEmpatCard = find.text('Roda Empat');
      await tester.tap(rodaEmpatCard);
      await tester.pumpAndSettle();

      // Fill in required fields
      await tester.enterText(
        find.widgetWithText(TextField, 'Merek Kendaraan *'),
        'Toyota',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Tipe/Model Kendaraan *'),
        'Avanza',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Plat Nomor *'),
        'B 1234 XYZ',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Warna Kendaraan *'),
        'Hitam',
      );
      await tester.pumpAndSettle();

      // Tap submit button
      final submitButton = find.text('Tambahkan Kendaraan');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify error message uses "menambahkan" context
      expect(
        find.text('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'),
        findsOneWidget,
      );

      // Verify we're still on the same page
      expect(find.text('Tambah Kendaraan'), findsOneWidget);
    });
  });
}
