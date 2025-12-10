# Point Error Handling Implementation

## Overview

Comprehensive error handling has been implemented for the Point Page Enhancement feature, providing user-friendly error messages, proper error logging with codes, and appropriate retry mechanisms.

## Requirements Addressed

- **1.4**: Error states with retry options
- **8.3**: Timeout errors with retry option  
- **10.2**: User-friendly error messages
- **10.3**: Backend API error handling
- **10.5**: Error logging with error codes

## Components Implemented

### 1. PointErrorHandler Utility (`lib/utils/point_error_handler.dart`)

A centralized error handling utility that provides:

#### Error Classification
- **POINT_ERR_001**: Network errors (connection failures, socket errors)
- **POINT_ERR_002**: Timeout errors (slow connections, request timeouts)
- **POINT_ERR_003**: Authentication errors (401, unauthorized)
- **POINT_ERR_004**: Not found errors (404, data not found)
- **POINT_ERR_005**: Server errors (500, 502, 503, 504)
- **POINT_ERR_006**: Validation errors (400, bad request)
- **POINT_ERR_007**: Insufficient points errors (402, 403)
- **POINT_ERR_008**: Format errors (JSON parsing, decode errors)
- **POINT_ERR_999**: Unknown errors

#### Key Methods

```dart
// Classify error and return error code
String classifyError(dynamic error)

// Get user-friendly message
String getUserFriendlyMessage(dynamic error)

// Get detailed message for logging
String getDetailedMessage(dynamic error, {String? context})

// Log error with code and stack trace
void logError(dynamic error, {String? context, StackTrace? stackTrace})

// Check if error requires internet message
bool requiresInternetMessage(dynamic error)

// Check if error is retryable
bool isRetryable(dynamic error)

// Get retry message for user
String getRetryMessage(dynamic error)
```

#### User-Friendly Messages

The error handler converts technical errors into Indonesian messages:

- Network errors: "Tidak dapat terhubung ke server. Periksa koneksi internet Anda."
- Timeout errors: "Koneksi lambat. Silakan coba lagi."
- Auth errors: "Sesi Anda telah berakhir. Silakan login kembali."
- Server errors: "Server sedang bermasalah. Silakan coba beberapa saat lagi."
- Insufficient points: "Poin Anda tidak cukup untuk transaksi ini."

### 2. PointErrorDialog Utility (`lib/utils/point_error_dialog.dart`)

Provides UI components for displaying errors:

#### Dialog Methods

```dart
// Show error dialog with retry option
Future<void> showErrorDialog({
  required BuildContext context,
  required dynamic error,
  String? title,
  VoidCallback? onRetry,
})

// Show error snackbar with retry
void showErrorSnackBar({
  required BuildContext context,
  required dynamic error,
  VoidCallback? onRetry,
  Duration duration,
})

// Show success snackbar
void showSuccessSnackBar({
  required BuildContext context,
  required String message,
  Duration duration,
})

// Show network required dialog
Future<void> showNetworkRequiredDialog({
  required BuildContext context,
  String? action,
})

// Show timeout dialog with retry
Future<void> showTimeoutDialog({
  required BuildContext context,
  VoidCallback? onRetry,
})
```

### 3. Enhanced PointService (`lib/data/services/point_service.dart`)

Updated all API methods to:
- Log errors with context and stack traces
- Classify errors using PointErrorHandler
- Provide detailed error information for debugging

Example:
```dart
try {
  return _handleBalanceResponse(response);
} on TimeoutException catch (e, stackTrace) {
  PointErrorHandler.logError(e, context: 'getBalance', stackTrace: stackTrace);
  throw Exception('Koneksi lambat. Silakan coba lagi.');
} on http.ClientException catch (e, stackTrace) {
  PointErrorHandler.logError(e, context: 'getBalance', stackTrace: stackTrace);
  throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
}
```

### 4. Enhanced PointProvider (`lib/logic/providers/point_provider.dart`)

Updated error handling in all fetch methods:
- Uses PointErrorHandler for user-friendly messages
- Logs errors with context
- Detects network errors and shows "Memerlukan koneksi internet" message
- Falls back to cached data when offline

Example:
```dart
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
      _balanceError = null;
    }
  }
  
  notifyListeners();
}
```

### 5. Enhanced PointPage (`lib/presentation/screens/point_page.dart`)

Updated refresh handler to show specific error messages:
```dart
} catch (e) {
  if (mounted) {
    final errorMessage = PointErrorHandler.getUserFriendlyMessage(e);
    final requiresInternet = PointErrorHandler.requiresInternetMessage(e);
    
    PointErrorHandler.logError(e, context: 'handleRefresh');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          requiresInternet 
            ? 'Memerlukan koneksi internet. Periksa koneksi Anda.'
            : errorMessage
        ),
        action: SnackBarAction(
          label: 'Coba Lagi',
          onPressed: _handleRefresh,
        ),
      ),
    );
  }
}
```

### 6. Enhanced BookingPage (`lib/presentation/screens/booking_page.dart`)

Updated point usage error handling:
```dart
} catch (e) {
  PointErrorHandler.logError(e, context: 'usePointsInBooking');
  
  final requiresInternet = PointErrorHandler.requiresInternetMessage(e);
  final errorMessage = requiresInternet
      ? 'Booking berhasil, tetapi memerlukan koneksi internet untuk menggunakan poin'
      : 'Booking berhasil, tetapi gagal menggunakan poin: ${PointErrorHandler.getUserFriendlyMessage(e)}';
  _showErrorSnackbar(errorMessage);
}
```

## Error Handling Flow

### 1. Network Errors
```
User Action → API Call → Network Error
  ↓
PointErrorHandler.classifyError() → POINT_ERR_001
  ↓
PointErrorHandler.getUserFriendlyMessage() → "Tidak dapat terhubung ke server..."
  ↓
PointErrorHandler.requiresInternetMessage() → true
  ↓
UI shows: "Memerlukan koneksi internet. Periksa koneksi Anda."
  ↓
Retry button available (if retryable)
```

### 2. Timeout Errors
```
User Action → API Call → Timeout
  ↓
PointErrorHandler.classifyError() → POINT_ERR_002
  ↓
PointErrorHandler.getUserFriendlyMessage() → "Koneksi lambat..."
  ↓
UI shows: "Koneksi lambat. Silakan coba lagi."
  ↓
Retry button available
```

### 3. Auth Errors
```
User Action → API Call → 401 Unauthorized
  ↓
PointErrorHandler.classifyError() → POINT_ERR_003
  ↓
PointErrorHandler.getUserFriendlyMessage() → "Sesi Anda telah berakhir..."
  ↓
PointErrorHandler.isRetryable() → false
  ↓
UI shows error without retry button
```

### 4. Server Errors
```
User Action → API Call → 500 Server Error
  ↓
PointErrorHandler.classifyError() → POINT_ERR_005
  ↓
PointErrorHandler.getUserFriendlyMessage() → "Server sedang bermasalah..."
  ↓
UI shows: "Server sedang bermasalah. Silakan coba beberapa saat lagi."
  ↓
Retry button available
```

## Error Logging

All errors are logged with:
- Timestamp
- Error code (POINT_ERR_XXX)
- Context (which operation failed)
- Full error message
- Stack trace (when available)

Example log output:
```
[2024-12-03 10:30:45] Error Code: POINT_ERR_001 [Context: fetchBalance] - ClientException: Connection failed
[PointErrorHandler] Stack trace: ...
```

## Testing

Comprehensive unit tests verify:
- Error classification for all error types
- User-friendly message generation
- Internet requirement detection
- Retry eligibility determination
- Detailed message formatting

Test file: `test/utils/point_error_handler_test.dart`

All 17 tests pass successfully.

## Benefits

1. **User Experience**: Clear, actionable error messages in Indonesian
2. **Debugging**: Error codes and detailed logging for troubleshooting
3. **Offline Support**: Graceful degradation with cached data
4. **Retry Logic**: Smart retry for transient errors, no retry for permanent errors
5. **Consistency**: Centralized error handling across all point operations
6. **Maintainability**: Single source of truth for error messages

## Future Enhancements

1. Error analytics tracking
2. Automatic retry with exponential backoff
3. Error recovery suggestions based on error type
4. Localization support for multiple languages
5. Custom error pages for specific error scenarios
