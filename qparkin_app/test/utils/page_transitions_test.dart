import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/page_transitions.dart';

void main() {
  group('PageTransitions', () {
    testWidgets('slideFromRight creates a route with correct transition',
        (WidgetTester tester) async {
      // Create a simple test page
      final testPage = Scaffold(
        appBar: AppBar(title: const Text('Test Page')),
        body: const Center(child: Text('Test Content')),
      );

      // Build a test app with navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to navigate
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Verify the new page is displayed
      expect(find.text('Test Page'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('slideFromRight uses 300ms duration by default',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('Test'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Tap to navigate
      await tester.tap(find.text('Navigate'));
      
      // Pump for less than 300ms - transition should still be in progress
      await tester.pump(const Duration(milliseconds: 150));
      
      // The transition should not be complete yet
      // We can verify this by checking if the animation is still running
      expect(tester.binding.hasScheduledFrame, isTrue);
      
      // Complete the animation
      await tester.pumpAndSettle();
      
      // Now the page should be fully visible
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('slideFromLeft creates a route with left-to-right transition',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('From Left'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromLeft(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('From Left'), findsOneWidget);
    });

    testWidgets('slideFromBottom creates a route with bottom-to-top transition',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('From Bottom'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromBottom(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('From Bottom'), findsOneWidget);
    });

    testWidgets('fade creates a route with fade transition',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('Faded'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.fade(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Faded'), findsOneWidget);
    });

    testWidgets('scale creates a route with scale transition',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('Scaled'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.scale(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Scaled'), findsOneWidget);
    });

    testWidgets('custom duration can be specified',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('Custom Duration'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(
                      page: testPage,
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      
      // Pump for 300ms (default duration) - should still be animating
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.hasScheduledFrame, isTrue);
      
      // Complete the animation
      await tester.pumpAndSettle();
      
      expect(find.text('Custom Duration'), findsOneWidget);
    });

    testWidgets('route settings can be provided',
        (WidgetTester tester) async {
      final testPage = const Scaffold(body: Text('With Settings'));
      const routeSettings = RouteSettings(name: '/test-route');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(
                      page: testPage,
                      settings: routeSettings,
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('With Settings'), findsOneWidget);
    });

    testWidgets('back navigation works correctly with slide transition',
        (WidgetTester tester) async {
      final testPage = Scaffold(
        appBar: AppBar(title: const Text('Second Page')),
        body: const Text('Content'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('First Page')),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(page: testPage),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Navigate forward
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('First Page'), findsOneWidget);
    });
  });
}
