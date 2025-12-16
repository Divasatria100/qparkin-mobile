import 'package:flutter/foundation.dart';

/// Provider for managing notification state
///
/// Handles both general notifications and point-specific notifications.
/// Tracks point balance changes and provides notification badges.
class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  
  // Point notification state
  int? _lastKnownBalance;
  bool _hasPointChanges = false;

  /// Get the current unread notification count
  int get unreadCount => _unreadCount;

  /// Check if there are unread notifications
  bool get hasUnread => _unreadCount > 0;
  
  /// Check if there are unread point changes
  bool get hasPointChanges => _hasPointChanges;

  /// Set the unread notification count
  void setUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  /// Increment the unread count
  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
  }

  /// Decrement the unread count
  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    if (_unreadCount > 0) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  /// Fetch unread notification count from API
  Future<void> fetchUnreadCount() async {
    // TODO: Implement API call to fetch unread count
    // For now, simulate with mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock: Set a random unread count for demonstration
    // In production, this would come from the API
    setUnreadCount(3);
  }
  
  // ========== Point Notification Methods ==========
  
  /// Initialize point balance tracking
  ///
  /// Should be called when user first logs in or app starts.
  /// Sets the baseline balance for change detection.
  ///
  /// Parameters:
  /// - [balance]: Current point balance
  void initializeBalance(int balance) {
    _lastKnownBalance = balance;
    _hasPointChanges = false;
    debugPrint('[NotificationProvider] Balance initialized: $balance');
  }
  
  /// Mark that points have changed
  ///
  /// Should be called by PointProvider when balance changes.
  /// Sets notification badge to indicate new point activity.
  ///
  /// Parameters:
  /// - [newBalance]: New point balance after change
  void markPointsChanged(int newBalance) {
    if (_lastKnownBalance != null && _lastKnownBalance != newBalance) {
      _hasPointChanges = true;
      _lastKnownBalance = newBalance;
      debugPrint('[NotificationProvider] Points changed: $_lastKnownBalance -> $newBalance');
      notifyListeners();
    }
  }
  
  /// Mark point changes as read
  ///
  /// Should be called when user opens the point page.
  /// Clears the notification badge for point changes.
  void markPointChangesAsRead() {
    if (_hasPointChanges) {
      _hasPointChanges = false;
      debugPrint('[NotificationProvider] Point changes marked as read');
      notifyListeners();
    }
  }
  
  /// Clear all point notification state
  ///
  /// Should be called when user logs out.
  void clearPointNotifications() {
    _lastKnownBalance = null;
    _hasPointChanges = false;
    debugPrint('[NotificationProvider] Point notifications cleared');
    notifyListeners();
  }
}
