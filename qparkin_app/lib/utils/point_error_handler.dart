import 'package:flutter/foundation.dart';

/// Utility class for handling point-related errors
///
/// Provides centralized error handling, logging, and user-friendly
/// error message generation for the point system.
///
/// Requirements: 3.1
class PointErrorHandler {
  /// Log error with context and stack trace
  ///
  /// Parameters:
  /// - [error]: The error object
  /// - [context]: Optional context string describing where error occurred
  /// - [stackTrace]: Optional stack trace for debugging
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? '[$context]' : '';
    
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔴 POINT ERROR $contextStr');
    debugPrint('Time: $timestamp');
    debugPrint('Error: $error');
    
    if (stackTrace != null) {
      debugPrint('Stack Trace:');
      debugPrint(stackTrace.toString());
    }
    
    debugPrint('═══════════════════════════════════════════════════════');
  }

  /// Convert technical error to user-friendly message
  ///
  /// Maps various error types to Indonesian user-friendly messages
  /// that users can understand and act upon.
  ///
  /// Parameters:
  /// - [error]: The error object to convert
  ///
  /// Returns: User-friendly error message in Indonesian
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Koneksi bermasalah. Periksa koneksi internet Anda.';
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Permintaan timeout. Silakan coba lagi.';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('authentication') ||
        errorString.contains('token')) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }

    // Not found errors
    if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'Data tidak ditemukan. Silakan coba lagi.';
    }

    // Server errors
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server error') ||
        errorString.contains('internal server')) {
      return 'Terjadi kesalahan server. Silakan coba beberapa saat lagi.';
    }

    // Validation errors
    if (errorString.contains('validation') ||
        errorString.contains('invalid')) {
      return 'Data tidak valid. Periksa kembali data Anda.';
    }

    // Insufficient balance
    if (errorString.contains('insufficient') ||
        errorString.contains('not enough') ||
        errorString.contains('saldo tidak cukup')) {
      return 'Saldo poin tidak mencukupi.';
    }

    // Format errors
    if (errorString.contains('format') ||
        errorString.contains('parse')) {
      return 'Format data tidak valid. Silakan coba lagi.';
    }

    // Generic error
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Check if error requires internet connection message
  ///
  /// Determines if the error is network-related and should show
  /// an internet connection message to the user.
  ///
  /// Parameters:
  /// - [error]: The error object to check
  ///
  /// Returns: true if error is network-related
  static bool requiresInternetMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    return errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('timed out') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no internet');
  }

  /// Check if error is authentication-related
  ///
  /// Determines if the error is due to authentication failure
  /// and user needs to re-login.
  ///
  /// Parameters:
  /// - [error]: The error object to check
  ///
  /// Returns: true if error is authentication-related
  static bool isAuthenticationError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    return errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('authentication') ||
        errorString.contains('token expired') ||
        errorString.contains('invalid token');
  }

  /// Check if error is server-related
  ///
  /// Determines if the error is due to server issues
  /// that are beyond user control.
  ///
  /// Parameters:
  /// - [error]: The error object to check
  ///
  /// Returns: true if error is server-related
  static bool isServerError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server error') ||
        errorString.contains('internal server') ||
        errorString.contains('service unavailable');
  }

  /// Get error category for analytics
  ///
  /// Categorizes errors for analytics and monitoring purposes.
  ///
  /// Parameters:
  /// - [error]: The error object to categorize
  ///
  /// Returns: Error category string
  static String getErrorCategory(dynamic error) {
    if (requiresInternetMessage(error)) {
      return 'NETWORK_ERROR';
    } else if (isAuthenticationError(error)) {
      return 'AUTH_ERROR';
    } else if (isServerError(error)) {
      return 'SERVER_ERROR';
    } else {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('validation')) {
        return 'VALIDATION_ERROR';
      } else if (errorString.contains('not found') || errorString.contains('404')) {
        return 'NOT_FOUND_ERROR';
      } else if (errorString.contains('insufficient')) {
        return 'INSUFFICIENT_BALANCE';
      } else if (errorString.contains('format') || errorString.contains('parse')) {
        return 'FORMAT_ERROR';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  /// Create detailed error report for debugging
  ///
  /// Generates a comprehensive error report including all available
  /// information for debugging purposes.
  ///
  /// Parameters:
  /// - [error]: The error object
  /// - [context]: Optional context string
  /// - [stackTrace]: Optional stack trace
  ///
  /// Returns: Detailed error report string
  static String createErrorReport({
    required dynamic error,
    String? context,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln('POINT SYSTEM ERROR REPORT');
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    
    buffer.writeln('Error Type: ${error.runtimeType}');
    buffer.writeln('Error Category: ${getErrorCategory(error)}');
    buffer.writeln('Error Message: $error');
    buffer.writeln('User Message: ${getUserFriendlyMessage(error)}');
    
    if (stackTrace != null) {
      buffer.writeln('\nStack Trace:');
      buffer.writeln(stackTrace.toString());
    }
    
    buffer.writeln('═══════════════════════════════════════════════════════');
    
    return buffer.toString();
  }
}
