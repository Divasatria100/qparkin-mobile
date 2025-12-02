# OSM Map Integration - Feature Documentation

## Overview

The OSM Map Integration feature provides a complete interactive mapping solution for the QPARKIN mobile application. It enables users to visualize parking mall locations, view their current position, calculate routes, and navigate seamlessly between map and list views.

This feature replaces the previous map placeholder with a fully functional OpenStreetMap implementation using the `flutter_osm_plugin` package.

### Key Capabilities

- **Interactive Map**: Pan, zoom, and explore mall locations on an OpenStreetMap
- **Real-time Location**: Display user's current position with GPS integration
- **Mall Markers**: Visual markers for all parking mall locations
- **Route Calculation**: Calculate and display routes from current location to selected malls
- **Distance & Duration**: Show estimated travel distance and time
- **Seamless Navigation**: Switch between map view and list view with automatic centering
- **Offline Support**: Cached map tiles for offline viewing
- **Error Handling**: Graceful handling of permission denials, GPS issues, and network errors

## Architecture

### Design Pattern

The feature follows a **layered architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (UI widgets, screens, dialogs)                         │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Logic Layer                           │
│  (State management with Provider pattern)               │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Data Layer                            │
│  (Models, Services, Data sources)                       │
└─────────────────────────────────────────────────────────┘
```

### State Management Approach

The feature uses the **Provider pattern** (ChangeNotifier) for state management, which is consistent with the existing QPARKIN application architecture.

**Why Provider?**
- Already integrated in the project
- Simple and intuitive API
- Efficient rebuilds with Consumer widgets
- Good performance for this use case
- Easy to test and maintain

**State Management Flow:**
1. User interacts with UI (tap marker, press button)
2. UI calls method on MapProvider
3. MapProvider updates internal state
4. MapProvider calls notifyListeners()
5. Consumer widgets rebuild with new state
6. UI reflects the changes

### Component Structure

```
lib/
├── data/
│   ├── models/
│   │   ├── mall_model.dart          # Mall data model
│   │   └── route_data.dart          # Route data model
│   ├── services/
│   │   ├── location_service.dart    # GPS/location operations
│   │   └── route_service.dart       # Route calculation
│   └── dummy/
│       └── mall_data.dart           # Dummy data for development
├── logic/
│   └── providers/
│       └── map_provider.dart        # Map state management
├── presentation/
│   ├── screens/
│   │   └── map_page.dart           # Main map screen
│   ├── widgets/
│   │   ├── map_view.dart           # OSM map widget
│   │   ├── map_controls.dart       # Map control buttons
│   │   └── map_mall_info_card.dart # Info card overlay
│   └── dialogs/
│       └── map_error_dialog.dart   # Error dialogs
└── utils/
    ├── map_logger.dart             # Logging utility
    └── map_error_utils.dart        # Error handling utilities
```

## Dependencies

### Required Packages

```yaml
dependencies:
  flutter_osm_plugin: ^1.0.3    # OpenStreetMap integration
  geolocator: ^10.1.0           # Location services
  permission_handler: ^11.1.0   # Permission management
  provider: ^6.1.1              # State management (already in project)
  http: ^1.1.0                  # HTTP requests (already in project)
```

### Dependency Purposes

| Package | Purpose | Why This Package? |
|---------|---------|-------------------|
| flutter_osm_plugin | OpenStreetMap integration | Open-source, no API keys required, good performance, tile caching support |
| geolocator | GPS location services | Industry standard, cross-platform, comprehensive permission handling |
| permission_handler | Permission management | Unified API for all permissions, handles platform differences |
| provider | State management | Simple, efficient, already integrated in project |
| http | Network requests | Standard Dart HTTP client, used for route calculation API |

## Setup Instructions

### 1. Install Dependencies

```bash
cd qparkin_app
flutter pub get
```

### 2. Configure Android Permissions

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application>
        <!-- Existing configuration -->
    </application>
</manifest>
```

### 3. Configure iOS Permissions

Edit `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Add these keys -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>QParkin needs your location to show nearby parking and calculate routes</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>QParkin needs your location to show nearby parking and calculate routes</string>
</dict>
```

### 4. Run the Application

```bash
# For Android
flutter run --dart-define=API_URL=http://192.168.x.xx:8000

# For iOS
flutter run --dart-define=API_URL=http://192.168.x.xx:8000
```

## Usage Guide

### Basic Usage

#### Initialize Map Provider

```dart
import 'package:provider/provider.dart';
import 'package:qparkin_app/logic/providers/map_provider.dart';

// In your widget tree
ChangeNotifierProvider(
  create: (_) => MapProvider(),
  child: MapPage(),
)
```

#### Display Map

```dart
import 'package:qparkin_app/presentation/widgets/map_view.dart';

// In your build method
MapView()
```

#### Select a Mall

```dart
final mapProvider = context.read<MapProvider>();
final mall = mapProvider.malls.first;
await mapProvider.selectMall(mall);
```

#### Get Current Location

```dart
final mapProvider = context.read<MapProvider>();
try {
  await mapProvider.getCurrentLocation();
  print('Location: ${mapProvider.currentLocation}');
} on PermissionDeniedException {
  print('Permission denied');
} on LocationServiceDisabledException {
  print('GPS disabled');
}
```

#### Calculate Route

```dart
final mapProvider = context.read<MapProvider>();
final origin = mapProvider.currentLocation!;
final destination = mall.geoPoint;

try {
  await mapProvider.calculateRoute(origin, destination);
  final route = mapProvider.currentRoute!;
  print('Distance: ${route.formattedDistance}');
  print('Duration: ${route.formattedDuration}');
} on RouteCalculationException {
  print('Route calculation failed');
}
```

### Advanced Usage

#### Custom Marker Icons

```dart
await mapController.addMarker(
  geoPoint,
  markerIcon: MarkerIcon(
    icon: Icon(
      Icons.location_on,
      color: Colors.blue,
      size: 48,
    ),
  ),
);
```

#### Handle Permission Flow

```dart
final locationService = LocationService();

// Check if services are enabled
final serviceEnabled = await locationService.isLocationServiceEnabled();
if (!serviceEnabled) {
  // Show dialog to enable GPS
  return;
}

// Check permission
var permission = await locationService.checkPermission();
if (permission == LocationPermission.denied) {
  // Request permission
  permission = await locationService.requestPermission();
}

if (permission == LocationPermission.deniedForever) {
  // Show dialog to open settings
  return;
}

// Get location
final position = await locationService.getCurrentPosition();
```

#### Custom Route Styling

```dart
await mapController.drawRoad(
  origin,
  destination,
  roadType: RoadType.car,
  roadOption: RoadOption(
    roadWidth: 10,
    roadColor: Color(0xFF573ED1),
    zoomInto: true,
  ),
);
```

## API Integration Guide

### Current Implementation (Dummy Data)

The feature currently uses dummy data for development and testing. Mall data is loaded from `lib/data/dummy/mall_data.dart`.

### Future API Integration

When the backend API is ready, follow these steps to integrate:

#### 1. Update Mall Loading

In `lib/logic/providers/map_provider.dart`, replace the `loadMalls()` method:

```dart
Future<void> loadMalls() async {
  try {
    _isLoading = true;
    notifyListeners();

    // Make API request
    final response = await http.get(
      Uri.parse('$API_URL/api/malls'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final mallsData = jsonData['data'] as List<dynamic>;
      _malls = mallsData.map((json) => MallModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load malls: ${response.statusCode}');
    }

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Gagal memuat data mall: ${e.toString()}';
    notifyListeners();
    rethrow;
  }
}
```

#### 2. Parse Coordinates from alamat_gmaps

In `lib/data/models/mall_model.dart`, add coordinate parsing:

```dart
static (double, double) _parseGoogleMapsUrl(String url) {
  final regex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
  final match = regex.firstMatch(url);
  if (match != null) {
    return (
      double.parse(match.group(1)!),
      double.parse(match.group(2)!)
    );
  }
  return (0.0, 0.0);
}

factory MallModel.fromJson(Map<String, dynamic> json) {
  final (lat, lng) = _parseGoogleMapsUrl(json['alamat_gmaps'] ?? '');
  
  return MallModel(
    id: json['id_mall']?.toString() ?? '',
    name: json['nama_mall']?.toString() ?? '',
    address: json['lokasi']?.toString() ?? '',
    latitude: lat,
    longitude: lng,
    availableSlots: _parseInt(json['kapasitas']),
  );
}
```

#### 3. Expected API Response Format

```json
{
  "success": true,
  "data": [
    {
      "id_mall": "1",
      "nama_mall": "Mega Mall Batam Centre",
      "lokasi": "Jl. Engku Putri no.1, Batam Centre",
      "alamat_gmaps": "https://maps.google.com/?q=1.1191,104.0538",
      "kapasitas": 45
    }
  ]
}
```

## Performance Considerations

### Optimization Strategies

1. **Marker Clustering**: For >50 malls, markers are added in batches with smaller icons
2. **Tile Caching**: OSM tiles are automatically cached for offline viewing
3. **Debounced Location Updates**: Location marker updates are debounced by 500ms
4. **Location Update Threshold**: Marker only updates if location changes >10 meters
5. **Lazy Route Calculation**: Routes are only calculated when a mall is selected

### Performance Targets

- **Map Rendering**: >30 FPS during pan/zoom operations
- **Route Calculation**: <3 seconds for typical routes
- **Marker Rendering**: Handle 50+ markers without lag
- **App Startup**: Map initializes within 2 seconds

### Memory Management

- Map controller is properly disposed in provider's dispose method
- Debounce timers are cancelled to prevent memory leaks
- Old markers are removed before adding new ones
- Route polylines are cleared before drawing new routes

## Error Handling

### Error Categories

1. **Location Permission Errors**
   - Permission denied
   - Permission permanently denied
   - Handled with informative dialogs and fallback to default location

2. **GPS/Location Service Errors**
   - GPS disabled
   - Location unavailable/timeout
   - Handled with retry options and default location fallback

3. **Network Errors**
   - No internet connection
   - Map tiles fail to load
   - Handled with cached tiles and retry mechanisms

4. **Route Calculation Errors**
   - Route calculation fails
   - Invalid coordinates
   - Handled with error messages and retry options

### Error Handling Strategy

All errors are:
1. Logged with detailed context for debugging
2. Displayed to users with clear, actionable messages
3. Handled gracefully without crashing the app
4. Provided with retry mechanisms where appropriate
5. Fallback to default behavior when possible

## Testing

### Test Coverage

The feature includes comprehensive test coverage:

- **Unit Tests**: Services, models, state management
- **Property-Based Tests**: Universal properties across all inputs
- **Widget Tests**: UI components and interactions
- **Integration Tests**: Complete user flows

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/providers/map_provider_test.dart

# Run property tests only
flutter test --tags property-test
```

### Test Examples

```dart
// Unit test
test('LocationService calculates distance correctly', () {
  final service = LocationService();
  final point1 = GeoPoint(latitude: 1.1191, longitude: 104.0538);
  final point2 = GeoPoint(latitude: 1.1304, longitude: 104.0534);
  
  final distance = service.calculateDistance(point1, point2);
  
  expect(distance, greaterThan(0));
  expect(distance, lessThan(2)); // Should be ~1.3 km
});

// Property test
test('All malls should have markers', () {
  for (int i = 0; i < 100; i++) {
    final malls = generateRandomMalls(count: Random().nextInt(10) + 1);
    final provider = MapProvider();
    provider.loadMalls(malls);
    
    expect(provider.markers.length, equals(malls.length));
  }
});
```

## Troubleshooting

### Common Issues

#### Map doesn't load

**Symptoms**: Blank screen or loading indicator doesn't disappear

**Solutions**:
1. Check internet connection
2. Verify permissions are granted
3. Check console for error messages
4. Try clearing app cache

#### Location not working

**Symptoms**: "My Location" button doesn't work

**Solutions**:
1. Enable GPS in device settings
2. Grant location permission in app settings
3. Check if location services are enabled
4. Try restarting the app

#### Route calculation fails

**Symptoms**: Error message when selecting a mall

**Solutions**:
1. Check internet connection (route calculation requires network)
2. Verify coordinates are valid
3. Try selecting a different mall
4. Check console for detailed error messages

#### Markers not appearing

**Symptoms**: Map loads but no mall markers visible

**Solutions**:
1. Check if mall data is loaded (console logs)
2. Zoom out to see if markers are outside viewport
3. Check if markers are being added (console logs)
4. Restart the app

## Future Enhancements

### Planned Features

1. **Advanced Marker Clustering**
   - Dynamic clustering based on zoom level
   - Cluster count badges
   - Smooth animations

2. **Real-time Updates**
   - WebSocket for live availability updates
   - Push notifications for availability changes

3. **Search and Filters**
   - Search malls by name
   - Filter by availability
   - Sort by distance

4. **Navigation Integration**
   - Deep link to Google Maps/Waze
   - In-app turn-by-turn navigation

5. **Offline Mode**
   - Pre-download map tiles
   - Cache mall data
   - Offline indicator

6. **Accessibility**
   - Voice announcements
   - High contrast mode
   - Larger touch targets

## Contributing

### Code Style

Follow the existing code style:
- Use dartdoc comments for all public APIs
- Add TODO comments for API integration points
- Include usage examples in documentation
- Follow Flutter/Dart naming conventions

### Adding New Features

1. Update the design document
2. Add tests first (TDD approach)
3. Implement the feature
4. Update documentation
5. Test on physical devices

## Support

For issues or questions:
1. Check this documentation
2. Review the design document at `.kiro/specs/osm-map-integration/design.md`
3. Check console logs for error details
4. Contact the development team

## License

This feature is part of the QPARKIN mobile application.
