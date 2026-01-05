import 'package:flutter/widgets.dart';
import '../../data/models/user_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/services/vehicle_api_service.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/auth_service.dart';
import 'dart:io';

/// Provider for managing profile-related data and operations
/// Implements state management for user data and vehicle list
/// Now integrated with VehicleApiService for real backend data
class ProfileProvider extends ChangeNotifier {
  // Private state
  UserModel? _user;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  
  // API Services
  final VehicleApiService _vehicleApiService;
  final ProfileService _profileService;
  final AuthService _authService;

  // Constructor with required API services
  ProfileProvider({
    required VehicleApiService vehicleApiService,
    ProfileService? profileService,
    AuthService? authService,
  })  : _vehicleApiService = vehicleApiService,
        _profileService = profileService ?? ProfileService(),
        _authService = authService ?? AuthService();

  // Getters
  UserModel? get user => _user;
  List<VehicleModel> get vehicles => List.unmodifiable(_vehicles);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Fetch user data from API or local storage
  /// Sets loading state and handles errors appropriately
  Future<void> fetchUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ProfileProvider] Fetching user data from API...');
      
      // Get auth token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }
      
      // Fetch from real API
      _user = await _profileService.fetchUserData(token: token);

      _lastSyncTime = DateTime.now();
      _isLoading = false;
      _errorMessage = null;
      
      debugPrint('[ProfileProvider] User data fetched successfully: ${_user?.name}');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getUserFriendlyError(e.toString());
      
      debugPrint('[ProfileProvider] Error fetching user data: $e');
      notifyListeners();
    }
  }

  /// Fetch vehicles associated with the user
  /// Sets loading state and handles errors appropriately
  /// Now fetches from real backend API
  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ProfileProvider] Fetching vehicles from API...');
      
      // Fetch from real API
      _vehicles = await _vehicleApiService.getVehicles();

      _lastSyncTime = DateTime.now();
      _isLoading = false;
      _errorMessage = null;
      
      debugPrint('[ProfileProvider] Vehicles fetched successfully: ${_vehicles.length} vehicles');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      
      // Handle 404 gracefully - empty list is not an error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('404') || errorString.contains('not found')) {
        // 404 means no vehicles found, which is valid - just empty list
        _vehicles = [];
        _errorMessage = null; // Don't show error for empty list
        debugPrint('[ProfileProvider] No vehicles found (404) - showing empty state');
      } else {
        // Other errors should be shown to user
        _errorMessage = _getUserFriendlyError(e.toString());
        debugPrint('[ProfileProvider] Error fetching vehicles: $e');
      }
      
      notifyListeners();
    }
  }

  /// Update user data
  /// Notifies listeners on successful update
  /// IMPORTANT: Always fetch fresh data after update to ensure UI shows latest data
  Future<void> updateUser(UserModel user) async {
    try {
      debugPrint('[ProfileProvider] Updating user data via API...');
      debugPrint('[ProfileProvider] Update payload - name: ${user.name}, email: ${user.email}');
      
      // Get auth token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }
      
      // Update via real API
      final updatedUser = await _profileService.updateUser(user: user, token: token);
      
      // CRITICAL: Update local state with response from API
      _user = updatedUser;
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] User data updated successfully');
      debugPrint('[ProfileProvider] Updated email from API: ${updatedUser.email}');
      
      // Notify listeners immediately with fresh data
      notifyListeners();
      
      // IMPORTANT: Fetch fresh data from API to ensure complete sync
      // This ensures any server-side transformations are reflected
      await fetchUserData();
      
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error updating user: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Add a new vehicle to the list
  /// Notifies listeners on successful addition
  /// Now uses real backend API
  Future<void> addVehicle({
    required String platNomor,
    required String jenisKendaraan,
    required String merk,
    required String tipe,
    String? warna,
    bool isActive = false,
    File? foto,
  }) async {
    try {
      debugPrint('[ProfileProvider] Adding vehicle via API...');
      
      // Add via real API
      final newVehicle = await _vehicleApiService.addVehicle(
        platNomor: platNomor,
        jenisKendaraan: jenisKendaraan,
        merk: merk,
        tipe: tipe,
        warna: warna,
        isActive: isActive,
        foto: foto,
      );
      
      // Add to local list
      _vehicles.add(newVehicle);
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] Vehicle added successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error adding vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing vehicle
  /// Notifies listeners on successful update
  /// Now uses real backend API
  Future<void> updateVehicle({
    required String id,
    String? platNomor,
    String? jenisKendaraan,
    String? merk,
    String? tipe,
    String? warna,
    bool? isActive,
    File? foto,
  }) async {
    try {
      debugPrint('[ProfileProvider] Updating vehicle via API...');
      
      // Update via real API
      final updatedVehicle = await _vehicleApiService.updateVehicle(
        id: id,
        platNomor: platNomor,
        jenisKendaraan: jenisKendaraan,
        merk: merk,
        tipe: tipe,
        warna: warna,
        isActive: isActive,
        foto: foto,
      );
      
      // Update in local list
      final index = _vehicles.indexWhere((v) => v.idKendaraan == id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        _lastSyncTime = DateTime.now();
        
        debugPrint('[ProfileProvider] Vehicle updated successfully');
        notifyListeners();
      } else {
        throw Exception('Vehicle not found');
      }
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error updating vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a vehicle from the list
  /// Notifies listeners on successful deletion
  /// Now uses real backend API
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      debugPrint('[ProfileProvider] Deleting vehicle via API...');
      
      // Delete via real API
      await _vehicleApiService.deleteVehicle(vehicleId);
      
      // Remove from local list
      _vehicles.removeWhere((v) => v.idKendaraan == vehicleId);
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] Vehicle deleted successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error deleting vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Set a vehicle as the active vehicle
  /// Ensures only one vehicle is active at a time
  /// Now uses real backend API
  Future<void> setActiveVehicle(String vehicleId) async {
    try {
      debugPrint('[ProfileProvider] Setting active vehicle via API...');
      
      // Set active via real API
      final updatedVehicle = await _vehicleApiService.setActiveVehicle(vehicleId);
      
      // Update local list - deactivate all first
      _vehicles = _vehicles.map((v) => v.copyWith(isActive: false)).toList();
      
      // Activate the selected vehicle
      final index = _vehicles.indexWhere((v) => v.idKendaraan == vehicleId);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        _lastSyncTime = DateTime.now();
        
        debugPrint('[ProfileProvider] Active vehicle set successfully');
        notifyListeners();
      } else {
        throw Exception('Vehicle not found');
      }
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error setting active vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  /// Allows user to dismiss error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh all profile data (user and vehicles)
  /// Used for pull-to-refresh functionality
  Future<void> refreshAll() async {
    debugPrint('[ProfileProvider] Refreshing all data...');
    
    // Fetch both user data and vehicles
    await Future.wait([
      fetchUserData(),
      fetchVehicles(),
    ]);
    
    debugPrint('[ProfileProvider] All data refreshed');
  }

  /// Convert technical error messages to user-friendly messages
  String _getUserFriendlyError(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('timeout') || errorLower.contains('connection')) {
      return 'Koneksi internet bermasalah. Silakan periksa koneksi Anda.';
    } else if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (errorLower.contains('404') || errorLower.contains('not found')) {
      return 'Data tidak ditemukan. Silakan coba lagi.';
    } else if (errorLower.contains('500') || errorLower.contains('server')) {
      return 'Server sedang bermasalah. Silakan coba beberapa saat lagi.';
    } else if (errorLower.contains('network')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Clear all data
  void clear() {
    debugPrint('[ProfileProvider] Clearing all data');
    _user = null;
    _vehicles = [];
    _isLoading = false;
    _errorMessage = null;
    _lastSyncTime = null;
    notifyListeners();
  }

  /// Set error state for testing purposes
  /// This method should only be used in tests
  @visibleForTesting
  void setErrorForTesting(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Set user data for testing purposes
  /// This method should only be used in tests
  @visibleForTesting
  void setUser(UserModel? user) {
    _user = user;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set vehicles list for testing purposes
  /// This method should only be used in tests
  @visibleForTesting
  void setVehicles(List<VehicleModel> vehicles) {
    _vehicles = vehicles;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Set loading state for testing purposes
  /// This method should only be used in tests
  @visibleForTesting
  void setLoadingForTesting(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[ProfileProvider] Disposing provider');
    _profileService.dispose();
    super.dispose();
  }
}
