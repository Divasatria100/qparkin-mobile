import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/common/cached_profile_image.dart';

void main() {
  group('CachedProfileImage Widget Tests', () {
    testWidgets('displays fallback icon when no image URL is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
            ),
          ),
        ),
      );

      // Should display fallback icon
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('displays fallback icon when empty image URL is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: '',
              size: 56,
            ),
          ),
        ),
      );

      // Should display fallback icon
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('applies correct size to the widget',
        (WidgetTester tester) async {
      const testSize = 100.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: testSize,
            ),
          ),
        ),
      );

      // Find the container with the specified size
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CachedProfileImage),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, testSize);
      expect(container.constraints?.maxHeight, testSize);
    });

    testWidgets('applies custom fallback icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
              fallbackIcon: Icons.account_circle,
            ),
          ),
        ),
      );

      // Should display custom fallback icon
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('applies semantic label when provided',
        (WidgetTester tester) async {
      const testLabel = 'Test profile image';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
              semanticLabel: testLabel,
            ),
          ),
        ),
      );

      // Find the Semantics widget with the specific label
      final semanticsFinder = find.descendant(
        of: find.byType(CachedProfileImage),
        matching: find.byType(Semantics),
      );

      expect(semanticsFinder, findsWidgets);
      
      // Check that at least one Semantics widget has the correct label
      bool foundCorrectLabel = false;
      for (final element in semanticsFinder.evaluate()) {
        final semantics = element.widget as Semantics;
        if (semantics.properties.label == testLabel && 
            semantics.properties.image == true) {
          foundCorrectLabel = true;
          break;
        }
      }
      
      expect(foundCorrectLabel, true);
    });

    testWidgets('applies circular shape by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
            ),
          ),
        ),
      );

      // Find the container with circular decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CachedProfileImage),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('applies custom background color',
        (WidgetTester tester) async {
      const testColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
              backgroundColor: testColor,
            ),
          ),
        ),
      );

      // Find the container with the specified background color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CachedProfileImage),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, testColor);
    });

    testWidgets('applies box shadow for elevation effect',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
            ),
          ),
        ),
      );

      // Find the container with shadow
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CachedProfileImage),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });

    testWidgets('applies custom fallback icon size',
        (WidgetTester tester) async {
      const testIconSize = 40.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 100,
              fallbackIconSize: testIconSize,
            ),
          ),
        ),
      );

      // Find the icon
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.person),
      );

      expect(icon.size, testIconSize);
    });

    testWidgets('applies custom fallback icon color',
        (WidgetTester tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedProfileImage(
              imageUrl: null,
              size: 56,
              fallbackIconColor: testColor,
            ),
          ),
        ),
      );

      // Find the icon
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.person),
      );

      expect(icon.color, testColor);
    });
  });
}
