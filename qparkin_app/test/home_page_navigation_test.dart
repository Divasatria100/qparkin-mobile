import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/screens/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Navigation Tests', () {
    testWidgets('parking location card navigates to Map Page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: const Center(child: Text('Map Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the first parking location card
      final firstCard = find.text('Mega Mall Batam Centre');
      expect(firstCard, findsOneWidget);

      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Verify navigation to Map Page
      expect(find.text('Map Page'), findsOneWidget);
      expect(find.text('Map Page Content'), findsOneWidget);
    });

    testWidgets('"Lihat Semua" button navigates to Map Page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: const Center(child: Text('Map Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Lihat Semua" button
      final lihatSemuaButton = find.text('Lihat Semua');
      expect(lihatSemuaButton, findsOneWidget);

      await tester.tap(lihatSemuaButton);
      await tester.pumpAndSettle();

      // Verify navigation to Map Page
      expect(find.text('Map Page'), findsOneWidget);
      expect(find.text('Map Page Content'), findsOneWidget);
    });

    testWidgets('Peta quick action navigates to Map Page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: const Center(child: Text('Map Page Content')),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Peta" quick action
      final petaAction = find.text('Peta');
      expect(petaAction, findsOneWidget);

      await tester.tap(petaAction);
      await tester.pumpAndSettle();

      // Verify navigation to Map Page
      expect(find.text('Map Page'), findsOneWidget);
      expect(find.text('Map Page Content'), findsOneWidget);
    });

    testWidgets('Riwayat quick action navigates to Activity Page with initialTab', (WidgetTester tester) async {
      bool receivedCorrectArguments = false;

      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/activity') {
              // Verify arguments are passed correctly
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args['initialTab'] == 1) {
                receivedCorrectArguments = true;
              }

              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Activity Page')),
                  body: const Center(child: Text('Activity Page Content')),
                ),
              );
            }
            return null;
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Riwayat" quick action
      final riwayatAction = find.text('Riwayat');
      expect(riwayatAction, findsOneWidget);

      await tester.tap(riwayatAction);
      await tester.pumpAndSettle();

      // Verify navigation to Activity Page
      expect(find.text('Activity Page'), findsOneWidget);
      expect(find.text('Activity Page Content'), findsOneWidget);

      // Verify correct arguments were passed
      expect(receivedCorrectArguments, isTrue);
    });

    testWidgets('multiple navigation actions work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Map Page via Peta action
      await tester.tap(find.text('Peta'));
      await tester.pumpAndSettle();
      expect(find.text('Map Page'), findsOneWidget);

      // Navigate back to Home
      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);

      // Navigate to Map Page via parking card
      await tester.tap(find.text('Mega Mall Batam Centre'));
      await tester.pumpAndSettle();
      expect(find.text('Map Page'), findsOneWidget);

      // Navigate back to Home
      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);

      // Navigate to Map Page via "Lihat Semua"
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();
      expect(find.text('Map Page'), findsOneWidget);
    });

    testWidgets('navigation preserves home page state on return', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
                  appBar: AppBar(title: const Text('Map Page')),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);
      expect(find.text('One Batam Mall'), findsOneWidget);

      // Navigate away
      await tester.tap(find.text('Peta'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Verify state is preserved
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);
      expect(find.text('One Batam Mall'), findsOneWidget);
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);
    });

    testWidgets('Booking quick action shows TODO placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Booking" quick action
      final bookingAction = find.text('Booking');
      expect(bookingAction, findsOneWidget);

      // Tap should not cause error (TODO placeholder)
      await tester.tap(bookingAction);
      await tester.pumpAndSettle();

      // Should still be on home page
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);
    });

    testWidgets('Tukar Poin quick action shows TODO placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Tukar Poin" quick action
      final tukarPoinAction = find.text('Tukar Poin');
      expect(tukarPoinAction, findsOneWidget);

      // Tap should not cause error (TODO placeholder)
      await tester.tap(tukarPoinAction);
      await tester.pumpAndSettle();

      // Should still be on home page
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);
    });
  });
}
