import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Page Navigation Tests', () {
    testWidgets('ProfilePage has CurvedNavigationBar with correct index', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfilePage(),
          routes: {
            '/home': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Home Page')),
                  body: const Center(child: Text('Home Page Content')),
                ),
            '/activity': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Activity Page')),
                  body: const Center(child: Text('Activity Page Content')),
                ),
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: const Center(child: Text('Map Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify ProfilePage is displayed
      expect(find.text('Profile'), findsOneWidget);
      
      // Verify bottom navigation bar exists
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Aktivitas'), findsOneWidget);
      expect(find.text('Peta'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Bottom navigation navigates to Home Page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfilePage(),
          routes: {
            '/home': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Home Page')),
                  body: const Center(child: Text('Home Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Beranda" navigation item
      final berandaNav = find.text('Beranda');
      expect(berandaNav, findsOneWidget);

      await tester.tap(berandaNav);
      await tester.pumpAndSettle();

      // Verify navigation to Home Page
      expect(find.text('Home Page'), findsOneWidget);
      expect(find.text('Home Page Content'), findsOneWidget);
    });

    testWidgets('Bottom navigation navigates to Activity Page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfilePage(),
          routes: {
            '/activity': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Activity Page')),
                  body: const Center(child: Text('Activity Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Aktivitas" navigation item
      final aktivitasNav = find.text('Aktivitas');
      expect(aktivitasNav, findsOneWidget);

      await tester.tap(aktivitasNav);
      await tester.pumpAndSettle();

      // Verify navigation to Activity Page
      expect(find.text('Activity Page'), findsOneWidget);
      expect(find.text('Activity Page Content'), findsOneWidget);
    });

    testWidgets('Bottom navigation navigates to Map Page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfilePage(),
          routes: {
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: const Center(child: Text('Map Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Peta" navigation item
      final petaNav = find.text('Peta');
      expect(petaNav, findsOneWidget);

      await tester.tap(petaNav);
      await tester.pumpAndSettle();

      // Verify navigation to Map Page
      expect(find.text('Map Page'), findsOneWidget);
      expect(find.text('Map Page Content'), findsOneWidget);
    });

    testWidgets('Tapping current page (Profil) does not navigate', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfilePage(),
          routes: {
            '/profile': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Profile Page')),
                  body: const Center(child: Text('Profile Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Profil" navigation item (current page)
      final profilNav = find.text('Profil');
      expect(profilNav, findsOneWidget);

      await tester.tap(profilNav);
      await tester.pumpAndSettle();

      // Should still be on ProfilePage (no navigation)
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Diva Satria'), findsOneWidget);
    });

    testWidgets('Navigation preserves profile page state on return', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfilePage(),
          routes: {
            '/home': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Home Page')),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Profile'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Diva Satria'), findsOneWidget);

      // Navigate away
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('Back to Profile'));
      await tester.pumpAndSettle();

      // Verify state is preserved
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Diva Satria'), findsOneWidget);
    });
  });
}
