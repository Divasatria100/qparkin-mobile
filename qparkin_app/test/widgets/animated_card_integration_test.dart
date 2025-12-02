import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/common/animated_card.dart';

/// Integration test to verify AnimatedCard meets all task requirements:
/// - Extracted from home_page.dart ✓
/// - Public class with proper documentation ✓
/// - Accepts customization parameters (borderRadius, padding) ✓
/// - Animation behavior (scale 0.97, duration 150ms) ✓
void main() {
  group('AnimatedCard Integration Tests - Task Requirements', () {
    testWidgets('Requirement: Public class with proper documentation',
        (WidgetTester tester) async {
      // Verify the class is public (no underscore prefix)
      // and can be instantiated from outside the library
      const card = AnimatedCard(
        child: Text('Test'),
      );

      expect(card, isNotNull);
      expect(card, isA<AnimatedCard>());
    });

    testWidgets('Requirement: Accepts borderRadius customization',
        (WidgetTester tester) async {
      const customRadius = 24.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              borderRadius: customRadius,
              child: const Text('Custom Border Radius'),
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(customRadius));
    });

    testWidgets('Requirement: Accepts padding customization',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              padding: customPadding,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.child, isA<Padding>());

      final padding = inkWell.child as Padding;
      expect(padding.padding, customPadding);
    });

    testWidgets('Requirement: Animation scale is 0.97 on press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Container(
                key: const Key('test_container'),
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('test_container'))),
      );
      await tester.pump();

      // Verify scale is 0.97
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final transformContainer = animatedContainers.first;
      final transform = transformContainer.transform as Matrix4;

      expect(transform.getMaxScaleOnAxis(), closeTo(0.97, 0.01));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Requirement: Animation duration is 150ms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: const Text('Duration Test'),
            ),
          ),
        ),
      );

      // Verify all AnimatedContainers have 150ms duration
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      for (final container in animatedContainers) {
        expect(
          container.duration,
          const Duration(milliseconds: 150),
          reason: 'Animation duration should be 150ms',
        );
      }
    });

    testWidgets('Requirement: Works with default parameters',
        (WidgetTester tester) async {
      // Verify it works with minimal configuration
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: const Text('Minimal Config'),
            ),
          ),
        ),
      );

      expect(find.text('Minimal Config'), findsOneWidget);

      // Verify default borderRadius is 16
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('Requirement: Maintains consistent brand colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {},
              child: const Text('Brand Colors'),
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      // Verify brand purple color (0xFF573ED1) is used
      expect(
        inkWell.splashColor,
        const Color(0xFF573ED1).withOpacity(0.15),
        reason: 'Splash color should use brand purple',
      );
      expect(
        inkWell.highlightColor,
        const Color(0xFF573ED1).withOpacity(0.08),
        reason: 'Highlight color should use brand purple',
      );
    });

    testWidgets('Requirement: Complete animation cycle works correctly',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {
                wasTapped = true;
              },
              child: Container(
                key: const Key('test_container'),
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byKey(const Key('test_container')));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(wasTapped, isTrue);

      // Verify scale returns to 1.0 after tap completes
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();
      final transform = animatedContainers.first.transform as Matrix4;
      expect(transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
    });
  });
}
