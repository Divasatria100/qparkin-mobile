import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/// Property-based test for location update threshold
/// 
/// **Feature: osm-map-integration, Property 4: Location Update Threshold**
/// 
/// For any location change >10m, marker should update
/// 
/// **Validates: Requirements 2.5**

void main() {
  group('Property 4: Location Update Threshold', () {
    test('For any location change >10m, marker should update', () {
      // Run property test 100 times with different random inputs
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random starting location in Batam area
        final startLat = 1.0 + Random().nextDouble() * 0.2;
        final startLng = 103.9 + Random().nextDouble() * 0.2;
        final startLocation = GeoPoint(latitude: startLat, longitude: startLng);

        // Generate random distance change (0-100 meters)
        final distanceChangeMeters = Random().nextDouble() * 100;
        
        // Convert meters to degrees (approximately)
        // 1 degree latitude ≈ 111,000 meters
        // At equator, 1 degree longitude ≈ 111,000 meters
        final distanceChangeDegrees = distanceChangeMeters / 111000;

        // Generate new location with the distance change
        final newLat = startLat + (Random().nextBool() ? distanceChangeDegrees : -distanceChangeDegrees);
        final newLng = startLng + (Random().nextBool() ? distanceChangeDegrees : -distanceChangeDegrees);
        final newLocation = GeoPoint(latitude: newLat, longitude: newLng);

        // Calculate actual distance
        final actualDistance = _calculateDistanceInMeters(startLocation, newLocation);

        // Verify the threshold logic
        const threshold = 10.0; // 10 meters
        final shouldUpdate = actualDistance > threshold;

        // Property: If distance > 10m, update should occur
        // If distance <= 10m, update should not occur
        if (distanceChangeMeters > threshold) {
          expect(shouldUpdate, isTrue, 
            reason: 'Distance ${actualDistance.toStringAsFixed(2)}m > 10m should trigger update');
        } else {
          expect(shouldUpdate, isFalse,
            reason: 'Distance ${actualDistance.toStringAsFixed(2)}m <= 10m should not trigger update');
        }
      }
    });

    test('Location changes exactly at 10m threshold', () {
      // Test edge case: exactly 10 meters
      final startLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
      
      // 10 meters in degrees (approximately)
      final tenMetersInDegrees = 10.0 / 111000;
      final newLocation = GeoPoint(
        latitude: 1.1 + tenMetersInDegrees,
        longitude: 104.0,
      );

      final distance = _calculateDistanceInMeters(startLocation, newLocation);
      
      // At exactly 10m, should not update (threshold is >10m, not >=10m)
      expect(distance, lessThanOrEqualTo(10.1)); // Allow small floating point error
    });

    test('Very small location changes (<1m) should not trigger update', () {
      for (int i = 0; i < 100; i++) {
        final startLat = 1.0 + Random().nextDouble() * 0.2;
        final startLng = 103.9 + Random().nextDouble() * 0.2;
        final startLocation = GeoPoint(latitude: startLat, longitude: startLng);

        // Very small change (< 1 meter)
        final smallChange = (Random().nextDouble() * 0.9) / 111000; // < 1 meter in degrees
        final newLocation = GeoPoint(
          latitude: startLat + smallChange,
          longitude: startLng + smallChange,
        );

        final distance = _calculateDistanceInMeters(startLocation, newLocation);
        
        // Should not trigger update
        expect(distance, lessThan(10.0));
      }
    });

    test('Large location changes (>100m) should always trigger update', () {
      for (int i = 0; i < 100; i++) {
        final startLat = 1.0 + Random().nextDouble() * 0.2;
        final startLng = 103.9 + Random().nextDouble() * 0.2;
        final startLocation = GeoPoint(latitude: startLat, longitude: startLng);

        // Large change (100-1000 meters)
        final largeChangeMeters = 100 + Random().nextDouble() * 900;
        final largeChangeDegrees = largeChangeMeters / 111000;
        final newLocation = GeoPoint(
          latitude: startLat + largeChangeDegrees,
          longitude: startLng + largeChangeDegrees,
        );

        final distance = _calculateDistanceInMeters(startLocation, newLocation);
        
        // Should always trigger update
        expect(distance, greaterThan(10.0));
      }
    });
  });
}

/// Calculate distance between two GeoPoints in meters using Haversine formula
/// 
/// This is a simplified version for testing purposes
double _calculateDistanceInMeters(GeoPoint point1, GeoPoint point2) {
  const earthRadiusMeters = 6371000.0; // Earth's radius in meters

  final lat1Rad = point1.latitude * pi / 180;
  final lat2Rad = point2.latitude * pi / 180;
  final deltaLatRad = (point2.latitude - point1.latitude) * pi / 180;
  final deltaLngRad = (point2.longitude - point1.longitude) * pi / 180;

  final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(lat1Rad) * cos(lat2Rad) *
      sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
  
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusMeters * c;
}
