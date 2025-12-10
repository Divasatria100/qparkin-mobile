# Point Page Offline Caching Implementation

## Overview

This document describes the offline data caching implementation for the Point Page, which allows users to view their point data even when offline or experiencing network issues.

## Requirements Addressed

- **10.1**: Cache data and display when offline with indicator
- **10.2**: Display user-friendly error messages and offline indicators
- **10.4**: Implement cache invalidation and sync on connection restoration

## Architecture

### Caching Strategy

The Point Page uses **SharedPreferences** for local data caching with the following approach:

1. **Write-Through Cache**: Data is cached immediately after successful API fetch
2. **Cache-First on Error**: When network fails, cached data is displayed with an indicator
3. **Time-Based Invalidation**: Cache is considered stale after 24 hours
4. **Auto-Sync**: Data syncs automatically when connection is restored

### Cached Data

The following data is cached:

- **Balance** (`point_balance`): Current point balance
- **History** (`point_history`): List of point transactions
- **Statistics** (`point_statistics`): Aggregated point statistics
- **Last Sync Time** (`point_last_sync`): Timestamp of last successful sync

## Implementation Details

### PointProvider Enhancements

#### New State Properties

```dart
bool _isUsingCachedData = false;  // True when displaying cached data
bool _isOffline = false;           // True when network error detected
static const Duration _cacheValidityDuration = Duration(hours: 24);
```

#### New Getters

```dart
bool get isUsingCachedData => _isUsingCachedData;
bool get isOffline => _isOffline;
bool get isCacheStale {
  if (_lastSyncTime == null) return true;
  return DateTime.now().difference(_lastSyncTime!) > _cacheValidityDuration;
}
```

#### Enhanced Fetch Methods

All fetch methods (`fetchBalance`, `fetchHistory`, `fetchStatistics`) now:

1. Attempt to fetch from API
2. On success:
   - Update state with fresh data
   - Clear offline flags
   - Cache the data
3. On network error:
   - Set offline flag
   - If cached data exists, use it and clear error
   - If no cached data, show error

Example:

```dart
try {
  final balance = await _pointService.getBalance(token: token ?? '');
  _balance = balance;
  _isUsingCachedData = false;
  _isOffline = false;
  await _cacheData();
} catch (e) {
  if (_isNetworkError(e.toString())) {
    _isOffline = true;
    if (_balance != null) {
      _isUsingCachedData = true;
      _balanceError = null; // Clear error since we have cache
    }
  }
}
```

#### Cache Management Methods

**invalidateStaleCache()**
```dart
Future<void> invalidateStaleCache() async {
  if (isCacheStale) {
    await _clearCache();
    _balance = null;
    _history = [];
    _statistics = null;
    _lastSyncTime = null;
    _isUsingCachedData = false;
    notifyListeners();
  }
}
```

**syncOnConnectionRestored()**
```dart
Future<void> syncOnConnectionRestored({String? token}) async {
  if (_isOffline) {
    _isOffline = false;
    await refreshAll(token: token);
  }
}
```

**_isNetworkError()**
```dart
bool _isNetworkError(String error) {
  final errorLower = error.toLowerCase();
  return errorLower.contains('timeout') ||
      errorLower.contains('connection') ||
      errorLower.contains('network') ||
      errorLower.contains('socket') ||
      errorLower.contains('failed host lookup');
}
```

### PointPage UI Enhancements

#### Offline Indicator Banner

A banner is displayed at the top of the page when using cached data:

```dart
Widget _buildOfflineIndicator(PointProvider provider) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.orange[100],
      border: Border(
        bottom: BorderSide(color: Colors.orange[300]!, width: 1),
      ),
    ),
    child: Row(
      children: [
        Icon(Icons.cloud_off, color: Colors.orange[900]),
        Text('Data mungkin tidak terkini'),
        Text(_formatLastSyncTime(provider.lastSyncTime!)),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => provider.syncOnConnectionRestored(),
        ),
      ],
    ),
  );
}
```

The banner shows:
- Cloud-off icon
- "Data mungkin tidak terkini" message
- Time since last sync (e.g., "5m lalu", "2j lalu")
- Refresh button to attempt sync

#### Enhanced Auto-Sync

The auto-sync logic now includes cache invalidation and connection restoration:

```dart
Future<void> _autoSyncData() async {
  final provider = context.read<PointProvider>();
  
  // Invalidate stale cache first
  await provider.invalidateStaleCache();
  
  // Attempt to sync if offline
  if (provider.isOffline) {
    await provider.syncOnConnectionRestored();
  } else {
    await provider.autoSync();
  }
}
```

## User Experience Flow

### Scenario 1: Normal Online Usage

1. User opens Point Page
2. Data fetches from API successfully
3. Data is cached in SharedPreferences
4. UI displays fresh data
5. No offline indicator shown

### Scenario 2: Opening Page While Offline

1. User opens Point Page without internet
2. Cached data loads from SharedPreferences
3. API fetch fails with network error
4. Provider detects network error and sets offline flag
5. UI displays cached data with orange banner
6. Banner shows "Data mungkin tidak terkini" and last sync time

### Scenario 3: Connection Restored

1. User is viewing cached data (offline banner visible)
2. User taps refresh button in banner OR pulls to refresh
3. Provider attempts to sync with server
4. If successful:
   - Fresh data replaces cached data
   - Offline flag cleared
   - Banner disappears
   - Success snackbar shown
5. If still offline:
   - Cached data remains
   - Banner stays visible
   - Error snackbar shown

### Scenario 4: Stale Cache

1. User hasn't opened app for 25+ hours
2. User opens Point Page
3. Provider detects cache is stale (> 24 hours)
4. Cache is invalidated and cleared
5. Fresh data fetched from API
6. If fetch fails, empty state shown (no cached data)

## Cache Invalidation Strategy

### Time-Based Invalidation

- Cache validity: **24 hours**
- Checked on: Page initialization
- Action: Clear cache and force fresh fetch

### Manual Invalidation

Cache is cleared when:
- User logs out (`provider.clear()`)
- Cache becomes stale
- User explicitly refreshes

### Automatic Sync

Data syncs automatically when:
- Page is opened (if > 30 seconds since last sync)
- Connection is restored after being offline
- User pulls to refresh
- User taps refresh button in offline banner

## Testing

### Test Coverage

The implementation includes comprehensive tests in `test/providers/point_provider_offline_test.dart`:

1. ✅ Cache balance after successful fetch
2. ✅ Use cached data when network fails
3. ✅ Cache history after successful fetch
4. ✅ Use cached history when network fails
5. ✅ Cache statistics after successful fetch
6. ✅ Use cached statistics when network fails
7. ✅ Load cached data on initialization
8. ✅ Sync when connection is restored
9. ✅ Detect stale cache
10. ✅ Invalidate stale cache
11. ✅ Clear cache on clear()
12. ✅ Detect network errors correctly
13. ✅ Clear offline state on successful fetch

All tests pass successfully.

## Accessibility

The offline indicator banner includes:

- **Semantic label**: "Peringatan: Data mungkin tidak terkini"
- **Refresh button**: Labeled "Tombol coba sinkronisasi" with hint
- **Minimum touch target**: 48x48dp for refresh button
- **Color contrast**: Orange banner with dark text meets WCAG AA

## Performance Considerations

### Memory Usage

- Cached data stored in SharedPreferences (persistent storage)
- Data loaded asynchronously on provider initialization
- No impact on app startup time

### Network Efficiency

- Reduces unnecessary API calls when data is fresh
- Auto-sync only when > 30 seconds since last sync
- Graceful degradation when offline

### UI Responsiveness

- Cached data displays immediately while fetching fresh data
- No blocking operations on UI thread
- Smooth transitions between cached and fresh data

## Error Handling

### Network Errors

Detected by checking error message for keywords:
- "timeout"
- "connection"
- "network"
- "socket"
- "failed host lookup"

### User-Friendly Messages

Network errors show:
- "Koneksi internet bermasalah. Silakan periksa koneksi Anda."
- Cached data displayed if available
- Offline indicator banner shown

### Fallback Behavior

1. **With cached data**: Display cache + offline indicator
2. **Without cached data**: Show error state with retry button
3. **Stale cache**: Clear and fetch fresh data

## Future Enhancements

Potential improvements for future iterations:

1. **Background Sync**: Sync data in background when app is resumed
2. **Selective Cache**: Cache only frequently accessed data
3. **Compression**: Compress cached data to reduce storage
4. **Encryption**: Encrypt sensitive cached data
5. **Cache Size Limit**: Implement maximum cache size
6. **Network Status Listener**: Automatically sync when network becomes available

## Related Files

- `lib/logic/providers/point_provider.dart` - Provider implementation
- `lib/presentation/screens/point_page.dart` - UI implementation
- `test/providers/point_provider_offline_test.dart` - Test suite
- `.kiro/specs/point-page-enhancement/requirements.md` - Requirements 10.1, 10.2, 10.4
- `.kiro/specs/point-page-enhancement/design.md` - Design specifications

## Conclusion

The offline caching implementation provides a robust, user-friendly experience for viewing point data even when network connectivity is poor or unavailable. The implementation follows Flutter best practices, includes comprehensive testing, and meets all accessibility requirements.
