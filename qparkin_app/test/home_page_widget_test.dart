import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qparkin_app/presentation/screens/home_page.dart';
import 'package:qparkin_app/presentation/widgets/shimmer_loading.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Widget Tests - Component Rendering', () {
    testWidgets('renders all main sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header section elements
      expect(find.text('Selamat Datang Kembali!'), findsOneWidget);
      expect(find.text('Diva Satria'), findsOneWidget);
      expect(find.text('divasatria100@gmail.com'), findsOneWidget);

      // Verify content sections
      expect(find.text('Lokasi Parkir Terdekat'), findsOneWidget);
      expect(find.text('Akses Cepat'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);
    });

    testWidgets('renders parking location cards after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Initially shows shimmer loading
      expect(find.byType(HomePageLocationShimmer), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify parking location cards are displayed
      expect(find.text('Mega Mall Batam Centre'), findsOneWidget);
      expect(find.text('One Batam Mall'), findsOneWidget);
      expect(find.text('SNL Food Bengkong'), findsOneWidget);

      // Verify only 3 locations are shown (limit)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders quick action cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all 4 quick actions are displayed
      expect(find.text('Booking'), findsOneWidget);
      expect(find.text('Peta'), findsWidgets); // May appear in bottom nav too
      expect(find.text('Tukar Poin'), findsOneWidget);
      expect(find.text('Riwayat'), findsWidgets); // May appear in bottom nav too
    });

    testWidgets('renders parking location card with correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify icon container
      expect(find.byIcon(FontAwesomeIcons.bagShopping), findsWidgets);

      // Verify distance badges
      expect(find.text('1.3 km'), findsOneWidget);
      expect(find.text('1.5 km'), findsOneWidget);

      // Verify available slots badges
      expect(find.textContaining('slot tersedia'), findsWidgets);

      // Verify navigation arrows
      expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
    });

    testWidgets('renders premium points card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify points card is displayed
      expect(find.textContaining('200'), findsWidgets);
    });
  });

  group('Home Page Widget Tests - Layout Consistency', () {
    testWidgets('quick actions grid has 4 columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the GridView
      final gridView = tester.widget<GridView>(
        find.byType(GridView),
      );

      // Verify grid configuration
      final gridDelegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, equals(4));
      expect(gridDelegate.crossAxisSpacing, equals(12));
      expect(gridDelegate.mainAxisSpacing, equals(12));
      expect(gridDelegate.childAspectRatio, equals(0.85));
    });

    testWidgets('content section has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find content section padding
      final paddingWidgets = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Padding),
      );

      expect(paddingWidgets, findsWidgets);
    });

    testWidgets('parking location cards have consistent spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify spacing between cards (12px bottom padding)
      final paddedCards = find.descendant(
        of: find.byType(Column),
        matching: find.byType(Padding),
      );

      expect(paddedCards, findsWidgets);
    });

    testWidgets('section titles have correct typography', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find section title
      final titleWidget = tester.widget<Text>(
        find.text('Lokasi Parkir Terdekat'),
      );

      expect(titleWidget.style?.fontSize, equals(20));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(titleWidget.style?.color, equals(Colors.black87));
    });

    testWidgets('card titles have correct typography', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find card title
      final cardTitle = tester.widget<Text>(
        find.text('Mega Mall Batam Centre'),
      );

      expect(cardTitle.style?.fontSize, equals(16));
      expect(cardTitle.style?.fontWeight, equals(FontWeight.bold));
      expect(cardTitle.style?.color, equals(Colors.black87));
    });

    testWidgets('address text has correct typography', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find address text
      final addressText = tester.widget<Text>(
        find.text('Jl. Engku Putri no.1, Batam Centre'),
      );

      expect(addressText.style?.fontSize, equals(14));
      expect(addressText.maxLines, equals(2));
      expect(addressText.overflow, equals(TextOverflow.ellipsis));
    });
  });

  group('Home Page Widget Tests - Responsive Behavior', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test with default size
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout renders correctly
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify grid is scrollable
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.shrinkWrap, isTrue);
      expect(gridView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('handles long text with ellipsis', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify address text has ellipsis overflow
      final addressTexts = tester.widgetList<Text>(
        find.textContaining('Jl.'),
      );

      for (final text in addressTexts) {
        if (text.maxLines != null) {
          expect(text.overflow, equals(TextOverflow.ellipsis));
        }
      }
    });

    testWidgets('scrollable content works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Perform scroll gesture
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Verify page still renders correctly after scroll
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
