import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';

void main() {
  group('ProfilePage Swipe-to-Delete Tests', () {
    testWidgets('Shows confirmation dialog when swiping to delete vehicle', (WidgetTester tester) async {
      // Create provider with test vehicles
      final provider = ProfileProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      // Wait for the widget to build and data to load
      await tester.pumpAndSettle();

      // Find the first Dismissible widget (there will be 2 from mock data)
      final dismissible = find.byType(Dismissible).first;

      // Swipe to delete
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Hapus Kendaraan'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin menghapus Toyota Avanza (B 1234 XYZ)?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('Cancels deletion when Batal is tapped', (WidgetTester tester) async {
      // Create provider with test vehicles
      final provider = ProfileProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialVehicleCount = provider.vehicles.length;

      // Swipe to delete the first vehicle
      final dismissible = find.byType(Dismissible).first;
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Batal button
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Verify vehicle count is unchanged
      expect(provider.vehicles.length, initialVehicleCount);
    });

    testWidgets('Deletes vehicle when Hapus is confirmed', (WidgetTester tester) async {
      // Create provider with test vehicles
      final provider = ProfileProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialVehicleCount = provider.vehicles.length;

      // Swipe to delete the first vehicle
      final dismissible = find.byType(Dismissible).first;
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Hapus button
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Wait for deletion to complete
      await tester.pump(const Duration(milliseconds: 500));

      // Verify vehicle count decreased by 1
      expect(provider.vehicles.length, initialVehicleCount - 1);
    });

    testWidgets('Shows undo snackbar after deletion', (WidgetTester tester) async {
      // Create provider with test vehicles
      final provider = ProfileProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Swipe to delete the first vehicle
      final dismissible = find.byType(Dismissible).first;
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Hapus button
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Wait for deletion and snackbar
      await tester.pump(const Duration(milliseconds: 500));

      // Verify snackbar appears with undo button
      expect(find.text('Urungkan'), findsOneWidget);
      // The snackbar should contain "dihapus" text
      expect(find.textContaining('dihapus'), findsOneWidget);
    });

    testWidgets('Undo button restores deleted vehicle', (WidgetTester tester) async {
      // Create provider with test vehicles
      final provider = ProfileProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialVehicleCount = provider.vehicles.length;
      final firstVehicleId = provider.vehicles[0].idKendaraan;

      // Swipe to delete the first vehicle
      final dismissible = find.byType(Dismissible).first;
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Hapus button
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Wait for deletion
      await tester.pump(const Duration(milliseconds: 500));

      // Verify vehicle count decreased
      expect(provider.vehicles.length, initialVehicleCount - 1);

      // Tap Urungkan button
      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();

      // Wait for restoration
      await tester.pump(const Duration(milliseconds: 500));

      // Verify vehicle is restored
      expect(provider.vehicles.length, initialVehicleCount);
      // The restored vehicle should have the same ID
      expect(provider.vehicles.any((v) => v.idKendaraan == firstVehicleId), isTrue);
    });

    testWidgets('Shows red background with delete icon when swiping', (WidgetTester tester) async {
      // Create provider with test vehicles
      final provider = ProfileProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: provider,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start swiping the first vehicle (but don't complete)
      final dismissible = find.byType(Dismissible).first;
      await tester.drag(dismissible, const Offset(-200, 0));
      await tester.pump();

      // Verify delete icon is visible in background
      expect(find.byIcon(Icons.delete), findsWidgets);
    });
  });
}
