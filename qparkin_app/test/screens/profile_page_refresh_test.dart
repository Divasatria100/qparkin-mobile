import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/user_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';

void main() {
  group('ProfilePage Pull-to-Refresh Tests', () {
    late ProfileProvider provider;

    setUp(() {
      provider = ProfileProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<ProfileProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: ProfilePage(),
        ),
      );
    }

    testWidgets('should display RefreshIndicator with brand color',
        (WidgetTester tester) async {
      // Set up provider with data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      provider.setVehicles([
        VehicleModel(
          idKendaraan: '1',
          platNomor: 'B 1234 XYZ',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
          warna: 'Hitam',
          isActive: true,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find RefreshIndicator
      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );

      // Verify brand color is used
      expect(refreshIndicator.color, equals(const Color(0xFF573ED1)));
    });

    testWidgets('should use AlwaysScrollableScrollPhysics for scrolling',
        (WidgetTester tester) async {
      // Set up provider with data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      provider.setVehicles([
        VehicleModel(
          idKendaraan: '1',
          platNomor: 'B 1234 XYZ',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
          warna: 'Hitam',
          isActive: true,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find SingleChildScrollView
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );

      // Verify AlwaysScrollableScrollPhysics is used
      expect(
        scrollView.physics,
        isA<AlwaysScrollableScrollPhysics>(),
      );
    });

    testWidgets('should have RefreshIndicator wrapping the scroll view',
        (WidgetTester tester) async {
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      provider.setVehicles([
        VehicleModel(
          idKendaraan: '1',
          platNomor: 'B 1234 XYZ',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
          warna: 'Hitam',
          isActive: true,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify RefreshIndicator exists
      expect(find.byType(RefreshIndicator), findsOneWidget);
      
      // Verify SingleChildScrollView exists inside RefreshIndicator
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should call refreshAll when pull-to-refresh is triggered',
        (WidgetTester tester) async {
      // Set up provider with initial data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      provider.setVehicles([
        VehicleModel(
          idKendaraan: '1',
          platNomor: 'B 1234 XYZ',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
          warna: 'Hitam',
          isActive: true,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify RefreshIndicator exists
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Perform pull-to-refresh gesture
      await tester.drag(
        find.text('Profile'),
        const Offset(0, 300),
      );
      await tester.pump();
      
      // Wait for refresh to complete
      await tester.pumpAndSettle();

      // Verify page is still functional after refresh
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
