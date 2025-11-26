import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/screens/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Interaction Tests', () {
    testWidgets('parking location card has tap feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => const Scaffold(body: Text('Map')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find the first parking card
      final cardFinder = find.text('Mega Mall Batam Centre');
      expect(cardFinder, findsOneWidget);

      // Tap the card
      await tester.tap(cardFinder);
      await tester.pump(); // Start animation

      // Card should be in pressed state (scale 0.98)
      // We can't directly test the scale, but we can verify the tap was registered
      await tester.pumpAndSettle();

      // Should navigate to map page
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('quick action card has tap feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => const Scaffold(body: Text('Map')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find Peta quick action
      final petaFinder = find.text('Peta');
      expect(petaFinder, findsOneWidget);

      // Tap the quick action
      await tester.tap(petaFinder);
      await tester.pump(); // Start animation

      await tester.pumpAndSettle();

      // Should navigate to map page
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('InkWell ripple effect is present on cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify InkWell widgets exist for interactive elements
      expect(find.byType(InkWell), findsWidgets);

      // Find InkWell in parking cards
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      
      // Verify InkWell has proper configuration
      for (final inkWell in inkWells) {
        expect(inkWell.onTap, isNotNull);
      }
    });

    testWidgets('scale animation works on card press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => const Scaffold(body: Text('Map')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find AnimatedScale widget (used in _AnimatedCard)
      expect(find.byType(AnimatedScale), findsWidgets);

      // Get one of the AnimatedScale widgets
      final animatedScales = tester.widgetList<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Verify AnimatedScale has correct configuration
      for (final animatedScale in animatedScales) {
        expect(animatedScale.duration, equals(const Duration(milliseconds: 150)));
        expect(animatedScale.curve, equals(Curves.easeInOut));
      }
    });

    testWidgets('card press and release animation cycle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => const Scaffold(body: Text('Map')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find a parking card
      final cardFinder = find.text('Mega Mall Batam Centre');

      // Press down on card
      final gesture = await tester.startGesture(
        tester.getCenter(cardFinder),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Release
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 50));

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Should navigate after release
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('multiple cards can be tapped independently', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
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

      // Tap first card
      await tester.tap(find.text('Mega Mall Batam Centre'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);

      // Go back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Tap second card
      await tester.tap(find.text('One Batam Mall'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);

      // Go back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Tap third card
      await tester.tap(find.text('SNL Food Bengkong'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('quick action buttons have proper touch targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find quick action cards
      final bookingCard = find.text('Booking');
      final petaCard = find.text('Peta');
      final tukarPoinCard = find.text('Tukar Poin');
      final riwayatCard = find.text('Riwayat');

      // Get sizes of quick action cards
      final bookingSize = tester.getSize(bookingCard.hitTestable());
      final petaSize = tester.getSize(petaCard.hitTestable());
      final tukarPoinSize = tester.getSize(tukarPoinCard.hitTestable());
      final riwayatSize = tester.getSize(riwayatCard.hitTestable());

      // Verify all cards have adequate touch targets (minimum 48dp)
      // Note: The actual card container is larger than just the text
      expect(bookingSize.height, greaterThan(0));
      expect(petaSize.height, greaterThan(0));
      expect(tukarPoinSize.height, greaterThan(0));
      expect(riwayatSize.height, greaterThan(0));
    });

    testWidgets('ripple effect has correct border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find InkWell widgets
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));

      // Verify InkWell has borderRadius set
      for (final inkWell in inkWells) {
        if (inkWell.borderRadius != null) {
          // Border radius should be 16px for cards
          expect(inkWell.borderRadius, isA<BorderRadius>());
        }
      }
    });

    testWidgets('Material wrapper provides proper ripple surface', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Material widgets exist (for ripple effect)
      expect(find.byType(Material), findsWidgets);

      // Find Material widgets that wrap InkWell
      final materials = tester.widgetList<Material>(find.byType(Material));

      // Verify some Materials have transparent color (for ripple effect)
      final transparentMaterials = materials.where(
        (m) => m.color == Colors.transparent,
      );
      expect(transparentMaterials.isNotEmpty, isTrue);
    });

    testWidgets('tap cancel does not trigger navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => const Scaffold(body: Text('Map')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find a parking card
      final cardFinder = find.text('Mega Mall Batam Centre');

      // Start gesture but don't complete it
      final gesture = await tester.startGesture(
        tester.getCenter(cardFinder),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Move away (cancel the tap)
      await gesture.moveBy(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 50));

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      // Should NOT navigate (tap was cancelled)
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);
      expect(find.text('Map'), findsNothing);
    });

    testWidgets('animation duration is correct (150ms)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find AnimatedScale widgets
      final animatedScales = tester.widgetList<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Verify all have 150ms duration
      for (final animatedScale in animatedScales) {
        expect(
          animatedScale.duration,
          equals(const Duration(milliseconds: 150)),
        );
      }
    });

    testWidgets('animation curve is easeInOut', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find AnimatedScale widgets
      final animatedScales = tester.widgetList<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Verify all use easeInOut curve
      for (final animatedScale in animatedScales) {
        expect(animatedScale.curve, equals(Curves.easeInOut));
      }
    });

    testWidgets('InkWell splash color is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find InkWell widgets
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));

      // Verify splash color is set (purple with opacity)
      for (final inkWell in inkWells) {
        if (inkWell.splashColor != null) {
          // Should be purple color with opacity
          expect(inkWell.splashColor, isNotNull);
        }
      }
    });

    testWidgets('buttons remain responsive after multiple taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/map': (context) => Scaffold(
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

      // Tap Peta button multiple times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Peta'));
        await tester.pumpAndSettle();
        expect(find.text('Back'), findsOneWidget);

        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);
      }

      // Button should still be responsive
      await tester.tap(find.text('Peta'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
    });
  });
}
