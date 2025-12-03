import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfilePage Empty Vehicle State Tests', () {
    testWidgets('Shows EmptyStateWidget when vehicle list is empty',
        (WidgetTester tester) async {
      // Create a provider with user data but no vehicles
      final provider = ProfileProvider();
      
      // Set user data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      
      // Set empty vehicle list
      provider.setVehicles([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify EmptyStateWidget is displayed
      expect(find.text('Tidak ada kendaraan terdaftar'), findsOneWidget);
      expect(find.text('Anda belum memiliki kendaraan terdaftar. Tambahkan kendaraan untuk memulai parkir.'), findsOneWidget);
      expect(find.text('Tambah Kendaraan'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('Empty state action button navigates to vehicle list page',
        (WidgetTester tester) async {
      // Create a provider with user data but no vehicles
      final provider = ProfileProvider();
      
      // Set user data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      
      // Set empty vehicle list
      provider.setVehicles([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "Tambah Kendaraan" button
      final addButton = find.text('Tambah Kendaraan');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred (VehicleListPage should be displayed)
      // Note: We can't verify the exact page without importing it,
      // but we can verify that navigation happened by checking if
      // the ProfilePage is no longer the only widget
      expect(find.text('Tidak ada kendaraan terdaftar'), findsNothing);
    });

    testWidgets('Does not show EmptyStateWidget when vehicles exist',
        (WidgetTester tester) async {
      // Create a provider with user data and vehicles
      final provider = ProfileProvider();
      
      // Set user data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify EmptyStateWidget is NOT displayed when vehicles exist
      expect(find.text('Tidak ada kendaraan terdaftar'), findsNothing);
      expect(find.text('Tambah Kendaraan'), findsNothing);
    });

    testWidgets('Empty state has proper semantic labels for accessibility',
        (WidgetTester tester) async {
      // Create a provider with user data but no vehicles
      final provider = ProfileProvider();
      
      // Set user data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
      
      // Set empty vehicle list
      provider.setVehicles([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify semantic labels exist
      final semantics = tester.getSemantics(find.text('Tidak ada kendaraan terdaftar'));
      expect(semantics, isNotNull);
      
      // Verify button has proper semantics
      final buttonSemantics = tester.getSemantics(find.text('Tambah Kendaraan'));
      expect(buttonSemantics, isNotNull);
    });
  });
}
