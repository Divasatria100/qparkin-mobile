import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import '../models/route_data.dart';
import '../../utils/map_logger.dart';

/// Service for calculating routes between two geographic points
/// Uses OpenStreetMap routing service (OSRM) for route calculation
/// 
/// TODO: API Integration - Optional backend routing service
/// 
/// Current implementation uses public OSRM API for route calculation.
/// For production, consider using a backend routing service for:
/// - Better control over routing logic
/// - Custom routing preferences (avoid tolls, prefer highways, etc.)
/// - Rate limiting and caching
/// - Integration with real-time traffic data
/// 
/// Backend API endpoint (if implemented): POST /api/routes/calculate
/// Expected request format:
/// ```json
/// {
///   "origin": {"latitude": 1.1191, "longitude": 104.0538},
///   "destination": {"latitude": 1.1304, "longitude": 104.0534}
/// }
/// ```
/// 
/// Expected response format:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "polyline_points": [
///       {"latitude": 1.1191, "longitude": 104.0538},
///       {"latitude": 1.1200, "longitude": 104.0540}
///     ],
///     "distance_in_km": 1.5,
///     "duration_in_minutes": 5
///   }
/// }
/// ```
/// 
/// To integrate backend routing:
/// 1. Add a flag to switch between OSRM and backend routing
/// 2. Implement _calculateRouteFromBackend() method
/// 3. Use backend routing when available, fallback to OSRM
class RouteService {
  // OSRM (Open Source Routing Machine) API endpoint
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';
  
  // TODO: Add backend routing URL when available
  // static const String _backendRoutingUrl = '$API_URL/api/routes/calculate';
  
  // Logger instance
  final MapLogger _logger = MapLogger.instance;

  /// Calculate route between two points using OSM routing.
  /// 
  /// Uses the OSRM (Open Source Routing Machine) API to calculate the optimal
  /// driving route between two geographic points. Returns detailed route
  /// information including polyline points for visualization, distance, and
  /// estimated travel time.
  /// 
  /// Parameters:
  ///   - [origin]: Starting point of the route as a [GeoPoint]
  ///   - [destination]: End point of the route as a [GeoPoint]
  /// 
  /// Returns:
  ///   A [Future] that completes with [RouteData] containing:
  ///   - Polyline points for drawing the route on the map
  ///   - Distance in kilometers
  ///   - Estimated duration in minutes
  /// 
  /// Throws:
  ///   - [RouteCalculationException] if route calculation fails
  ///   - [NetworkException] if network request fails or times out
  ///   - [InvalidCoordinatesException] if coordinates are out of valid range
  /// 
  /// Example:
  /// ```dart
  /// final routeService = RouteService();
  /// final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
  /// final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);
  /// 
  /// try {
  ///   final route = await routeService.calculateRoute(origin, destination);
  ///   print('Distance: ${route.formattedDistance}');
  ///   print('Duration: ${route.formattedDuration}');
  ///   print('Polyline points: ${route.polylinePoints.length}');
  /// } on NetworkException {
  ///   print('No internet connection');
  /// } on RouteCalculationException catch (e) {
  ///   print('Route calculation failed: $e');
  /// }
  /// ```
  Future<RouteData> calculateRoute(
    GeoPoint origin,
    GeoPoint destination,
  ) async {
    try {
      // Validate coordinates
      _validateCoordinates(origin, destination);

      // Build OSRM API URL
      // Format: /route/v1/driving/{longitude},{latitude};{longitude},{latitude}
      final url = Uri.parse(
        '$_osrmBaseUrl/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson',
      );

      // Make HTTP request with timeout
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.logNetworkError(
            'Route calculation request timed out',
            'RouteService.calculateRoute',
            url: url.toString(),
          );
          throw NetworkException('Route calculation request timed out');
        },
      );

      // Check response status
      if (response.statusCode != 200) {
        _logger.logNetworkError(
          'Failed to calculate route: HTTP ${response.statusCode}',
          'RouteService.calculateRoute',
          statusCode: response.statusCode,
          url: url.toString(),
        );
        throw RouteCalculationException(
          'Failed to calculate route: HTTP ${response.statusCode}',
        );
      }

      // Parse response
      final data = json.decode(response.body) as Map<String, dynamic>;

      // Check if route was found
      if (data['code'] != 'Ok') {
        _logger.logRouteCalculationError(
          'Route calculation failed: ${data['code']}',
          'RouteService.calculateRoute',
          originLat: origin.latitude,
          originLng: origin.longitude,
          destLat: destination.latitude,
          destLng: destination.longitude,
        );
        throw RouteCalculationException(
          'Route calculation failed: ${data['code']}',
        );
      }

      // Extract route data
      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        _logger.logRouteCalculationError(
          'No route found',
          'RouteService.calculateRoute',
          originLat: origin.latitude,
          originLng: origin.longitude,
          destLat: destination.latitude,
          destLng: destination.longitude,
        );
        throw RouteCalculationException('No route found');
      }

      final route = routes[0] as Map<String, dynamic>;

      // Extract polyline points from GeoJSON geometry
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final polylinePoints = coordinates.map((coord) {
        final coordList = coord as List<dynamic>;
        // GeoJSON format is [longitude, latitude]
        return GeoPoint(
          latitude: (coordList[1] as num).toDouble(),
          longitude: (coordList[0] as num).toDouble(),
        );
      }).toList();

      // Extract distance (in meters) and duration (in seconds)
      final distanceInMeters = (route['distance'] as num).toDouble();
      final durationInSeconds = (route['duration'] as num).toDouble();

      // Convert to kilometers and minutes
      final distanceInKm = distanceInMeters / 1000.0;
      final durationInMinutes = (durationInSeconds / 60.0).ceil();

      return RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: distanceInKm,
        durationInMinutes: durationInMinutes,
      );
    } on RouteCalculationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.logError(
        'ROUTE_CALCULATION_ERROR',
        'Unexpected error during route calculation: $e',
        'RouteService.calculateRoute',
        stackTrace: stackTrace,
        additionalData: {
          'originLat': origin.latitude,
          'originLng': origin.longitude,
          'destLat': destination.latitude,
          'destLng': destination.longitude,
        },
      );
      throw RouteCalculationException(
        'Unexpected error during route calculation: $e',
      );
    }
  }

  /// Extract polyline points from [RouteData].
  /// 
  /// Convenience method to get the list of geographic points that make up
  /// the route path. These points can be used to draw the route on a map.
  /// 
  /// Parameters:
  ///   - [route]: [RouteData] object containing route information
  /// 
  /// Returns:
  ///   A [List] of [GeoPoint] objects representing the route path in order
  ///   from origin to destination.
  /// 
  /// Example:
  /// ```dart
  /// final routeService = RouteService();
  /// final route = await routeService.calculateRoute(origin, destination);
  /// final polyline = routeService.getRoutePolyline(route);
  /// 
  /// // Draw polyline on map
  /// await mapController.drawRoad(
  ///   polyline.first,
  ///   polyline.last,
  ///   roadOption: RoadOption(roadColor: Colors.blue),
  /// );
  /// ```
  List<GeoPoint> getRoutePolyline(RouteData route) {
    return route.polylinePoints;
  }

  /// Validate that coordinates are within valid ranges
  /// 
  /// @param origin Starting point
  /// @param destination End point
  /// @throws InvalidCoordinatesException if coordinates are invalid
  void _validateCoordinates(GeoPoint origin, GeoPoint destination) {
    if (!_isValidLatitude(origin.latitude)) {
      _logger.logRouteCalculationError(
        'Invalid origin latitude: ${origin.latitude}',
        'RouteService._validateCoordinates',
        originLat: origin.latitude,
        originLng: origin.longitude,
      );
      throw InvalidCoordinatesException(
        'Invalid origin latitude: ${origin.latitude}',
      );
    }
    if (!_isValidLongitude(origin.longitude)) {
      _logger.logRouteCalculationError(
        'Invalid origin longitude: ${origin.longitude}',
        'RouteService._validateCoordinates',
        originLat: origin.latitude,
        originLng: origin.longitude,
      );
      throw InvalidCoordinatesException(
        'Invalid origin longitude: ${origin.longitude}',
      );
    }
    if (!_isValidLatitude(destination.latitude)) {
      _logger.logRouteCalculationError(
        'Invalid destination latitude: ${destination.latitude}',
        'RouteService._validateCoordinates',
        destLat: destination.latitude,
        destLng: destination.longitude,
      );
      throw InvalidCoordinatesException(
        'Invalid destination latitude: ${destination.latitude}',
      );
    }
    if (!_isValidLongitude(destination.longitude)) {
      _logger.logRouteCalculationError(
        'Invalid destination longitude: ${destination.longitude}',
        'RouteService._validateCoordinates',
        destLat: destination.latitude,
        destLng: destination.longitude,
      );
      throw InvalidCoordinatesException(
        'Invalid destination longitude: ${destination.longitude}',
      );
    }
  }

  /// Check if latitude is within valid range (-90 to 90)
  bool _isValidLatitude(double latitude) {
    return latitude >= -90.0 && latitude <= 90.0;
  }

  /// Check if longitude is within valid range (-180 to 180)
  bool _isValidLongitude(double longitude) {
    return longitude >= -180.0 && longitude <= 180.0;
  }
}

/// Exception thrown when route calculation fails
class RouteCalculationException implements Exception {
  final String message;

  RouteCalculationException(this.message);

  @override
  String toString() => 'RouteCalculationException: $message';
}

/// Exception thrown when network request fails
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when coordinates are invalid
class InvalidCoordinatesException implements Exception {
  final String message;

  InvalidCoordinatesException(this.message);

  @override
  String toString() => 'InvalidCoordinatesException: $message';
}
