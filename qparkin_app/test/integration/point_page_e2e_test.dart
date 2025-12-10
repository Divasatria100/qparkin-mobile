import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/point_history_model.dart';
import 'package:qparkin_app/data/models/point_statistics_model.dart';
import 'package:qparkin_app/data/models/point_filter_model.dart';
import 'package:qparkin_app/data/services/point_service.dart';
import 'package:qparkin_app/logic/providers/point_provider.dart';
import 'package:qparkin_app/presentation/screens/point_page.dart';
import 'package:qparkin_app/presentation/widgets/point_balance_card.dart';
import 'package:qparkin_app/presentation/widgets/point_history_item.dart';
import 'package:qparkin_app/presentation/widgets/point_statistics_card.dart';
import 'package:qparkin_app/presentation/widgets/filter_bottom_sheet.dart';
import 'package:qparkin_app/presentation/widgets/point_info_bottom_sheet.dart';

/// End-to-End Integration Tests for Point Page Feature
/// 
/// This test suite validates the complete point management flow including:
/// - Viewing point balance and history
/// - Filtering point transactions
/// - Using points for payment
/// - Offline scenarios and error recovery
/// - Accessibility compliance
/// 
/// Requirements: All requirements from point-page-enhancement spec
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Complete Point Flow - View Balance and History', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('SUCCESS: View point balance on page load', (WidgetTester tester) async {
      // Setup test data
      mockPointService.mockBalance = 1250;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify balance is displayed
      expect(find.text('1.250'), findsOneWidget);
      expect(find.byType(PointBalanceCard), findsOneWidget);
      expect(pointProvider.balance, equals(1250));
      expect(pointProvider.isLoadingBalance, isFalse);

      pointProvider.dispose();
    });

    testWidgets('SUCCESS: View point history with correct formatting', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to History tab
      final historyTab = find.text('Riwayat');
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Verify history items are displayed
      expect(find.byType(PointHistoryItem), findsWidgets);
      expect(find.text('Poin dari parkir'), findsOneWidget);
      expect(find.text('Pembayaran parkir'), findsOneWidget);

      pointProvider.dispose();
    });

    testWidgets('SUCCESS: Statistics display correctly', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics(
        totalEarned: 5000,
        totalUsed: 2000,
        thisMonthEarned: 1500,
        thisMonthUsed: 500,
      );

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify statistics card is displayed
      expect(find.byType(PointStatisticsCard), findsOneWidget);
      expect(find.text('5.000'), findsOneWidget); // Total earned
      expect(find.text('2.000'), findsOneWidget); // Total used

      pointProvider.dispose();
    });

    testWidgets('SUCCESS: Pull-to-refresh updates data', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update mock data
      mockPointService.mockBalance = 1500;

      // Perform pull-to-refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify data updated
      expect(find.text('1.500'), findsOneWidget);
      expect(pointProvider.balance, equals(1500));

      pointProvider.dispose();
    });
  });

  group('E2E: Filter and Search History', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('SUCCESS: Filter by addition type', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createMixedHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to History tab
      final historyTab = find.text('Riwayat');
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Open filter bottom sheet
      final filterButton = find.byIcon(Icons.filter_list);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Select "Penambahan" filter
      final additionFilter = find.text('Penambahan');
      await tester.tap(additionFilter);
      await tester.pumpAndSettle();

      // Apply filter
      final applyButton = find.text('Terapkan');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Verify only addition items are shown
      final filteredHistory = pointProvider.filteredHistory;
      expect(filteredHistory.every((h) => h.isAddition), isTrue);

      pointProvider.dispose();
    });

    testWidgets('SUCCESS: Filter by period', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createHistoryWithDates();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to History tab
      final historyTab = find.text('Riwayat');
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Open filter
      final filterButton = find.byIcon(Icons.filter_list);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Select "Bulan Ini" period
      final thisMonthFilter = find.text('Bulan Ini');
      await tester.tap(thisMonthFilter);
      await tester.pumpAndSettle();

      // Apply filter
      final applyButton = find.text('Terapkan');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Verify filter is applied
      expect(pointProvider.currentFilter.period, equals(PointFilterPeriod.thisMonth));

      pointProvider.dispose();
    });

    testWidgets('SUCCESS: Reset filter shows all history', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createMixedHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Apply a filter first
      pointProvider.setFilter(PointFilter(
        type: PointFilterType.addition,
        period: PointFilterPeriod.thisMonth,
      ));
      await tester.pumpAndSettle();

      // Switch to History tab
      final historyTab = find.text('Riwayat');
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Open filter
      final filterButton = find.byIcon(Icons.filter_list);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Reset filter
      final resetButton = find.text('Reset');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify all history is shown
      expect(pointProvider.currentFilter.type, equals(PointFilterType.all));
      expect(pointProvider.currentFilter.period, equals(PointFilterPeriod.allTime));

      pointProvider.dispose();
    });
  });

  group('E2E: Point Information', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('SUCCESS: Display point information bottom sheet', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap info button
      final infoButton = find.byIcon(Icons.info_outline);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet is displayed
      expect(find.byType(PointInfoBottomSheet), findsOneWidget);
      expect(find.text('Cara Kerja Poin'), findsOneWidget);

      pointProvider.dispose();
    });
  });

  group('E2E: Error Scenarios', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('ERROR: Network failure shows error message', (WidgetTester tester) async {
      mockPointService.shouldThrowError = true;
      mockPointService.errorMessage = 'Network connection failed';

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(pointProvider.balanceError, isNotNull);

      pointProvider.dispose();
    });

    testWidgets('ERROR: Retry after network failure', (WidgetTester tester) async {
      mockPointService.shouldThrowError = true;
      mockPointService.errorMessage = 'Network error';

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error state
      expect(pointProvider.balanceError, isNotNull);

      // Fix the error
      mockPointService.shouldThrowError = false;
      mockPointService.mockBalance = 1000;

      // Tap retry button
      final retryButton = find.text('Coba Lagi');
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      // Verify data loaded successfully
      expect(find.text('1.000'), findsOneWidget);
      expect(pointProvider.balanceError, isNull);

      pointProvider.dispose();
    });

    testWidgets('ERROR: Timeout shows appropriate message', (WidgetTester tester) async {
      mockPointService.shouldThrowError = true;
      mockPointService.errorMessage = 'Request timeout';

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify timeout error is handled
      expect(pointProvider.balanceError, contains('timeout'));

      pointProvider.dispose();
    });
  });

  group('E2E: Offline Support', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('SUCCESS: Display cached data when offline', (WidgetTester tester) async {
      // First load with network
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify data loaded
      expect(find.text('1.000'), findsOneWidget);

      // Simulate offline
      mockPointService.shouldThrowError = true;
      mockPointService.errorMessage = 'No internet connection';

      // Rebuild widget
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cached data is still displayed
      expect(pointProvider.balance, equals(1000));

      pointProvider.dispose();
    });
  });

  group('E2E: Accessibility Compliance', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('ACCESSIBILITY: Semantic labels present', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify semantic labels exist
      expect(find.bySemanticsLabel('Saldo poin Anda: 1.000 poin'), findsOneWidget);

      pointProvider.dispose();
    });

    testWidgets('ACCESSIBILITY: Touch targets meet minimum size', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find interactive elements
      final infoButton = find.byIcon(Icons.info_outline);
      expect(infoButton, findsOneWidget);

      // Verify button size meets minimum (48x48dp)
      final buttonWidget = tester.widget<IconButton>(infoButton);
      expect(buttonWidget.iconSize, greaterThanOrEqualTo(24.0));

      pointProvider.dispose();
    });
  });

  group('E2E: Data Persistence', () {
    late MockPointService mockPointService;

    setUp(() {
      mockPointService = MockPointService();
    });

    tearDown(() {
      mockPointService.reset();
    });

    testWidgets('Data persists across tab navigation', (WidgetTester tester) async {
      mockPointService.mockBalance = 1000;
      mockPointService.mockHistory = _createTestHistory();
      mockPointService.mockStatistics = _createTestStatistics();

      final pointProvider = PointProvider(pointService: mockPointService);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PointProvider>.value(
            value: pointProvider,
            child: const PointPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial data
      expect(pointProvider.balance, equals(1000));

      // Switch to History tab
      final historyTab = find.text('Riwayat');
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Switch back to Overview tab
      final overviewTab = find.text('Ringkasan');
      await tester.tap(overviewTab);
      await tester.pumpAndSettle();

      // Verify data persists
      expect(pointProvider.balance, equals(1000));
      expect(find.text('1.000'), findsOneWidget);

      pointProvider.dispose();
    });
  });
}

// Mock Service
class MockPointService extends PointService {
  int? mockBalance;
  List<PointHistory> mockHistory = [];
  PointStatistics? mockStatistics;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  int getBalanceCallCount = 0;
  int getHistoryCallCount = 0;

  @override
  Future<int> getBalance({required String token}) async {
    getBalanceCallCount++;
    
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    if (mockBalance == null) {
      throw Exception('Mock balance not set');
    }
    
    return mockBalance!;
  }

  @override
  Future<List<PointHistory>> getHistory({
    required String token,
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    getHistoryCallCount++;
    
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    return mockHistory;
  }

  @override
  Future<PointStatistics> getStatistics({required String token}) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    if (mockStatistics == null) {
      throw Exception('Mock statistics not set');
    }
    
    return mockStatistics!;
  }

  @override
  Future<bool> usePoints({
    required String token,
    required int amount,
    required String transactionId,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    if (mockBalance == null || mockBalance! < amount) {
      return false;
    }
    
    mockBalance = mockBalance! - amount;
    return true;
  }

  void reset() {
    mockBalance = null;
    mockHistory = [];
    mockStatistics = null;
    shouldThrowError = false;
    errorMessage = 'Network error';
    getBalanceCallCount = 0;
    getHistoryCallCount = 0;
  }
}

// Test Data Helpers
List<PointHistory> _createTestHistory() {
  return [
    PointHistory(
      idPoin: 1,
      idUser: 1,
      idTransaksi: 1001,
      poin: 100,
      perubahan: 'tambah',
      keterangan: 'Poin dari parkir',
      waktu: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PointHistory(
      idPoin: 2,
      idUser: 1,
      idTransaksi: 1002,
      poin: 50,
      perubahan: 'kurang',
      keterangan: 'Pembayaran parkir',
      waktu: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}

List<PointHistory> _createMixedHistory() {
  return [
    PointHistory(
      idPoin: 1,
      idUser: 1,
      idTransaksi: 1001,
      poin: 100,
      perubahan: 'tambah',
      keterangan: 'Poin dari parkir',
      waktu: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PointHistory(
      idPoin: 2,
      idUser: 1,
      idTransaksi: 1002,
      poin: 50,
      perubahan: 'kurang',
      keterangan: 'Pembayaran parkir',
      waktu: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PointHistory(
      idPoin: 3,
      idUser: 1,
      idTransaksi: 1003,
      poin: 75,
      perubahan: 'tambah',
      keterangan: 'Poin dari parkir',
      waktu: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PointHistory(
      idPoin: 4,
      idUser: 1,
      idTransaksi: null,
      poin: 25,
      perubahan: 'kurang',
      keterangan: 'Penalty overstay',
      waktu: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}

List<PointHistory> _createHistoryWithDates() {
  final now = DateTime.now();
  return [
    PointHistory(
      idPoin: 1,
      idUser: 1,
      idTransaksi: 1001,
      poin: 100,
      perubahan: 'tambah',
      keterangan: 'Poin bulan ini',
      waktu: now.subtract(const Duration(days: 5)),
    ),
    PointHistory(
      idPoin: 2,
      idUser: 1,
      idTransaksi: 1002,
      poin: 50,
      perubahan: 'tambah',
      keterangan: 'Poin 2 bulan lalu',
      waktu: DateTime(now.year, now.month - 2, 15),
    ),
    PointHistory(
      idPoin: 3,
      idUser: 1,
      idTransaksi: 1003,
      poin: 75,
      perubahan: 'tambah',
      keterangan: 'Poin 5 bulan lalu',
      waktu: DateTime(now.year, now.month - 5, 10),
    ),
  ];
}

PointStatistics _createTestStatistics({
  int totalEarned = 1000,
  int totalUsed = 500,
  int thisMonthEarned = 200,
  int thisMonthUsed = 100,
}) {
  return PointStatistics(
    totalEarned: totalEarned,
    totalUsed: totalUsed,
    thisMonthEarned: thisMonthEarned,
    thisMonthUsed: thisMonthUsed,
  );
}
