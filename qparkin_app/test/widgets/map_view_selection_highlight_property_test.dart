import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/mall_model.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';

/// Property-based test for selection visual feedback
/// 
/// **Feature: osm-map-integration, Property 6: Selection Visual Feedback**
/// 
/// For any selected mall, marker should be highlighted
/// 
/// **Validates: Requirements 3.3**

void main() {
  group('Property 6: Selection Visual Feedback', () {
    test('For any selected mall, the selection state should be tracked', () async {
      // Run property test 100 times with different random inputs
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random mall
        final mall = _generateRandomMall();

        // Create MapProvider and initialize
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        // Initially, no mall should be selected
        expect(mapProvider.selectedMall, isNull);
        expect(mapProvider.hasSelectedMall, isFalse);

        // Select the mall
        await mapProvider.selectMall(mall);

        // Verify the mall is now selected
        expect(mapProvider.selectedMall, isNotNull);
        expect(mapProvider.selectedMall, equals(mall));
        expect(mapProvider.hasSelectedMall, isTrue);

        // Verify the selected mall has the same properties
        expect(mapProvider.selectedMall!.id, equals(mall.id));
        expect(mapProvider.selectedMall!.name, equals(mall.name));
        expect(mapProvider.selectedMall!.geoPoint.latitude, equals(mall.geoPoint.latitude));
        expect(mapProvider.selectedMall!.geoPoint.longitude, equals(mall.geoPoint.longitude));

        // Clean up
        mapProvider.dispose();
      }
    });

    test('Selection should be clearable for any mall', () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final mall = _generateRandomMall();
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        // Select mall
        await mapProvider.selectMall(mall);
        expect(mapProvider.hasSelectedMall, isTrue);

        // Clear selection
        mapProvider.clearSelection();

        // Verify selection is cleared
        expect(mapProvider.selectedMall, isNull);
        expect(mapProvider.hasSelectedMall, isFalse);

        mapProvider.dispose();
      }
    });

    test('Selecting different malls should update selection state', () async {
      for (int iteration = 0; iteration < 50; iteration++) {
        final mall1 = _generateRandomMall();
        final mall2 = _generateRandomMall();
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        // Select first mall
        await mapProvider.selectMall(mall1);
        expect(mapProvider.selectedMall, equals(mall1));

        // Select second mall
        await mapProvider.selectMall(mall2);
        expect(mapProvider.selectedMall, equals(mall2));
        expect(mapProvider.selectedMall, isNot(equals(mall1)));

        mapProvider.dispose();
      }
    });

    test('Selected mall should maintain its properties', () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final mall = _generateRandomMall();
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        // Store original properties
        final originalId = mall.id;
        final originalName = mall.name;
        final originalLat = mall.latitude;
        final originalLng = mall.longitude;
        final originalSlots = mall.availableSlots;

        // Select mall
        await mapProvider.selectMall(mall);

        // Verify all properties are preserved
        expect(mapProvider.selectedMall!.id, equals(originalId));
        expect(mapProvider.selectedMall!.name, equals(originalName));
        expect(mapProvider.selectedMall!.latitude, equals(originalLat));
        expect(mapProvider.selectedMall!.longitude, equals(originalLng));
        expect(mapProvider.selectedMall!.availableSlots, equals(originalSlots));

        mapProvider.dispose();
      }
    });

    test('Selection state should be consistent across multiple operations', () async {
      for (int iteration = 0; iteration < 50; iteration++) {
        final malls = _generateRandomMalls(5);
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        // Test selecting each mall in sequence
        for (final mall in malls) {
          await mapProvider.selectMall(mall);
          
          // Verify selection is correct
          expect(mapProvider.hasSelectedMall, isTrue);
          expect(mapProvider.selectedMall, equals(mall));
          expect(mapProvider.selectedMall!.id, equals(mall.id));
        }

        // Clear and verify
        mapProvider.clearSelection();
        expect(mapProvider.hasSelectedMall, isFalse);

        mapProvider.dispose();
      }
    });

    test('Selected mall GeoPoint should be valid for marker highlighting', () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final mall = _generateRandomMall();
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        await mapProvider.selectMall(mall);

        // Verify GeoPoint is valid for marker operations
        final geoPoint = mapProvider.selectedMall!.geoPoint;
        expect(geoPoint, isNotNull);
        expect(geoPoint.latitude, isA<double>());
        expect(geoPoint.longitude, isA<double>());
        expect(geoPoint.latitude, inInclusiveRange(-90, 90));
        expect(geoPoint.longitude, inInclusiveRange(-180, 180));

        // Verify GeoPoint matches mall coordinates
        expect(geoPoint.latitude, equals(mall.latitude));
        expect(geoPoint.longitude, equals(mall.longitude));

        mapProvider.dispose();
      }
    });

    test('Selection should work with edge case coordinates', () async {
      // Test with boundary coordinates
      final edgeCaseMalls = [
        _generateMallWithCoordinates(1.0, 103.9),    // Min Batam area
        _generateMallWithCoordinates(1.2, 104.1),    // Max Batam area
        _generateMallWithCoordinates(1.1, 104.0),    // Center
        _generateMallWithCoordinates(1.05, 103.95),  // Near min
        _generateMallWithCoordinates(1.15, 104.05),  // Near max
      ];

      for (final mall in edgeCaseMalls) {
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        await mapProvider.selectMall(mall);

        // Verify selection works with edge coordinates
        expect(mapProvider.hasSelectedMall, isTrue);
        expect(mapProvider.selectedMall, equals(mall));
        expect(mapProvider.selectedMall!.geoPoint.latitude, equals(mall.latitude));
        expect(mapProvider.selectedMall!.geoPoint.longitude, equals(mall.longitude));

        mapProvider.dispose();
      }
    });

    test('Selection should work with malls having different slot counts', () async {
      final slotCounts = [0, 1, 5, 10, 50, 100, 200];

      for (final slots in slotCounts) {
        final mall = _generateMallWithSlots(slots);
        final mapProvider = MapProvider();
        await mapProvider.initializeMap();

        await mapProvider.selectMall(mall);

        // Verify selection works regardless of slot count
        expect(mapProvider.hasSelectedMall, isTrue);
        expect(mapProvider.selectedMall!.availableSlots, equals(slots));

        mapProvider.dispose();
      }
    });
  });
}

/// Generate random mall for property testing
MallModel _generateRandomMall() {
  final random = Random();
  final lat = 1.0 + random.nextDouble() * 0.2;  // 1.0 to 1.2
  final lng = 103.9 + random.nextDouble() * 0.2;  // 103.9 to 104.1

  return MallModel(
    id: 'mall_${random.nextInt(10000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}, Batam',
    latitude: lat,
    longitude: lng,
    availableSlots: random.nextInt(100),
    distance: '${(random.nextDouble() * 10).toStringAsFixed(1)} km',
  );
}

/// Generate list of random malls
List<MallModel> _generateRandomMalls(int count) {
  return List.generate(count, (_) => _generateRandomMall());
}

/// Generate mall with specific coordinates
MallModel _generateMallWithCoordinates(double lat, double lng) {
  final random = Random();
  return MallModel(
    id: 'mall_${random.nextInt(10000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}, Batam',
    latitude: lat,
    longitude: lng,
    availableSlots: random.nextInt(100),
    distance: '${(random.nextDouble() * 10).toStringAsFixed(1)} km',
  );
}

/// Generate mall with specific slot count
MallModel _generateMallWithSlots(int slots) {
  final random = Random();
  return MallModel(
    id: 'mall_${random.nextInt(10000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}, Batam',
    latitude: 1.1,
    longitude: 104.0,
    availableSlots: slots,
    distance: '5.0 km',
  );
}
