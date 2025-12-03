import 'package:flutter/foundation.dart';

/// Provider for managing notification state
class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;

  /// Get the current unread notification count
  int get unreadCount => _unreadCount;

  /// Check if there are unread notifications
  bool get hasUnread => _unreadCount > 0;

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
}
