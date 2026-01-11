import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/mall_model.dart';
import '../../data/models/route_data.dart';
import '../../data/models/search_result_model.dart';
import '../../data/services/location_service.dart';
import '../../data/services/route_service.dart';
import '../../data/services/search_service.dart' as search;
import '../../data/services/mall_service.dart';
import '../../utils/map_logger.dart';

/// Provider for managing map state and operations
///
/// Handles map initialization, location management, mall selection,
/// route calculation, and error handling for the OSM map integration.
/// 
/// State Persistence:
/// This provider maintains all state across device rotations and configuration
/// changes. The ChangeNotifier pattern ensures that state is preserved in the
/// widget tree, and all properties (selected mall, current location, route, etc.)
/// remain intact when the device is rotated.
///
/// Requirements: 1.1, 3.1, 3.2, 6.4, 6.5
class MapProvider extends ChangeNotifier {
  final LocationService _locationService;
  final RouteService _routeService;
  final search.SearchService _searchService;
  final MallService _mallService;  // Tambah MallService

  // State properties - Map controller
  MapController? _mapController;

  // State properties - Mall data
  MallModel? _selectedMall;
  List<MallModel> _malls = [];

  // State properties - Location
  GeoPoint? _currentLocation;

  // State properties - Route
  RouteData? _currentRoute;

  // State properties - Search
  List<SearchResultModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchErrorMessage;
  SearchResultModel? _selectedSearchResult;

  // State properties - Loading and errors
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  MapController? get mapController => _mapController;
  MallModel? get selectedMall => _selectedMall;
  List<MallModel> get malls => List.unmodifiable(_malls);
  GeoPoint? get currentLocation => _currentLocation;
  RouteData? get currentRoute => _currentRoute;
  List<SearchResultModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;
  String? get searchErrorMessage => _searchErrorMessage;
  SearchResultModel? get selectedSearchResult => _selectedSearchResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed properties
  bool get hasSelectedMall => _selectedMall != null;
  bool get hasCurrentLocation => _currentLocation != null;
  bool get hasRoute => _currentRoute != null;
  bool get isMapInitialized => _mapController != null;

  // Logger instance
  final MapLogger _logger = MapLogger.instance;

  MapProvider({
    LocationService? locationService,
    RouteService? routeService,
    search.SearchService? searchService,
    MallService? mallService,  // Tambah parameter
  })  : _locationService = locationService ?? LocationService(),
        _routeService = routeService ?? RouteService(),
        _searchService = searchService ?? search.SearchService(),
        _mallService = mallService ?? MallService(
          baseUrl: const String.fromEnvironment('API_URL', 
            defaultValue: 'http://192.168.1.100:8000')
        );

  /// Initialize the map controller.
  ///
  /// Creates a new [MapController] instance for OSM map with default settings.
  /// Should be called when the map widget is ready to be displayed, typically
  /// in the widget's initState or when the map tab becomes active.
  /// 
  /// The map is initialized with:
  /// - Default center: Batam city center (1.1°N, 104.0°E)
  /// - Automatic tile caching for offline functionality
  /// - Standard zoom and pan controls
  /// 
  /// Tile caching is automatically enabled by flutter_osm_plugin.
  /// Previously viewed map tiles are cached locally, allowing offline viewing
  /// of areas that have been loaded before. This improves performance and
  /// provides fallback functionality when network is unavailable.
  /// 
  /// Throws:
  ///   - [Exception] if map controller creation fails
  /// 
  /// Example:
  /// ```dart
  /// final mapProvider = MapProvider();
  /// await mapProvider.initializeMap();
  /// if (mapProvider.isMapInitialized) {
  ///   print('Map ready to use');
  /// }
  /// ```
  ///
  /// Requirements: 1.1, 7.1, 5.3
  Future<void> initializeMap() async {
    debugPrint('[MapProvider] Initializing map...');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create map controller
      // Default center: Batam city center (1.1, 104.0)
      // Note: flutter_osm_plugin automatically enables tile caching
      // for offline functionality (Requirement 5.3)
      _mapController = MapController(
        initPosition: GeoPoint(latitude: 1.1, longitude: 104.0),
      );

      debugPrint('[MapProvider] Map controller created successfully');
      debugPrint('[MapProvider] Tile caching enabled for offline functionality');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menginisialisasi peta: ${e.toString()}';
      
      debugPrint('[MapProvider] Error initializing map: $e');
      _logger.logStateManagementError(
        e.toString(),
        'MapProvider.initializeMap',
        currentState: 'initializing',
        attemptedAction: 'create map controller',
      );
      
      notifyListeners();
      rethrow;
    }
  }

  /// Load mall data from dummy data source
  ///
  /// TODO: API Integration - Replace with backend API call
  /// 
  /// API endpoint: GET /api/malls
  /// 
  /// Expected API response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": [
  ///     {
  ///       "id_mall": "1",
  ///       "nama_mall": "Mega Mall Batam Centre",
  ///       "lokasi": "Jl. Engku Putri no.1, Batam Centre",
  ///       "alamat_gmaps": "https://maps.google.com/?q=1.1191,104.0538",
  ///       "kapasitas": 45
  ///     }
  ///   ]
  /// }
  /// ```
  /// 
  /// Integration steps:
  /// 1. Import http package (already available in project)
  /// 2. Get API_URL from environment or config
  /// 3. Make GET request with error handling
  /// 4. Parse response and map to MallModel list
  /// 5. Handle network errors appropriately
  /// 
  /// Example implementation:
  /// ```dart
  /// import 'package:http/http.dart' as http;
  /// import 'dart:convert';
  /// 
  /// final response = await http.get(
  ///   Uri.parse('$API_URL/api/malls'),
  ///   headers: {'Accept': 'application/json'},
  /// ).timeout(const Duration(seconds: 10));
  /// 
  /// if (response.statusCode == 200) {
  ///   final jsonData = json.decode(response.body);
  ///   final mallsData = jsonData['data'] as List<dynamic>;
  ///   _malls = mallsData.map((json) => MallModel.fromJson(json)).toList();
  /// } else {
  /// Load mall data from backend API
  /// 
  /// Fetches active malls from /api/mall endpoint
  /// NO FALLBACK - Shows error state if API fails
  ///
  /// Requirements: 1.1, 7.1, 7.4
  Future<void> loadMalls() async {
    debugPrint('[MapProvider] Loading malls from API...');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch from API - NO FALLBACK
      _malls = await _mallService.fetchMalls();

      debugPrint('[MapProvider] Loaded ${_malls.length} malls from API');

      // Validate all malls have coordinates
      final invalidMalls = _malls.where((m) => !m.validate()).toList();
      if (invalidMalls.isNotEmpty) {
        debugPrint('[MapProvider] Warning: ${invalidMalls.length} malls have invalid data');
        _malls.removeWhere((m) => !m.validate());
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[MapProvider] Error loading malls from API: $e');
      
      // NO FALLBACK - Clear malls and show error
      _malls = [];
      _isLoading = false;
      _errorMessage = 'Gagal memuat data mall dari server. Silakan coba lagi.';
      
      _logger.logError(
        'MALL_LOAD_ERROR',
        e.toString(),
        'MapProvider.loadMalls',
      );
      
      notifyListeners();
      rethrow; // Propagate error to UI
    }
  }

  /// Get current location using LocationService
  ///
  /// Requests location permission if needed and retrieves the user's
  /// current position. Updates currentLocation state.
  ///
  /// Requirements: 2.2, 2.3, 2.4
  Future<void> getCurrentLocation({bool showRationale = false}) async {
    debugPrint('[MapProvider] Getting current location...');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if location services are enabled
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw QParkinLocationServiceDisabledException(
          'GPS tidak aktif. Silakan aktifkan layanan lokasi.',
        );
      }

      // Check and request permission if needed
      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
        if (permission == LocationPermission.denied) {
          throw QParkinPermissionDeniedException(
            'Izin lokasi ditolak. Aplikasi memerlukan izin lokasi untuk menampilkan posisi Anda.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw QParkinPermissionDeniedException(
          'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan perangkat.',
        );
      }

      // Get current position
      final position = await _locationService.getCurrentPosition();
      _currentLocation = _locationService.positionToGeoPoint(position);

      debugPrint('[MapProvider] Current location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}');

      _isLoading = false;
      notifyListeners();
    } on QParkinLocationServiceDisabledException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      
      debugPrint('[MapProvider] Location service disabled: $e');
      _logger.logLocationServiceError(
        e.toString(),
        'MapProvider.getCurrentLocation',
        serviceEnabled: false,
      );
      
      notifyListeners();
      rethrow;
    } on QParkinPermissionDeniedException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      
      debugPrint('[MapProvider] Permission denied: $e');
      _logger.logLocationPermissionError(
        e.toString(),
        'MapProvider.getCurrentLocation',
        permissionStatus: 'denied',
      );
      
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
      
      debugPrint('[MapProvider] Error getting location: $e');
      _logger.logError(
        'LOCATION_ERROR',
        e.toString(),
        'MapProvider.getCurrentLocation',
      );
      
      notifyListeners();
      rethrow;
    }
  }

  /// Use default location (Batam city center) as fallback
  ///
  /// Called when location permission is denied or GPS is disabled.
  /// Sets a default location so the app can continue functioning.
  ///
  /// Requirements: 1.4, 2.4
  void useDefaultLocation() {
    debugPrint('[MapProvider] Using default location (Batam city center)');
    
    // Batam city center coordinates
    _currentLocation = GeoPoint(latitude: 1.1, longitude: 104.0);
    _errorMessage = null;
    
    notifyListeners();
  }

  /// Center map camera on a specific location.
  ///
  /// Moves the map camera to the specified location with the given zoom level.
  /// Can use smooth animation for better user experience or instant movement
  /// for immediate positioning.
  /// 
  /// The camera movement is non-blocking and errors are handled gracefully.
  /// If the map controller is not initialized, the method returns without error.
  ///
  /// Parameters:
  ///   - [location]: The [GeoPoint] to center on
  ///   - [zoom]: Zoom level (5-20, default: 15). Higher values = more zoomed in
  ///   - [animate]: Whether to animate the camera movement (default: true)
  /// 
  /// Example:
  /// ```dart
  /// final mapProvider = context.read<MapProvider>();
  /// final location = GeoPoint(latitude: 1.1191, longitude: 104.0538);
  /// 
  /// // Smooth animated movement
  /// await mapProvider.centerOnLocation(location);
  /// 
  /// // Instant movement with custom zoom
  /// await mapProvider.centerOnLocation(
  ///   location,
  ///   zoom: 18.0,
  ///   animate: false,
  /// );
  /// ```
  ///
  /// Requirements: 2.2, 2.3, 2.4, 6.3
  Future<void> centerOnLocation(
    GeoPoint location, {
    double zoom = 15.0,
    bool animate = true,
  }) async {
    if (_mapController == null) {
      debugPrint('[MapProvider] Cannot center - map controller not initialized');
      return;
    }

    try {
      debugPrint('[MapProvider] Centering map on: ${location.latitude}, ${location.longitude}');

      if (animate) {
        // Smooth animated camera movement
        await _mapController!.setZoom(zoomLevel: zoom);
        await _mapController!.goToLocation(location);
      } else {
        // Instant camera movement (no animation)
        await _mapController!.setZoom(zoomLevel: zoom);
        await _mapController!.goToLocation(location);
      }

      debugPrint('[MapProvider] Map centered successfully');
    } catch (e) {
      debugPrint('[MapProvider] Error centering map: $e');
      _logger.logStateManagementError(
        e.toString(),
        'MapProvider.centerOnLocation',
        currentState: 'centering',
        attemptedAction: 'move camera to location',
      );
      // Don't rethrow - this is not a critical error
    }
  }

  /// Center map on current location
  ///
  /// Convenience method that centers the map on the user's current location.
  /// Gets current location if not already available.
  ///
  /// Requirements: 2.2, 2.3, 2.4
  Future<void> centerOnCurrentLocation() async {
    debugPrint('[MapProvider] Centering on current location...');

    try {
      // Get current location if not available
      if (_currentLocation == null) {
        await getCurrentLocation();
      }

      if (_currentLocation != null) {
        await centerOnLocation(_currentLocation!);
      } else {
        debugPrint('[MapProvider] Current location not available');
      }
    } catch (e) {
      debugPrint('[MapProvider] Error centering on current location: $e');
      // Error already logged in getCurrentLocation
    }
  }

  /// Select a mall and update state.
  ///
  /// Updates the selected mall, centers the map on it with smooth animation,
  /// and automatically triggers route calculation if current location is available.
  /// Notifies all listeners of the state change.
  /// 
  /// This method performs the following actions:
  /// 1. Updates the selected mall state
  /// 2. Centers the map camera on the mall location
  /// 3. Calculates route from current location (if available)
  /// 4. Notifies UI to update (show info card, highlight marker)
  ///
  /// Parameters:
  ///   - [mall]: The [MallModel] to select
  /// 
  /// Example:
  /// ```dart
  /// final mapProvider = context.read<MapProvider>();
  /// final mall = mapProvider.malls.first;
  /// await mapProvider.selectMall(mall);
  /// 
  /// // UI will automatically update to show:
  /// // - Highlighted marker
  /// // - Info card with mall details
  /// // - Route polyline (if location available)
  /// ```
  ///
  /// Requirements: 3.1, 3.2, 3.3, 3.5
  Future<void> selectMall(MallModel mall) async {
    debugPrint('[MapProvider] Selecting mall: ${mall.name}');

    try {
      _selectedMall = mall;
      notifyListeners();

      // Center map on selected mall
      await centerOnLocation(mall.geoPoint);

      // Calculate route if current location is available
      if (_currentLocation != null) {
        await calculateRoute(_currentLocation!, mall.geoPoint);
      }

      debugPrint('[MapProvider] Mall selected successfully');
    } catch (e) {
      debugPrint('[MapProvider] Error selecting mall: $e');
      _logger.logStateManagementError(
        e.toString(),
        'MapProvider.selectMall',
        currentState: 'selecting mall',
        attemptedAction: 'select mall: ${mall.name}',
      );
      // Don't rethrow - partial success is acceptable
    }
  }

  /// Clear mall selection.
  ///
  /// Resets the selected mall to null and clears the current route.
  /// Notifies all listeners to update the UI (remove info card, unhighlight marker).
  /// 
  /// Example:
  /// ```dart
  /// final mapProvider = context.read<MapProvider>();
  /// mapProvider.clearSelection();
  /// 
  /// // UI will automatically update to:
  /// // - Remove info card
  /// // - Restore normal marker appearance
  /// // - Clear route polyline
  /// ```
  ///
  /// Requirements: 3.1, 3.2, 3.3, 3.5
  void clearSelection() {
    debugPrint('[MapProvider] Clearing mall selection');

    _selectedMall = null;
    _currentRoute = null;
    notifyListeners();
  }

  /// Calculate route between two points
  ///
  /// Uses RouteService to calculate a route and updates the currentRoute state.
  /// Handles errors gracefully and logs them for debugging.
  ///
  /// Parameters:
  /// - [origin]: Starting point of the route
  /// - [destination]: End point of the route
  ///
  /// Requirements: 4.1, 4.5
  Future<void> calculateRoute(GeoPoint origin, GeoPoint destination) async {
    debugPrint('[MapProvider] Calculating route...');
    debugPrint('  Origin: ${origin.latitude}, ${origin.longitude}');
    debugPrint('  Destination: ${destination.latitude}, ${destination.longitude}');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Calculate route using RouteService
      final route = await _routeService.calculateRoute(origin, destination);
      
      _currentRoute = route;

      debugPrint('[MapProvider] Route calculated successfully');
      debugPrint('  Distance: ${route.distanceInKm} km');
      debugPrint('  Duration: ${route.durationInMinutes} minutes');
      debugPrint('  Polyline points: ${route.polylinePoints.length}');

      _isLoading = false;
      notifyListeners();
    } on RouteCalculationException catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghitung rute: ${e.message}';
      _currentRoute = null;
      
      debugPrint('[MapProvider] Route calculation failed: $e');
      _logger.logRouteCalculationError(
        e.toString(),
        'MapProvider.calculateRoute',
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
      );
      
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _currentRoute = null;
      
      debugPrint('[MapProvider] Unexpected error during route calculation: $e');
      _logger.logError(
        'ROUTE_ERROR',
        e.toString(),
        'MapProvider.calculateRoute',
        stackTrace: stackTrace,
        additionalData: {
          'originLat': origin.latitude,
          'originLng': origin.longitude,
          'destLat': destination.latitude,
          'destLng': destination.longitude,
        },
      );
      
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  ///
  /// Resets the error state to allow user to retry operations.
  ///
  /// Requirements: 5.4
  void clearError() {
    debugPrint('[MapProvider] Clearing error');
    _errorMessage = null;
    notifyListeners();
  }

  /// Search for locations using OSM Nominatim API
  ///
  /// Performs location search with debouncing to avoid excessive API calls.
  /// Updates searchResults state with found locations.
  ///
  /// Parameters:
  ///   - [query]: Search query string (minimum 3 characters)
  ///
  /// Requirements: 9.2, 9.3, 9.4, 9.7, 9.8, 9.9
  void searchLocation(String query) {
    debugPrint('[MapProvider] Searching for: $query');

    // Clear previous error
    _searchErrorMessage = null;

    // If query is too short, clear results
    if (query.trim().length < 3) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Set searching state
    _isSearching = true;
    notifyListeners();

    // Use SearchService with debouncing
    _searchService.searchWithDebounce(
      query,
      onResults: (results) {
        debugPrint('[MapProvider] Search completed with ${results.length} results');
        _searchResults = results;
        _isSearching = false;
        _searchErrorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('[MapProvider] Search error: $error');
        _searchResults = [];
        _isSearching = false;
        _searchErrorMessage = error;
        
        _logger.logError(
          'SEARCH_ERROR',
          error,
          'MapProvider.searchLocation',
          additionalData: {'query': query},
        );
        
        notifyListeners();
      },
      countryCode: 'id', // Limit to Indonesia
      // Viewbox for Batam area to prioritize local results
      viewbox: '103.8,1.0,104.2,1.3',
    );
  }

  /// Select a search result and navigate to it
  ///
  /// Centers the map on the selected search result, adds a marker,
  /// and calculates route if current location is available.
  ///
  /// Parameters:
  ///   - [result]: The [SearchResultModel] to select
  ///
  /// Requirements: 9.5, 9.10
  Future<void> selectSearchResult(SearchResultModel result) async {
    debugPrint('[MapProvider] Selecting search result: ${result.displayName}');

    try {
      _selectedSearchResult = result;
      _searchResults = []; // Clear search results
      notifyListeners();

      // Center map on selected location
      await centerOnLocation(result.geoPoint, zoom: 16.0);

      // Calculate route if current location is available
      if (_currentLocation != null) {
        await calculateRoute(_currentLocation!, result.geoPoint);
      }

      debugPrint('[MapProvider] Search result selected successfully');
    } catch (e) {
      debugPrint('[MapProvider] Error selecting search result: $e');
      _logger.logStateManagementError(
        e.toString(),
        'MapProvider.selectSearchResult',
        currentState: 'selecting search result',
        attemptedAction: 'select: ${result.displayName}',
      );
      // Don't rethrow - partial success is acceptable
    }
  }

  /// Clear search results and selected search result
  ///
  /// Requirements: 9.6
  void clearSearch() {
    debugPrint('[MapProvider] Clearing search');
    
    _searchResults = [];
    _isSearching = false;
    _searchErrorMessage = null;
    _selectedSearchResult = null;
    
    // Cancel any pending search
    _searchService.cancelPendingSearch();
    
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[MapProvider] Disposing provider');
    _mapController?.dispose();
    _searchService.dispose();
    super.dispose();
  }

}
