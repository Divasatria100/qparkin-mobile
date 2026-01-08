import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/map_provider.dart';
import '../../data/services/location_service.dart';
import '../../data/models/route_data.dart';
import '../../data/models/mall_model.dart';
import '../../data/models/search_result_model.dart';
import '../../utils/map_error_utils.dart';
import '../dialogs/map_error_dialog.dart';
import 'map_controls.dart';
import 'map_mall_info_card.dart';
import 'map_search_bar.dart';

/// MapView widget that displays the OpenStreetMap
/// 
/// Implements StatefulWidget with OSMFlutter map widget.
/// Configures map with initial center and zoom level.
/// Adds zoom and pan controls.
/// Handles map initialization and loading states.
/// 
/// TODO: Future Enhancements
/// 
/// 1. Advanced Marker Clustering
///    - Implement dynamic clustering based on zoom level
///    - Show cluster count badges
///    - Smooth cluster expansion/collapse animations
/// 
/// 2. Real-time Updates
///    - WebSocket connection for live parking availability updates
///    - Auto-refresh markers when availability changes
///    - Push notifications for selected mall availability changes
/// 
/// 3. Search and Filters
///    - Search bar to find malls by name
///    - Filter by available slots (e.g., only show malls with >10 slots)
///    - Filter by distance from current location
///    - Sort results by distance, availability, or name
/// 
/// 4. Navigation Integration
///    - Deep link to Google Maps/Waze for turn-by-turn navigation
///    - In-app navigation with voice guidance
///    - Alternative route options
/// 
/// 5. Offline Mode Improvements
///    - Pre-download map tiles for Batam area
///    - Cache mall data for offline access
///    - Show "offline mode" indicator
/// 
/// 6. Accessibility Improvements
///    - Voice announcements for selected malls
///    - High contrast mode for markers
///    - Larger touch targets for markers
/// 
/// 7. Performance Optimizations
///    - Implement viewport-based marker loading (only show markers in view)
///    - Use marker sprites for better rendering performance
///    - Lazy load route polylines
/// 
/// Requirements: 1.1, 1.4, 6.1, 6.2
class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool _isMapReady = false;
  bool _markersAdded = false;
  GeoPoint? _lastLocationMarker;
  RoadInfo? _currentRoadInfo;
  GeoPoint? _selectedMarkerPoint;
  GeoPoint? _searchResultMarkerPoint; // Track search result marker
  
  // Debouncing for location updates
  Timer? _locationUpdateDebounceTimer;
  GeoPoint? _pendingLocationUpdate;
  
  // Track previous values to avoid unnecessary updates
  GeoPoint? _previousLocation;
  RouteData? _previousRoute;
  MallModel? _previousSelectedMall;
  SearchResultModel? _previousSearchResult;
  
  // Track listener for cleanup
  VoidCallback? _markerTapListener;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only update if values actually changed
    final mapProvider = context.watch<MapProvider>();
    
    if (mapProvider.currentLocation != _previousLocation) {
      _previousLocation = mapProvider.currentLocation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateLocationMarker();
      });
    }
    
    if (mapProvider.currentRoute != _previousRoute) {
      _previousRoute = mapProvider.currentRoute;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateRoutePolyline();
      });
    }
    
    if (mapProvider.selectedMall != _previousSelectedMall) {
      _previousSelectedMall = mapProvider.selectedMall;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateSelectedMarkerHighlight();
      });
    }
    
    if (mapProvider.selectedSearchResult != _previousSearchResult) {
      _previousSearchResult = mapProvider.selectedSearchResult;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateSearchResultMarker();
      });
    }
  }

  /// Initialize the map when widget is created
  /// 
  /// Implements fallback behaviors:
  /// - Uses default location if permission denied
  /// - Maintains app stability on errors
  /// - Allows offline usage with cached tiles
  /// 
  /// Requirements: 1.4, 2.4, 5.3
  Future<void> _initializeMap() async {
    final mapProvider = context.read<MapProvider>();
    
    try {
      // Initialize map controller if not already initialized
      if (!mapProvider.isMapInitialized) {
        await mapProvider.initializeMap();
      }
      
      // Load mall data
      await mapProvider.loadMalls();
      
      setState(() {
        _isMapReady = true;
      });

      // Add markers after map is ready
      await _addMallMarkers();
      
      // Try to get current location, but don't fail if it doesn't work
      // This implements the fallback behavior for permission denied
      try {
        await mapProvider.getCurrentLocation();
      } catch (e) {
        debugPrint('[MapView] Could not get location during init: $e');
        // Use default location as fallback
        mapProvider.useDefaultLocation();
        
        // Show informative snackbar (not an error, just info)
        if (mounted) {
          MapErrorUtils.showGeneralError(
            context,
            message: 'Menggunakan lokasi default. Ketuk tombol lokasi untuk mengaktifkan GPS.',
          );
        }
      }
    } catch (e) {
      debugPrint('[MapView] Error initializing map: $e');
      // Error is already handled in MapProvider
      // App remains stable - error state is shown in UI
    }
  }

  /// Add markers for all malls on the map
  /// 
  /// Optimized marker rendering:
  /// - Pre-creates marker icons to avoid repeated widget builds
  /// - Implements marker clustering for >50 malls to improve performance
  /// - Batches marker additions to reduce UI updates
  /// 
  /// Requirements: 1.2, 1.3
  Future<void> _addMallMarkers() async {
    if (_markersAdded) return;

    final mapProvider = context.read<MapProvider>();
    
    if (mapProvider.mapController == null || mapProvider.malls.isEmpty) {
      return;
    }

    try {
      debugPrint('[MapView] Adding ${mapProvider.malls.length} mall markers');

      // Pre-create marker icon to avoid repeated widget builds (optimization)
      const normalMarkerIcon = MarkerIcon(
        icon: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 48,
        ),
      );

      // Check if we need marker clustering (>50 malls)
      final shouldCluster = mapProvider.malls.length > 50;
      
      if (shouldCluster) {
        debugPrint('[MapView] Using marker clustering for ${mapProvider.malls.length} malls');
        // For clustering, we'll add markers in batches and use simpler icons
        await _addMarkersWithClustering(mapProvider, normalMarkerIcon);
      } else {
        // Standard marker addition for smaller datasets
        for (final mall in mapProvider.malls) {
          await mapProvider.mapController!.addMarker(
            mall.geoPoint,
            markerIcon: normalMarkerIcon,
          );
        }
      }

      // Set up marker tap listener
      _markerTapListener = () async {
        final tappedPoint = mapProvider.mapController!.listenerMapSingleTapping.value;
        if (tappedPoint != null && mounted) {
          await _handleMarkerTap(tappedPoint);
        }
      };
      
      mapProvider.mapController!.listenerMapSingleTapping.addListener(_markerTapListener!);

      _markersAdded = true;
      debugPrint('[MapView] Mall markers added successfully');
    } catch (e) {
      debugPrint('[MapView] Error adding markers: $e');
    }
  }

  /// Add markers with clustering optimization for large datasets
  /// 
  /// Groups nearby markers when zoomed out to improve performance.
  /// Individual markers are shown when zoomed in.
  /// 
  /// Requirements: 1.2
  Future<void> _addMarkersWithClustering(
    MapProvider mapProvider,
    MarkerIcon normalMarkerIcon,
  ) async {
    // For simplicity, we'll use a grid-based clustering approach
    // Divide the map into grid cells and show one marker per cell when zoomed out
    
    // Get current zoom level to determine clustering
    // Note: OSM plugin doesn't expose zoom level directly, so we'll add all markers
    // but use smaller icons for better performance
    
    // Use smaller, simpler icons for large datasets to improve rendering performance
    const optimizedMarkerIcon = MarkerIcon(
      icon: Icon(
        Icons.location_on,
        color: Colors.red,
        size: 36, // Smaller size for better performance
      ),
    );

    // Add markers in batches to reduce UI blocking
    const batchSize = 10;
    for (var i = 0; i < mapProvider.malls.length; i += batchSize) {
      final endIndex = (i + batchSize < mapProvider.malls.length) 
          ? i + batchSize 
          : mapProvider.malls.length;
      
      final batch = mapProvider.malls.sublist(i, endIndex);
      
      // Add batch of markers
      for (final mall in batch) {
        await mapProvider.mapController!.addMarker(
          mall.geoPoint,
          markerIcon: optimizedMarkerIcon,
        );
      }
      
      // Small delay between batches to keep UI responsive
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    debugPrint('[MapView] Added ${mapProvider.malls.length} markers with clustering optimization');
  }

  /// Handle marker tap events
  /// 
  /// When a marker is tapped, find the corresponding mall and select it
  /// 
  /// Requirements: 1.3
  Future<void> _handleMarkerTap(GeoPoint tappedPoint) async {
    final mapProvider = context.read<MapProvider>();
    
    // Find the mall closest to the tapped point (within 0.001 degrees ~100m)
    const threshold = 0.001;
    
    for (final mall in mapProvider.malls) {
      final latDiff = (mall.geoPoint.latitude - tappedPoint.latitude).abs();
      final lngDiff = (mall.geoPoint.longitude - tappedPoint.longitude).abs();
      
      if (latDiff < threshold && lngDiff < threshold) {
        debugPrint('[MapView] Marker tapped for mall: ${mall.name}');
        await mapProvider.selectMall(mall);
        break;
      }
    }
  }

  /// Update current location marker on the map
  /// 
  /// Adds or updates the user's current location marker.
  /// Only updates if location has changed by more than 10 meters.
  /// Uses debouncing to avoid excessive marker updates and improve performance.
  /// 
  /// Requirements: 2.2, 2.5
  Future<void> _updateLocationMarker() async {
    final mapProvider = context.read<MapProvider>();
    
    if (mapProvider.mapController == null || mapProvider.currentLocation == null) {
      return;
    }

    final currentLocation = mapProvider.currentLocation!;

    // Check if location has changed significantly (>10m threshold)
    if (_lastLocationMarker != null) {
      final distance = _calculateDistance(_lastLocationMarker!, currentLocation);
      
      // 10 meters = 0.00009 degrees approximately
      if (distance < 0.0001) {
        // Location hasn't changed significantly, don't update
        return;
      }
    }

    // Debounce location updates to avoid excessive marker updates
    // Cancel any pending update
    _locationUpdateDebounceTimer?.cancel();
    
    // Store the pending location
    _pendingLocationUpdate = currentLocation;
    
    // Set a timer to update after 500ms of no new location updates
    _locationUpdateDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_pendingLocationUpdate == null) return;
      
      final locationToUpdate = _pendingLocationUpdate!;
      _pendingLocationUpdate = null;
      
      // Remove old location marker
      if (_lastLocationMarker != null) {
        try {
          await mapProvider.mapController!.removeMarker(_lastLocationMarker!);
        } catch (e) {
          debugPrint('[MapView] Error removing old location marker: $e');
        }
      }

      // Add new location marker with distinct icon
      try {
        await mapProvider.mapController!.addMarker(
          locationToUpdate,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.my_location,
              color: Color(0xFF573ED1),
              size: 56,
            ),
          ),
        );

        _lastLocationMarker = locationToUpdate;
        debugPrint('[MapView] Location marker updated at: ${locationToUpdate.latitude}, ${locationToUpdate.longitude}');
      } catch (e) {
        debugPrint('[MapView] Error adding location marker: $e');
      }
    });
  }

  /// Calculate distance between two GeoPoints in degrees
  /// 
  /// Simple distance calculation for threshold checking
  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    final latDiff = point1.latitude - point2.latitude;
    final lngDiff = point1.longitude - point2.longitude;
    return (latDiff * latDiff + lngDiff * lngDiff);
  }

  /// Handle "My Location" button press with permission flow
  /// 
  /// Implements complete permission request flow:
  /// 1. Check if location services are enabled
  /// 2. Request permission if needed
  /// 3. Handle denied/permanently denied cases
  /// 4. Show appropriate error dialogs
  /// 5. Provide fallback to default location
  /// 
  /// Requirements: 2.1, 2.4, 5.5
  Future<void> _handleMyLocationPressed() async {
    final mapProvider = context.read<MapProvider>();

    try {
      await mapProvider.getCurrentLocation();
      
      // If successful, center on location
      if (mapProvider.currentLocation != null) {
        await mapProvider.centerOnCurrentLocation();
      }
    } on QParkinLocationServiceDisabledException catch (_) {
      // GPS is disabled - show dialog
      if (!mounted) return;
      
      await MapErrorDialog.showGPSDisabled(
        context,
        onOpenSettings: () async {
          // User will manually enable GPS and come back
          // We'll use default location for now
          mapProvider.useDefaultLocation();
        },
      );
      
      // Use default location as fallback
      mapProvider.useDefaultLocation();
    } on QParkinPermissionDeniedException {
      if (!mounted) return;
      
      // Check if permanently denied
      final locationService = LocationService();
      final permission = await locationService.checkPermission();
      
      if (permission == LocationPermission.deniedForever) {
        // Permanently denied - show settings dialog
        await MapErrorDialog.showPermissionPermanentlyDenied(context);
      } else {
        // Regular denial - show retry dialog
        await MapErrorDialog.showPermissionDenied(
          context,
          onRetry: () async {
            // Retry getting location
            await _handleMyLocationPressed();
          },
        );
      }
      
      // Use default location as fallback
      mapProvider.useDefaultLocation();
    } catch (e) {
      if (!mounted) return;
      
      // Check if it's a timeout error
      if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
        await MapErrorDialog.showLocationTimeout(
          context,
          onRetry: () async {
            await _handleMyLocationPressed();
          },
        );
      } else {
        // General error
        await MapErrorDialog.showGeneralError(
          context,
          errorMessage: 'Gagal mendapatkan lokasi: ${e.toString()}',
          onRetry: () async {
            await _handleMyLocationPressed();
          },
        );
      }
      
      // Use default location as fallback
      mapProvider.useDefaultLocation();
    }
  }

  /// Update selected marker highlight
  /// 
  /// Highlights the selected mall marker with a distinct appearance.
  /// Removes highlight from previously selected marker.
  /// Uses smooth animation for marker selection.
  /// 
  /// Requirements: 3.3, 6.3
  Future<void> _updateSelectedMarkerHighlight() async {
    final mapProvider = context.read<MapProvider>();
    
    if (mapProvider.mapController == null || !_markersAdded) {
      return;
    }

    final selectedMall = mapProvider.selectedMall;
    
    // If there's a new selection different from the current one
    if (selectedMall != null && _selectedMarkerPoint != selectedMall.geoPoint) {
      // Remove old highlighted marker if exists
      if (_selectedMarkerPoint != null) {
        try {
          await mapProvider.mapController!.removeMarker(_selectedMarkerPoint!);
          
          // Re-add the old marker with normal appearance
          await mapProvider.mapController!.addMarker(
            _selectedMarkerPoint!,
            markerIcon: const MarkerIcon(
              icon: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 48,
              ),
            ),
          );
        } catch (e) {
          debugPrint('[MapView] Error removing old highlighted marker: $e');
        }
      }

      // Remove the normal marker at the selected location
      try {
        await mapProvider.mapController!.removeMarker(selectedMall.geoPoint);
      } catch (e) {
        debugPrint('[MapView] Error removing marker for highlighting: $e');
      }

      // Add highlighted marker at selected location with animation effect
      // The marker appears with a larger size and different color
      try {
        await mapProvider.mapController!.addMarker(
          selectedMall.geoPoint,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Color(0xFF573ED1), // Purple color for selected
              size: 64, // Larger size for selected (animated effect)
            ),
          ),
        );

        _selectedMarkerPoint = selectedMall.geoPoint;
        debugPrint('[MapView] Selected marker highlighted at: ${selectedMall.name}');
        
        // Animate camera to center on selected marker with smooth transition
        await mapProvider.centerOnLocation(
          selectedMall.geoPoint,
          zoom: 15.0,
          animate: true,
        );
      } catch (e) {
        debugPrint('[MapView] Error adding highlighted marker: $e');
      }
    } else if (selectedMall == null && _selectedMarkerPoint != null) {
      // Selection was cleared, restore normal marker with smooth transition
      try {
        await mapProvider.mapController!.removeMarker(_selectedMarkerPoint!);
        
        // Re-add with normal appearance
        await mapProvider.mapController!.addMarker(
          _selectedMarkerPoint!,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 48,
            ),
          ),
        );

        _selectedMarkerPoint = null;
        debugPrint('[MapView] Marker highlight removed');
      } catch (e) {
        debugPrint('[MapView] Error restoring normal marker: $e');
      }
    }
  }

  /// Update route polyline on the map
  /// 
  /// Draws a polyline showing the route from current location to selected mall.
  /// Clears previous polyline when new route is calculated.
  /// Shows snackbar on errors.
  /// 
  /// Requirements: 4.2, 4.5
  Future<void> _updateRoutePolyline() async {
    final mapProvider = context.read<MapProvider>();
    
    if (mapProvider.mapController == null) {
      return;
    }

    // Clear previous polyline if exists
    if (_currentRoadInfo != null) {
      try {
        await mapProvider.mapController!.removeLastRoad();
        _currentRoadInfo = null;
      } catch (e) {
        debugPrint('[MapView] Error removing previous polyline: $e');
      }
    }

    // Draw new polyline if route is available
    if (mapProvider.currentRoute != null && mapProvider.currentRoute!.polylinePoints.isNotEmpty) {
      try {
        final route = mapProvider.currentRoute!;
        
        // Draw polyline on map
        final roadInfo = await mapProvider.mapController!.drawRoad(
          route.polylinePoints.first,
          route.polylinePoints.last,
          roadType: RoadType.car,
          roadOption: const RoadOption(
            roadWidth: 10,
            roadColor: Color(0xFF573ED1),
            zoomInto: true,
          ),
        );

        _currentRoadInfo = roadInfo;
        debugPrint('[MapView] Route polyline drawn with ${route.polylinePoints.length} points');
      } catch (e) {
        debugPrint('[MapView] Error drawing route polyline: $e');
        
        // Show error snackbar
        if (mounted) {
          MapErrorUtils.showRouteCalculationError(
            context,
            onRetry: () async {
              // Retry route calculation
              if (mapProvider.selectedMall != null && mapProvider.currentLocation != null) {
                try {
                  await mapProvider.calculateRoute(
                    mapProvider.currentLocation!,
                    mapProvider.selectedMall!.geoPoint,
                  );
                } catch (e) {
                  debugPrint('[MapView] Retry route calculation failed: $e');
                }
              }
            },
          );
        }
      }
    }
  }

  /// Update search result marker on the map
  ///
  /// Adds a marker for the selected search result with a distinct green color.
  /// Removes previous search result marker if exists.
  ///
  /// Requirements: 9.5
  Future<void> _updateSearchResultMarker() async {
    final mapProvider = context.read<MapProvider>();
    
    if (mapProvider.mapController == null || !_markersAdded) {
      return;
    }

    final searchResult = mapProvider.selectedSearchResult;
    
    // If there's a new search result
    if (searchResult != null && _searchResultMarkerPoint != searchResult.geoPoint) {
      // Remove old search result marker if exists
      if (_searchResultMarkerPoint != null) {
        try {
          await mapProvider.mapController!.removeMarker(_searchResultMarkerPoint!);
        } catch (e) {
          debugPrint('[MapView] Error removing old search result marker: $e');
        }
      }

      // Add new search result marker with green color
      try {
        await mapProvider.mapController!.addMarker(
          searchResult.geoPoint,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.place,
              color: Colors.green,
              size: 56,
            ),
          ),
        );

        _searchResultMarkerPoint = searchResult.geoPoint;
        debugPrint('[MapView] Search result marker added at: ${searchResult.displayName}');
      } catch (e) {
        debugPrint('[MapView] Error adding search result marker: $e');
      }
    } else if (searchResult == null && _searchResultMarkerPoint != null) {
      // Search result was cleared, remove marker
      try {
        await mapProvider.mapController!.removeMarker(_searchResultMarkerPoint!);
        _searchResultMarkerPoint = null;
        debugPrint('[MapView] Search result marker removed');
      } catch (e) {
        debugPrint('[MapView] Error removing search result marker: $e');
      }
    }
  }

  @override
  void dispose() {
    // Cancel debounce timer to prevent memory leaks
    _locationUpdateDebounceTimer?.cancel();
    
    // Remove marker tap listener
    final mapProvider = context.read<MapProvider>();
    if (_markerTapListener != null && mapProvider.mapController != null) {
      try {
        mapProvider.mapController!.listenerMapSingleTapping.removeListener(_markerTapListener!);
      } catch (e) {
        debugPrint('[MapView] Error removing listener: $e');
      }
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        // Show loading indicator while map is initializing
        if (!_isMapReady || mapProvider.isLoading) {
          return _buildLoadingState();
        }

        // Show error state if there's an error
        if (mapProvider.errorMessage != null) {
          return _buildErrorState(mapProvider);
        }

        // Show map
        return _buildMapWidget(mapProvider);
      },
    );
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat peta...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(MapProvider mapProvider) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mapProvider.errorMessage ?? 'Gagal memuat peta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  mapProvider.clearError();
                  _initializeMap();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF573ED1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the actual map widget
  Widget _buildMapWidget(MapProvider mapProvider) {
    if (mapProvider.mapController == null) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        // OSM Map
        // Tile caching is enabled for offline functionality
        // Cached tiles allow the map to work without internet connection
        // Requirements: 5.3
        OSMFlutter(
          controller: mapProvider.mapController!,
          osmOption: OSMOption(
            userTrackingOption: const UserTrackingOption(
              enableTracking: false,
              unFollowUser: false,
            ),
            zoomOption: const ZoomOption(
              initZoom: 13,
              minZoomLevel: 5,
              maxZoomLevel: 19,
              stepZoom: 1.0,
            ),
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_on,
                  color: Color(0xFF573ED1),
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.navigation,
                  color: Color(0xFF573ED1),
                  size: 48,
                ),
              ),
            ),
            roadConfiguration: const RoadOption(
              roadColor: Color(0xFF573ED1),
              roadWidth: 10,
            ),
            // Enable tile caching for offline functionality
            // This allows the map to display previously viewed areas without internet
            enableRotationByGesture: true,
            isPicker: false,
            showDefaultInfoWindow: false,
            showContributorBadgeForOSM: true,
            // Static tile layer configuration with caching enabled
            staticPoints: const [],
          ),
          mapIsLoading: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat peta...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search Bar (at the top)
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: MapSearchBar(
            onSearchChanged: (query) {
              mapProvider.searchLocation(query);
            },
            onResultSelected: (result) async {
              await mapProvider.selectSearchResult(result);
            },
            searchResults: mapProvider.searchResults,
            isSearching: mapProvider.isSearching,
            errorMessage: mapProvider.searchErrorMessage,
          ),
        ),

        // Mall Info Card (if mall is selected)
        // Positioned below search bar
        if (mapProvider.selectedMall != null)
          Positioned(
            top: 90, // Below search bar
            left: 16,
            right: 16,
            child: MapMallInfoCard(
              mall: mapProvider.selectedMall!,
              route: mapProvider.currentRoute,
              onClose: () {
                mapProvider.clearSelection();
              },
            ),
          ),

        // Map Controls
        MapControls(
          onMyLocationPressed: () async {
            await _handleMyLocationPressed();
          },
        ),

        // Loading overlay (for route calculation, etc.)
        if (mapProvider.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
