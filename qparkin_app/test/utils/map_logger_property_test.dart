import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/utils/map_logger.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';
import 'package:qparkin_app/data/services/location_service.dart';
import 'package:qparkin_app/data/services/route_service.dart';
import 'package:qparkin_app/data/models/route_data.dart';
import 'package:geolocator/geolocator.dart';

/// Property-based test for MapLogger error logging
/// Tests universal properties that should hold across all valid inputs
/// 
/// **Feature: osm-map-integration, Property 13: Error Logging Consistency**
/// **Validates: Requirements 5.4**
/// 
/// Property 13: Error Logging Consistency
/// For any error that occurs during map operations, the system should log
/// the error details including error type, message, and timestamp.
@Tags(['property-test', 'Feature: osm-map-integration, Property 13'])
void main() {
  // Track logged messages for verification
  final List<String> loggedMessages = [];
  
  setUp(() {
    loggedMessages.clear();
    
    // Override debugPrint to capture log messages
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        loggedMessages.add(message);
      }
    };
  });

  tearDown(() {
    // Restore debugPrint
    debugPrint = debugPrintSynchronously;
  });

  group('MapLogger Property Tests', () {
    test(
      'Property 13: Error Logging Consistency - '
      'For any error, system should log error details with timestamp, type, and message',
      () async {
        // Run property test with 100 iterations as specified in design
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          // Generate random error data
          final errorType = _generateRandomErrorType();
          final message = _generateRandomErrorMessage();
          final context = _generateRandomContext();

          // Log the error
          logger.logError(errorType, message, context);

          // Verify log was created
          expect(loggedMessages, isNotEmpty,
              reason: 'Error should be logged');

          // Combine all logged messages into one string for verification
          final fullLog = loggedMessages.join('\n');

          // Verify log contains timestamp (ISO 8601 format)
          final timestampRegex = RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}');
          expect(timestampRegex.hasMatch(fullLog), isTrue,
              reason: 'Log should contain ISO 8601 timestamp');

          // Verify log contains error type
          expect(fullLog.contains(errorType), isTrue,
              reason: 'Log should contain error type: $errorType');

          // Verify log contains error message
          expect(fullLog.contains(message), isTrue,
              reason: 'Log should contain error message');

          // Verify log contains context
          expect(fullLog.contains(context), isTrue,
              reason: 'Log should contain context');

          // Verify log contains log level (ERROR)
          expect(fullLog.contains('ERROR'), isTrue,
              reason: 'Log should contain ERROR level');

          // Verify log contains device info section
          expect(fullLog.contains('Device:'), isTrue,
              reason: 'Log should contain device information');

          // Verify log contains app version section
          expect(fullLog.contains('App Version:'), isTrue,
              reason: 'Log should contain app version');
        }
      },
    );

    test(
      'Property: Location permission errors should be logged with permission status',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final message = 'Location permission denied';
          final context = 'MapProvider.getCurrentLocation';
          final permissionStatus = _generateRandomPermissionStatus();

          // Log location permission error
          logger.logLocationPermissionError(
            message,
            context,
            permissionStatus: permissionStatus,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify error type is correct
          expect(fullLog.contains('LOCATION_PERMISSION_ERROR'), isTrue,
              reason: 'Log should contain LOCATION_PERMISSION_ERROR type');

          // Verify permission status is logged
          expect(fullLog.contains(permissionStatus), isTrue,
              reason: 'Log should contain permission status: $permissionStatus');

          // Verify message and context are logged
          expect(fullLog.contains(message), isTrue);
          expect(fullLog.contains(context), isTrue);
        }
      },
    );

    test(
      'Property: GPS/location service errors should be logged with service status',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final message = 'Location services are disabled';
          final context = 'LocationService.getCurrentPosition';
          final serviceEnabled = i % 2 == 0; // Alternate true/false

          // Log location service error
          logger.logLocationServiceError(
            message,
            context,
            serviceEnabled: serviceEnabled,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify error type is correct
          expect(fullLog.contains('LOCATION_SERVICE_ERROR'), isTrue,
              reason: 'Log should contain LOCATION_SERVICE_ERROR type');

          // Verify service status is logged
          expect(fullLog.contains('serviceEnabled'), isTrue,
              reason: 'Log should contain serviceEnabled field');
          expect(fullLog.contains(serviceEnabled.toString()), isTrue,
              reason: 'Log should contain service status value');
        }
      },
    );

    test(
      'Property: Network errors should be logged with status code and URL',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final message = 'Network request failed';
          final context = 'RouteService.calculateRoute';
          final statusCode = _generateRandomStatusCode();
          final url = _generateRandomUrl();

          // Log network error
          logger.logNetworkError(
            message,
            context,
            statusCode: statusCode,
            url: url,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify error type is correct
          expect(fullLog.contains('NETWORK_ERROR'), isTrue,
              reason: 'Log should contain NETWORK_ERROR type');

          // Verify status code is logged
          expect(fullLog.contains(statusCode.toString()), isTrue,
              reason: 'Log should contain status code: $statusCode');

          // Verify URL is logged
          expect(fullLog.contains(url), isTrue,
              reason: 'Log should contain URL: $url');
        }
      },
    );

    test(
      'Property: Route calculation errors should be logged with coordinates',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final message = 'Route calculation failed';
          final context = 'RouteService.calculateRoute';
          final origin = _generateRandomBatamLocation();
          final destination = _generateRandomBatamLocation();

          // Log route calculation error
          logger.logRouteCalculationError(
            message,
            context,
            originLat: origin.latitude,
            originLng: origin.longitude,
            destLat: destination.latitude,
            destLng: destination.longitude,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify error type is correct
          expect(fullLog.contains('ROUTE_CALCULATION_ERROR'), isTrue,
              reason: 'Log should contain ROUTE_CALCULATION_ERROR type');

          // Verify coordinates are logged
          expect(fullLog.contains('originLat'), isTrue,
              reason: 'Log should contain origin latitude');
          expect(fullLog.contains('originLng'), isTrue,
              reason: 'Log should contain origin longitude');
          expect(fullLog.contains('destLat'), isTrue,
              reason: 'Log should contain destination latitude');
          expect(fullLog.contains('destLng'), isTrue,
              reason: 'Log should contain destination longitude');

          // Verify coordinate values are present
          expect(fullLog.contains(origin.latitude.toString()), isTrue);
          expect(fullLog.contains(origin.longitude.toString()), isTrue);
          expect(fullLog.contains(destination.latitude.toString()), isTrue);
          expect(fullLog.contains(destination.longitude.toString()), isTrue);
        }
      },
    );

    test(
      'Property: State management errors should be logged with state and action',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final message = 'Invalid state transition';
          final context = 'MapProvider.selectMall';
          final currentState = _generateRandomState();
          final attemptedAction = _generateRandomAction();

          // Log state management error
          logger.logStateManagementError(
            message,
            context,
            currentState: currentState,
            attemptedAction: attemptedAction,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify error type is correct
          expect(fullLog.contains('STATE_MANAGEMENT_ERROR'), isTrue,
              reason: 'Log should contain STATE_MANAGEMENT_ERROR type');

          // Verify state and action are logged
          expect(fullLog.contains('currentState'), isTrue,
              reason: 'Log should contain currentState field');
          expect(fullLog.contains('attemptedAction'), isTrue,
              reason: 'Log should contain attemptedAction field');
          expect(fullLog.contains(currentState), isTrue,
              reason: 'Log should contain state value');
          expect(fullLog.contains(attemptedAction), isTrue,
              reason: 'Log should contain action value');
        }
      },
    );

    test(
      'Property: Warning logs should contain WARNING level',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final warningType = 'PERFORMANCE_WARNING';
          final message = 'Map rendering slow';
          final context = 'MapView.render';

          // Log warning
          logger.logWarning(warningType, message, context);

          final fullLog = loggedMessages.join('\n');

          // Verify log contains WARNING level
          expect(fullLog.contains('WARNING'), isTrue,
              reason: 'Log should contain WARNING level');

          // Verify warning type, message, and context
          expect(fullLog.contains(warningType), isTrue);
          expect(fullLog.contains(message), isTrue);
          expect(fullLog.contains(context), isTrue);
        }
      },
    );

    test(
      'Property: Info logs should contain INFO level',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final infoType = 'MAP_OPERATION';
          final message = 'Map initialized successfully';
          final context = 'MapProvider.initializeMap';

          // Log info
          logger.logInfo(infoType, message, context);

          final fullLog = loggedMessages.join('\n');

          // Verify log contains INFO level
          expect(fullLog.contains('INFO'), isTrue,
              reason: 'Log should contain INFO level');

          // Verify info type, message, and context
          expect(fullLog.contains(infoType), isTrue);
          expect(fullLog.contains(message), isTrue);
          expect(fullLog.contains(context), isTrue);
        }
      },
    );

    test(
      'Property: Logs with stack traces should include stack trace information',
      () async {
        const int iterations = 50;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final errorType = 'TEST_ERROR';
          final message = 'Test error with stack trace';
          final context = 'TestContext';
          
          // Create a stack trace
          StackTrace? stackTrace;
          try {
            throw Exception('Test exception');
          } catch (e, st) {
            stackTrace = st;
          }

          // Log error with stack trace
          logger.logError(
            errorType,
            message,
            context,
            stackTrace: stackTrace,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify log contains stack trace section
          expect(fullLog.contains('Stack Trace:'), isTrue,
              reason: 'Log should contain Stack Trace section');

          // Verify stack trace has some content
          final stackTraceIndex = fullLog.indexOf('Stack Trace:');
          expect(stackTraceIndex, greaterThan(-1));
          final afterStackTrace = fullLog.substring(stackTraceIndex);
          expect(afterStackTrace.length, greaterThan(20),
              reason: 'Stack trace should have content');
        }
      },
    );

    test(
      'Property: Logs with additional data should include all key-value pairs',
      () async {
        const int iterations = 100;
        final logger = MapLogger.instance;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          final errorType = 'TEST_ERROR';
          final message = 'Test error with additional data';
          final context = 'TestContext';
          
          // Generate random additional data
          final additionalData = {
            'key1': _generateRandomString(),
            'key2': _generateRandomNumber(),
            'key3': _generateRandomBool(),
          };

          // Log error with additional data
          logger.logError(
            errorType,
            message,
            context,
            additionalData: additionalData,
          );

          final fullLog = loggedMessages.join('\n');

          // Verify log contains additional data section
          expect(fullLog.contains('Additional Data:'), isTrue,
              reason: 'Log should contain Additional Data section');

          // Verify all keys and values are present
          additionalData.forEach((key, value) {
            expect(fullLog.contains(key), isTrue,
                reason: 'Log should contain key: $key');
            expect(fullLog.contains(value.toString()), isTrue,
                reason: 'Log should contain value: $value');
          });
        }
      },
    );
  });

  group('Integration with MapProvider', () {
    test(
      'Property: MapProvider errors should trigger logging',
      () async {
        const int iterations = 50;

        for (int i = 0; i < iterations; i++) {
          loggedMessages.clear();

          // Create provider with mock service that throws error
          final mockLocationService = MockLocationServiceWithErrors();
          mockLocationService.shouldThrowPermissionError = true;
          final provider = MapProvider(locationService: mockLocationService);

          try {
            // Trigger an error
            await provider.getCurrentLocation();
          } catch (e) {
            // Error expected
          }

          // Verify logging occurred
          final fullLog = loggedMessages.join('\n');
          
          // Should contain error log
          expect(fullLog.contains('ERROR') || fullLog.contains('LOCATION'), isTrue,
              reason: 'Error should be logged when MapProvider encounters error');

          provider.dispose();
        }
      },
    );
  });
}

// Helper functions for generating random test data

String _generateRandomErrorType() {
  final types = [
    'NETWORK_ERROR',
    'LOCATION_ERROR',
    'ROUTE_ERROR',
    'STATE_ERROR',
    'PERMISSION_ERROR',
  ];
  return types[Random().nextInt(types.length)];
}

String _generateRandomErrorMessage() {
  final messages = [
    'Connection timeout',
    'Invalid coordinates',
    'Permission denied',
    'Service unavailable',
    'Unknown error occurred',
  ];
  return messages[Random().nextInt(messages.length)];
}

String _generateRandomContext() {
  final contexts = [
    'MapProvider.initializeMap',
    'LocationService.getCurrentPosition',
    'RouteService.calculateRoute',
    'MapView.render',
    'MapProvider.selectMall',
  ];
  return contexts[Random().nextInt(contexts.length)];
}

String _generateRandomPermissionStatus() {
  final statuses = ['denied', 'denied_forever', 'granted', 'restricted'];
  return statuses[Random().nextInt(statuses.length)];
}

int _generateRandomStatusCode() {
  final codes = [400, 401, 403, 404, 500, 502, 503, 504];
  return codes[Random().nextInt(codes.length)];
}

String _generateRandomUrl() {
  final urls = [
    'https://router.project-osrm.org/route/v1/driving',
    'https://api.example.com/malls',
    'https://maps.googleapis.com/maps/api',
  ];
  return urls[Random().nextInt(urls.length)];
}

GeoPoint _generateRandomBatamLocation() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2; // 1.0 to 1.2
  final lng = 103.9 + random.nextDouble() * 0.2; // 103.9 to 104.1
  return GeoPoint(latitude: lat, longitude: lng);
}

String _generateRandomState() {
  final states = [
    'initializing',
    'loading',
    'ready',
    'error',
    'selecting',
  ];
  return states[Random().nextInt(states.length)];
}

String _generateRandomAction() {
  final actions = [
    'initialize map',
    'load malls',
    'get location',
    'calculate route',
    'select mall',
  ];
  return actions[Random().nextInt(actions.length)];
}

String _generateRandomString() {
  final strings = ['test', 'value', 'data', 'info', 'detail'];
  return strings[Random().nextInt(strings.length)];
}

int _generateRandomNumber() {
  return Random().nextInt(1000);
}

bool _generateRandomBool() {
  return Random().nextBool();
}

/// Mock LocationService that throws errors for testing
class MockLocationServiceWithErrors extends LocationService {
  bool shouldThrowGpsError = false;
  bool shouldThrowPermissionError = false;

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (shouldThrowGpsError) {
      return false;
    }
    return true;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    if (shouldThrowPermissionError) {
      return LocationPermission.denied;
    }
    return LocationPermission.whileInUse;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (shouldThrowPermissionError) {
      return LocationPermission.denied;
    }
    return LocationPermission.whileInUse;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (shouldThrowGpsError) {
      throw QParkinLocationServiceDisabledException('GPS disabled');
    }
    if (shouldThrowPermissionError) {
      throw QParkinPermissionDeniedException('Permission denied');
    }
    return Position(
      latitude: 1.1,
      longitude: 104.0,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}
