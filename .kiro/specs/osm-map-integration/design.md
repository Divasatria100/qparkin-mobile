# Design Document

## Overview

The OSM Map Integration feature enhances the QPARKIN mobile application by replacing the current map placeholder with a fully functional OpenStreetMap implementation. This feature enables drivers to visualize parking mall locations, view their current position, calculate routes, and navigate seamlessly between list and map views.

The implementation leverages the `flutter_osm_plugin` package to provide an interactive map experience while maintaining the existing UI/UX design patterns established in the QPARKIN application. The feature is designed to work with dummy data during development and can be easily extended to integrate with the backend API in future iterations.

### Key Features
- Interactive OpenStreetMap with zoom and pan controls
- Real-time display of user's current location
- Mall location markers with information overlays
- Route calculation and visualization with polylines
- Distance and estimated travel time display
- Seamless navigation between map and list views
- Graceful error handling for network and GPS issues
- Extensible architecture for future API integration

### Design Goals
1. **User Experience**: Provide intuitive map navigation that helps drivers quickly find and navigate to parking locations
2. **Performance**: Maintain smooth map interactions with frame rates above 30 FPS
3. **Reliability**: Handle errors gracefully and provide clear feedback to users
4. **Maintainability**: Follow Flutter best practices with clean separation of concerns
5. **Extensibility**: Design for easy integration with backend API in future iterations

## Architecture

### High-Level Architecture

The OSM map integration follows a layered architecture pattern consistent with the existing QPARKIN application structure:

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (map_page.dart, map widgets, UI components)            │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Logic Layer                           │
│  (MapProvider - state management with ChangeNotifier)   │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Data Layer                            │
│  (MallModel, LocationService, RouteService)             │
└─────────────────────────────────────────────────────────┘
```


### Architecture Layers

#### 1. Presentation Layer
- **map_page.dart**: Main screen with tab navigation (Map view / Mall list view)
- **Map Widgets**: Reusable components for map controls, markers, info cards
- **Responsibilities**:
  - Render UI components
  - Handle user interactions (tap, zoom, pan)
  - Display loading states and error messages
  - Navigate between tabs and screens

#### 2. Logic Layer (State Management)
- **MapProvider**: ChangeNotifier-based provider managing map state
- **Responsibilities**:
  - Manage selected mall state
  - Handle location permission requests
  - Coordinate route calculations
  - Manage map camera position
  - Handle error states
  - Notify UI of state changes

#### 3. Data Layer
- **MallModel**: Data class representing mall entities
- **LocationService**: Service for geolocation operations
- **RouteService**: Service for route calculation
- **Responsibilities**:
  - Provide mall data (dummy data initially, API later)
  - Get user's current location
  - Calculate routes between two points
  - Handle data transformations

### Technology Stack

- **Flutter SDK**: 3.0+
- **flutter_osm_plugin**: ^1.0.0 (OpenStreetMap integration)
- **geolocator**: ^10.0.0 (Location services)
- **permission_handler**: ^11.0.0 (Permission management)
- **provider**: ^6.1.1 (State management - already in project)
- **http**: ^1.1.0 (API calls - already in project)


## Components and Interfaces

### 1. MapProvider (State Management)

```dart
class MapProvider extends ChangeNotifier {
  // State properties
  OSMController? _mapController;
  MallModel? _selectedMall;
  GeoPoint? _currentLocation;
  List<MallModel> _malls = [];
  bool _isLoading = false;
  String? _errorMessage;
  RouteData? _currentRoute;
  
  // Getters
  OSMController? get mapController => _mapController;
  MallModel? get selectedMall => _selectedMall;
  GeoPoint? get currentLocation => _currentLocation;
  List<MallModel> get malls => _malls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RouteData? get currentRoute => _currentRoute;
  
  // Methods
  Future<void> initializeMap();
  Future<void> getCurrentLocation();
  Future<void> selectMall(MallModel mall);
  Future<void> calculateRoute(GeoPoint origin, GeoPoint destination);
  Future<void> centerOnLocation(GeoPoint location);
  Future<void> centerOnCurrentLocation();
  void clearSelection();
  void clearError();
}
```

### 2. MallModel (Data Model)

```dart
class MallModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final String distance; // Calculated from user location
  
  MallModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableSlots,
    this.distance = '',
  });
  
  GeoPoint get geoPoint => GeoPoint(latitude: latitude, longitude: longitude);
  
  factory MallModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```


### 3. LocationService

```dart
class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled();
  
  // Check location permission status
  Future<LocationPermission> checkPermission();
  
  // Request location permission
  Future<LocationPermission> requestPermission();
  
  // Get current position
  Future<Position> getCurrentPosition();
  
  // Convert Position to GeoPoint
  GeoPoint positionToGeoPoint(Position position);
  
  // Calculate distance between two points (in km)
  double calculateDistance(GeoPoint point1, GeoPoint point2);
}
```

### 4. RouteService

```dart
class RouteService {
  // Calculate route between two points
  Future<RouteData> calculateRoute(GeoPoint origin, GeoPoint destination);
  
  // Get route polyline points
  List<GeoPoint> getRoutePolyline(RouteData route);
}

class RouteData {
  final List<GeoPoint> polylinePoints;
  final double distanceInKm;
  final int durationInMinutes;
  
  RouteData({
    required this.polylinePoints,
    required this.distanceInKm,
    required this.durationInMinutes,
  });
}
```

### 5. UI Components

#### MapView Widget
```dart
class MapView extends StatelessWidget {
  final MapProvider mapProvider;
  final Function(MallModel) onMallSelected;
  
  // Displays OSM map with markers and routes
  // Handles map interactions (zoom, pan)
  // Shows loading indicator and error states
}
```

#### MallMarker Widget
```dart
class MallMarker extends StatelessWidget {
  final MallModel mall;
  final bool isSelected;
  
  // Custom marker widget for mall locations
  // Different appearance for selected vs unselected
}
```

#### MallInfoCard Widget
```dart
class MallInfoCard extends StatelessWidget {
  final MallModel mall;
  final RouteData? route;
  final VoidCallback onClose;
  
  // Displays mall information overlay on map
  // Shows name, address, distance, available slots
  // Shows route info if available
}
```


## Data Models

### Mall Data Structure

```dart
class MallModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final String distance;
  
  // Constructor, fromJson, toJson methods
}
```

**Field Descriptions:**
- `id`: Unique identifier for the mall (maps to `id_mall` in database)
- `name`: Mall name (maps to `nama_mall` in database)
- `address`: Full address (maps to `lokasi` in database)
- `latitude`: Geographic latitude coordinate
- `longitude`: Geographic longitude coordinate
- `availableSlots`: Number of available parking slots (maps to `kapasitas` in database)
- `distance`: Calculated distance from user's location (computed field)

### Dummy Data for Development

```dart
final List<MallModel> dummyMalls = [
  MallModel(
    id: '1',
    name: 'Mega Mall Batam Centre',
    address: 'Jl. Engku Putri no.1, Batam Centre',
    latitude: 1.1191,
    longitude: 104.0538,
    availableSlots: 45,
  ),
  MallModel(
    id: '2',
    name: 'BCS Mall',
    address: 'Jl. Raja H. Fisabilillah, Batam Center',
    latitude: 1.1304,
    longitude: 104.0534,
    availableSlots: 32,
  ),
  MallModel(
    id: '3',
    name: 'Harbour Bay Mall',
    address: 'Komplek Ruko Harbour Bay, Batam',
    latitude: 1.1368,
    longitude: 104.0245,
    availableSlots: 28,
  ),
  MallModel(
    id: '4',
    name: 'Grand Batam Mall',
    address: 'Jl. Ahmad Yani, Batam Kota',
    latitude: 1.0822,
    longitude: 103.9635,
    availableSlots: 50,
  ),
  MallModel(
    id: '5',
    name: 'Kepri Mall',
    address: 'Jl. Duyung, Sei Jodoh, Batam',
    latitude: 1.1456,
    longitude: 104.0304,
    availableSlots: 18,
  ),
];
```

**Note**: These coordinates are realistic locations in Batam, Indonesia. When integrating with the backend API, the `alamat_gmaps` field from the database will be parsed to extract latitude and longitude coordinates.


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Mall Marker Display Completeness
*For any* list of mall data with valid coordinates, the system should display a marker on the map for each mall in the list.
**Validates: Requirements 1.2**

### Property 2: Marker Interaction Consistency
*For any* mall marker on the map, when tapped, the system should display an information card containing the mall's name, address, and available parking slots.
**Validates: Requirements 1.3**

### Property 3: Location Marker Display
*For any* state where location permission is granted and current location is available, the system should display a distinct marker at the user's current position on the map.
**Validates: Requirements 2.2**

### Property 4: Location Update Threshold
*For any* location change, if the distance from the previous location exceeds 10 meters, the system should update the position marker on the map.
**Validates: Requirements 2.5**

### Property 5: Mall Selection Navigation
*For any* mall selected from the mall list tab, the system should automatically switch to the map tab and center the map on that mall's location.
**Validates: Requirements 3.1, 3.2**

### Property 6: Selection Visual Feedback
*For any* mall that is selected, the system should display that mall's marker with a distinct visual highlight or animation different from unselected markers.
**Validates: Requirements 3.3**

### Property 7: Route Button Navigation
*For any* mall card where the "Rute" button is tapped, the system should switch to the map tab and initiate route calculation to that mall.
**Validates: Requirements 3.4**

### Property 8: Selected Mall Info Display
*For any* mall that is currently selected, the system should display an information card overlay on the map showing the mall's details.
**Validates: Requirements 3.5**


### Property 9: Route Calculation Trigger
*For any* mall selection when location permission is granted and current location is available, the system should calculate a route from the current location to the selected mall.
**Validates: Requirements 4.1**

### Property 10: Route Polyline Visualization
*For any* calculated route with valid polyline points, the system should draw a polyline on the map connecting the origin to the destination.
**Validates: Requirements 4.2**

### Property 11: Route Distance Display
*For any* successfully calculated route, the system should display the estimated distance in kilometers.
**Validates: Requirements 4.3**

### Property 12: Route Duration Display
*For any* successfully calculated route, the system should display the estimated travel time in minutes.
**Validates: Requirements 4.4**

### Property 13: Error Logging Consistency
*For any* error that occurs during map operations, the system should log the error details including error type, message, and timestamp.
**Validates: Requirements 5.4**

### Property 14: Loading Indicator Display
*For any* asynchronous operation (map initialization, route calculation, location fetch), the system should display a loading indicator while the operation is in progress.
**Validates: Requirements 6.4**

## Error Handling

### Error Categories and Handling Strategies

#### 1. Location Permission Errors

**Error**: Location permission denied
- **Detection**: Check permission status before requesting location
- **Handling**: 
  - Display informative dialog explaining why location is needed
  - Provide "Settings" button to open app settings
  - Fall back to default location (Batam city center)
  - Allow continued use of app with limited functionality
- **User Feedback**: "Location permission is required to show your position and calculate routes. You can still browse mall locations."

**Error**: Location permission permanently denied
- **Detection**: Permission status returns `permanentlyDenied`
- **Handling**:
  - Display dialog with instructions to enable in device settings
  - Provide direct link to app settings
  - Continue with default location
- **User Feedback**: "Please enable location permission in Settings > Apps > QParkin > Permissions"


#### 2. GPS/Location Service Errors

**Error**: GPS disabled
- **Detection**: Check if location services are enabled
- **Handling**:
  - Display dialog prompting user to enable GPS
  - Provide button to open location settings
  - Continue with last known location or default
- **User Feedback**: "GPS is disabled. Please enable location services to see your current position."

**Error**: Location unavailable/timeout
- **Detection**: Timeout after 10 seconds of trying to get location
- **Handling**:
  - Log error with details
  - Display error message
  - Provide retry button
  - Fall back to default location
- **User Feedback**: "Unable to get your location. Please check your GPS signal and try again."

#### 3. Network Errors

**Error**: No internet connection
- **Detection**: Catch network exceptions when loading map tiles
- **Handling**:
  - Display error banner at top of map
  - Show cached tiles if available
  - Provide retry button
  - Disable route calculation (requires network)
- **User Feedback**: "No internet connection. Map tiles may not load properly."

**Error**: Map tiles fail to load
- **Detection**: OSM tile loading errors
- **Handling**:
  - Log error details
  - Display placeholder for failed tiles
  - Provide retry mechanism
  - Maintain app stability (don't crash)
- **User Feedback**: "Some map tiles failed to load. Tap to retry."

#### 4. Route Calculation Errors

**Error**: Route calculation fails
- **Detection**: Exception during route calculation
- **Handling**:
  - Log error with origin/destination coordinates
  - Display error message
  - Provide retry button
  - Keep mall selection active
- **User Feedback**: "Unable to calculate route. Please try again."

**Error**: Invalid coordinates
- **Detection**: Validate coordinates before route calculation
- **Handling**:
  - Log validation error
  - Display error message
  - Prevent route calculation
- **User Feedback**: "Invalid location data. Please contact support."


#### 5. State Management Errors

**Error**: Map controller not initialized
- **Detection**: Check if controller is null before operations
- **Handling**:
  - Reinitialize map controller
  - Log error
  - Display loading state
- **User Feedback**: "Initializing map..."

**Error**: Invalid state transition
- **Detection**: Validate state before updates
- **Handling**:
  - Log state error
  - Reset to valid state
  - Notify user if necessary
- **User Feedback**: "An error occurred. Please try again."

### Error Logging Strategy

All errors should be logged with the following information:
- **Timestamp**: When the error occurred
- **Error Type**: Category of error (location, network, route, etc.)
- **Error Message**: Detailed error description
- **Context**: User action that triggered the error
- **Device Info**: OS version, app version
- **Location**: User's last known location (if available)

Example log format:
```
[2025-01-15 10:30:45] ERROR: Location Permission Denied
Context: User opened map tab
Device: Android 12, App v1.0.0
Action: Displayed permission dialog
```

## Testing Strategy

### Dual Testing Approach

The OSM map integration will be tested using both unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests** verify specific examples, edge cases, and error conditions
- **Property tests** verify universal properties that should hold across all inputs
- Together they provide comprehensive coverage: unit tests catch concrete bugs, property tests verify general correctness

### Unit Testing

#### Test Categories

**1. Widget Tests**
- Map page renders correctly
- Tab navigation works
- Mall list displays correctly
- Map controls are interactive
- Loading indicators appear during async operations
- Error messages display correctly

**2. State Management Tests**
- MapProvider initializes correctly
- State updates notify listeners
- Selected mall state changes correctly
- Error state is managed properly
- Loading state transitions correctly

**3. Service Tests**
- LocationService gets current position
- LocationService handles permission errors
- RouteService calculates routes correctly
- RouteService handles calculation errors
- Distance calculations are accurate

**4. Model Tests**
- MallModel serialization/deserialization
- GeoPoint conversion
- Data validation


#### Example Unit Tests

```dart
// Test: Map page initializes correctly
testWidgets('MapPage displays map and list tabs', (tester) async {
  await tester.pumpWidget(MaterialApp(home: MapPage()));
  expect(find.text('Peta'), findsOneWidget);
  expect(find.text('Daftar Mall'), findsOneWidget);
});

// Test: Location permission denied shows error
test('LocationService handles permission denied', () async {
  final service = LocationService();
  // Mock permission denied
  final result = await service.requestPermission();
  expect(result, LocationPermission.denied);
});

// Test: Route calculation with valid coordinates
test('RouteService calculates route successfully', () async {
  final service = RouteService();
  final origin = GeoPoint(latitude: 1.1191, longitude: 104.0538);
  final destination = GeoPoint(latitude: 1.1304, longitude: 104.0534);
  
  final route = await service.calculateRoute(origin, destination);
  
  expect(route, isNotNull);
  expect(route.distanceInKm, greaterThan(0));
  expect(route.durationInMinutes, greaterThan(0));
});
```

### Property-Based Testing

Property-based testing will use the **test** package with custom generators to verify universal properties across many inputs.

#### Configuration
- **Minimum iterations**: 100 runs per property test
- **Framework**: Dart test package with custom property testing utilities
- **Tagging**: Each property test tagged with format: `@Tags(['property-test', 'Feature: osm-map-integration, Property X'])`

#### Property Test Examples

```dart
// Property 1: Mall Marker Display Completeness
// Feature: osm-map-integration, Property 1: Mall Marker Display Completeness
test('All malls with valid coordinates should have markers', () {
  // Generate random list of malls
  for (int i = 0; i < 100; i++) {
    final malls = generateRandomMalls(count: Random().nextInt(10) + 1);
    final provider = MapProvider();
    provider.loadMalls(malls);
    
    // Verify marker count matches mall count
    expect(provider.markers.length, equals(malls.length));
    
    // Verify each mall has a corresponding marker
    for (final mall in malls) {
      final marker = provider.markers.firstWhere(
        (m) => m.position == mall.geoPoint,
      );
      expect(marker, isNotNull);
    }
  }
});

// Property 9: Route Calculation Trigger
// Feature: osm-map-integration, Property 9: Route Calculation Trigger
test('Selecting any mall with location permission should trigger route calculation', () {
  for (int i = 0; i < 100; i++) {
    final mall = generateRandomMall();
    final currentLocation = generateRandomLocation();
    final provider = MapProvider();
    
    // Mock location permission granted
    provider.setCurrentLocation(currentLocation);
    provider.selectMall(mall);
    
    // Verify route calculation was triggered
    expect(provider.currentRoute, isNotNull);
    expect(provider.currentRoute!.polylinePoints, isNotEmpty);
  }
});
```


#### Property Test Generators

```dart
// Generator for random mall data
MallModel generateRandomMall() {
  final random = Random();
  // Batam area coordinates: lat 1.0-1.2, lng 103.9-104.1
  final lat = 1.0 + random.nextDouble() * 0.2;
  final lng = 103.9 + random.nextDouble() * 0.2;
  
  return MallModel(
    id: 'mall_${random.nextInt(1000)}',
    name: 'Mall ${random.nextInt(100)}',
    address: 'Jl. Test ${random.nextInt(100)}',
    latitude: lat,
    longitude: lng,
    availableSlots: random.nextInt(100),
  );
}

// Generator for random location in Batam area
GeoPoint generateRandomLocation() {
  final random = Random();
  return GeoPoint(
    latitude: 1.0 + random.nextDouble() * 0.2,
    longitude: 103.9 + random.nextDouble() * 0.2,
  );
}

// Generator for list of random malls
List<MallModel> generateRandomMalls({required int count}) {
  return List.generate(count, (_) => generateRandomMall());
}
```

### Integration Testing

Integration tests will verify the complete flow from user interaction to map display:

1. **Mall Selection Flow**
   - User taps mall in list
   - Tab switches to map
   - Map centers on mall
   - Info card displays
   - Route calculates and displays

2. **Location Permission Flow**
   - App requests permission
   - User grants/denies
   - Map responds appropriately
   - Current location marker appears (if granted)

3. **Route Calculation Flow**
   - User selects mall
   - Location is available
   - Route calculates
   - Polyline draws on map
   - Distance and duration display

### Performance Testing

- **Map rendering**: Verify frame rate stays above 30 FPS during pan/zoom
- **Route calculation**: Should complete within 3 seconds
- **Marker rendering**: Should handle 50+ markers without lag
- **Memory usage**: Monitor for memory leaks during extended use

### Manual Testing Checklist

- [ ] Map loads and displays correctly
- [ ] Zoom and pan gestures work smoothly
- [ ] Mall markers appear at correct locations
- [ ] Tapping markers shows info cards
- [ ] Current location marker appears (with permission)
- [ ] Route calculation works and displays polyline
- [ ] Distance and duration are accurate
- [ ] Tab navigation works correctly
- [ ] Error messages display for all error scenarios
- [ ] App doesn't crash on permission denial
- [ ] App works offline (with cached tiles)
- [ ] Device rotation preserves state
- [ ] Back button navigation works correctly


## Implementation Notes

### Dependencies to Add

Update `pubspec.yaml` with the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Existing dependencies...
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  
  # New dependencies for OSM map integration
  flutter_osm_plugin: ^1.0.3
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
```

### File Structure

```
lib/
├── data/
│   ├── models/
│   │   ├── mall_model.dart          # Mall data model
│   │   └── route_data.dart          # Route data model
│   └── services/
│       ├── location_service.dart    # Location operations
│       └── route_service.dart       # Route calculation
├── logic/
│   └── providers/
│       └── map_provider.dart        # Map state management
├── presentation/
│   ├── screens/
│   │   └── map_page.dart           # Main map screen (update existing)
│   └── widgets/
│       ├── map_view.dart           # OSM map widget
│       ├── mall_marker.dart        # Custom marker widget
│       ├── mall_info_card.dart     # Info overlay widget
│       └── map_controls.dart       # Map control buttons
└── utils/
    └── map_utils.dart              # Map helper functions
```

### Integration Points for Future API

The following locations in the code should be updated when integrating with the backend API:

**1. Mall Data Loading** (`map_provider.dart`)
```dart
// TODO: Replace with API call
Future<void> loadMalls() async {
  // Current: Load from dummy data
  _malls = dummyMalls;
  
  // Future: Load from API
  // final response = await http.get('$API_URL/api/malls');
  // _malls = (response.data as List)
  //     .map((json) => MallModel.fromJson(json))
  //     .toList();
  
  notifyListeners();
}
```

**2. Coordinate Parsing** (`mall_model.dart`)
```dart
// TODO: Parse coordinates from alamat_gmaps field
factory MallModel.fromJson(Map<String, dynamic> json) {
  // Current: Direct lat/lng fields
  return MallModel(
    latitude: json['latitude'],
    longitude: json['longitude'],
    // ...
  );
  
  // Future: Parse from alamat_gmaps
  // final coords = _parseGoogleMapsUrl(json['alamat_gmaps']);
  // return MallModel(
  //   latitude: coords.latitude,
  //   longitude: coords.longitude,
  //   // ...
  // );
}
```

**3. Route Calculation** (`route_service.dart`)
```dart
// TODO: Use backend routing service if available
Future<RouteData> calculateRoute(GeoPoint origin, GeoPoint destination) async {
  // Current: Use OSM routing
  // Future: Option to use backend routing API for better accuracy
}
```

### Platform-Specific Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<manifest>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application>
        <!-- Existing configuration -->
    </application>
</manifest>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<dict>
    <!-- Add location usage descriptions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>QParkin needs your location to show nearby parking and calculate routes</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>QParkin needs your location to show nearby parking and calculate routes</string>
</dict>
```

### Performance Optimization

1. **Marker Clustering**: If more than 50 malls, implement marker clustering to improve performance
2. **Tile Caching**: Enable OSM tile caching to reduce network usage
3. **Lazy Loading**: Load mall data only when map tab is active
4. **Debouncing**: Debounce location updates to avoid excessive marker updates
5. **Memory Management**: Dispose map controller properly to prevent memory leaks

### Accessibility Considerations

- Provide text descriptions for map markers
- Ensure sufficient color contrast for UI elements
- Support screen readers for mall information
- Provide alternative text-based navigation option
- Ensure touch targets are at least 44x44 pixels

