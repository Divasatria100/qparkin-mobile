import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:qparkin_app/data/models/route_data.dart';

void main() {
  group('RouteData Unit Tests', () {
    test('constructor creates model with all fields', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
        GeoPoint(latitude: 1.1304, longitude: 104.0534),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      expect(routeData.polylinePoints.length, equals(2));
      expect(routeData.distanceInKm, equals(2.5));
      expect(routeData.durationInMinutes, equals(15));
    });

    test('constructor throws ArgumentError for negative distance', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      expect(
        () => RouteData(
          polylinePoints: polylinePoints,
          distanceInKm: -1.0,
          durationInMinutes: 15,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('constructor throws ArgumentError for negative duration', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      expect(
        () => RouteData(
          polylinePoints: polylinePoints,
          distanceInKm: 2.5,
          durationInMinutes: -5,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('constructor accepts zero distance', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 0.0,
        durationInMinutes: 0,
      );

      expect(routeData.distanceInKm, equals(0.0));
      expect(routeData.durationInMinutes, equals(0));
    });

    test('validate returns true for valid route data', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
        GeoPoint(latitude: 1.1304, longitude: 104.0534),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      expect(routeData.validate(), isTrue);
    });

    test('validate returns false for empty polyline points', () {
      final routeData = RouteData(
        polylinePoints: [],
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      expect(routeData.validate(), isFalse);
    });

    test('formattedDistance returns meters for distance < 1 km', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 0.5,
        durationInMinutes: 5,
      );

      expect(routeData.formattedDistance, equals('500 m'));
    });

    test('formattedDistance returns kilometers for distance >= 1 km', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      expect(routeData.formattedDistance, equals('2.5 km'));
    });

    test('formattedDuration returns minutes for duration < 60', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 2.5,
        durationInMinutes: 45,
      );

      expect(routeData.formattedDuration, equals('45 menit'));
    });

    test('formattedDuration returns hours for duration >= 60 with no remaining minutes', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 50.0,
        durationInMinutes: 120,
      );

      expect(routeData.formattedDuration, equals('2 jam'));
    });

    test('formattedDuration returns hours and minutes for duration >= 60 with remaining minutes', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 50.0,
        durationInMinutes: 135,
      );

      expect(routeData.formattedDuration, equals('2 jam 15 menit'));
    });

    test('fromJson creates model with all fields', () {
      final json = {
        'polyline_points': [
          {'latitude': 1.1191, 'longitude': 104.0538},
          {'latitude': 1.1304, 'longitude': 104.0534},
        ],
        'distance_in_km': 2.5,
        'duration_in_minutes': 15,
      };

      final routeData = RouteData.fromJson(json);

      expect(routeData.polylinePoints.length, equals(2));
      expect(routeData.polylinePoints[0].latitude, equals(1.1191));
      expect(routeData.polylinePoints[0].longitude, equals(104.0538));
      expect(routeData.distanceInKm, equals(2.5));
      expect(routeData.durationInMinutes, equals(15));
    });

    test('fromJson handles empty polyline points', () {
      final json = {
        'polyline_points': [],
        'distance_in_km': 0.0,
        'duration_in_minutes': 0,
      };

      final routeData = RouteData.fromJson(json);

      expect(routeData.polylinePoints.length, equals(0));
    });

    test('fromJson parses double from string', () {
      final json = {
        'polyline_points': [
          {'latitude': '1.1191', 'longitude': '104.0538'},
        ],
        'distance_in_km': '2.5',
        'duration_in_minutes': '15',
      };

      final routeData = RouteData.fromJson(json);

      expect(routeData.polylinePoints[0].latitude, equals(1.1191));
      expect(routeData.distanceInKm, equals(2.5));
      expect(routeData.durationInMinutes, equals(15));
    });

    test('fromJson parses double from int', () {
      final json = {
        'polyline_points': [
          {'latitude': 1, 'longitude': 104},
        ],
        'distance_in_km': 2,
        'duration_in_minutes': 15,
      };

      final routeData = RouteData.fromJson(json);

      expect(routeData.polylinePoints[0].latitude, equals(1.0));
      expect(routeData.polylinePoints[0].longitude, equals(104.0));
      expect(routeData.distanceInKm, equals(2.0));
    });

    test('toJson creates correct JSON structure', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
        GeoPoint(latitude: 1.1304, longitude: 104.0534),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      final json = routeData.toJson();

      expect(json['polyline_points'], isA<List>());
      expect(json['polyline_points'].length, equals(2));
      expect(json['polyline_points'][0]['latitude'], equals(1.1191));
      expect(json['polyline_points'][0]['longitude'], equals(104.0538));
      expect(json['distance_in_km'], equals(2.5));
      expect(json['duration_in_minutes'], equals(15));
    });

    test('copyWith creates new instance with updated fields', () {
      final originalPoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final original = RouteData(
        polylinePoints: originalPoints,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      final updated = original.copyWith(
        distanceInKm: 3.0,
        durationInMinutes: 20,
      );

      expect(updated.distanceInKm, equals(3.0));
      expect(updated.durationInMinutes, equals(20));
      expect(updated.polylinePoints, equals(originalPoints));
      expect(original.distanceInKm, equals(2.5));
    });

    test('equality operator works correctly', () {
      final points = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
        GeoPoint(latitude: 1.1304, longitude: 104.0534),
      ];

      final route1 = RouteData(
        polylinePoints: points,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      final route2 = RouteData(
        polylinePoints: points,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      expect(route1, equals(route2));
    });

    test('equality operator returns false for different routes', () {
      final points1 = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final points2 = [
        GeoPoint(latitude: 1.1304, longitude: 104.0534),
      ];

      final route1 = RouteData(
        polylinePoints: points1,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      final route2 = RouteData(
        polylinePoints: points2,
        distanceInKm: 3.0,
        durationInMinutes: 20,
      );

      expect(route1, isNot(equals(route2)));
    });

    test('hashCode is consistent with equality', () {
      final points = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      final route1 = RouteData(
        polylinePoints: points,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      final route2 = RouteData(
        polylinePoints: points,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      expect(route1.hashCode, equals(route2.hashCode));
    });

    test('toString returns formatted string', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
        GeoPoint(latitude: 1.1304, longitude: 104.0534),
      ];

      final routeData = RouteData(
        polylinePoints: polylinePoints,
        distanceInKm: 2.5,
        durationInMinutes: 15,
      );

      final str = routeData.toString();

      expect(str, contains('2 points'));
      expect(str, contains('2.5'));
      expect(str, contains('15'));
    });
  });

  group('RouteData Validation Tests', () {
    test('positive distance validation - accepts valid positive values', () {
      for (int i = 0; i < 10; i++) {
        final distance = Random().nextDouble() * 100; // 0 to 100 km
        final polylinePoints = [
          GeoPoint(latitude: 1.1191, longitude: 104.0538),
        ];

        final routeData = RouteData(
          polylinePoints: polylinePoints,
          distanceInKm: distance,
          durationInMinutes: 10,
        );

        expect(routeData.distanceInKm, greaterThanOrEqualTo(0));
      }
    });

    test('positive duration validation - accepts valid positive values', () {
      for (int i = 0; i < 10; i++) {
        final duration = Random().nextInt(200); // 0 to 200 minutes
        final polylinePoints = [
          GeoPoint(latitude: 1.1191, longitude: 104.0538),
        ];

        final routeData = RouteData(
          polylinePoints: polylinePoints,
          distanceInKm: 5.0,
          durationInMinutes: duration,
        );

        expect(routeData.durationInMinutes, greaterThanOrEqualTo(0));
      }
    });

    test('negative distance validation - rejects negative values', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      expect(
        () => RouteData(
          polylinePoints: polylinePoints,
          distanceInKm: -0.1,
          durationInMinutes: 10,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('negative duration validation - rejects negative values', () {
      final polylinePoints = [
        GeoPoint(latitude: 1.1191, longitude: 104.0538),
      ];

      expect(
        () => RouteData(
          polylinePoints: polylinePoints,
          distanceInKm: 5.0,
          durationInMinutes: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
