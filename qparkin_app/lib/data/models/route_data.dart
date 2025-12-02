import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/// Model representing route data between two locations.
/// 
/// Contains all information needed to display and describe a route:
/// - Polyline points for drawing the route on a map
/// - Distance in kilometers
/// - Estimated travel time in minutes
/// 
/// This model is used for:
/// - Drawing route polylines on the map
/// - Displaying route information to users
/// - Calculating estimated arrival times
/// 
/// Example:
/// ```dart
/// final routeService = RouteService();
/// final route = await routeService.calculateRoute(origin, destination);
/// 
/// // Display route info
/// print('Distance: ${route.formattedDistance}');
/// print('Duration: ${route.formattedDuration}');
/// 
/// // Draw on map
/// await mapController.drawRoad(
///   route.polylinePoints.first,
///   route.polylinePoints.last,
/// );
/// ```
class RouteData {
  final List<GeoPoint> polylinePoints;
  final double distanceInKm;
  final int durationInMinutes;

  RouteData({
    required this.polylinePoints,
    required this.distanceInKm,
    required this.durationInMinutes,
  }) {
    // Validate that distance and duration are positive
    if (distanceInKm < 0) {
      throw ArgumentError('Distance must be positive, got: $distanceInKm');
    }
    if (durationInMinutes < 0) {
      throw ArgumentError('Duration must be positive, got: $durationInMinutes');
    }
  }

  /// Check if route data is valid.
  /// 
  /// Validates that:
  /// - Polyline points list is not empty
  /// - Distance is not negative
  /// - Duration is not negative
  /// 
  /// Returns:
  ///   `true` if all validation checks pass, `false` otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final route = RouteData.fromJson(jsonData);
  /// if (!route.validate()) {
  ///   print('Invalid route data');
  /// }
  /// ```
  bool validate() {
    if (polylinePoints.isEmpty) return false;
    if (distanceInKm < 0) return false;
    if (durationInMinutes < 0) return false;
    return true;
  }

  /// Get formatted distance string in Indonesian.
  /// 
  /// Returns a user-friendly distance string:
  /// - "X m" for distances less than 1 km
  /// - "X.X km" for distances 1 km or more
  /// 
  /// Example:
  /// ```dart
  /// final route = RouteData(..., distanceInKm: 1.5, ...);
  /// print(route.formattedDistance); // "1.5 km"
  /// 
  /// final shortRoute = RouteData(..., distanceInKm: 0.5, ...);
  /// print(shortRoute.formattedDistance); // "500 m"
  /// ```
  String get formattedDistance {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Get formatted duration string in Indonesian.
  /// 
  /// Returns a user-friendly duration string:
  /// - "X menit" for durations less than 60 minutes
  /// - "X jam" for exact hours
  /// - "X jam Y menit" for hours with remaining minutes
  /// 
  /// Example:
  /// ```dart
  /// final route = RouteData(..., durationInMinutes: 45, ...);
  /// print(route.formattedDuration); // "45 menit"
  /// 
  /// final longRoute = RouteData(..., durationInMinutes: 90, ...);
  /// print(longRoute.formattedDuration); // "1 jam 30 menit"
  /// ```
  String get formattedDuration {
    if (durationInMinutes < 60) {
      return '$durationInMinutes menit';
    } else {
      final hours = durationInMinutes ~/ 60;
      final minutes = durationInMinutes % 60;
      if (minutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $minutes menit';
      }
    }
  }

  /// Create [RouteData] from JSON.
  /// 
  /// Deserializes route data from a JSON map. Handles various data types
  /// and provides safe parsing with default values.
  /// 
  /// Parameters:
  ///   - [json]: Map containing route data
  /// 
  /// Returns:
  ///   A new [RouteData] instance.
  /// 
  /// Example:
  /// ```dart
  /// final json = {
  ///   'polyline_points': [
  ///     {'latitude': 1.1191, 'longitude': 104.0538},
  ///     {'latitude': 1.1200, 'longitude': 104.0540}
  ///   ],
  ///   'distance_in_km': 1.5,
  ///   'duration_in_minutes': 5
  /// };
  /// final route = RouteData.fromJson(json);
  /// ```
  factory RouteData.fromJson(Map<String, dynamic> json) {
    final polylinePointsJson = json['polyline_points'] as List<dynamic>? ?? [];
    final polylinePoints = polylinePointsJson.map((point) {
      if (point is Map<String, dynamic>) {
        return GeoPoint(
          latitude: _parseDouble(point['latitude']),
          longitude: _parseDouble(point['longitude']),
        );
      }
      return GeoPoint(latitude: 0, longitude: 0);
    }).toList();

    return RouteData(
      polylinePoints: polylinePoints,
      distanceInKm: _parseDouble(json['distance_in_km']),
      durationInMinutes: _parseInt(json['duration_in_minutes']),
    );
  }

  /// Convert [RouteData] to JSON.
  /// 
  /// Serializes the route data to a JSON-compatible map.
  /// 
  /// Returns:
  ///   A [Map] containing all route properties.
  /// 
  /// Example:
  /// ```dart
  /// final route = RouteData(...);
  /// final json = route.toJson();
  /// final jsonString = jsonEncode(json);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'polyline_points': polylinePoints.map((point) {
        return {
          'latitude': point.latitude,
          'longitude': point.longitude,
        };
      }).toList(),
      'distance_in_km': distanceInKm,
      'duration_in_minutes': durationInMinutes,
    };
  }

  /// Helper method to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper method to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Create a copy of this model with updated fields.
  /// 
  /// Returns a new [RouteData] instance with the same values as this instance,
  /// except for any fields explicitly provided as parameters.
  /// 
  /// Parameters:
  ///   All parameters are optional. Only provided parameters will be updated.
  /// 
  /// Returns:
  ///   A new [RouteData] with updated values.
  /// 
  /// Example:
  /// ```dart
  /// final route = RouteData(...);
  /// final updatedRoute = route.copyWith(durationInMinutes: 10);
  /// ```
  RouteData copyWith({
    List<GeoPoint>? polylinePoints,
    double? distanceInKm,
    int? durationInMinutes,
  }) {
    return RouteData(
      polylinePoints: polylinePoints ?? this.polylinePoints,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteData &&
        _listEquals(other.polylinePoints, polylinePoints) &&
        other.distanceInKm == distanceInKm &&
        other.durationInMinutes == durationInMinutes;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(polylinePoints.map((p) => Object.hash(p.latitude, p.longitude))),
      distanceInKm,
      durationInMinutes,
    );
  }

  @override
  String toString() {
    return 'RouteData(polylinePoints: ${polylinePoints.length} points, '
        'distanceInKm: $distanceInKm, durationInMinutes: $durationInMinutes)';
  }

  /// Helper method to compare lists of GeoPoints
  static bool _listEquals(List<GeoPoint> a, List<GeoPoint> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude || a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }
}
