import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/logic/providers/point_provider.dart';
import '../../lib/data/services/point_service.dart';
import '../../lib/data/models/point_history_model.dart';
import '../../lib/data/models/point_statistics_model.dart';

/// Mock PointService for testing offline behavior
class MockPointService extends PointService {
  bool shouldFail = false;
  int mockBalance = 1000;
  List<PointHistory> mockHistory = [];
  PointStatistics mockStatistics = PointStatistics(
    totalEarned: 5000,
    totalUsed: 4000,
    thisMonthEarned: 500,
    thisMonthUsed: 250,
  );

  @override
  Future<int> getBalance({String? token}) async {
    if (shouldFail) {
      throw Exception('Network error: Failed host lookup');
    }
    return mockBalance;
  }

  @override
  Future<List<PointHistory>> getHistory({
    String? token,
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldFail) {
      throw Exception('Network error: Connection timeout');
    }
    return mockHistory;
  }

  @override
  Future<PointStatistics> getStatistics({String? token}) async {
    if (shouldFail) {
      throw Exception('Network error: Socket exception');
    }
    return mockStatistics;
  }

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PointProvider Offline Caching Tests', () {
    late MockPointService mockService;
    late PointProvider provider;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      mockService = MockPointService();
      provider = PointProvider(pointService: mockService);
      
      // Wait for cached data to load
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      provider.dispose();
    });

    test('Should cache balance after successful fetch', () async {
      // Arrange
      mockService.mockBalance = 1500;

      // Act
      await provider.fetchBalance();

      // Assert
      expect(provider.balance, 1500);
      expect(provider.isUsingCachedData, false);
      expect(provider.isOffline, false);

      // Verify data is cached
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('point_balance'), 1500);
    });

    test('Should use cached data when network fails', () async {
      // Arrange - First fetch successfully to cache data
      mockService.mockBalance = 2000;
      await provider.fetchBalance();
      expect(provider.balance, 2000);

      // Act - Simulate network failure
      mockService.shouldFail = true;
      await provider.fetchBalance();

      // Assert - Should still have cached balance
      expect(provider.balance, 2000);
      expect(provider.isUsingCachedData, true);
      expect(provider.isOffline, true);
      expect(provider.balanceError, null); // Error cleared since we have cache
    });

    test('Should cache history after successful fetch', () async {
      // Arrange
      mockService.mockHistory = [
        PointHistory(
          idPoin: 1,
          idUser: 1,
          idTransaksi: 1,
          poin: 100,
          perubahan: 'tambah',
          keterangan: 'Test',
          waktu: DateTime.now(),
        ),
      ];

      // Act
      await provider.fetchHistory();

      // Assert
      expect(provider.history.length, 1);
      expect(provider.isUsingCachedData, false);

      // Verify data is cached
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('point_history'), isNotNull);
    });

    test('Should use cached history when network fails', () async {
      // Arrange - First fetch successfully to cache data
      mockService.mockHistory = [
        PointHistory(
          idPoin: 1,
          idUser: 1,
          poin: 100,
          perubahan: 'tambah',
          keterangan: 'Cached',
          waktu: DateTime.now(),
        ),
      ];
      await provider.fetchHistory();
      expect(provider.history.length, 1);

      // Act - Simulate network failure
      mockService.shouldFail = true;
      await provider.fetchHistory();

      // Assert - Should still have cached history
      expect(provider.history.length, 1);
      expect(provider.history[0].keterangan, 'Cached');
      expect(provider.isUsingCachedData, true);
      expect(provider.isOffline, true);
    });

    test('Should cache statistics after successful fetch', () async {
      // Arrange
      mockService.mockStatistics = PointStatistics(
        totalEarned: 3000,
        totalUsed: 2000,
        thisMonthEarned: 300,
        thisMonthUsed: 200,
      );

      // Act
      await provider.fetchStatistics();

      // Assert
      expect(provider.statistics, isNotNull);
      expect(provider.statistics!.totalEarned, 3000);
      expect(provider.isUsingCachedData, false);

      // Verify data is cached
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('point_statistics'), isNotNull);
    });

    test('Should use cached statistics when network fails', () async {
      // Arrange - First fetch successfully to cache data
      await provider.fetchStatistics();
      expect(provider.statistics, isNotNull);

      // Act - Simulate network failure
      mockService.shouldFail = true;
      await provider.fetchStatistics();

      // Assert - Should still have cached statistics
      expect(provider.statistics, isNotNull);
      expect(provider.isUsingCachedData, true);
      expect(provider.isOffline, true);
    });

    test('Should load cached data on initialization', () async {
      // Arrange - Set up cached data
      SharedPreferences.setMockInitialValues({
        'point_balance': 5000,
        'point_last_sync': DateTime.now().toIso8601String(),
      });

      // Act - Create new provider (should load cache)
      final newProvider = PointProvider(pointService: mockService);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(newProvider.balance, 5000);
      expect(newProvider.lastSyncTime, isNotNull);

      newProvider.dispose();
    });

    test('Should sync when connection is restored', () async {
      // Arrange - Start with offline state
      mockService.shouldFail = true;
      await provider.fetchBalance();
      expect(provider.isOffline, true);

      // Act - Restore connection and sync
      mockService.shouldFail = false;
      mockService.mockBalance = 3000;
      await provider.syncOnConnectionRestored();

      // Assert
      expect(provider.balance, 3000);
      expect(provider.isOffline, false);
      expect(provider.isUsingCachedData, false);
    });

    test('Should detect stale cache', () async {
      // Arrange - Set up old cached data (25 hours ago)
      final oldTime = DateTime.now().subtract(const Duration(hours: 25));
      SharedPreferences.setMockInitialValues({
        'point_balance': 1000,
        'point_last_sync': oldTime.toIso8601String(),
      });

      // Act
      final newProvider = PointProvider(pointService: mockService);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(newProvider.isCacheStale, true);

      newProvider.dispose();
    });

    test('Should invalidate stale cache', () async {
      // Arrange - Set up old cached data
      final oldTime = DateTime.now().subtract(const Duration(hours: 25));
      SharedPreferences.setMockInitialValues({
        'point_balance': 1000,
        'point_last_sync': oldTime.toIso8601String(),
      });

      final newProvider = PointProvider(pointService: mockService);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(newProvider.balance, 1000);

      // Act
      await newProvider.invalidateStaleCache();

      // Assert
      expect(newProvider.balance, null);
      expect(newProvider.lastSyncTime, null);

      newProvider.dispose();
    });

    test('Should clear cache on clear()', () async {
      // Arrange - Set up data and cache
      await provider.fetchBalance();
      await provider.fetchHistory();
      expect(provider.balance, isNotNull);

      // Act
      provider.clear();

      // Assert
      expect(provider.balance, null);
      expect(provider.history, isEmpty);
      expect(provider.statistics, null);
      expect(provider.lastSyncTime, null);

      // Verify cache is cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('point_balance'), null);
      expect(prefs.getString('point_history'), null);
    });

    test('Should detect network errors correctly', () async {
      // Arrange
      mockService.shouldFail = true;

      // Act
      await provider.fetchBalance();

      // Assert
      expect(provider.isOffline, true);
    });

    test('Should clear offline state on successful fetch', () async {
      // Arrange - Start offline
      mockService.shouldFail = true;
      await provider.fetchBalance();
      expect(provider.isOffline, true);

      // Act - Successful fetch
      mockService.shouldFail = false;
      await provider.fetchBalance();

      // Assert
      expect(provider.isOffline, false);
      expect(provider.isUsingCachedData, false);
    });
  });
}
