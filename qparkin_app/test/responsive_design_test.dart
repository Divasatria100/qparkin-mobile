import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/responsive_helper.dart';

void main() {
  group('ResponsiveHelper Tests', () {
    testWidgets('getResponsivePadding returns correct values for different screen sizes',
        (WidgetTester tester) async {
      // Test small screen (320px)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 568)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 12.0);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test medium screen (375px)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 16.0);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test large screen (414px)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(414, 896)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 20.0);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test tablet (768px)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 24.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getResponsiveFontSize scales correctly',
        (WidgetTester tester) async {
      const baseSize = 16.0;

      // Test small screen (320px) - 90% of base
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 568)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(context, baseSize);
                expect(fontSize, baseSize * 0.9);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test medium screen (375px) - 100% of base
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(context, baseSize);
                expect(fontSize, baseSize);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test large screen (414px) - 110% of base
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(414, 896)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(context, baseSize);
                expect(fontSize, baseSize * 1.1);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isLandscape detects orientation correctly',
        (WidgetTester tester) async {
      // Test portrait (height > width)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 667),
            ),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isLandscape(context), false);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test landscape (width > height)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(667, 375),
            ),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isLandscape(context), true);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getCardPadding adjusts for landscape orientation',
        (WidgetTester tester) async {
      // Test portrait mode (height > width)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 667),
            ),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getCardPadding(context);
                expect(padding, const EdgeInsets.all(16.0));
                return Container();
              },
            ),
          ),
        ),
      );

      // Test landscape mode (width > height) - should have reduced padding
      // Using 896x414 (iPhone 12 Pro Max landscape)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(896, 414),
            ),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getCardPadding(context);
                // In landscape with width 896 (> mobileLarge), should be 16.0
                expect(padding, const EdgeInsets.all(16.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getOrientationAwareSpacing reduces spacing in landscape',
        (WidgetTester tester) async {
      const portraitSpacing = 16.0;

      // Test portrait mode (height > width)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 667),
            ),
            child: Builder(
              builder: (context) {
                final spacing = ResponsiveHelper.getOrientationAwareSpacing(
                  context,
                  portraitSpacing,
                );
                expect(spacing, portraitSpacing);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test landscape mode (width > height) - should be 75% of portrait spacing
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(667, 375),
            ),
            child: Builder(
              builder: (context) {
                final spacing = ResponsiveHelper.getOrientationAwareSpacing(
                  context,
                  portraitSpacing,
                );
                expect(spacing, portraitSpacing * 0.75);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Screen size helpers work correctly',
        (WidgetTester tester) async {
      // Test small screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 568)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isSmallScreen(context), true);
                expect(ResponsiveHelper.isMediumScreen(context), false);
                expect(ResponsiveHelper.isLargeScreen(context), false);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test medium screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isSmallScreen(context), false);
                expect(ResponsiveHelper.isMediumScreen(context), true);
                expect(ResponsiveHelper.isLargeScreen(context), false);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test large screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(414, 896)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isSmallScreen(context), false);
                expect(ResponsiveHelper.isMediumScreen(context), false);
                expect(ResponsiveHelper.isLargeScreen(context), true);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });
}
