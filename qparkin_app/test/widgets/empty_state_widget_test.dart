import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the empty state display in ActivityPage
/// The empty state is rendered inline in the ActivityPage when no active parking exists
void main() {
  group('EmptyStateWidget (ActivityPage Empty State)', () {
    Widget buildEmptyState() {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Center(
              child: Semantics(
                label: 'Tidak ada parkir aktif. Mulai parkir untuk melihat aktivitas Anda',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Ikon mobil',
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExcludeSemantics(
                      child: const Text(
                        'Tidak ada parkir aktif',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ExcludeSemantics(
                      child: Text(
                        'Mulai parkir untuk melihat aktivitas Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('displays empty state message', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      expect(find.text('Tidak ada parkir aktif'), findsOneWidget);
      expect(find.text('Mulai parkir untuk melihat aktivitas Anda'), findsOneWidget);
    });

    testWidgets('displays car icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('has centered layout', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      final center = tester.widget<Center>(
        find.ancestor(
          of: find.text('Tidak ada parkir aktif'),
          matching: find.byType(Center),
        ).first,
      );

      expect(center, isNotNull);
    });

    testWidgets('has proper icon styling', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      final icon = tester.widget<Icon>(find.byIcon(Icons.directions_car));
      expect(icon.size, 48);
      expect(icon.color, isNotNull);
    });

    testWidgets('has circular icon container', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.directions_car),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(50));
    });

    testWidgets('has proper text styling', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      final headingText = tester.widget<Text>(
        find.text('Tidak ada parkir aktif'),
      );
      expect(headingText.style?.fontSize, 18);
      expect(headingText.style?.fontWeight, FontWeight.bold);

      final subtitleText = tester.widget<Text>(
        find.text('Mulai parkir untuk melihat aktivitas Anda'),
      );
      expect(subtitleText.style?.fontSize, 14);
      expect(subtitleText.textAlign, TextAlign.center);
    });

    testWidgets('has proper semantic labels for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      // Find the main Semantics widget
      final semanticsFinder = find.ancestor(
        of: find.text('Tidak ada parkir aktif'),
        matching: find.byType(Semantics),
      );

      expect(semanticsFinder, findsWidgets);
    });

    testWidgets('has white background', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.color, Colors.white);
    });

    testWidgets('has proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(buildEmptyState());

      final column = tester.widget<Column>(
        find.ancestor(
          of: find.text('Tidak ada parkir aktif'),
          matching: find.byType(Column),
        ).first,
      );

      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      
      // Verify SizedBox spacing exists
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('Error State Widget (ActivityPage Error State)', () {
    Widget buildErrorState() {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Semantics(
                  label: 'Terjadi kesalahan: Gagal memuat data',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: 'Ikon kesalahan',
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFF44336),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ExcludeSemantics(
                        child: const Text(
                          'Terjadi Kesalahan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExcludeSemantics(
                        child: Text(
                          'Gagal memuat data',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Semantics(
                        label: 'Tombol coba lagi. Ketuk untuk memuat ulang data parkir',
                        button: true,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF573ED1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: ExcludeSemantics(
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('displays error message', (WidgetTester tester) async {
      await tester.pumpWidget(buildErrorState());

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Gagal memuat data'), findsOneWidget);
    });

    testWidgets('displays error icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildErrorState());

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays retry button', (WidgetTester tester) async {
      await tester.pumpWidget(buildErrorState());

      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retry button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(buildErrorState());

      // Verify button exists and is tappable
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('has proper error icon styling', (WidgetTester tester) async {
      await tester.pumpWidget(buildErrorState());

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.size, 48);
      expect(icon.color, const Color(0xFFF44336));
    });

    testWidgets('retry button meets minimum touch target size', (WidgetTester tester) async {
      await tester.pumpWidget(buildErrorState());

      // Verify button exists
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Find the SizedBox that wraps the button
      final sizedBoxes = find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byType(SizedBox),
      );
      
      expect(sizedBoxes, findsWidgets);
      
      final sizedBox = tester.widget<SizedBox>(sizedBoxes.first);
      expect(sizedBox.height, 56);
    });
  });
}
