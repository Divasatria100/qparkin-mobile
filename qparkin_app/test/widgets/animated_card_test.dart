import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/common/animated_card.dart';

void main() {
  group('AnimatedCard Widget Tests', () {
    testWidgets('should render child widget correctly',
        (WidgetTester tester) async {
      const testText = 'Test Card Content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should call onTap callback when tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {
                wasTapped = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('should apply custom border radius',
        (WidgetTester tester) async {
      const customRadius = 24.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              borderRadius: customRadius,
              child: const Text('Custom Radius'),
            ),
          ),
        ),
      );

      // Find the InkWell widget
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(customRadius));
    });

    testWidgets('should apply custom padding when provided',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              padding: customPadding,
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

      // Find the InkWell's child - if padding is provided, it should be a Padding widget
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.child, isA<Padding>());
      
      final padding = inkWell.child as Padding;
      expect(padding.padding, customPadding);
    });

    testWidgets('should not have custom padding when not provided',
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

      // Find the InkWell's child - if no padding is provided, it should be the Container directly
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.child, isA<Container>());
    });

    testWidgets('should animate scale to 0.97 on tap down',
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

      // Get initial transform
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('test_container'))),
      );
      await tester.pump();

      // Find the AnimatedContainer with transform
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // The first AnimatedContainer should have the scale transform
      final transformContainer = animatedContainers.first;
      final transform = transformContainer.transform as Matrix4;

      // Check if scale is approximately 0.97
      expect(transform.getMaxScaleOnAxis(), closeTo(0.97, 0.01));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should have 150ms animation duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: const Text('Animation Test'),
            ),
          ),
        ),
      );

      // Find all AnimatedContainers
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // Both AnimatedContainers should have 150ms duration
      for (final container in animatedContainers) {
        expect(container.duration, const Duration(milliseconds: 150));
      }
    });

    testWidgets('should use easeInOut curve for animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: const Text('Curve Test'),
            ),
          ),
        ),
      );

      // Find the first AnimatedContainer (the one with transform)
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      expect(animatedContainer.curve, Curves.easeInOut);
    });

    testWidgets('should show ripple effect with brand color on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {},
              child: const Text('Ripple Test'),
            ),
          ),
        ),
      );

      // Find the InkWell
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      // Check splash and highlight colors
      expect(
        inkWell.splashColor,
        const Color(0xFF573ED1).withOpacity(0.15),
      );
      expect(
        inkWell.highlightColor,
        const Color(0xFF573ED1).withOpacity(0.08),
      );
    });

    testWidgets('should reset scale to 1.0 after tap',
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

      // Tap and release
      await tester.tap(find.byKey(const Key('test_container')));
      await tester.pumpAndSettle();

      // Find the AnimatedContainer with transform
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      final transformContainer = animatedContainers.first;
      final transform = transformContainer.transform as Matrix4;

      // Scale should be back to 1.0
      expect(transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
    });

    testWidgets('should reset scale on tap cancel',
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

      // Start gesture but don't complete
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('test_container'))),
      );
      await tester.pump();

      // Cancel the gesture
      await gesture.cancel();
      await tester.pumpAndSettle();

      // Find the AnimatedContainer with transform
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      final transformContainer = animatedContainers.first;
      final transform = transformContainer.transform as Matrix4;

      // Scale should be back to 1.0
      expect(transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
    });

    testWidgets('should change shadow elevation when pressed',
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

      // Get initial shadow
      var animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();
      var decorationContainer = animatedContainers[1]; // Second container has decoration
      var initialDecoration = decorationContainer.decoration as BoxDecoration;
      var initialShadow = initialDecoration.boxShadow!.first;

      // Initial shadow should have lower blur radius
      expect(initialShadow.blurRadius, 8);
      expect(initialShadow.offset, const Offset(0, 2));

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('test_container'))),
      );
      await tester.pump();

      // Get pressed shadow
      animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();
      decorationContainer = animatedContainers[1];
      var pressedDecoration = decorationContainer.decoration as BoxDecoration;
      var pressedShadow = pressedDecoration.boxShadow!.first;

      // Pressed shadow should have higher blur radius
      expect(pressedShadow.blurRadius, 12);
      expect(pressedShadow.offset, const Offset(0, 4));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
