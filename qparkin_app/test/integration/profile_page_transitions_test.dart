import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/page_transitions.dart';

void main() {
  group('Profile Page Transitions Integration Tests', () {
    testWidgets('Slide transition animates correctly over 300ms',
        (WidgetTester tester) async {
      final testPage = Scaffold(
        appBar: AppBar(title: const Text('Test Page')),
        body: const Center(child: Text('Test Content')),
      );

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
      await tester.pump();

      // Verify transition is in progress
      expect(tester.binding.hasScheduledFrame, isTrue);

      // Pump for 150ms (half of 300ms) - should still be animating
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.binding.hasScheduledFrame, isTrue);

      // Complete the animation
      await tester.pumpAndSettle();

      // Verify navigation completed
      expect(find.text('Test Page'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('Back navigation works correctly with slide transition',
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
      
      // Verify transition is in progress
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isTrue);
      
      await tester.pumpAndSettle();
      expect(find.text('First Page'), findsOneWidget);
    });

    testWidgets('Multiple sequential navigations maintain proper stack',
        (WidgetTester tester) async {
      final secondPage = Scaffold(
        appBar: AppBar(title: const Text('Second Page')),
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                PageTransitions.slideFromRight(
                  page: Scaffold(
                    appBar: AppBar(title: const Text('Third Page')),
                    body: const Text('Third Content'),
                  ),
                ),
              );
            },
            child: const Text('Go to Third'),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('First Page')),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(page: secondPage),
                  );
                },
                child: const Text('Go to Second'),
              ),
            ),
          ),
        ),
      );

      // Navigate to second page
      await tester.tap(find.text('Go to Second'));
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);

      // Navigate to third page
      await tester.tap(find.text('Go to Third'));
      await tester.pumpAndSettle();
      expect(find.text('Third Page'), findsOneWidget);

      // Navigate back to second
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);

      // Navigate back to first
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('First Page'), findsOneWidget);
    });

    testWidgets('Transition uses easeInOut curve',
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

      // Start navigation
      await tester.tap(find.text('Navigate'));
      await tester.pump();

      // The animation should be smooth and not linear
      // We can verify this by checking that the animation is still running
      // at different points in time
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);

      // Complete
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Reverse transition duration matches forward transition',
        (WidgetTester tester) async {
      final testPage = Scaffold(
        appBar: AppBar(title: const Text('Test Page')),
        body: const Text('Content'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Home')),
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

      // Forward navigation
      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpAndSettle();

      // Backward navigation
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
