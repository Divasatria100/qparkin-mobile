import 'package:flutter/foundation.dart';

/// Comprehensive error handling utility for Point operations
///
/// Provides centralized error classification, user-friendly messages,
/// and error logging with codes for debugging.
///
/// Requirements: 1.4, 8.3, 10.2, 10.3, 10.5
class PointErrorHandler {
  /// Error codes for debugging and tracking
  static const String errorCodeNetwork = 'POINT_ERR_001';
  static const String errorCodeTimeout = 'POINT_ERR_002';
  static const String errorCodeAuth = 'POINT_ERR_003';
  static const String errorCodeNotFound = 'POINT_ERR_004';
  static const String errorCodeServer = 'POINT_ERR_005';
  static const String errorCodeValidation = 'POINT_ERR_006';
  static const String errorCodeInsufficientPoints = 'POINT_ERR_007';
  static const String errorCodeFormat = 'POINT_ERR_008';
  static const String errorCodeUnknown = 'POINT_ERR_999';

  /// Classify error and return appropriate error code
  ///
  /// Requirements: 10.5
  static String classifyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (_isNetworkError(errorString)) {
      return errorCodeNetwork;
    } else if (_isTimeoutError(errorString)) {
      return errorCodeTimeout;
    } else if (_isAuthError(errorString)) {
      return errorCodeAuth;
    } else if (_isNotFoundError(errorString)) {
      return errorCodeNotFound;
    } else if (_isServerError(errorString)) {
      return errorCodeServer;
    } else if (_isValidationError(errorString)) {
      return errorCodeValidation;
    } else if (_isInsufficientPointsError(errorString)) {
      return errorCodeInsufficientPoints;
    } else if (_isFormatError(errorString)) {
      return errorCodeFormat;
    } else {
      return errorCodeUnknown;
    }
  }

  /// Get user-friendly error message based on error
  ///
  /// Requirements: 10.2, 10.3
  static String getUserFriendlyMessage(dynamic error) {
    final errorCode = classifyError(error);
    final errorString = error.toString();

    switch (errorCode) {
      case errorCodeNetwork:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      
      case errorCodeTimeout:
        return 'Koneksi lambat. Silakan coba lagi.';
      
      case errorCodeAuth:
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      
      case errorCodeNotFound:
        return 'Data tidak ditemukan. Silakan coba lagi.';
      
      case errorCodeServer:
        return 'Server sedang bermasalah. Silakan coba beberapa saat lagi.';
      
      case errorCodeValidation:
        // Try to extract specific validation message
        if (errorString.contains('Exception:')) {
          final message = errorString.split('Exception:').last.trim();
          return message;
        }
        return 'Data tidak valid. Silakan periksa kembali.';
      
      case errorCodeInsufficientPoints:
        return 'Poin Anda tidak cukup untuk transaksi ini.';
      
      case errorCodeFormat:
        return 'Format data tidak valid. Silakan coba lagi.';
      
      default:
        // Try to extract message from exception
        if (errorString.contains('Exception:')) {
          final message = errorString.split('Exception:').last.trim();
          if (message.isNotEmpty && message.length < 100) {
            return message;
          }
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Get detailed error message for logging
  ///
  /// Requirements: 10.5
  static String getDetailedMessage(dynamic error, {String? context}) {
    final errorCode = classifyError(error);
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' [Context: $context]' : '';
    
    return '[$timestamp] Error Code: $errorCode$contextStr - ${error.toString()}';
  }

  /// Log error with code for debugging
  ///
  /// Requirements: 10.5
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final detailedMessage = getDetailedMessage(error, context: context);
    
    debugPrint('[PointErrorHandler] $detailedMessage');
    
    if (stackTrace != null) {
      debugPrint('[PointErrorHandler] Stack trace: $stackTrace');
    }
  }

  /// Check if error requires internet connection message
  ///
  /// Requirements: 10.5
  static bool requiresInternetMessage(dynamic error) {
    final errorCode = classifyError(error);
    return errorCode == errorCodeNetwork || errorCode == errorCodeTimeout;
  }

  /// Check if error is retryable
  ///
  /// Requirements: 8.3
  static bool isRetryable(dynamic error) {
    final errorCode = classifyError(error);
    
    // Don't retry auth, validation, or insufficient points errors
    return errorCode != errorCodeAuth &&
           errorCode != errorCodeValidation &&
           errorCode != errorCodeInsufficientPoints;
  }

  /// Get retry message for user
  ///
  /// Requirements: 8.3
  static String getRetryMessage(dynamic error) {
    if (requiresInternetMessage(error)) {
      return 'Memerlukan koneksi internet. Silakan periksa koneksi Anda dan coba lagi.';
    }
    
    return getUserFriendlyMessage(error);
  }

  // Private helper methods for error classification

  static bool _isNetworkError(String error) {
    return error.contains('network') ||
           error.contains('connection') ||
           error.contains('socket') ||
           error.contains('failed host lookup') ||
           error.contains('tidak dapat terhubung') ||
           error.contains('periksa koneksi');
  }

  static bool _isTimeoutError(String error) {
    return error.contains('timeout') ||
           error.contains('timed out') ||
           error.contains('koneksi lambat');
  }

  static bool _isAuthError(String error) {
    return error.contains('unauthorized') ||
           error.contains('401') ||
           error.contains('sesi') ||
           error.contains('login kembali') ||
           error.contains('authentication');
  }

  static bool _isNotFoundError(String error) {
    return error.contains('404') ||
           error.contains('not found') ||
           error.contains('tidak ditemukan');
  }

  static bool _isServerError(String error) {
    return error.contains('500') ||
           error.contains('502') ||
           error.contains('503') ||
           error.contains('504') ||
           error.contains('server error') ||
           error.contains('internal server') ||
           error.contains('server sedang bermasalah');
  }

  static bool _isValidationError(String error) {
    return error.contains('validation') ||
           error.contains('invalid') ||
           error.contains('tidak valid') ||
           error.contains('400') ||
           error.contains('bad request');
  }

  static bool _isInsufficientPointsError(String error) {
    return error.contains('insufficient') ||
           error.contains('tidak cukup') ||
           error.contains('402') ||
           error.contains('403');
  }

  static bool _isFormatError(String error) {
    return error.contains('format') ||
           error.contains('parse') ||
           error.contains('json') ||
           error.contains('decode');
  }
}

/// Extension on Exception for easier error handling
extension PointExceptionExtension on Exception {
  /// Get user-friendly message
  String get userMessage => PointErrorHandler.getUserFriendlyMessage(this);
  
  /// Get error code
  String get errorCode => PointErrorHandler.classifyError(this);
  
  /// Check if retryable
  bool get isRetryable => PointErrorHandler.isRetryable(this);
  
  /// Check if requires internet
  bool get requiresInternet => PointErrorHandler.requiresInternetMessage(this);
}
