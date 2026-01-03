import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/point_history_model.dart';
import '../../data/models/point_statistics_model.dart';
import '../../data/models/point_filter_model.dart';
import '../../data/services/point_service.dart';
import 'notification_provider.dart';

/// Provider for managing point system state
///
/// Handles point balance, history, statistics, and business logic.
/// Integrates with NotificationProvider for point change notifications.
/// Implements caching for offline support.
class PointProvider extends ChangeNotifier {
  final PointService _pointService;
  final NotificationProvider _notificationProvider;
  final SharedPreferences _prefs;

  // State
  int _balance = 0;
  List<PointHistoryModel> _history = [];
  PointStatisticsModel? _statistics;
  PointFilterModel _currentFilter = PointFilterModel.all();
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;
  
  // Pagination state
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  // Cache keys
  static const String _balanceKey = 'point_balance';
  static const String _historyKey = 'point_history';
  static const String _statisticsKey = 'point_statistics';
  static const String _cacheTimestampKey = 'point_cache_timestamp';
  static const Duration _cacheValidity = Duration(hours: 24);

  // Getters
  int get balance => _balance;
  String get balanceDisplay => '$_balance poin';
  String get equivalentValue {
    final value = _balance * PointService.redemptionValue;
    return 'Rp${value.toStringAsFixed(0)}';
  }
  
  List<PointHistoryModel> get filteredHistory => _applyFilter(_history);
  PointStatisticsModel? get statistics => _statistics;
  PointFilterModel get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPoints => _balance > 0;
  bool get isOffline => _isOffline;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;

  PointProvider({
    required PointService pointService,
    required NotificationProvider notificationProvider,
    required SharedPreferences prefs,
  })  : _pointService = pointService,
        _notificationProvider = notificationProvider,
        _prefs = prefs;

  // ========== Business Logic Methods ==========

  /// Calculate available discount for a given parking cost
  ///
  /// Returns the maximum discount amount the user can get based on:
  /// - Current balance
  /// - 30% maximum discount rule
  ///
  /// Parameters:
  /// - [parkingCost]: Total parking cost in Rupiah
  ///
  /// Returns: Maximum discount amount in Rupiah
  int calculateAvailableDiscount(int parkingCost) {
    final maxPoints = _pointService.calculateMaxAllowedPoints(parkingCost);
    final availablePoints = min(_balance, maxPoints);
    return _pointService.calculateDiscountAmount(availablePoints);
  }

  /// Check if user can use specified points for a booking
  ///
  /// Parameters:
  /// - [points]: Number of points to use
  /// - [parkingCost]: Total parking cost in Rupiah
  ///
  /// Returns: true if points can be used, false otherwise
  bool canUsePoints(int points, int parkingCost) {
    return _pointService.validatePointUsage(points, parkingCost, _balance);
  }

  /// Validate point usage and return error message if invalid
  ///
  /// Parameters:
  /// - [points]: Number of points to use
  /// - [parkingCost]: Total parking cost in Rupiah
  ///
  /// Returns: Error message if invalid, null if valid
  String? validatePointUsage(int points, int parkingCost) {
    return _pointService.getValidationError(points, parkingCost, _balance);
  }

  /// Calculate maximum points that can be used for a booking
  ///
  /// Parameters:
  /// - [parkingCost]: Total parking cost in Rupiah
  ///
  /// Returns: Maximum number of points that can be used
  int calculateMaxUsablePoints(int parkingCost) {
    final maxPoints = _pointService.calculateMaxAllowedPoints(parkingCost);
    return min(_balance, maxPoints);
  }

  // ========== Data Fetching Methods ==========

  /// Fetch current point balance from API
  Future<void> fetchBalance({required String token}) async {
    try {
      debugPrint('[PointProvider] Fetching balance...');
      
      final newBalance = await _pointService.getBalance(token: token);
      
      // Update balance and notify if changed
      if (_balance != newBalance) {
        final oldBalance = _balance;
        _balance = newBalance;
        
        // Notify NotificationProvider of balance change
        _notificationProvider.markPointsChanged(newBalance);
        
        debugPrint('[PointProvider] Balance updated: $oldBalance -> $newBalance');
      }
      
      _error = null;
      _isOffline = false;
      
      // Cache the balance
      await _cacheBalance();
      
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat saldo poin';
      _isOffline = true;
      debugPrint('[PointProvider] Error fetching balance: $e');
      notifyListeners();
    }
  }

  /// Fetch point history from API with pagination
  ///
  /// Parameters:
  /// - [token]: Authentication token
  /// - [loadMore]: If true, loads next page; if false, resets to page 1
  Future<void> fetchHistory({
    required String token,
    bool loadMore = false,
  }) async {
    // Prevent multiple simultaneous loads
    if (loadMore && (_isLoadingMore || !_hasMorePages)) {
      return;
    }

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _hasMorePages = true;
    }
    
    notifyListeners();

    try {
      debugPrint('[PointProvider] Fetching history page $_currentPage...');
      
      final historyItems = await _pointService.getHistory(
        token: token,
        page: _currentPage,
        limit: 20,
      );
      
      if (loadMore) {
        _history.addAll(historyItems);
      } else {
        _history = historyItems;
      }
      
      // Update pagination state
      // If we got less than the limit, there are no more pages
      _hasMorePages = historyItems.length >= 20;
      
      if (_hasMorePages) {
        _currentPage++;
      }
      
      _error = null;
      _isOffline = false;
      
      // Cache the history
      await _cacheHistory();
      
      debugPrint('[PointProvider] History loaded: ${_history.length} items, hasMore: $_hasMorePages');
    } catch (e) {
      _error = 'Gagal memuat riwayat poin';
      _isOffline = true;
      debugPrint('[PointProvider] Error fetching history: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Fetch point statistics from API
  Future<void> fetchStatistics({required String token}) async {
    try {
      debugPrint('[PointProvider] Fetching statistics...');
      
      _statistics = await _pointService.getStatistics(token: token);
      
      _error = null;
      _isOffline = false;
      
      // Cache the statistics
      await _cacheStatistics();
      
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat statistik poin';
      _isOffline = true;
      debugPrint('[PointProvider] Error fetching statistics: $e');
      notifyListeners();
    }
  }

  /// Refresh all point data
  Future<void> refresh({required String token}) async {
    debugPrint('[PointProvider] Refreshing all data...');
    
    await Future.wait([
      fetchBalance(token: token),
      fetchHistory(token: token, loadMore: false),
      fetchStatistics(token: token),
    ]);
  }

  // ========== Filter Operations ==========

  /// Apply a filter to the history list
  void applyFilter(PointFilterModel filter) {
    _currentFilter = filter;
    debugPrint('[PointProvider] Filter applied: ${filter.type}');
    notifyListeners();
  }

  /// Clear the current filter
  void clearFilter() {
    _currentFilter = PointFilterModel.all();
    debugPrint('[PointProvider] Filter cleared');
    notifyListeners();
  }

  /// Apply the current filter to the history list
  List<PointHistoryModel> _applyFilter(List<PointHistoryModel> history) {
    return history.where((item) => _currentFilter.matches(item)).toList();
  }

  // ========== Cache Operations ==========

  /// Cache current balance
  Future<void> _cacheBalance() async {
    try {
      await _prefs.setInt(_balanceKey, _balance);
      await _updateCacheTimestamp();
      debugPrint('[PointProvider] Balance cached');
    } catch (e) {
      debugPrint('[PointProvider] Error caching balance: $e');
    }
  }

  /// Cache history list
  Future<void> _cacheHistory() async {
    try {
      final jsonList = _history.map((item) => item.toJson()).toList();
      await _prefs.setString(_historyKey, jsonEncode(jsonList));
      await _updateCacheTimestamp();
      debugPrint('[PointProvider] History cached: ${_history.length} items');
    } catch (e) {
      debugPrint('[PointProvider] Error caching history: $e');
    }
  }

  /// Cache statistics
  Future<void> _cacheStatistics() async {
    try {
      if (_statistics != null) {
        await _prefs.setString(_statisticsKey, jsonEncode(_statistics!.toJson()));
        await _updateCacheTimestamp();
        debugPrint('[PointProvider] Statistics cached');
      }
    } catch (e) {
      debugPrint('[PointProvider] Error caching statistics: $e');
    }
  }

  /// Update cache timestamp
  Future<void> _updateCacheTimestamp() async {
    await _prefs.setString(
      _cacheTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      // Check cache validity
      if (!_isCacheValid()) {
        debugPrint('[PointProvider] Cache expired, skipping load');
        return;
      }

      // Load balance
      final cachedBalance = _prefs.getInt(_balanceKey);
      if (cachedBalance != null) {
        _balance = cachedBalance;
        debugPrint('[PointProvider] Loaded cached balance: $_balance');
      }

      // Load history
      final cachedHistoryJson = _prefs.getString(_historyKey);
      if (cachedHistoryJson != null) {
        final jsonList = jsonDecode(cachedHistoryJson) as List;
        _history = jsonList
            .map((json) => PointHistoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('[PointProvider] Loaded cached history: ${_history.length} items');
      }

      // Load statistics
      final cachedStatsJson = _prefs.getString(_statisticsKey);
      if (cachedStatsJson != null) {
        _statistics = PointStatisticsModel.fromJson(
          jsonDecode(cachedStatsJson) as Map<String, dynamic>,
        );
        debugPrint('[PointProvider] Loaded cached statistics');
      }

      _isOffline = true; // Mark as offline since we're using cached data
      notifyListeners();
    } catch (e) {
      debugPrint('[PointProvider] Error loading cached data: $e');
    }
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    final timestampStr = _prefs.getString(_cacheTimestampKey);
    if (timestampStr == null) return false;

    try {
      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      return age < _cacheValidity;
    } catch (e) {
      return false;
    }
  }

  /// Clear all cached data
  Future<void> _clearCache() async {
    try {
      await Future.wait([
        _prefs.remove(_balanceKey),
        _prefs.remove(_historyKey),
        _prefs.remove(_statisticsKey),
        _prefs.remove(_cacheTimestampKey),
      ]);
      debugPrint('[PointProvider] Cache cleared');
    } catch (e) {
      debugPrint('[PointProvider] Error clearing cache: $e');
    }
  }

  // ========== Lifecycle Methods ==========

  /// Initialize the provider
  ///
  /// Loads cached data first, then fetches fresh data if online.
  /// Should be called after user login.
  Future<void> initialize({required String token}) async {
    debugPrint('[PointProvider] Initializing...');

    // Load cached data first for instant display
    await _loadCachedData();

    // Initialize notification provider with current balance
    _notificationProvider.initializeBalance(_balance);

    // Fetch fresh data in background
    try {
      await refresh(token: token);
      debugPrint('[PointProvider] Initialization complete');
    } catch (e) {
      debugPrint('[PointProvider] Error during initialization: $e');
      // Keep cached data if fetch fails
    }
  }

  /// Clear all data and cache
  ///
  /// Should be called on user logout.
  Future<void> clear() async {
    debugPrint('[PointProvider] Clearing all data...');

    _balance = 0;
    _history = [];
    _statistics = null;
    _currentFilter = PointFilterModel.all();
    _isLoading = false;
    _error = null;
    _isOffline = false;
    _currentPage = 1;
    _hasMorePages = true;
    _isLoadingMore = false;

    await _clearCache();
    _notificationProvider.clearPointNotifications();

    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[PointProvider] Disposing...');
    _pointService.dispose();
    super.dispose();
  }
}
