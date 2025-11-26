import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/booking_request.dart';
import '../../data/models/booking_response.dart';
import '../../data/services/booking_service.dart';
import '../../utils/cost_calculator.dart';
import '../../utils/booking_validator.dart';

/// Provider for managing booking state and operations
///
/// Handles booking form state, validation, cost calculation,
/// real-time slot availability checking, and booking creation.
///
/// Requirements: 15.1, 15.8
class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  // State properties - Mall data
  Map<String, dynamic>? _selectedMall;

  // State properties - Vehicle data
  Map<String, dynamic>? _selectedVehicle;

  // State properties - Time and duration
  DateTime? _startTime;
  Duration? _bookingDuration;

  // State properties - Cost
  double _estimatedCost = 0.0;
  Map<String, dynamic>? _costBreakdown;

  // State properties - Slot availability
  int _availableSlots = 0;
  DateTime? _lastAvailabilityCheck;

  // State properties - Loading and errors
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  String? _errorMessage;
  Map<String, String> _validationErrors = {};

  // State properties - Booking result
  BookingModel? _createdBooking;

  // Timer for periodic availability checks
  Timer? _availabilityTimer;

  // Debounce timers for user inputs
  Timer? _costCalculationDebounce;
  Timer? _availabilityCheckDebounce;
  static const Duration _costCalculationDebounceDelay = Duration(milliseconds: 300);
  static const Duration _availabilityCheckDebounceDelay = Duration(milliseconds: 500);

  // Tariff data (fetched from mall data or API)
  double _firstHourRate = 5000.0; // Default values
  double _additionalHourRate = 3000.0;

  // Cache for frequently accessed data
  static final Map<String, Map<String, dynamic>> _mallCache = {};
  static final Map<String, List<Map<String, dynamic>>> _vehicleCache = {};
  static final Map<String, Map<String, double>> _tariffCache = {};
  static const Duration _cacheExpiration = Duration(minutes: 30);
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Getters
  Map<String, dynamic>? get selectedMall => _selectedMall;
  Map<String, dynamic>? get selectedVehicle => _selectedVehicle;
  DateTime? get startTime => _startTime;
  Duration? get bookingDuration => _bookingDuration;
  double get estimatedCost => _estimatedCost;
  Map<String, dynamic>? get costBreakdown => _costBreakdown;
  int get availableSlots => _availableSlots;
  DateTime? get lastAvailabilityCheck => _lastAvailabilityCheck;
  bool get isLoading => _isLoading;
  bool get isCheckingAvailability => _isCheckingAvailability;
  String? get errorMessage => _errorMessage;
  Map<String, String> get validationErrors => _validationErrors;
  BookingModel? get createdBooking => _createdBooking;
  double get firstHourRate => _firstHourRate;
  double get additionalHourRate => _additionalHourRate;

  // Computed properties
  DateTime? get calculatedEndTime {
    if (_startTime == null || _bookingDuration == null) return null;
    return _startTime!.add(_bookingDuration!);
  }

  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  bool get canConfirmBooking {
    return _selectedMall != null &&
        _selectedVehicle != null &&
        _startTime != null &&
        _bookingDuration != null &&
        _availableSlots > 0 &&
        !hasValidationErrors &&
        !_isLoading;
  }

  BookingProvider({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  /// Initialize provider with mall data from navigation
  ///
  /// Sets up initial state with mall information and default values.
  /// Automatically sets start time to current time + 15 minutes.
  /// Caches mall data for session duration.
  ///
  /// Parameters:
  /// - [mallData]: Map containing mall information (id, name, address, etc.)
  ///
  /// Requirements: 15.1, 15.8, 13.3
  void initialize(Map<String, dynamic> mallData) {
    debugPrint('[BookingProvider] Initializing with mall: ${mallData['name']}');

    // Cache mall data
    final mallId = mallData['id_mall']?.toString() ?? mallData['id']?.toString() ?? '';
    if (mallId.isNotEmpty) {
      _cacheMallData(mallId, mallData);
    }

    _selectedMall = mallData;

    // Set default start time to current time + 15 minutes
    _startTime = DateTime.now().add(const Duration(minutes: 15));

    // Extract tariff data from mall if available
    if (mallData['firstHourRate'] != null) {
      _firstHourRate = _parseDouble(mallData['firstHourRate']);
    }
    if (mallData['additionalHourRate'] != null) {
      _additionalHourRate = _parseDouble(mallData['additionalHourRate']);
    }

    // Set initial available slots from mall data if available
    if (mallData['available'] != null) {
      _availableSlots = _parseInt(mallData['available']);
    }

    // Clear any previous state
    _selectedVehicle = null;
    _bookingDuration = null;
    _estimatedCost = 0.0;
    _costBreakdown = null;
    _errorMessage = null;
    _validationErrors = {};
    _createdBooking = null;

    debugPrint('[BookingProvider] Initialized - Start time: $_startTime');
    notifyListeners();
  }

  /// Select a vehicle for booking
  ///
  /// Validates vehicle selection and triggers cost calculation if duration is set.
  ///
  /// Parameters:
  /// - [vehicle]: Map containing vehicle information (id, plat, jenis, etc.)
  ///
  /// Requirements: 15.1, 15.8
  void selectVehicle(Map<String, dynamic> vehicle) {
    debugPrint('[BookingProvider] Selecting vehicle: ${vehicle['plat_nomor']}');

    _selectedVehicle = vehicle;

    // Validate vehicle selection
    final vehicleId = vehicle['id_kendaraan']?.toString();
    final error = BookingValidator.validateVehicle(vehicleId);

    if (error != null) {
      _validationErrors['vehicleId'] = error;
    } else {
      _validationErrors.remove('vehicleId');
    }

    // Recalculate cost if duration is already set
    if (_bookingDuration != null) {
      calculateCost();
    }

    notifyListeners();
  }

  /// Set booking start time
  ///
  /// Validates start time and triggers debounced availability check.
  ///
  /// Parameters:
  /// - [time]: The proposed booking start time
  /// - [token]: Optional authentication token for availability check
  ///
  /// Requirements: 15.1, 15.8, 13.4
  void setStartTime(DateTime time, {String? token}) {
    debugPrint('[BookingProvider] Setting start time: $time');

    _startTime = time;

    // Validate start time
    final error = BookingValidator.validateStartTime(time);

    if (error != null) {
      _validationErrors['startTime'] = error;
    } else {
      _validationErrors.remove('startTime');
    }

    // Debounce availability check (500ms) if we have all required data
    if (_selectedMall != null &&
        _selectedVehicle != null &&
        _bookingDuration != null &&
        token != null) {
      _debounceAvailabilityCheck(token: token);
    }

    notifyListeners();
  }

  /// Set booking duration
  ///
  /// Validates duration and triggers debounced cost calculation and availability check.
  ///
  /// Parameters:
  /// - [duration]: The proposed booking duration
  /// - [token]: Optional authentication token for availability check
  ///
  /// Requirements: 15.1, 15.8, 13.4
  void setDuration(Duration duration, {String? token}) {
    debugPrint(
        '[BookingProvider] Setting duration: ${duration.inHours}h ${duration.inMinutes % 60}m');

    _bookingDuration = duration;

    // Validate duration
    final error = BookingValidator.validateDuration(duration);

    if (error != null) {
      _validationErrors['duration'] = error;
    } else {
      _validationErrors.remove('duration');
    }

    // Debounce cost calculation (300ms)
    _debounceCostCalculation();

    // Debounce availability check (500ms) if we have all required data
    if (_selectedMall != null &&
        _selectedVehicle != null &&
        _startTime != null &&
        token != null) {
      _debounceAvailabilityCheck(token: token);
    }

    notifyListeners();
  }

  /// Calculate estimated cost based on current duration and tariff
  ///
  /// Uses CostCalculator utility to compute cost breakdown and total.
  /// Updates estimatedCost and costBreakdown state.
  ///
  /// Requirements: 15.1, 15.8
  void calculateCost() {
    if (_bookingDuration == null) {
      _estimatedCost = 0.0;
      _costBreakdown = null;
      return;
    }

    // Convert duration to hours
    final durationHours = CostCalculator.durationToHours(_bookingDuration!);

    // Calculate cost using CostCalculator
    _estimatedCost = CostCalculator.estimateCost(
      durationHours: durationHours,
      firstHourRate: _firstHourRate,
      additionalHourRate: _additionalHourRate,
    );

    // Generate cost breakdown
    _costBreakdown = CostCalculator.generateCostBreakdown(
      durationHours: durationHours,
      firstHourRate: _firstHourRate,
      additionalHourRate: _additionalHourRate,
    );

    debugPrint('[BookingProvider] Cost calculated: Rp $_estimatedCost');
    debugPrint('[BookingProvider] Breakdown: $_costBreakdown');
  }

  /// Update tariff rates
  ///
  /// Allows updating tariff rates (e.g., from API or mall data)
  /// and recalculates cost if duration is set.
  /// Caches tariff data to reduce API calls.
  ///
  /// Parameters:
  /// - [firstHourRate]: Rate for the first hour
  /// - [additionalHourRate]: Rate for each additional hour
  /// - [mallId]: Optional mall ID for caching
  /// - [vehicleType]: Optional vehicle type for caching
  ///
  /// Requirements: 13.3
  void updateTariff({
    required double firstHourRate,
    required double additionalHourRate,
    String? mallId,
    String? vehicleType,
  }) {
    debugPrint(
        '[BookingProvider] Updating tariff: First=$firstHourRate, Additional=$additionalHourRate');

    _firstHourRate = firstHourRate;
    _additionalHourRate = additionalHourRate;

    // Cache tariff data if mall and vehicle type provided
    if (mallId != null && vehicleType != null) {
      _cacheTariffData(mallId, vehicleType, firstHourRate, additionalHourRate);
    }

    // Recalculate cost with new tariff
    if (_bookingDuration != null) {
      calculateCost();
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear validation errors
  void clearValidationErrors() {
    _validationErrors = {};
    notifyListeners();
  }

  /// Check if user has an active booking
  ///
  /// Queries the API to check if the user already has an active booking.
  /// This prevents duplicate bookings.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  ///
  /// Returns: Future<bool> indicating if active booking exists
  ///
  /// Requirements: 11.6
  Future<bool> hasActiveBooking({required String token}) async {
    try {
      debugPrint('[BookingProvider] Checking for active bookings...');
      
      final hasActive = await _bookingService.checkActiveBooking(token: token);
      
      debugPrint('[BookingProvider] Active booking check result: $hasActive');
      return hasActive;
    } catch (e) {
      debugPrint('[BookingProvider] Error checking active booking: $e');
      // On error, assume no active booking to allow user to proceed
      // The backend will do the final validation
      return false;
    }
  }

  /// Confirm booking and create booking record
  ///
  /// Validates all inputs, checks for active bookings, creates BookingRequest,
  /// calls BookingService, and handles success/error responses with user-friendly messages.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  /// - [onSuccess]: Optional callback function called on successful booking
  /// - [skipActiveCheck]: Skip active booking check (for testing)
  ///
  /// Returns: Future<bool> indicating success or failure
  ///
  /// Requirements: 9.1-9.9, 11.1-11.7, 11.6
  Future<bool> confirmBooking({
    required String token,
    Function(BookingModel)? onSuccess,
    bool skipActiveCheck = false,
  }) async {
    debugPrint('[BookingProvider] Confirming booking...');

    // Validate all inputs before proceeding
    final errors = BookingValidator.validateAll(
      startTime: _startTime,
      duration: _bookingDuration,
      vehicleId: _selectedVehicle?['id_kendaraan']?.toString(),
    );

    if (errors.isNotEmpty) {
      _validationErrors = errors;
      _errorMessage = 'Mohon lengkapi semua data dengan benar';
      debugPrint('[BookingProvider] Validation failed: $errors');
      notifyListeners();
      return false;
    }

    // Check if we have all required data
    if (_selectedMall == null) {
      _errorMessage = 'Mall tidak dipilih';
      notifyListeners();
      return false;
    }

    if (_selectedVehicle == null) {
      _errorMessage = 'Kendaraan tidak dipilih';
      notifyListeners();
      return false;
    }

    if (_startTime == null || _bookingDuration == null) {
      _errorMessage = 'Waktu dan durasi harus dipilih';
      notifyListeners();
      return false;
    }

    // Check slot availability
    if (_availableSlots <= 0) {
      _errorMessage = 'Slot tidak tersedia untuk waktu yang dipilih';
      notifyListeners();
      return false;
    }

    // Check for existing active booking (unless skipped for testing)
    if (!skipActiveCheck) {
      final hasActive = await hasActiveBooking(token: token);
      if (hasActive) {
        _errorMessage = 'Anda sudah memiliki booking aktif. Selesaikan booking sebelumnya terlebih dahulu.';
        debugPrint('[BookingProvider] Active booking detected - preventing duplicate');
        notifyListeners();
        return false;
      }
    }

    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create booking request
      final durationHours = (_bookingDuration!.inMinutes / 60.0).ceil();

      final request = BookingRequest(
        idMall: _selectedMall!['id_mall']?.toString() ??
            _selectedMall!['id']?.toString() ??
            '',
        idKendaraan: _selectedVehicle!['id_kendaraan']?.toString() ?? '',
        waktuMulai: _startTime!,
        durasiJam: durationHours,
        notes: null,
      );

      debugPrint(
          '[BookingProvider] Sending booking request: ${request.toJson()}');

      // Call booking service with retry
      final response = await _bookingService.createBookingWithRetry(
        request: request,
        token: token,
        maxRetries: 3,
      );

      _isLoading = false;

      if (response.success && response.booking != null) {
        // Booking created successfully
        _createdBooking = response.booking;
        _errorMessage = null;

        debugPrint(
            '[BookingProvider] Booking created successfully: ${response.booking!.idBooking}');

        // Stop availability timer since booking is complete
        _stopAvailabilityTimer();

        notifyListeners();

        // Call success callback if provided
        if (onSuccess != null) {
          onSuccess(response.booking!);
        }

        return true;
      } else {
        // Booking failed - set user-friendly error message
        _errorMessage = _getUserFriendlyErrorMessage(response);

        debugPrint('[BookingProvider] Booking failed: $_errorMessage');
        debugPrint('[BookingProvider] Error code: ${response.errorCode}');

        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';

      debugPrint('[BookingProvider] Exception during booking: $e');

      notifyListeners();
      return false;
    }
  }

  /// Convert BookingResponse error to user-friendly message
  ///
  /// Requirements: 11.1-11.7
  String _getUserFriendlyErrorMessage(BookingResponse response) {
    // Use response message if available and user-friendly
    if (response.message.isNotEmpty &&
        !response.message.toLowerCase().contains('error') &&
        !response.message.toLowerCase().contains('exception')) {
      return response.message;
    }

    // Map error codes to user-friendly messages
    switch (response.errorCode) {
      case 'NETWORK_ERROR':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';

      case 'TIMEOUT_ERROR':
        return 'Permintaan timeout. Silakan coba lagi.';

      case 'SLOT_UNAVAILABLE':
        return 'Slot tidak tersedia untuk waktu yang dipilih. Silakan pilih waktu lain.';

      case 'BOOKING_CONFLICT':
        return 'Anda sudah memiliki booking aktif. Selesaikan booking sebelumnya terlebih dahulu.';

      case 'UNAUTHORIZED':
      case 'AUTH_ERROR':
        return 'Sesi Anda telah berakhir. Silakan login kembali.';

      case 'VALIDATION_ERROR':
        return 'Data booking tidak valid. Periksa kembali data Anda.';

      case 'NOT_FOUND':
        return 'Data tidak ditemukan. Silakan coba lagi.';

      case 'SERVER_ERROR':
        return 'Terjadi kesalahan server. Silakan coba beberapa saat lagi.';

      case 'MAX_RETRIES_EXCEEDED':
        return 'Gagal membuat booking setelah beberapa percobaan. Silakan coba lagi nanti.';

      default:
        return response.message.isNotEmpty
            ? response.message
            : 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Check parking slot availability for current booking parameters
  ///
  /// Queries the API for available slots matching the selected mall,
  /// vehicle type, start time, and duration. Updates availableSlots state.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  ///
  /// Requirements: 5.1-5.7, 15.7
  Future<void> checkAvailability({required String token}) async {
    // Validate we have all required data
    if (_selectedMall == null ||
        _selectedVehicle == null ||
        _startTime == null ||
        _bookingDuration == null) {
      debugPrint(
          '[BookingProvider] Cannot check availability - missing required data');
      return;
    }

    _isCheckingAvailability = true;
    notifyListeners();

    try {
      final mallId = _selectedMall!['id_mall']?.toString() ??
          _selectedMall!['id']?.toString() ??
          '';
      final vehicleType = _selectedVehicle!['jenis_kendaraan']?.toString() ??
          _selectedVehicle!['jenis']?.toString() ??
          '';
      final durationHours = (_bookingDuration!.inMinutes / 60.0).ceil();

      debugPrint('[BookingProvider] Checking availability for:');
      debugPrint('  Mall: $mallId');
      debugPrint('  Vehicle Type: $vehicleType');
      debugPrint('  Start Time: $_startTime');
      debugPrint('  Duration: $durationHours hours');

      final slots = await _bookingService.checkSlotAvailabilityWithRetry(
        mallId: mallId,
        vehicleType: vehicleType,
        startTime: _startTime!,
        durationHours: durationHours,
        token: token,
        maxRetries: 2,
      );

      final previousSlots = _availableSlots;
      _availableSlots = slots;
      _lastAvailabilityCheck = DateTime.now();
      _isCheckingAvailability = false;

      debugPrint('[BookingProvider] Available slots: $slots');

      // Notify user if slot availability changed significantly
      if (previousSlots > 0 && slots == 0) {
        debugPrint('[BookingProvider] Warning: Slots became unavailable');
      } else if (previousSlots == 0 && slots > 0) {
        debugPrint('[BookingProvider] Slots became available');
      }

      notifyListeners();
    } catch (e) {
      _isCheckingAvailability = false;

      // Don't set error message for availability checks - fail silently
      // This prevents disrupting the user experience with error messages
      debugPrint('[BookingProvider] Error checking availability: $e');

      // Keep previous slot count on error
      notifyListeners();
    }
  }

  /// Start periodic availability checking with 30-second interval
  ///
  /// Automatically checks slot availability every 30 seconds while
  /// the booking form is active. Stops when booking is confirmed or cleared.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API calls
  ///
  /// Requirements: 5.1-5.7, 15.7
  void startPeriodicAvailabilityCheck({required String token}) {
    // Stop any existing timer
    _stopAvailabilityTimer();

    // Validate we have required data
    if (_selectedMall == null ||
        _selectedVehicle == null ||
        _startTime == null ||
        _bookingDuration == null) {
      debugPrint(
          '[BookingProvider] Cannot start periodic check - missing required data');
      return;
    }

    debugPrint(
        '[BookingProvider] Starting periodic availability check (30s interval)');

    // Do initial check immediately
    checkAvailability(token: token);

    // Set up periodic timer
    _availabilityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        // Only check if we still have all required data
        if (_selectedMall != null &&
            _selectedVehicle != null &&
            _startTime != null &&
            _bookingDuration != null) {
          checkAvailability(token: token);
        } else {
          // Stop timer if data is no longer available
          debugPrint(
              '[BookingProvider] Stopping periodic check - data cleared');
          _stopAvailabilityTimer();
        }
      },
    );
  }

  /// Stop periodic availability checking
  ///
  /// Requirements: 15.7
  void stopPeriodicAvailabilityCheck() {
    debugPrint('[BookingProvider] Stopping periodic availability check');
    _stopAvailabilityTimer();
  }

  /// Manually refresh slot availability
  ///
  /// Allows user to manually trigger availability check via refresh button.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  ///
  /// Requirements: 5.1-5.7
  Future<void> refreshAvailability({required String token}) async {
    debugPrint('[BookingProvider] Manual availability refresh triggered');
    await checkAvailability(token: token);
  }

  /// Clear all state and reset provider
  void clear() {
    debugPrint('[BookingProvider] Clearing all state');

    _selectedMall = null;
    _selectedVehicle = null;
    _startTime = null;
    _bookingDuration = null;
    _estimatedCost = 0.0;
    _costBreakdown = null;
    _availableSlots = 0;
    _lastAvailabilityCheck = null;
    _isLoading = false;
    _isCheckingAvailability = false;
    _errorMessage = null;
    _validationErrors = {};
    _createdBooking = null;

    // Stop availability timer
    _stopAvailabilityTimer();

    notifyListeners();
  }

  /// Stop the availability check timer
  void _stopAvailabilityTimer() {
    _availabilityTimer?.cancel();
    _availabilityTimer = null;
  }

  /// Debounce cost calculation to prevent excessive recalculations
  ///
  /// Requirements: 13.4
  void _debounceCostCalculation() {
    _costCalculationDebounce?.cancel();
    _costCalculationDebounce = Timer(_costCalculationDebounceDelay, () {
      debugPrint('[BookingProvider] Debounced cost calculation triggered');
      calculateCost();
      notifyListeners();
    });
  }

  /// Debounce availability check to prevent excessive API calls
  ///
  /// Requirements: 13.4
  void _debounceAvailabilityCheck({required String token}) {
    _availabilityCheckDebounce?.cancel();
    _availabilityCheckDebounce = Timer(_availabilityCheckDebounceDelay, () {
      debugPrint('[BookingProvider] Debounced availability check triggered');
      checkAvailability(token: token);
    });
  }

  /// Cancel all debounce timers
  void _cancelDebounceTimers() {
    _costCalculationDebounce?.cancel();
    _costCalculationDebounce = null;
    _availabilityCheckDebounce?.cancel();
    _availabilityCheckDebounce = null;
  }

  /// Cache mall data for session
  ///
  /// Requirements: 13.3
  static void _cacheMallData(String mallId, Map<String, dynamic> mallData) {
    _mallCache[mallId] = Map<String, dynamic>.from(mallData);
    _cacheTimestamps['mall_$mallId'] = DateTime.now();
    debugPrint('[BookingProvider] Cached mall data for: $mallId');
  }

  /// Get cached mall data if available and not expired
  ///
  /// Requirements: 13.3
  static Map<String, dynamic>? getCachedMallData(String mallId) {
    final timestamp = _cacheTimestamps['mall_$mallId'];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheExpiration) {
      debugPrint('[BookingProvider] Using cached mall data for: $mallId');
      return _mallCache[mallId];
    }
    return null;
  }

  /// Cache vehicle list for session
  ///
  /// Requirements: 13.3
  static void cacheVehicleList(String userId, List<Map<String, dynamic>> vehicles) {
    _vehicleCache[userId] = vehicles.map((v) => Map<String, dynamic>.from(v)).toList();
    _cacheTimestamps['vehicles_$userId'] = DateTime.now();
    debugPrint('[BookingProvider] Cached ${vehicles.length} vehicles for user: $userId');
  }

  /// Get cached vehicle list if available and not expired
  ///
  /// Requirements: 13.3
  static List<Map<String, dynamic>>? getCachedVehicleList(String userId) {
    final timestamp = _cacheTimestamps['vehicles_$userId'];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheExpiration) {
      debugPrint('[BookingProvider] Using cached vehicle list for user: $userId');
      return _vehicleCache[userId];
    }
    return null;
  }

  /// Cache tariff data for session
  ///
  /// Requirements: 13.3
  static void _cacheTariffData(
    String mallId,
    String vehicleType,
    double firstHourRate,
    double additionalHourRate,
  ) {
    final key = '${mallId}_$vehicleType';
    _tariffCache[key] = {
      'firstHourRate': firstHourRate,
      'additionalHourRate': additionalHourRate,
    };
    _cacheTimestamps['tariff_$key'] = DateTime.now();
    debugPrint('[BookingProvider] Cached tariff data for: $key');
  }

  /// Get cached tariff data if available and not expired
  ///
  /// Requirements: 13.3
  static Map<String, double>? getCachedTariffData(String mallId, String vehicleType) {
    final key = '${mallId}_$vehicleType';
    final timestamp = _cacheTimestamps['tariff_$key'];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheExpiration) {
      debugPrint('[BookingProvider] Using cached tariff data for: $key');
      return _tariffCache[key];
    }
    return null;
  }

  /// Clear all cached data
  ///
  /// Requirements: 13.3
  static void clearAllCache() {
    _mallCache.clear();
    _vehicleCache.clear();
    _tariffCache.clear();
    _cacheTimestamps.clear();
    debugPrint('[BookingProvider] Cleared all cache');
  }

  /// Clear expired cache entries
  ///
  /// Requirements: 13.3
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiration) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cacheTimestamps.remove(key);
      
      if (key.startsWith('mall_')) {
        _mallCache.remove(key.substring(5));
      } else if (key.startsWith('vehicles_')) {
        _vehicleCache.remove(key.substring(9));
      } else if (key.startsWith('tariff_')) {
        _tariffCache.remove(key.substring(7));
      }
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('[BookingProvider] Cleared ${expiredKeys.length} expired cache entries');
    }
  }

  @override
  void dispose() {
    debugPrint('[BookingProvider] Disposing provider');
    
    // Stop timers
    _stopAvailabilityTimer();
    _cancelDebounceTimers();
    
    // Cancel pending API calls
    _bookingService.cancelPendingRequests();
    
    // Clear large objects
    _selectedMall = null;
    _selectedVehicle = null;
    _costBreakdown = null;
    _createdBooking = null;
    
    super.dispose();
  }

  /// Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper method to safely parse int values
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Test helper methods
  /// Set loading state (for testing)
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message (for testing)
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Set available slots (for testing)
  void setAvailableSlots(int slots) {
    _availableSlots = slots;
    notifyListeners();
  }
}
