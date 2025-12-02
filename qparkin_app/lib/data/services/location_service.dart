import 'dart:math';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/map_logger.dart';

/// Service for handling location-related operations
/// Provides methods for permission management, location retrieval, and distance calculations
class LocationService {
  // Logger instance
  final MapLogger _logger = MapLogger.instance;
  /// Check if location services are enabled on the device.
  /// 
  /// Returns `true` if GPS/location services are turned on, `false` otherwise.
  /// This does not check permission status, only whether the device's
  /// location services are enabled.
  /// 
  /// Returns:
  ///   A [Future] that completes with `true` if location services are enabled.
  /// 
  /// Example:
  /// ```dart
  /// final locationService = LocationService();
  /// final isEnabled = await locationService.isLocationServiceEnabled();
  /// if (!isEnabled) {
  ///   print('Please enable GPS in device settings');
  /// }
  /// ```
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check the current location permission status.
  /// 
  /// Returns the current permission state without requesting permission.
  /// Possible values:
  /// - [LocationPermission.denied]: Permission not yet requested or denied
  /// - [LocationPermission.deniedForever]: Permission permanently denied
  /// - [LocationPermission.whileInUse]: Permission granted while app is in use
  /// - [LocationPermission.always]: Permission granted always
  /// 
  /// Returns:
  ///   A [Future] that completes with the current [LocationPermission] status.
  /// 
  /// Example:
  /// ```dart
  /// final locationService = LocationService();
  /// final permission = await locationService.checkPermission();
  /// if (permission == LocationPermission.denied) {
  ///   // Request permission
  ///   await locationService.requestPermission();
  /// }
  /// ```
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from the user.
  /// 
  /// Shows the system permission dialog and returns the result.
  /// Should only be called after checking that permission is not already granted.
  /// 
  /// Returns:
  ///   A [Future] that completes with the [LocationPermission] result after
  ///   the user responds to the permission dialog.
  /// 
  /// Example:
  /// ```dart
  /// final locationService = LocationService();
  /// final permission = await locationService.requestPermission();
  /// if (permission == LocationPermission.whileInUse) {
  ///   print('Permission granted!');
  /// } else {
  ///   print('Permission denied');
  /// }
  /// ```
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get the current position of the device.
  /// 
  /// Retrieves the device's current geographic position with high accuracy.
  /// Automatically checks location services and permissions before attempting
  /// to get the position.
  /// 
  /// Returns:
  ///   A [Future] that completes with the current [Position] containing
  ///   latitude, longitude, accuracy, altitude, and other location data.
  /// 
  /// Throws:
  ///   - [LocationServiceDisabledException] if GPS is disabled
  ///   - [PermissionDeniedException] if permission is not granted
  ///   - [TimeoutException] if location cannot be obtained within 10 seconds
  /// 
  /// Example:
  /// ```dart
  /// final locationService = LocationService();
  /// try {
  ///   final position = await locationService.getCurrentPosition();
  ///   print('Lat: ${position.latitude}, Lng: ${position.longitude}');
  /// } on LocationServiceDisabledException {
  ///   print('Please enable GPS');
  /// } on PermissionDeniedException {
  ///   print('Location permission denied');
  /// }
  /// ```
  Future<Position> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.logLocationServiceError(
          'Location services are disabled',
          'LocationService.getCurrentPosition',
          serviceEnabled: false,
        );
        throw LocationServiceDisabledException();
      }

      // Check permission status
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        _logger.logLocationPermissionError(
          'Location permission denied, requesting permission',
          'LocationService.getCurrentPosition',
          permissionStatus: 'denied',
        );
        
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.logLocationPermissionError(
            'Location permission denied by user',
            'LocationService.getCurrentPosition',
            permissionStatus: 'denied_after_request',
          );
          throw QParkinPermissionDeniedException('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.logLocationPermissionError(
          'Location permissions are permanently denied',
          'LocationService.getCurrentPosition',
          permissionStatus: 'denied_forever',
        );
        throw QParkinPermissionDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // Get current position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e, stackTrace) {
      if (e is QParkinLocationServiceDisabledException || e is QParkinPermissionDeniedException) {
        rethrow;
      }
      
      _logger.logError(
        'LOCATION_ERROR',
        e.toString(),
        'LocationService.getCurrentPosition',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Convert a [Position] object to a [GeoPoint] for use with OSM.
  /// 
  /// Transforms the geolocator [Position] format to the flutter_osm_plugin
  /// [GeoPoint] format for map operations.
  /// 
  /// Parameters:
  ///   - [position]: The [Position] object from geolocator package
  /// 
  /// Returns:
  ///   A [GeoPoint] object containing the same latitude and longitude
  /// 
  /// Example:
  /// ```dart
  /// final locationService = LocationService();
  /// final position = await locationService.getCurrentPosition();
  /// final geoPoint = locationService.positionToGeoPoint(position);
  /// // Use geoPoint with OSM map
  /// await mapController.goToLocation(geoPoint);
  /// ```
  GeoPoint positionToGeoPoint(Position position) {
    return GeoPoint(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Calculate the distance between two geographic points using the Haversine formula.
  /// 
  /// Uses the Haversine formula to calculate the great-circle distance between
  /// two points on Earth's surface. This provides accurate distance calculations
  /// for geographic coordinates.
  /// 
  /// Parameters:
  ///   - [point1]: First geographic point
  ///   - [point2]: Second geographic point
  /// 
  /// Returns:
  ///   Distance in kilometers as a [double]
  /// 
  /// Example:
  /// ```dart
  /// final locationService = LocationService();
  /// final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
  /// final point2 = GeoPoint(latitude: 1.1304, longitude: 104.0534);
  /// final distance = locationService.calculateDistance(point1, point2);
  /// print('Distance: ${distance.toStringAsFixed(2)} km');
  /// ```
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    // Earth's radius in kilometers
    const double earthRadiusKm = 6371.0;

    // Convert latitude and longitude from degrees to radians
    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLonRad = _degreesToRadians(point2.longitude - point1.longitude);

    // Haversine formula
    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  /// Convert degrees to radians
  /// @param degrees Angle in degrees
  /// @return Angle in radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}

/// Exception thrown when location services are disabled
class QParkinLocationServiceDisabledException implements Exception {
  final String message;

  QParkinLocationServiceDisabledException([this.message = 'Location services are disabled']);

  @override
  String toString() => message;
}

/// Exception thrown when location permission is denied
class QParkinPermissionDeniedException implements Exception {
  final String message;

  QParkinPermissionDeniedException(this.message);

  @override
  String toString() => message;
}
