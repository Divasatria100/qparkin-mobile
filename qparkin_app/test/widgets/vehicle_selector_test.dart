import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';
import 'package:qparkin_app/data/services/vehicle_service.dart';
import 'package:qparkin_app/presentation/widgets/vehicle_selector.dart';

class MockVehicleService extends VehicleService {
  final List<VehicleModel> mockVehicles;
  final bool shouldFail;

  MockVehicleService({
    this.mockVehicles = const [],
    this.shouldFail = false,
  }) : super(baseUrl: 'http://test.com');

  @override
  Future<List<VehicleModel>> fetchVehicles() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldFail) {
      throw Exception('Failed to fetch vehicles');
    }
    return mockVehicles;
  }
}

void main() {
  group('VehicleSelector', () {
    late List<VehicleModel> testVehicles;

    setUp(() {
      testVehicles = [
        VehicleModel(
          idKendaraan: '1',
          platNomor: 'BP 1234 XY',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
        ),
        VehicleModel(
          idKendaraan: '2',
          platNomor: 'BP 5678 AB',
          jenisKendaraan: 'Roda Dua',
          merk: 'Honda',
          tipe: 'Beat',
        ),
      ];
    });

    testWidgets('displays loading state initially', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays vehicle dropdown after loading', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<VehicleModel>), findsOneWidget);
      expect(find.text('Pilih Kendaraan'), findsOneWidget);
    });

    testWidgets('displays vehicle list in dropdown', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButtonFormField<VehicleModel>));
      await tester.pumpAndSettle();

      expect(find.text('BP 1234 XY'), findsWidgets);
      expect(find.text('Toyota Avanza'), findsWidgets);
      expect(find.text('BP 5678 AB'), findsWidgets);
      expect(find.text('Honda Beat'), findsWidgets);
    });

    testWidgets('calls onVehicleSelected when vehicle is selected', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);
      VehicleModel? selectedVehicle;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (vehicle) {
                selectedVehicle = vehicle;
              },
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButtonFormField<VehicleModel>));
      await tester.pumpAndSettle();

      // Select first vehicle
      await tester.tap(find.text('BP 1234 XY').last);
      await tester.pumpAndSettle();

      expect(selectedVehicle, isNotNull);
      expect(selectedVehicle?.platNomor, 'BP 1234 XY');
    });

    testWidgets('displays selected vehicle', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: testVehicles[0],
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BP 1234 XY'), findsOneWidget);
      expect(find.text('Toyota Avanza'), findsOneWidget);
    });

    testWidgets('displays empty state when no vehicles', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum ada kendaraan'), findsOneWidget);
      expect(find.text('Tambahkan kendaraan terlebih dahulu'), findsOneWidget);
      expect(find.text('Tambah Kendaraan'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('displays error state on fetch failure', (WidgetTester tester) async {
      final mockService = MockVehicleService(shouldFail: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat kendaraan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button refetches vehicles', (WidgetTester tester) async {
      final mockService = MockVehicleService(shouldFail: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat kendaraan'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      // Should show loading again
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays correct icon for Roda Empat', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: testVehicles[0],
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('displays correct icon for Roda Dua', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: testVehicles[1],
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.two_wheeler), findsOneWidget);
    });

    testWidgets('shows purple border when focused', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      
      // Initially transparent border
      expect(shape.side.color, Colors.transparent);
    });

    testWidgets('has proper card styling', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: testVehicles);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
      expect(card.color, Colors.white);
      
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('shows snackbar when add vehicle button is tapped', (WidgetTester tester) async {
      final mockService = MockVehicleService(mockVehicles: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelector(
              selectedVehicle: null,
              onVehicleSelected: (_) {},
              vehicleService: mockService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add vehicle button
      await tester.tap(find.text('Tambah Kendaraan'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Navigasi ke halaman tambah kendaraan'), findsOneWidget);
    });
  });
}
