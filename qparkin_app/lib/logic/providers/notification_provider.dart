import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing notification state and badge indicators
///
/// Tracks point changes and displays badge indicators on the point page icon
/// when there are unread point changes.
///
/// Requirements: 7.5
class NotificationProvider extends ChangeNotifier {
  // Badge state
  bool _hasUnreadPointChanges = false;
  int _lastKnownBalance = 0;

  // SharedPreferences cache keys
  static const String _cacheKeyLastBalance = 'notification_last_balance';
  static const String _cacheKeyHasUnread = 'notification_has_unread';

  // Getters
  bool get hasUnreadPointChanges => _hasUnreadPointChanges;

  NotificationProvider() {
    _loadCachedState();
  }

  /// Mark that there are unread point changes
  ///
  /// This should be called when points change (earned, used, or penalty)
  ///
  /// Requirements: 7.5
  void markPointsChanged(int newBalance) {
    debugPrint('[NotificationProvider] Points changed: $_lastKnownBalance -> $newBalance');

    // Only mark as unread if balance actually changed
    if (_lastKnownBalance != newBalance && _lastKnownBalance != 0) {
      _hasUnreadPointChanges = true;
      _cacheState();
      notifyListeners();
    }

    _lastKnownBalance = newBalance;
    _cacheState();
  }

  /// Mark point changes as read
  ///
  /// This should be called when user opens the point page
  ///
  /// Requirements: 7.5
  void markPointChangesAsRead() {
    if (_hasUnreadPointChanges) {
      debugPrint('[NotificationProvider] Marking point changes as read');
      _hasUnreadPointChanges = false;
      _cacheState();
      notifyListeners();
    }
  }

  /// Initialize with current balance
  ///
  /// Should be called on app start to set the baseline
  void initializeBalance(int balance) {
    if (_lastKnownBalance == 0) {
      debugPrint('[NotificationProvider] Initializing balance: $balance');
      _lastKnownBalance = balance;
      _cacheState();
    }
  }

  /// Clear all notification state
  void clear() {
    debugPrint('[NotificationProvider] Clearing notification state');
    _hasUnreadPointChanges = false;
    _lastKnownBalance = 0;
    _clearCache();
    notifyListeners();
  }

  /// Cache notification state to SharedPreferences
  Future<void> _cacheState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheKeyLastBalance, _lastKnownBalance);
      await prefs.setBool(_cacheKeyHasUnread, _hasUnreadPointChanges);
      debugPrint('[NotificationProvider] State cached');
    } catch (e) {
      debugPrint('[NotificationProvider] Error caching state: $e');
    }
  }

  /// Load cached notification state from SharedPreferences
  Future<void> _loadCachedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastKnownBalance = prefs.getInt(_cacheKeyLastBalance) ?? 0;
      _hasUnreadPointChanges = prefs.getBool(_cacheKeyHasUnread) ?? false;

      debugPrint('[NotificationProvider] Loaded cached state: '
          'balance=$_lastKnownBalance, hasUnread=$_hasUnreadPointChanges');

      if (_hasUnreadPointChanges) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Error loading cached state: $e');
    }
  }

  /// Clear cached notification state
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyLastBalance);
      await prefs.remove(_cacheKeyHasUnread);
      debugPrint('[NotificationProvider] Cache cleared');
    } catch (e) {
      debugPrint('[NotificationProvider] Error clearing cache: $e');
    }
  }
}
