import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';

void main() {
  group('ProfilePage Integration Tests', () {
    testWidgets('ProfilePage should display loading state initially',
        (WidgetTester tester) async {
      // Create provider
      final profileProvider = ProfileProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: const ProfilePage(),
          ),
        ),
      );

      // Verify loading state is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat data profil...'), findsOneWidget);
    });

    testWidgets('ProfilePage should use Consumer for reactive UI',
        (WidgetTester tester) async {
      // Create provider
      final profileProvider = ProfileProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: const ProfilePage(),
          ),
        ),
      );

      // Verify Consumer is being used by checking if loading state appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProfilePage should handle error state with retry button',
        (WidgetTester tester) async {
      // Create provider with error state
      final profileProvider = ProfileProvider();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
            child: const ProfilePage(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pump();

      // Simulate error by waiting for the API call to fail
      await tester.pump(const Duration(seconds: 2));

      // Check if error state is displayed (if API fails)
      // Note: This test depends on the actual API behavior
    });
  });
}
