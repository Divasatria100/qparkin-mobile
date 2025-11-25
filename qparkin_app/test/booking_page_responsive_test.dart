import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/booking_page.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';
import 'package:qparkin_app/utils/responsive_helper.dart';

void main() {
  group('BookingPage Responsive Design Tests', () {
    // Test data
    final testMall = {
      'id_mall': 'mall_001',
      'name': 'Test Mall',
      'nama_mall': 'Test Mall',
      'address': 'Jl. Test No. 123',
      'alamat': 'Jl. Test No. 123',
      'distance': '2.5 km',
      'available_slots': 15,
    };

    /// Helper to create BookingPage with specific screen size
    Widget createBookingPageWithSize(Size size, {Orientation? orientation}) {
      return MediaQuery(
        data: MediaQueryData(
          size: size,
          devicePixelRatio: 1.0,
        ),
        child: MaterialApp(
          home: BookingPage(mall: testMall),
        ),
      );
    }

    testWidgets('BookingPage renders correctly on small screen (320px)',
        (WidgetTester tester) async {
      // Arrange: Small screen size (iPhone SE)
      const screenSize = Size(320, 568);

      // Act: Build widget with small screen size
      await tester.pumpWidget(createBookingPageWithSize(screenSize));
      await tester.pumpAndSettle();

      // Assert: Page renders without overflow
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      
      // Verify AppBar is present
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify main content widgets are present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage uses correct padding on small screen (320px)',
        (WidgetTester tester) async {
      // Arrange: Small screen size
      const screenSize = Size(320, 568);

      // Act: Build widget
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: screenSize),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Assert: Verify responsive padding
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 12.0, reason: 'Small screen should use 12px padding');
                
                return BookingPage(mall: testMall);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page renders successfully
      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('BookingPage renders correctly on medium screen (375px)',
        (WidgetTester tester) async {
      // Arrange: Medium screen size (iPhone 12)
      const screenSize = Size(375, 667);

      // Act: Build widget with medium screen size
      await tester.pumpWidget(createBookingPageWithSize(screenSize));
      await tester.pumpAndSettle();

      // Assert: Page renders without overflow
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      
      // Verify main components are visible
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage uses correct padding on medium screen (375px)',
        (WidgetTester tester) async {
      // Arrange: Medium screen size
      const screenSize = Size(375, 667);

      // Act: Build widget
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: screenSize),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Assert: Verify responsive padding
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 16.0, reason: 'Medium screen should use 16px padding');
                
                return BookingPage(mall: testMall);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page renders successfully
      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('BookingPage renders correctly on large screen (414px+)',
        (WidgetTester tester) async {
      // Arrange: Large screen size (iPhone 12 Pro Max)
      const screenSize = Size(414, 896);

      // Act: Build widget with large screen size
      await tester.pumpWidget(createBookingPageWithSize(screenSize));
      await tester.pumpAndSettle();

      // Assert: Page renders without overflow
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      
      // Verify main components are visible
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage uses correct padding on large screen (414px+)',
        (WidgetTester tester) async {
      // Arrange: Large screen size
      const screenSize = Size(414, 896);

      // Act: Build widget
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: screenSize),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Assert: Verify responsive padding
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, 20.0, reason: 'Large screen should use 20px padding');
                
                return BookingPage(mall: testMall);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page renders successfully
      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('BookingPage handles orientation change from portrait to landscape',
        (WidgetTester tester) async {
      // Arrange: Start in portrait mode
      const portraitSize = Size(375, 667);

      // Act: Build widget in portrait
      await tester.pumpWidget(createBookingPageWithSize(portraitSize));
      await tester.pumpAndSettle();

      // Assert: Page renders in portrait
      expect(find.byType(BookingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Act: Change to landscape orientation
      const landscapeSize = Size(667, 375);
      await tester.pumpWidget(createBookingPageWithSize(landscapeSize));
      await tester.pumpAndSettle();

      // Assert: Page renders in landscape without errors
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage handles orientation change from landscape to portrait',
        (WidgetTester tester) async {
      // Arrange: Start in landscape mode
      const landscapeSize = Size(667, 375);

      // Act: Build widget in landscape
      await tester.pumpWidget(createBookingPageWithSize(landscapeSize));
      await tester.pumpAndSettle();

      // Assert: Page renders in landscape
      expect(find.byType(BookingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Act: Change to portrait orientation
      const portraitSize = Size(375, 667);
      await tester.pumpWidget(createBookingPageWithSize(portraitSize));
      await tester.pumpAndSettle();

      // Assert: Page renders in portrait without errors
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage preserves state during orientation change',
        (WidgetTester tester) async {
      // Arrange: Create a stateful widget wrapper to test state preservation
      final bookingProvider = BookingProvider();
      bookingProvider.initialize(testMall);

      Widget createPageWithProvider(Size size) {
        return MediaQuery(
          data: MediaQueryData(size: size),
          child: MaterialApp(
            home: ChangeNotifierProvider<BookingProvider>.value(
              value: bookingProvider,
              child: BookingPage(mall: testMall),
            ),
          ),
        );
      }

      // Act: Build in portrait
      const portraitSize = Size(375, 667);
      await tester.pumpWidget(createPageWithProvider(portraitSize));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(bookingProvider.selectedMall, isNotNull);
      final initialMallId = bookingProvider.selectedMall?['id_mall'];

      // Act: Rotate to landscape
      const landscapeSize = Size(667, 375);
      await tester.pumpWidget(createPageWithProvider(landscapeSize));
      await tester.pumpAndSettle();

      // Assert: State is preserved
      expect(bookingProvider.selectedMall, isNotNull);
      expect(bookingProvider.selectedMall?['id_mall'], equals(initialMallId));
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage adjusts spacing in landscape mode',
        (WidgetTester tester) async {
      // Arrange: Landscape screen size
      const landscapeSize = Size(667, 375);

      // Act: Build widget in landscape
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Assert: Verify landscape detection
                final isLandscape = ResponsiveHelper.isLandscape(context);
                expect(isLandscape, true, reason: 'Should detect landscape orientation');
                
                // Verify spacing adjustment
                const portraitSpacing = 16.0;
                final spacing = ResponsiveHelper.getOrientationAwareSpacing(
                  context,
                  portraitSpacing,
                );
                expect(spacing, portraitSpacing * 0.75, 
                    reason: 'Landscape spacing should be 75% of portrait');
                
                return BookingPage(mall: testMall);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page renders successfully
      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('BookingPage font sizes scale correctly on small screen',
        (WidgetTester tester) async {
      // Arrange: Small screen size
      const screenSize = Size(320, 568);

      // Act: Build widget
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: screenSize),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Assert: Verify font size scaling
                const baseSize = 16.0;
                final fontSize = ResponsiveHelper.getResponsiveFontSize(context, baseSize);
                expect(fontSize, baseSize * 0.9, 
                    reason: 'Small screen should scale fonts to 90%');
                
                return BookingPage(mall: testMall);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page renders successfully
      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('BookingPage font sizes scale correctly on large screen',
        (WidgetTester tester) async {
      // Arrange: Large screen size
      const screenSize = Size(414, 896);

      // Act: Build widget
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: screenSize),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Assert: Verify font size scaling
                const baseSize = 16.0;
                final fontSize = ResponsiveHelper.getResponsiveFontSize(context, baseSize);
                expect(fontSize, baseSize * 1.1, 
                    reason: 'Large screen should scale fonts to 110%');
                
                return BookingPage(mall: testMall);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page renders successfully
      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('BookingPage scrollable content works on all screen sizes',
        (WidgetTester tester) async {
      final screenSizes = [
        const Size(320, 568), // Small
        const Size(375, 667), // Medium
        const Size(414, 896), // Large
      ];

      for (final size in screenSizes) {
        // Act: Build widget with specific size
        await tester.pumpWidget(createBookingPageWithSize(size));
        await tester.pumpAndSettle();

        // Assert: ScrollView is present and scrollable
        final scrollView = find.byType(SingleChildScrollView);
        expect(scrollView, findsOneWidget, 
            reason: 'ScrollView should exist for size $size');

        // Verify we can scroll (if content is long enough)
        await tester.drag(scrollView, const Offset(0, -100));
        await tester.pumpAndSettle();

        // No overflow errors
        expect(tester.takeException(), isNull, 
            reason: 'No overflow errors for size $size');
      }
    });

    testWidgets('BookingPage maintains minimum touch target sizes on all screens',
        (WidgetTester tester) async {
      // Arrange: Test on small screen (most restrictive)
      const screenSize = Size(320, 568);

      // Act: Build widget
      await tester.pumpWidget(createBookingPageWithSize(screenSize));
      await tester.pumpAndSettle();

      // Assert: Back button has minimum 48dp touch target
      final backButton = find.byType(IconButton).first;
      expect(backButton, findsOneWidget);

      final backButtonWidget = tester.widget<IconButton>(backButton);
      expect(backButtonWidget.constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(backButtonWidget.constraints?.minHeight, greaterThanOrEqualTo(48));
    });

    testWidgets('BookingPage handles rapid orientation changes',
        (WidgetTester tester) async {
      // Arrange: Start in portrait
      const portraitSize = Size(375, 667);
      await tester.pumpWidget(createBookingPageWithSize(portraitSize));
      await tester.pumpAndSettle();

      // Act: Rapidly change orientations
      const landscapeSize = Size(667, 375);
      await tester.pumpWidget(createBookingPageWithSize(landscapeSize));
      await tester.pump();

      await tester.pumpWidget(createBookingPageWithSize(portraitSize));
      await tester.pump();

      await tester.pumpWidget(createBookingPageWithSize(landscapeSize));
      await tester.pumpAndSettle();

      // Assert: No errors or crashes
      expect(find.byType(BookingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage layout adapts correctly in landscape mode',
        (WidgetTester tester) async {
      // Arrange: Landscape orientation
      const landscapeSize = Size(896, 414); // iPhone 12 Pro Max landscape

      // Act: Build widget in landscape
      await tester.pumpWidget(createBookingPageWithSize(landscapeSize));
      await tester.pumpAndSettle();

      // Assert: Page renders without overflow
      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      
      // Verify scrollable content is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // No overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('BookingPage handles extreme aspect ratios',
        (WidgetTester tester) async {
      // Arrange: Very wide screen (extreme landscape)
      const extremeLandscape = Size(1024, 320);

      // Act: Build widget
      await tester.pumpWidget(createBookingPageWithSize(extremeLandscape));
      await tester.pumpAndSettle();

      // Assert: No overflow errors
      expect(find.byType(BookingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Arrange: Very tall screen (extreme portrait)
      const extremePortrait = Size(320, 1024);

      // Act: Build widget
      await tester.pumpWidget(createBookingPageWithSize(extremePortrait));
      await tester.pumpAndSettle();

      // Assert: No overflow errors
      expect(find.byType(BookingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
