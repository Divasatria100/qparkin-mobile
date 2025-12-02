import 'package:flutter/widgets.dart';
import '../../data/models/user_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/vehicle_statistics.dart';

/// Provider for managing profile-related data and operations
/// Implements state management for user data and vehicle list
class ProfileProvider extends ChangeNotifier {
  // Private state
  UserModel? _user;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;

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
      debugPrint('[ProfileProvider] Fetching user data...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      // For now, simulate API call with delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock user data for development
      _user = UserModel(
        id: '1',
        name: 'User Name',
        email: 'user@example.com',
        phoneNumber: '081234567890',
        photoUrl: null,
        saldoPoin: 150,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      _lastSyncTime = DateTime.now();
      _isLoading = false;
      _errorMessage = null;
      
      debugPrint('[ProfileProvider] User data fetched successfully');
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
  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ProfileProvider] Fetching vehicles...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      // For now, simulate API call with delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock vehicle data for development
      _vehicles = [
        VehicleModel(
          idKendaraan: '1',
          platNomor: 'B 1234 XYZ',
          jenisKendaraan: 'Roda Empat',
          merk: 'Toyota',
          tipe: 'Avanza',
          warna: 'Hitam',
          isActive: true,
          statistics: VehicleStatistics(
            parkingCount: 15,
            totalParkingMinutes: 1200, // 20 hours
            totalCostSpent: 150000,
            lastParkingDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ),
        VehicleModel(
          idKendaraan: '2',
          platNomor: 'B 5678 ABC',
          jenisKendaraan: 'Roda Dua',
          merk: 'Honda',
          tipe: 'Beat',
          warna: 'Merah',
          isActive: false,
          statistics: VehicleStatistics(
            parkingCount: 8,
            totalParkingMinutes: 480, // 8 hours
            totalCostSpent: 40000,
            lastParkingDate: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ),
      ];

      _lastSyncTime = DateTime.now();
      _isLoading = false;
      _errorMessage = null;
      
      debugPrint('[ProfileProvider] Vehicles fetched successfully: ${_vehicles.length} vehicles');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getUserFriendlyError(e.toString());
      
      debugPrint('[ProfileProvider] Error fetching user data: $e');
      notifyListeners();
    }
  }

  /// Update user data
  /// Notifies listeners on successful update
  Future<void> updateUser(UserModel user) async {
    try {
      debugPrint('[ProfileProvider] Updating user data...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      await Future.delayed(const Duration(milliseconds: 300));
      
      _user = user;
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] User data updated successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error updating user: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Add a new vehicle to the list
  /// Notifies listeners on successful addition
  Future<void> addVehicle(VehicleModel vehicle) async {
    try {
      debugPrint('[ProfileProvider] Adding vehicle...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      await Future.delayed(const Duration(milliseconds: 300));
      
      _vehicles.add(vehicle);
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
  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      debugPrint('[ProfileProvider] Updating vehicle...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _vehicles.indexWhere((v) => v.idKendaraan == vehicle.idKendaraan);
      if (index != -1) {
        _vehicles[index] = vehicle;
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
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      debugPrint('[ProfileProvider] Deleting vehicle...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      await Future.delayed(const Duration(milliseconds: 300));
      
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
  Future<void> setActiveVehicle(String vehicleId) async {
    try {
      debugPrint('[ProfileProvider] Setting active vehicle...');
      
      // TODO: Replace with actual API call when ProfileService is implemented
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Deactivate all vehicles first
      _vehicles = _vehicles.map((v) => v.copyWith(isActive: false)).toList();
      
      // Activate the selected vehicle
      final index = _vehicles.indexWhere((v) => v.idKendaraan == vehicleId);
      if (index != -1) {
        _vehicles[index] = _vehicles[index].copyWith(isActive: true);
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

  @override
  void dispose() {
    debugPrint('[ProfileProvider] Disposing provider');
    super.dispose();
  }
}
