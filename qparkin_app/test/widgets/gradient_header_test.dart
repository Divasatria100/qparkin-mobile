import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/common/gradient_header.dart';

void main() {
  group('GradientHeader Widget Tests', () {
    testWidgets('should render child widget correctly',
        (WidgetTester tester) async {
      const testText = 'Header Content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should use default QPARKIN gradient colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Find the Container with gradient
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // Check default colors
      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], const Color(0xFF7C5ED1)); // Lighter purple
      expect(gradient.colors[1], const Color(0xFF573ED1)); // Primary purple
    });

    testWidgets('should use custom gradient colors when provided',
        (WidgetTester tester) async {
      final customColors = [
        const Color(0xFF42CBF8),
        const Color(0xFF573ED1),
        const Color(0xFF39108A),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              gradientColors: customColors,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Find the Container with gradient
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // Check custom colors
      expect(gradient.colors.length, 3);
      expect(gradient.colors[0], const Color(0xFF42CBF8));
      expect(gradient.colors[1], const Color(0xFF573ED1));
      expect(gradient.colors[2], const Color(0xFF39108A));
    });

    testWidgets('should have gradient from top to bottom',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Find the Container with gradient
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // Check gradient direction
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
    });

    testWidgets('should apply default padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Find all Padding widgets inside SafeArea
      final paddings = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(SafeArea),
          matching: find.byType(Padding),
        ),
      ).toList();

      // Find the padding with our custom value
      final padding = paddings.firstWhere(
        (p) => p.padding == const EdgeInsets.fromLTRB(20, 40, 20, 100),
      );

      // Check default padding
      expect(
        padding.padding,
        const EdgeInsets.fromLTRB(20, 40, 20, 100),
      );
    });

    testWidgets('should apply custom padding when provided',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(24);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              padding: customPadding,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Find all Padding widgets inside SafeArea
      final paddings = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(SafeArea),
          matching: find.byType(Padding),
        ),
      ).toList();

      // Find the padding with our custom value
      final padding = paddings.firstWhere(
        (p) => p.padding == customPadding,
      );

      // Check custom padding
      expect(padding.padding, customPadding);
    });

    testWidgets('should wrap content in SafeArea',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Check that SafeArea exists
      expect(find.byType(SafeArea), findsOneWidget);

      // Check that SafeArea has bottom: false
      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.bottom, false);
    });

    testWidgets('should render complex child widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              child: Column(
                children: const [
                  Text('Title'),
                  SizedBox(height: 16),
                  Text('Subtitle'),
                  Icon(Icons.star),
                ],
              ),
            ),
          ),
        ),
      );

      // Check all child widgets are rendered
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should maintain consistent styling across instances',
        (WidgetTester tester) async {
      // Create two instances with default settings
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                GradientHeader(
                  child: Text('Header 1'),
                ),
                GradientHeader(
                  child: Text('Header 2'),
                ),
              ],
            ),
          ),
        ),
      );

      // Find all gradient containers
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      ).toList();

      // Get the first two containers (the gradient headers)
      final header1Container = containers[0];
      final header2Container = containers[1];

      final decoration1 = header1Container.decoration as BoxDecoration;
      final decoration2 = header2Container.decoration as BoxDecoration;

      final gradient1 = decoration1.gradient as LinearGradient;
      final gradient2 = decoration2.gradient as LinearGradient;

      // Both should have identical gradients
      expect(gradient1.colors, gradient2.colors);
      expect(gradient1.begin, gradient2.begin);
      expect(gradient1.end, gradient2.end);
    });

    testWidgets('should accept height parameter (for future use)',
        (WidgetTester tester) async {
      // Note: height parameter is defined but not currently used in the widget
      // This test verifies the parameter exists and can be passed
      const customHeight = 200.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              height: customHeight,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
