import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Logging utility for map-related operations
///
/// Provides structured logging with timestamp, error type, context, and device information.
/// Supports multiple log levels (error, warning, info) for different severity levels.
///
/// Requirements: 5.4
class MapLogger {
  static MapLogger? _instance;
  static PackageInfo? _packageInfo;
  static String? _deviceInfo;

  /// Private constructor for singleton pattern
  MapLogger._();

  /// Get singleton instance of MapLogger
  static MapLogger get instance {
    _instance ??= MapLogger._();
    return _instance!;
  }

  /// Initialize logger with app and device information
  ///
  /// Should be called once during app initialization to gather
  /// device and app version information for logging.
  static Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _deviceInfo = await _getDeviceInfo();
    } catch (e) {
      debugPrint('[MapLogger] Failed to initialize: $e');
    }
  }

  /// Get device information string
  ///
  /// Returns a string containing OS name and version.
  static Future<String> _getDeviceInfo() async {
    try {
      final os = Platform.operatingSystem;
      final version = Platform.operatingSystemVersion;
      return '$os $version';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Log an error with full context
  ///
  /// Logs error information including timestamp, error type, message,
  /// context, device info, and app version.
  ///
  /// Parameters:
  /// - [errorType]: Category of error (e.g., 'NETWORK_ERROR', 'LOCATION_ERROR')
  /// - [message]: Detailed error message
  /// - [context]: Context where error occurred (method name, operation)
  /// - [stackTrace]: Optional stack trace for debugging
  /// - [additionalData]: Optional map of additional contextual data
  ///
  /// Requirements: 5.4
  void logError(
    String errorType,
    String message,
    String context, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final logEntry = _buildLogEntry(
      level: LogLevel.error,
      errorType: errorType,
      message: message,
      context: context,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );

    _writeLog(logEntry);
  }

  /// Log a warning with context
  ///
  /// Logs warning information for non-critical issues that should be monitored.
  ///
  /// Parameters:
  /// - [warningType]: Category of warning
  /// - [message]: Warning message
  /// - [context]: Context where warning occurred
  /// - [additionalData]: Optional map of additional contextual data
  ///
  /// Requirements: 5.4
  void logWarning(
    String warningType,
    String message,
    String context, {
    Map<String, dynamic>? additionalData,
  }) {
    final logEntry = _buildLogEntry(
      level: LogLevel.warning,
      errorType: warningType,
      message: message,
      context: context,
      additionalData: additionalData,
    );

    _writeLog(logEntry);
  }

  /// Log an informational message
  ///
  /// Logs informational messages for tracking normal operations.
  ///
  /// Parameters:
  /// - [infoType]: Category of information
  /// - [message]: Information message
  /// - [context]: Context where info was logged
  /// - [additionalData]: Optional map of additional contextual data
  ///
  /// Requirements: 5.4
  void logInfo(
    String infoType,
    String message,
    String context, {
    Map<String, dynamic>? additionalData,
  }) {
    final logEntry = _buildLogEntry(
      level: LogLevel.info,
      errorType: infoType,
      message: message,
      context: context,
      additionalData: additionalData,
    );

    _writeLog(logEntry);
  }

  /// Build a structured log entry
  ///
  /// Creates a formatted log entry with all required information.
  ///
  /// Returns a formatted string containing:
  /// - Timestamp (ISO 8601 format)
  /// - Log level
  /// - Error/warning/info type
  /// - Message
  /// - Context
  /// - Device information
  /// - App version
  /// - Additional data (if provided)
  /// - Stack trace (if provided)
  String _buildLogEntry({
    required LogLevel level,
    required String errorType,
    required String message,
    required String context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final appVersion = _packageInfo?.version ?? 'Unknown';
    final buildNumber = _packageInfo?.buildNumber ?? 'Unknown';
    final device = _deviceInfo ?? 'Unknown Device';

    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] $levelStr: $errorType');
    buffer.writeln('Message: $message');
    buffer.writeln('Context: $context');
    buffer.writeln('Device: $device');
    buffer.writeln('App Version: $appVersion (Build $buildNumber)');

    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.writeln('Additional Data:');
      additionalData.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }

    return buffer.toString();
  }

  /// Write log entry to output
  ///
  /// In debug mode, writes to console using debugPrint.
  /// In production, this should send logs to a logging service.
  ///
  /// TODO: Integrate with logging service (e.g., Firebase Crashlytics, Sentry)
  void _writeLog(String logEntry) {
    // In debug mode, print to console
    if (kDebugMode) {
      debugPrint(logEntry);
    }

    // TODO: In production, send to logging service
    // Example integrations:
    // - Firebase Crashlytics: FirebaseCrashlytics.instance.log(logEntry);
    // - Sentry: Sentry.captureMessage(logEntry);
    // - Custom backend: await http.post('$API_URL/logs', body: logEntry);
  }

  /// Log location permission error
  ///
  /// Convenience method for logging location permission errors.
  ///
  /// Requirements: 5.4
  void logLocationPermissionError(
    String message,
    String context, {
    String? permissionStatus,
  }) {
    logError(
      'LOCATION_PERMISSION_ERROR',
      message,
      context,
      additionalData: permissionStatus != null
          ? {'permissionStatus': permissionStatus}
          : null,
    );
  }

  /// Log GPS/location service error
  ///
  /// Convenience method for logging GPS and location service errors.
  ///
  /// Requirements: 5.4
  void logLocationServiceError(
    String message,
    String context, {
    bool? serviceEnabled,
  }) {
    logError(
      'LOCATION_SERVICE_ERROR',
      message,
      context,
      additionalData: serviceEnabled != null
          ? {'serviceEnabled': serviceEnabled}
          : null,
    );
  }

  /// Log network error
  ///
  /// Convenience method for logging network-related errors.
  ///
  /// Requirements: 5.4
  void logNetworkError(
    String message,
    String context, {
    int? statusCode,
    String? url,
  }) {
    final additionalData = <String, dynamic>{};
    if (statusCode != null) additionalData['statusCode'] = statusCode;
    if (url != null) additionalData['url'] = url;

    logError(
      'NETWORK_ERROR',
      message,
      context,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }

  /// Log route calculation error
  ///
  /// Convenience method for logging route calculation errors.
  ///
  /// Requirements: 5.4
  void logRouteCalculationError(
    String message,
    String context, {
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
  }) {
    final additionalData = <String, dynamic>{};
    if (originLat != null) additionalData['originLat'] = originLat;
    if (originLng != null) additionalData['originLng'] = originLng;
    if (destLat != null) additionalData['destLat'] = destLat;
    if (destLng != null) additionalData['destLng'] = destLng;

    logError(
      'ROUTE_CALCULATION_ERROR',
      message,
      context,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }

  /// Log state management error
  ///
  /// Convenience method for logging state management errors.
  ///
  /// Requirements: 5.4
  void logStateManagementError(
    String message,
    String context, {
    String? currentState,
    String? attemptedAction,
  }) {
    final additionalData = <String, dynamic>{};
    if (currentState != null) additionalData['currentState'] = currentState;
    if (attemptedAction != null) {
      additionalData['attemptedAction'] = attemptedAction;
    }

    logError(
      'STATE_MANAGEMENT_ERROR',
      message,
      context,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }
}

/// Log level enumeration
enum LogLevel {
  error,
  warning,
  info,
}
