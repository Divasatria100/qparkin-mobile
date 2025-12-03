# Implementation Plan

This implementation plan breaks down the OSM map integration feature into discrete, manageable coding tasks. Each task builds incrementally on previous steps, with property-based tests placed close to implementation to catch errors early.

## Task List

- [x] 1. Set up project dependencies and configuration
  - Add flutter_osm_plugin, geolocator, and permission_handler to pubspec.yaml
  - Configure Android manifest with location permissions
  - Configure iOS Info.plist with location usage descriptions
  - Run flutter pub get to install dependencies
  - _Requirements: 1.1, 2.1, 2.2_

- [x] 2. Create data models and dummy data
  - [x] 2.1 Create MallModel class with all required fields
    - Implement MallModel with id, name, address, latitude, longitude, availableSlots
    - Add geoPoint getter for coordinate conversion
    - Implement fromJson and toJson methods for API compatibility
    - _Requirements: 7.1, 7.2, 7.3, 7.5_

  - [x] 2.2 Write property test for MallModel serialization
    - **Property: Round trip consistency** - For any MallModel, serializing then deserializing should produce equivalent object
    - **Validates: Requirements 7.3**

  - [x] 2.3 Create RouteData model
    - Implement RouteData with polylinePoints, distanceInKm, durationInMinutes
    - Add validation for positive distance and duration values
    - _Requirements: 4.2, 4.3, 4.4_

  - [x] 2.4 Create dummy mall data file
    - Create data/dummy/mall_data.dart with 5 Batam mall locations
    - Use realistic coordinates for Batam area (lat 1.0-1.2, lng 103.9-104.1)
    - Include varied available slot counts
    - _Requirements: 7.5_

- [x] 3. Implement location services
  - [x] 3.1 Create LocationService class
    - Implement isLocationServiceEnabled() method
    - Implement checkPermission() method
    - Implement requestPermission() method
    - Implement getCurrentPosition() method with timeout
    - Implement positionToGeoPoint() conversion method
    - Implement calculateDistance() using Haversine formula
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 3.2 Write unit tests for LocationService
    - Test permission checking and requesting
    - Test position retrieval with mocked GPS
    - Test distance calculation accuracy
    - Test error handling for GPS disabled
    - _Requirements: 2.1, 2.2, 5.2_

- [x] 4. Implement route calculation service
  - [x] 4.1 Create RouteService class
    - Implement calculateRoute() method using OSM routing
    - Implement getRoutePolyline() to extract polyline points
    - Add error handling for route calculation failures
    - Calculate distance and duration from route data
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [x] 4.2 Write property test for route calculation
    - **Property 9: Route Calculation Trigger** - For any mall selection with valid location, route should be calculated
    - **Validates: Requirements 4.1**

  - [x] 4.3 Write unit tests for RouteService
    - Test successful route calculation with valid coordinates
    - Test error handling for invalid coordinates
    - Test error handling for network failures
    - Test distance and duration calculations
    - _Requirements: 4.1, 4.5_

- [x] 5. Create MapProvider for state management
  - [x] 5.1 Implement MapProvider class with ChangeNotifier
    - Add state properties (mapController, selectedMall, currentLocation, malls, isLoading, errorMessage, currentRoute)
    - Implement all getters for state properties
    - Add notifyListeners() calls after state changes
    - _Requirements: 1.1, 3.1, 3.2, 6.4_

  - [x] 5.2 Implement map initialization methods
    - Implement initializeMap() to create OSM controller
    - Implement loadMalls() to load dummy data
    - Add error handling for initialization failures
    - _Requirements: 1.1, 7.1_

  - [x] 5.3 Implement location management methods
    - Implement getCurrentLocation() using LocationService
    - Implement centerOnLocation() to move map camera
    - Implement centerOnCurrentLocation() convenience method
    - Add error handling for location errors
    - _Requirements: 2.2, 2.3, 2.4_

  - [x] 5.4 Write property test for location marker display
    - **Property 3: Location Marker Display** - For any state with location permission and current location, marker should display
    - **Validates: Requirements 2.2**

  - [x] 5.5 Implement mall selection methods
    - Implement selectMall() to update selected mall state
    - Implement clearSelection() to reset selection
    - Trigger route calculation when mall is selected
    - Update map camera to center on selected mall
    - _Requirements: 3.1, 3.2, 3.3, 3.5_

  - [x] 5.6 Write property test for mall selection navigation
    - **Property 5: Mall Selection Navigation** - For any mall selected, system should switch to map tab and center on mall
    - **Validates: Requirements 3.1, 3.2**

  - [x] 5.7 Implement route calculation coordination
    - Implement calculateRoute() that uses RouteService
    - Update currentRoute state with calculated route
    - Handle route calculation errors
    - _Requirements: 4.1, 4.5_

  - [x] 5.8 Implement error management methods
    - Implement clearError() to reset error state
    - Add error logging for all error scenarios
    - _Requirements: 5.4_

  - [x] 5.9 Write property test for error logging
    - **Property 13: Error Logging Consistency** - For any error, system should log error details
    - **Validates: Requirements 5.4**

- [x] 6. Create map UI widgets
  - [x] 6.1 Create MapView widget
    - Implement StatefulWidget with OSMFlutter map widget
    - Configure map with initial center and zoom level
    - Add zoom and pan controls
    - Handle map initialization and loading states
    - _Requirements: 1.1, 1.4, 6.1, 6.2_

  - [x] 6.2 Implement marker display in MapView
    - Add method to display markers for all malls
    - Implement custom marker icons
    - Handle marker tap events
    - _Requirements: 1.2, 1.3_

  - [x] 6.3 Write property test for marker display
    - **Property 1: Mall Marker Display Completeness** - For any list of malls, all should have markers
    - **Validates: Requirements 1.2**

  - [x] 6.4 Implement current location marker
    - Add distinct marker for user's current location
    - Update marker when location changes (>10m threshold)
    - _Requirements: 2.2, 2.5_

  - [x] 6.5 Write property test for location update threshold
    - **Property 4: Location Update Threshold** - For any location change >10m, marker should update
    - **Validates: Requirements 2.5**

  - [x] 6.6 Implement route polyline display
    - Add method to draw polyline on map
    - Style polyline with appropriate color and width
    - Clear previous polyline when new route is calculated
    - _Requirements: 4.2_

  - [x] 6.7 Write property test for route polyline
    - **Property 10: Route Polyline Visualization** - For any calculated route, polyline should be drawn
    - **Validates: Requirements 4.2**

  - [x] 6.8 Create MallInfoCard widget
    - Design card layout with mall name, address, distance, available slots
    - Add close button to dismiss card
    - Display route information (distance, duration) if available
    - Animate card appearance
    - _Requirements: 1.3, 3.5, 4.3, 4.4_

  - [x] 6.9 Write property test for info card display
    - **Property 8: Selected Mall Info Display** - For any selected mall, info card should display
    - **Validates: Requirements 3.5**

  - [x] 6.10 Create map control buttons
    - Create "My Location" floating action button
    - Implement button to center on current location
    - Add visual feedback on button press
    - _Requirements: 2.3_

  - [x] 6.11 Add loading indicators
    - Display loading spinner during map initialization
    - Show loading indicator during route calculation
    - Display loading state during location fetch
    - _Requirements: 6.4_

  - [x] 6.12 Write property test for loading indicators
    - **Property 14: Loading Indicator Display** - For any async operation, loading indicator should display
    - **Validates: Requirements 6.4**

- [x] 7. Update map_page.dart with OSM integration
  - [x] 7.1 Integrate MapProvider with ChangeNotifierProvider
    - Wrap MapPage with ChangeNotifierProvider<MapProvider>
    - Initialize MapProvider in initState
    - Dispose MapProvider properly
    - _Requirements: 1.1_

  - [x] 7.2 Replace map placeholder with MapView widget
    - Remove placeholder Container
    - Add MapView widget consuming MapProvider
    - Pass callbacks for user interactions
    - _Requirements: 1.1_

  - [x] 7.3 Implement mall selection from list
    - Update _selectMall() to use MapProvider.selectMall()
    - Automatically switch to map tab when mall is selected
    - _Requirements: 3.1, 3.2_

  - [x] 7.4 Write property test for mall selection from list
    - **Property 5: Mall Selection Navigation** - Verify tab switch and map centering
    - **Validates: Requirements 3.1, 3.2**

  - [x] 7.5 Implement route button functionality
    - Update _showRouteOnMap() to trigger route calculation
    - Switch to map tab and display route
    - _Requirements: 3.4_

  - [x] 7.6 Write property test for route button
    - **Property 7: Route Button Navigation** - For any mall, route button should trigger navigation
    - **Validates: Requirements 3.4**

  - [x] 7.7 Add selected mall visual feedback
    - Highlight selected mall marker
    - Update mall card appearance when selected
    - _Requirements: 3.3_

  - [x] 7.8 Write property test for selection visual feedback
    - **Property 6: Selection Visual Feedback** - For any selected mall, marker should be highlighted
    - **Validates: Requirements 3.3**

  - [x] 7.9 Display MallInfoCard for selected mall
    - Show info card overlay when mall is selected
    - Update card with route information when available
    - Handle card dismissal
    - _Requirements: 3.5_

- [x] 8. Implement error handling UI
  - [x] 8.1 Create error dialog widgets
    - Create reusable error dialog component
    - Add specific dialogs for permission errors
    - Add dialog for GPS disabled
    - Add dialog for network errors
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 8.2 Implement permission request flow
    - Show permission rationale dialog
    - Request location permission
    - Handle permission granted/denied/permanently denied
    - Provide settings navigation for permanently denied
    - _Requirements: 2.1, 2.4, 5.5_

  - [x] 8.3 Add error banners and snackbars
    - Display network error banner
    - Show snackbar for route calculation errors
    - Add retry buttons where appropriate
    - _Requirements: 5.1, 5.3, 4.5_

  - [x] 8.4 Implement fallback behaviors
    - Use default location when permission denied
    - Show cached tiles when offline
    - Maintain app stability on errors
    - _Requirements: 1.4, 2.4, 5.3_

- [x] 9. Add comprehensive error logging
  - [x] 9.1 Create logging utility
    - Implement structured logging with timestamp, error type, context
    - Add log levels (error, warning, info)
    - Include device and app version in logs
    - _Requirements: 5.4_

  - [x] 9.2 Add logging to all error scenarios
    - Log location permission errors
    - Log GPS/location service errors
    - Log network errors
    - Log route calculation errors
    - Log state management errors
    - _Requirements: 5.4_

  - [x] 9.3 Write property test for error logging
    - **Property 13: Error Logging Consistency** - Verify all errors are logged with required information
    - **Validates: Requirements 5.4**

- [x] 10. Checkpoint - Ensure all tests pass
  - Run all unit tests and verify they pass
  - Run all property tests (100+ iterations each) and verify they pass
  - Fix any failing tests
  - Ensure all tests pass, ask the user if questions arise

- [x] 11. Add integration and widget tests
  - [x] 11.1 Write integration test for mall selection flow
    - Test complete flow: tap mall → switch tab → center map → show info → calculate route
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 4.1_

  - [x] 11.2 Write integration test for location permission flow
    - Test permission request → grant/deny → map response → marker display
    - _Requirements: 2.1, 2.2, 2.4_

  - [x] 11.3 Write widget tests for map page
    - Test map page renders correctly
    - Test tab navigation works
    - Test mall list displays
    - Test loading indicators appear
    - _Requirements: 1.1, 6.4_

  - [x] 11.4 Write widget tests for error scenarios
    - Test error dialogs display correctly
    - Test error messages are clear
    - Test retry buttons work
    - _Requirements: 5.1, 5.2, 5.3, 5.5_

- [x] 12. Performance optimization and polish
  - [x] 12.1 Optimize marker rendering
    - Implement marker clustering if needed (>50 malls)
    - Optimize marker icon loading
    - _Requirements: 1.2_

  - [x] 12.2 Enable tile caching
    - Configure OSM tile caching
    - Test offline functionality with cached tiles
    - _Requirements: 5.3_

  - [x] 12.3 Add debouncing for location updates
    - Debounce location updates to avoid excessive marker updates
    - Implement 10-meter threshold check
    - _Requirements: 2.5_

  - [x] 12.4 Add smooth animations
    - Animate map camera movements
    - Animate marker selection
    - Animate info card appearance
    - _Requirements: 3.3, 6.3_

  - [x] 12.5 Test device rotation
    - Verify state persists across rotation
    - Test that selected mall remains selected
    - _Requirements: 6.5_

- [x] 13. Documentation and code comments
  - [x] 13.1 Add API integration comments
    - Mark all locations where API integration will replace dummy data
    - Document expected API response format
    - Add TODO comments for future enhancements
    - _Requirements: 7.4, 8.4_

  - [x] 13.2 Document public APIs
    - Add dartdoc comments to all public classes and methods
    - Document parameters and return values
    - Add usage examples in comments
    - _Requirements: 8.3_

  - [x] 13.3 Create README for map feature
    - Document architecture and design decisions
    - Explain state management approach
    - List dependencies and their purposes
    - Provide setup instructions
    - _Requirements: 8.5_

- [x] 14. Final checkpoint - Comprehensive testing
  - Run complete test suite (unit + property + integration + widget tests)
  - Verify all 14 correctness properties pass
  - Test on physical Android device
  - Verify performance meets requirements (>30 FPS, <3s route calculation)
  - Test all error scenarios manually
  - Verify accessibility features work
  - Ensure all tests pass, ask the user if questions arise

## Implementation Status

✅ **COMPLETE** - All tasks have been successfully implemented!

The OSM map integration feature is fully functional with:
- Interactive OpenStreetMap with zoom and pan controls
- Real-time user location tracking with distinct marker
- Mall location markers with tap-to-select functionality
- Route calculation and visualization with polylines
- Distance and travel time display
- Seamless navigation between map and list views
- Comprehensive error handling with user-friendly dialogs
- Graceful fallback behaviors for offline/permission denied scenarios
- Performance optimizations (marker clustering, tile caching, debouncing)
- Smooth animations for camera movements and marker selection
- State persistence across device rotations
- Extensive test coverage (unit, property-based, integration, widget tests)
- Complete documentation with API integration comments

## Notes

### Property-Based Test Configuration
- All property tests should run a minimum of 100 iterations
- Each property test must be tagged with: `@Tags(['property-test', 'Feature: osm-map-integration, Property X'])`
- Property tests should use custom generators for mall data and locations

### Testing Priority
- Core functionality (map display, markers, selection) - ✅ Complete
- Route calculation and display - ✅ Complete
- Error handling - ✅ Complete
- Performance optimization - ✅ Complete
- Polish and animations - ✅ Complete

### API Integration Points
The following areas are designed for easy API integration:
1. `MapProvider.loadMalls()` - Replace dummy data with API call
2. `MallModel.fromJson()` - Parse coordinates from `alamat_gmaps` field
3. `RouteService.calculateRoute()` - Option to use backend routing service

### Performance Targets
- Map rendering: >30 FPS during pan/zoom ✅
- Route calculation: <3 seconds ✅
- Marker rendering: Handle 50+ markers without lag ✅
- App startup: Map should initialize within 2 seconds ✅
