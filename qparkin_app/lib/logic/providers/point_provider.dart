import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/point_history_model.dart';
import '../../data/models/point_statistics_model.dart';
import '../../data/models/point_filter_model.dart';
import '../../data/services/point_service.dart';
import '../../utils/point_error_handler.dart';
import 'notification_provider.dart';

/// Provider for managing point state and operations
///
/// Handles point balance, history, statistics, filtering, and caching.
/// Follows the same patterns as BookingProvider and ActiveParkingProvider.
///
/// Requirements: 1.1, 1.3, 2.1, 3.1, 4.1, 6.1, 8.1, 8.4
class PointProvider extends ChangeNotifier {
  final PointService _pointService;
  final NotificationProvider? _notificationProvider;

  // Balance state
  int? _balance;
  bool _isLoadingBalance = false;
  String? _balanceError;

  // History state
  List<PointHistory> _history = [];
  bool _isLoadingHistory = false;
  String? _historyError;
  int _currentPage = 1;
  bool _hasMoreHistory = true;

  // Statistics state
  PointStatistics? _statistics;
  bool _isLoadingStatistics = false;
  String? _statisticsError;

  // Filter state
  PointFilter _filter = PointFilter.all();

  // Cache state
  DateTime? _lastSyncTime;
  static const Duration _syncThreshold = Duration(seconds: 30);
  static const Duration _cacheValidityDuration = Duration(hours: 24);
  bool _isUsingCachedData = false;
  bool _isOffline = false;

  // SharedPreferences cache keys
  static const String _cacheKeyBalance = 'point_balance';
  static const String _cacheKeyHistory = 'point_history';
  static const String _cacheKeyStatistics = 'point_statistics';
  static const String _cacheKeyLastSync = 'point_last_sync';

  // Getters
  int? get balance => _balance;
  bool get isLoadingBalance => _isLoadingBalance;
  String? get balanceError => _balanceError;

  List<PointHistory> get history => _history;
  List<PointHistory> get filteredHistory => _applyFilter(_history);
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;
  bool get hasMoreHistory => _hasMoreHistory;

  PointStatistics? get statistics => _statistics;
  bool get isLoadingStatistics => _isLoadingStatistics;
  String? get statisticsError => _statisticsError;

  PointFilter get currentFilter => _filter;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isUsingCachedData => _isUsingCachedData;
  bool get isOffline => _isOffline;
  bool get isCacheStale {
    if (_lastSyncTime == null) return true;
    return DateTime.now().difference(_lastSyncTime!) > _cacheValidityDuration;
  }

  bool get isLoading =>
      _isLoadingBalance || _isLoadingHistory || _isLoadingStatistics;
  bool get hasError =>
      _balanceError != null || _historyError != null || _statisticsError != null;

  PointProvider({
    PointService? pointService,
    NotificationProvider? notificationProvider,
  })  : _pointService = pointService ?? PointService(),
        _notificationProvider = notificationProvider {
    _loadCachedData();
  }

  /// Fetch current point balance from API
  ///
  /// Requirements: 1.1, 1.3, 10.1, 10.2
  Future<void> fetchBalance({String? token}) async {
    _isLoadingBalance = true;
    _balanceError = null;
    notifyListeners();

    try {
      debugPrint('[PointProvider] Fetching balance...');

      final balance = await _pointService.getBalance(token: token ?? '');

      // Track balance change for notifications
      final oldBalance = _balance;
      _balance = balance;
      _lastSyncTime = DateTime.now();
      _isLoadingBalance = false;
      _balanceError = null;
      _isUsingCachedData = false;
      _isOffline = false;

      debugPrint('[PointProvider] Balance fetched: $balance');

      // Notify about balance change
      if (oldBalance != null && oldBalance != balance) {
        _notificationProvider?.markPointsChanged(balance);
      } else if (oldBalance == null) {
        // Initialize notification provider with first balance
        _notificationProvider?.initializeBalance(balance);
      }

      // Cache the data
      await _cacheData();

      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingBalance = false;
      
      // Log error with context
      PointErrorHandler.logError(e, context: 'fetchBalance', stackTrace: stackTrace);
      
      // Get user-friendly error message
      _balanceError = PointErrorHandler.getUserFriendlyMessage(e);
      
      // Mark as offline if network error
      if (PointErrorHandler.requiresInternetMessage(e)) {
        _isOffline = true;
        // If we have cached data, use it
        if (_balance != null) {
          _isUsingCachedData = true;
          _balanceError = null; // Clear error since we have cached data
        }
      }

      notifyListeners();
    }
  }

  /// Fetch point history from API with pagination
  ///
  /// Requirements: 2.1, 8.1, 10.1, 10.2
  Future<void> fetchHistory({
    String? token,
    bool loadMore = false,
  }) async {
    // Prevent duplicate loading
    if (_isLoadingHistory) return;

    // If loading more but no more data, return
    if (loadMore && !_hasMoreHistory) return;

    _isLoadingHistory = true;
    _historyError = null;

    // Reset page if not loading more
    if (!loadMore) {
      _currentPage = 1;
      _hasMoreHistory = true;
    }

    notifyListeners();

    try {
      debugPrint('[PointProvider] Fetching history (page: $_currentPage)...');

      final newHistory = await _pointService.getHistory(
        token: token ?? '',
        page: _currentPage,
        limit: 20,
      );

      if (loadMore) {
        // Append to existing history
        _history.addAll(newHistory);
      } else {
        // Replace history
        _history = newHistory;
      }

      // Invalidate filter cache since history changed
      _invalidateFilterCache();

      // Check if there's more data
      _hasMoreHistory = newHistory.length >= 20;

      // Increment page for next load
      if (_hasMoreHistory) {
        _currentPage++;
      }

      _lastSyncTime = DateTime.now();
      _isLoadingHistory = false;
      _historyError = null;
      _isUsingCachedData = false;
      _isOffline = false;

      debugPrint('[PointProvider] History fetched: ${newHistory.length} items');

      // Cache the data
      await _cacheData();

      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingHistory = false;
      
      // Log error with context
      PointErrorHandler.logError(e, context: 'fetchHistory', stackTrace: stackTrace);
      
      // Get user-friendly error message
      _historyError = PointErrorHandler.getUserFriendlyMessage(e);
      
      // Mark as offline if network error
      if (PointErrorHandler.requiresInternetMessage(e)) {
        _isOffline = true;
        // If we have cached data, use it
        if (_history.isNotEmpty) {
          _isUsingCachedData = true;
          _historyError = null; // Clear error since we have cached data
        }
      }

      notifyListeners();
    }
  }

  /// Fetch point statistics from API
  ///
  /// Requirements: 4.1, 10.1, 10.2
  Future<void> fetchStatistics({String? token}) async {
    _isLoadingStatistics = true;
    _statisticsError = null;
    notifyListeners();

    try {
      debugPrint('[PointProvider] Fetching statistics...');

      final stats = await _pointService.getStatistics(token: token ?? '');

      _statistics = stats;
      _lastSyncTime = DateTime.now();
      _isLoadingStatistics = false;
      _statisticsError = null;
      _isUsingCachedData = false;
      _isOffline = false;

      debugPrint('[PointProvider] Statistics fetched: ${stats.toJson()}');

      // Cache the data
      await _cacheData();

      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingStatistics = false;
      
      // Log error with context
      PointErrorHandler.logError(e, context: 'fetchStatistics', stackTrace: stackTrace);
      
      // Get user-friendly error message
      _statisticsError = PointErrorHandler.getUserFriendlyMessage(e);
      
      // Mark as offline if network error
      if (PointErrorHandler.requiresInternetMessage(e)) {
        _isOffline = true;
        // If we have cached data, use it
        if (_statistics != null) {
          _isUsingCachedData = true;
          _statisticsError = null; // Clear error since we have cached data
        }
      }

      notifyListeners();
    }
  }

  /// Refresh all data (balance, history, statistics)
  ///
  /// Used for pull-to-refresh functionality
  ///
  /// Requirements: 8.1
  Future<void> refreshAll({String? token}) async {
    debugPrint('[PointProvider] Refreshing all data...');

    // Fetch all data in parallel
    await Future.wait([
      fetchBalance(token: token),
      fetchHistory(token: token, loadMore: false),
      fetchStatistics(token: token),
    ]);

    debugPrint('[PointProvider] All data refreshed');
  }

  /// Auto-sync data if last sync was more than 30 seconds ago
  ///
  /// Requirements: 8.4
  Future<void> autoSync({String? token}) async {
    if (_lastSyncTime == null) {
      // No previous sync, fetch all data
      await refreshAll(token: token);
      return;
    }

    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);

    if (timeSinceLastSync > _syncThreshold) {
      debugPrint(
          '[PointProvider] Auto-sync triggered (${timeSinceLastSync.inSeconds}s since last sync)');
      await refreshAll(token: token);
    } else {
      debugPrint(
          '[PointProvider] Auto-sync skipped (${timeSinceLastSync.inSeconds}s since last sync)');
    }
  }

  /// Mark point changes as read
  ///
  /// Should be called when user opens the point page
  ///
  /// Requirements: 7.5
  void markNotificationsAsRead() {
    _notificationProvider?.markPointChangesAsRead();
  }

  /// Set filter for history
  /// Only notifies listeners if filter actually changed
  ///
  /// Requirements: 3.1
  void setFilter(PointFilter filter) {
    // Only update if filter actually changed
    if (_filter == filter) {
      return;
    }

    debugPrint('[PointProvider] Setting filter: ${filter.displayText}');

    _filter = filter;
    _invalidateFilterCache(); // Invalidate cache when filter changes
    notifyListeners();
  }

  // Cache for filtered history to avoid recomputing on every access
  List<PointHistory>? _cachedFilteredHistory;
  PointFilter? _lastAppliedFilter;

  /// Apply filter to history list with caching
  ///
  /// Requirements: 3.1
  List<PointHistory> _applyFilter(List<PointHistory> history) {
    // Return cached result if filter hasn't changed
    if (_cachedFilteredHistory != null && _lastAppliedFilter == _filter) {
      return _cachedFilteredHistory!;
    }

    // Compute and cache filtered history
    _cachedFilteredHistory = history.where((item) => _filter.matches(item)).toList();
    _lastAppliedFilter = _filter;
    
    return _cachedFilteredHistory!;
  }

  /// Invalidate filter cache when history changes
  void _invalidateFilterCache() {
    _cachedFilteredHistory = null;
    _lastAppliedFilter = null;
  }

  /// Use points for payment
  ///
  /// Requirements: 6.1
  Future<bool> usePoints({
    required int amount,
    required String transactionId,
    String? token,
  }) async {
    try {
      debugPrint('[PointProvider] Using $amount points for transaction $transactionId');

      final success = await _pointService.usePoints(
        amount: amount,
        transactionId: transactionId,
        token: token ?? '',
      );

      if (success) {
        // Update balance locally
        if (_balance != null) {
          final newBalance = _balance! - amount;
          _balance = newBalance;

          // Notify about balance change
          _notificationProvider?.markPointsChanged(newBalance);
        }

        // Refresh data to get updated history
        await refreshAll(token: token);

        debugPrint('[PointProvider] Points used successfully');
      }

      return success;
    } catch (e, stackTrace) {
      // Log error with context
      PointErrorHandler.logError(e, context: 'usePoints', stackTrace: stackTrace);
      
      // Rethrow to let caller handle the error with proper message
      rethrow;
    }
  }

  /// Clear all errors
  void clearErrors() {
    _balanceError = null;
    _historyError = null;
    _statisticsError = null;
    notifyListeners();
  }

  /// Clear all data and cache
  void clear() {
    debugPrint('[PointProvider] Clearing all data');

    _balance = null;
    _history = [];
    _statistics = null;
    _filter = PointFilter.all();
    _lastSyncTime = null;
    _currentPage = 1;
    _hasMoreHistory = true;

    _isLoadingBalance = false;
    _isLoadingHistory = false;
    _isLoadingStatistics = false;

    _balanceError = null;
    _historyError = null;
    _statisticsError = null;

    _clearCache();

    notifyListeners();
  }

  /// Cache data to SharedPreferences
  ///
  /// Requirements: 8.4, 10.1
  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cache balance
      if (_balance != null) {
        await prefs.setInt(_cacheKeyBalance, _balance!);
      }

      // Cache history
      if (_history.isNotEmpty) {
        final historyJson = jsonEncode(_history.map((h) => h.toJson()).toList());
        await prefs.setString(_cacheKeyHistory, historyJson);
      }

      // Cache statistics
      if (_statistics != null) {
        final statsJson = jsonEncode(_statistics!.toJson());
        await prefs.setString(_cacheKeyStatistics, statsJson);
      }

      // Cache last sync time
      if (_lastSyncTime != null) {
        await prefs.setString(_cacheKeyLastSync, _lastSyncTime!.toIso8601String());
      }

      debugPrint('[PointProvider] Data cached successfully');
    } catch (e) {
      debugPrint('[PointProvider] Error caching data: $e');
    }
  }

  /// Load cached data from SharedPreferences
  ///
  /// Requirements: 8.4, 10.1
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load balance
      final cachedBalance = prefs.getInt(_cacheKeyBalance);
      if (cachedBalance != null) {
        _balance = cachedBalance;
        debugPrint('[PointProvider] Loaded cached balance: $cachedBalance');
      }

      // Load history
      final cachedHistory = prefs.getString(_cacheKeyHistory);
      if (cachedHistory != null) {
        final historyList = jsonDecode(cachedHistory) as List;
        _history = historyList
            .map((json) => PointHistory.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('[PointProvider] Loaded cached history: ${_history.length} items');
      }

      // Load statistics
      final cachedStats = prefs.getString(_cacheKeyStatistics);
      if (cachedStats != null) {
        _statistics = PointStatistics.fromJson(
            jsonDecode(cachedStats) as Map<String, dynamic>);
        debugPrint('[PointProvider] Loaded cached statistics');
      }

      // Load last sync time
      final cachedLastSync = prefs.getString(_cacheKeyLastSync);
      if (cachedLastSync != null) {
        _lastSyncTime = DateTime.parse(cachedLastSync);
        debugPrint('[PointProvider] Last sync: $_lastSyncTime');
      }

      // Notify listeners if we loaded any cached data
      if (_balance != null || _history.isNotEmpty || _statistics != null) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[PointProvider] Error loading cached data: $e');
    }
  }

  /// Clear cached data from SharedPreferences
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_cacheKeyBalance);
      await prefs.remove(_cacheKeyHistory);
      await prefs.remove(_cacheKeyStatistics);
      await prefs.remove(_cacheKeyLastSync);

      debugPrint('[PointProvider] Cache cleared');
    } catch (e) {
      debugPrint('[PointProvider] Error clearing cache: $e');
    }
  }

  /// Invalidate cache if it's stale (older than 24 hours)
  ///
  /// Requirements: 10.4
  Future<void> invalidateStaleCache() async {
    if (isCacheStale) {
      debugPrint('[PointProvider] Cache is stale, clearing...');
      await _clearCache();
      _balance = null;
      _history = [];
      _statistics = null;
      _lastSyncTime = null;
      _isUsingCachedData = false;
      notifyListeners();
    }
  }

  /// Attempt to sync with server when connection is restored
  ///
  /// Requirements: 10.4
  Future<void> syncOnConnectionRestored({String? token}) async {
    if (_isOffline) {
      debugPrint('[PointProvider] Connection restored, syncing data...');
      _isOffline = false;
      await refreshAll(token: token);
    }
  }

  @override
  void dispose() {
    debugPrint('[PointProvider] Disposing provider');
    _pointService.dispose();
    super.dispose();
  }

  // ========== Test Helper Methods ==========
  // These methods are only used for testing purposes

  /// Simulate earning points (for testing)
  void simulatePointsEarned(int amount, String description) {
    _balance = (_balance ?? 0) + amount;
    _history.insert(
      0,
      PointHistory(
        idPoin: _history.length + 1,
        idUser: 1,
        poin: amount,
        perubahan: 'tambah',
        keterangan: description,
        waktu: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Add test history (for testing)
  void addTestHistory(List<PointHistory> testHistory, {int? balance}) {
    _history = testHistory;
    if (balance != null) {
      _balance = balance;
    }
    // Invalidate filter cache when history changes
    _invalidateFilterCache();
    notifyListeners();
  }

  /// Set test statistics (for testing)
  void setTestStatistics(PointStatistics stats) {
    _statistics = stats;
    notifyListeners();
  }

  /// Simulate network error (for testing)
  void simulateNetworkError() {
    _balanceError = 'Koneksi bermasalah';
    _historyError = 'Koneksi bermasalah';
    notifyListeners();
  }

  /// Clear error (for testing)
  void clearError() {
    _balanceError = null;
    _historyError = null;
    _statisticsError = null;
    notifyListeners();
  }

  /// Set offline mode (for testing)
  void setOfflineMode(bool offline) {
    _isOffline = offline;
    if (offline) {
      _isUsingCachedData = true;
    }
    notifyListeners();
  }

  /// Load cached data (for testing)
  Future<void> loadCachedData() async {
    await _loadCachedData();
  }

  /// Get error state (for testing)
  String? get error => _balanceError ?? _historyError ?? _statisticsError;

  /// Simulate using points without backend (for testing)
  Future<bool> simulateUsePoints(int amount) async {
    if (_balance == null || _balance! < amount) {
      return false;
    }
    
    _balance = _balance! - amount;
    _history.insert(
      0,
      PointHistory(
        idPoin: _history.length + 1,
        idUser: 1,
        poin: amount,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk pembayaran',
        waktu: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }
}