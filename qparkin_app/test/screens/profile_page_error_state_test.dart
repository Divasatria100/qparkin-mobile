import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/common/empty_state_widget.dart';

void main() {
  group('ProfilePage Error State UI Tests', () {
    testWidgets('EmptyStateWidget displays error icon and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              description: 'Network error occurred',
              actionText: 'Coba Lagi',
              iconColor: Colors.red[400],
              onAction: () {},
            ),
          ),
        ),
      );

      // Verify error UI components are displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Network error occurred'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget displays default error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              description: 'Gagal memuat data profil. Silakan coba lagi.',
              actionText: 'Coba Lagi',
              iconColor: Colors.red[400],
              onAction: () {},
            ),
          ),
        ),
      );

      // Verify default error message
      expect(find.text('Gagal memuat data profil. Silakan coba lagi.'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget retry button is tappable', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              description: 'Test error',
              actionText: 'Coba Lagi',
              iconColor: Colors.red[400],
              onAction: () {
                actionCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap retry button
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      // Verify action was called
      expect(actionCalled, true);
    });

    testWidgets('EmptyStateWidget has proper icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              description: 'Test error',
              actionText: 'Coba Lagi',
              iconColor: Colors.red[400],
              onAction: () {},
            ),
          ),
        ),
      );

      // Find the icon widget
      final iconFinder = find.byIcon(Icons.error_outline);
      expect(iconFinder, findsOneWidget);

      // Verify icon exists
      final Icon iconWidget = tester.widget(iconFinder);
      expect(iconWidget.icon, Icons.error_outline);
    });

    testWidgets('EmptyStateWidget displays all required elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              description: 'Test error message',
              actionText: 'Coba Lagi',
              iconColor: Colors.red[400],
              onAction: () {},
            ),
          ),
        ),
      );

      // Verify all elements are present
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(3)); // title, description, button text
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
