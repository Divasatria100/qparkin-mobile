import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/filter_bottom_sheet.dart';
import 'package:qparkin_app/data/models/point_filter_model.dart';

void main() {
  group('FilterBottomSheet Widget Tests', () {
    testWidgets('should display filter bottom sheet with all elements',
        (WidgetTester tester) async {
      PointFilter? appliedFilter;
      final currentFilter = PointFilter.all();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {
                        appliedFilter = filter;
                      },
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      // Open the bottom sheet
      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Filter Riwayat'), findsOneWidget);

      // Verify type filter section
      expect(find.text('Jenis Transaksi'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Penambahan'), findsOneWidget);
      expect(find.text('Pengurangan'), findsOneWidget);

      // Verify period filter section
      expect(find.text('Periode Waktu'), findsOneWidget);
      expect(find.text('Semua Waktu'), findsOneWidget);
      expect(find.text('Bulan Ini'), findsOneWidget);
      expect(find.text('3 Bulan Terakhir'), findsOneWidget);
      expect(find.text('6 Bulan Terakhir'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Terapkan Filter'), findsOneWidget);
    });

    testWidgets('should show active filter count indicator',
        (WidgetTester tester) async {
      final currentFilter = PointFilter(
        type: PointFilterType.addition,
        period: PointFilterPeriod.thisMonth,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {},
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Should show count of 2 (type + period)
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should apply filter when Terapkan Filter is tapped',
        (WidgetTester tester) async {
      PointFilter? appliedFilter;
      final currentFilter = PointFilter.all();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {
                        appliedFilter = filter;
                      },
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Select addition type
      await tester.tap(find.text('Penambahan'));
      await tester.pumpAndSettle();

      // Select this month period
      await tester.tap(find.text('Bulan Ini').last);
      await tester.pumpAndSettle();

      // Scroll to make button visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Apply filter
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // Verify filter was applied
      expect(appliedFilter, isNotNull);
      expect(appliedFilter!.type, PointFilterType.addition);
      expect(appliedFilter!.period, PointFilterPeriod.thisMonth);
    });

    testWidgets('should reset filter when Reset button is tapped',
        (WidgetTester tester) async {
      final currentFilter = PointFilter(
        type: PointFilterType.addition,
        period: PointFilterPeriod.thisMonth,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {},
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Initially should show 2 active filters
      expect(find.text('2'), findsOneWidget);

      // Scroll to make button visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Tap reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Active filter count should be gone (0 filters)
      expect(find.text('2'), findsNothing);
    });

    testWidgets('should update UI when type filter is selected',
        (WidgetTester tester) async {
      final currentFilter = PointFilter.all();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {},
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Tap on Pengurangan
      await tester.tap(find.text('Pengurangan'));
      await tester.pumpAndSettle();

      // Should show 1 active filter
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should update UI when period filter is selected',
        (WidgetTester tester) async {
      final currentFilter = PointFilter.all();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {},
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Scroll to make period options visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Tap on 3 Bulan Terakhir
      await tester.tap(find.text('3 Bulan Terakhir'));
      await tester.pumpAndSettle();

      // Should show 1 active filter
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should close bottom sheet after applying filter',
        (WidgetTester tester) async {
      PointFilter? appliedFilter;
      final currentFilter = PointFilter.all();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterBottomSheet(
                      currentFilter: currentFilter,
                      onApply: (filter) {
                        appliedFilter = filter;
                      },
                    ),
                  );
                },
                child: const Text('Open Filter'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Filter'));
      await tester.pumpAndSettle();

      // Bottom sheet should be visible
      expect(find.text('Filter Riwayat'), findsOneWidget);

      // Scroll to make button visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Apply filter
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // Bottom sheet should be closed
      expect(find.text('Filter Riwayat'), findsNothing);
    });
  });
}
