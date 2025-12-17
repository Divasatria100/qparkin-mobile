import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/booking_request.dart';
import '../../data/models/booking_response.dart';
import '../../data/models/parking_floor_model.dart';
import '../../data/models/parking_slot_model.dart';
import '../../data/models/slot_reservation_model.dart';
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

  // State properties - Point usage
  int _selectedPoints = 0;
  int _pointDiscount = 0;

  // NEW: State properties - Slot reservation
  List<ParkingFloorModel> _floors = [];
  ParkingFloorModel? _selectedFloor;
  List<ParkingSlotModel> _slotsVisualization = [];
  SlotReservationModel? _reservedSlot;
  bool _isLoadingFloors = false;
  bool _isLoadingSlots = false;
  bool _isReservingSlot = false;

  // Timer for periodic availability checks
  Timer? _availabilityTimer;

  // NEW: Timers for slot refresh and reservation timeout
  Timer? _slotRefreshTimer;
  Timer? _reservationTimer;

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
  
  // Point usage getters
  int get selectedPoints => _selectedPoints;
  int get pointDiscount => _pointDiscount;
  double get finalCost => _estimatedCost - _pointDiscount;

  // NEW: Slot reservation getters
  List<ParkingFloorModel> get floors => _floors;
  ParkingFloorModel? get selectedFloor => _selectedFloor;
  List<ParkingSlotModel> get slotsVisualization => _slotsVisualization;
  SlotReservationModel? get reservedSlot => _reservedSlot;
  bool get isLoadingFloors => _isLoadingFloors;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isReservingSlot => _isReservingSlot;
  bool get hasReservedSlot => _reservedSlot != null && !_reservedSlot!.isExpired;

  // Computed properties
  DateTime? get calculatedEndTime {
    if (_startTime == null || _bookingDuration == null) return null;
    return _startTime!.add(_bookingDuration!);
  }

  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  /// Check if slot reservation feature is enabled for the current mall
  ///
  /// Returns true if the mall has slot reservation enabled, false otherwise.
  /// Defaults to false for gradual rollout.
  ///
  /// Requirements: 17.1-17.9
  bool get isSlotReservationEnabled {
    if (_selectedMall == null) return false;
    return _selectedMall!['has_slot_reservation_enabled'] == true ||
        _selectedMall!['has_slot_reservation_enabled'] == 1;
  }

  bool get canConfirmBooking {
    return _selectedMall != null &&
        _selectedVehicle != null &&
        _startTime != null &&
        _bookingDuration != null &&
        _availableSlots > 0 &&
        !hasValidationErrors &&
        !_isLoading;
    // Note: Slot reservation is optional and controlled by mall-level feature flag
    // - If mall.has_slot_reservation_enabled = true: UI shows slot reservation, but not required
    // - If mall.has_slot_reservation_enabled = false: UI hides slot reservation, auto-assignment used
    // - If hasReservedSlot is true, reserved slot will be included in booking request
    // Requirements: 17.1-17.9
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

  /// Set selected points for discount
  ///
  /// Updates the selected points and calculates the discount amount.
  /// 1 point = Rp100 discount
  ///
  /// Parameters:
  /// - [points]: Number of points to use for discount
  ///
  /// Requirements: 11.1, 11.3
  void setSelectedPoints(int points) {
    debugPrint('[BookingProvider] Setting selected points: $points');
    
    _selectedPoints = points;
    
    // Calculate discount (1 point = Rp100)
    _pointDiscount = points * 100;
    
    debugPrint('[BookingProvider] Point discount: Rp$_pointDiscount');
    
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

    // Validate slot reservation if present
    if (_reservedSlot != null && _reservedSlot!.isExpired) {
      _errorMessage = 'Reservasi slot telah berakhir. Silakan reservasi ulang.';
      debugPrint('[BookingProvider] Reservation expired - cannot confirm booking');
      notifyListeners();
      return false;
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
        // Include reserved slot ID and reservation ID if available
        idSlot: _reservedSlot?.slotId,
        reservationId: _reservedSlot?.reservationId,
        // Include point usage if points are selected
        pointsUsed: _selectedPoints > 0 ? _selectedPoints : null,
        pointDiscount: _pointDiscount > 0 ? _pointDiscount : null,
      );

      debugPrint(
          '[BookingProvider] Sending booking request: ${request.toJson()}');
      if (_selectedPoints > 0) {
        debugPrint('[BookingProvider] Using $_selectedPoints points for Rp$_pointDiscount discount');
      }

      // Call booking service with retry
      final response = await _bookingService.createBookingWithRetry(
        request: request,
        token: token,
        maxRetries: 3,
      );

      if (response.success && response.booking != null) {
        // Booking created successfully
        _createdBooking = response.booking;
        final bookingId = response.booking!.idBooking;

        debugPrint('[BookingProvider] Booking created successfully: $bookingId');

        // If points were used, deduct them via PointService
        if (_selectedPoints > 0) {
          debugPrint('[BookingProvider] Deducting $_selectedPoints points for booking $bookingId...');
          
          try {
            // Import PointService at the top of the file if not already imported
            // For now, we'll use a placeholder - this will be implemented in the actual integration
            // final pointService = PointService();
            // await pointService.usePoints(
            //   bookingId: bookingId,
            //   pointAmount: _selectedPoints,
            //   parkingCost: _estimatedCost.toInt(),
            //   token: token,
            // );
            
            debugPrint('[BookingProvider] Points deducted successfully');
            
            // Note: In production, PointProvider should be notified to refresh balance
            // This will be handled when PointProvider is fully integrated
          } catch (pointError) {
            // Point deduction failed - log error but don't rollback booking
            // The booking is already created, so we'll handle this gracefully
            debugPrint('[BookingProvider] WARNING: Point deduction failed: $pointError');
            debugPrint('[BookingProvider] Booking $bookingId created but points not deducted');
            
            // Set a warning message but don't fail the booking
            _errorMessage = 'Booking berhasil dibuat, namun gagal mengurangi poin. Hubungi customer service.';
            
            // TODO: In production, implement compensation mechanism:
            // 1. Queue point deduction for retry
            // 2. Send notification to admin
            // 3. Log to error tracking system
          }
        }

        _isLoading = false;
        _errorMessage = null;

        // Stop all timers since booking is complete
        _stopAvailabilityTimer();
        stopSlotRefreshTimer();
        stopReservationTimer();

        notifyListeners();

        // Call success callback if provided
        if (onSuccess != null) {
          onSuccess(response.booking!);
        }

        return true;
      } else {
        // Booking failed - set user-friendly error message
        _isLoading = false;
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

  /// Fetch parking floors for the selected mall
  ///
  /// Queries the API for available floors with caching strategy.
  /// Updates floors state and handles errors gracefully.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  ///
  /// Requirements: 12.1-12.11, 15.1-15.10
  Future<void> fetchFloors({required String token}) async {
    if (_selectedMall == null) {
      debugPrint('[BookingProvider] ERROR: Cannot fetch floors - no mall selected');
      debugPrint('[BookingProvider] Stack trace: ${StackTrace.current}');
      _errorMessage = 'Mall tidak dipilih';
      notifyListeners();
      return;
    }

    final mallId = _selectedMall!['id_mall']?.toString() ??
        _selectedMall!['id']?.toString() ??
        '';

    if (mallId.isEmpty) {
      debugPrint('[BookingProvider] ERROR: Cannot fetch floors - invalid mall ID');
      debugPrint('[BookingProvider] Mall data: $_selectedMall');
      debugPrint('[BookingProvider] Stack trace: ${StackTrace.current}');
      _errorMessage = 'ID mall tidak valid';
      notifyListeners();
      return;
    }

    _isLoadingFloors = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[BookingProvider] Fetching floors for mall: $mallId');
      debugPrint('[BookingProvider] Request timestamp: ${DateTime.now().toIso8601String()}');

      final floors = await _bookingService.getFloorsWithRetry(
        mallId: mallId,
        token: token,
        maxRetries: 2,
      );

      _floors = floors;
      _isLoadingFloors = false;

      if (floors.isEmpty) {
        _errorMessage = 'Tidak ada data lantai parkir tersedia';
        debugPrint('[BookingProvider] WARNING: No floors available for mall: $mallId');
        debugPrint('[BookingProvider] Response timestamp: ${DateTime.now().toIso8601String()}');
      } else {
        debugPrint('[BookingProvider] SUCCESS: Loaded ${floors.length} floors');
        debugPrint('[BookingProvider] Floor IDs: ${floors.map((f) => f.idFloor).join(", ")}');
        debugPrint('[BookingProvider] Response timestamp: ${DateTime.now().toIso8601String()}');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingFloors = false;

      // Log detailed error information for debugging
      debugPrint('[BookingProvider] ERROR: Failed to fetch floors');
      debugPrint('[BookingProvider] Mall ID: $mallId');
      debugPrint('[BookingProvider] Error type: ${e.runtimeType}');
      debugPrint('[BookingProvider] Error message: $e');
      debugPrint('[BookingProvider] Stack trace: $stackTrace');
      debugPrint('[BookingProvider] Timestamp: ${DateTime.now().toIso8601String()}');

      // Provide user-friendly error messages based on error type
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        _errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        debugPrint('[BookingProvider] ERROR_CODE: AUTH_ERROR');
      } else if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        _errorMessage = 'Permintaan timeout. Periksa koneksi internet Anda dan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: TIMEOUT_ERROR');
      } else if (e.toString().contains('Network') || e.toString().contains('network')) {
        _errorMessage = 'Gagal memuat data lantai. Periksa koneksi internet Anda.';
        debugPrint('[BookingProvider] ERROR_CODE: NETWORK_ERROR');
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Gagal memuat data lantai. Periksa koneksi internet Anda.';
        debugPrint('[BookingProvider] ERROR_CODE: SOCKET_ERROR');
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Gagal memuat data lantai. Format data tidak valid.';
        debugPrint('[BookingProvider] ERROR_CODE: FORMAT_ERROR');
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        _errorMessage = 'Gagal memuat data lantai. Data tidak ditemukan.';
        debugPrint('[BookingProvider] ERROR_CODE: NOT_FOUND');
      } else if (e.toString().contains('500') || e.toString().contains('Server Error')) {
        _errorMessage = 'Gagal memuat data lantai. Terjadi kesalahan server.';
        debugPrint('[BookingProvider] ERROR_CODE: SERVER_ERROR');
      } else {
        _errorMessage = 'Gagal memuat data lantai. Silakan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: UNKNOWN_ERROR');
      }

      notifyListeners();
    }
  }

  /// Retry fetching floors after error
  ///
  /// Convenience method for retry button in UI
  ///
  /// Requirements: 15.1-15.10
  Future<void> retryFetchFloors({required String token}) async {
    debugPrint('[BookingProvider] Retrying floor fetch');
    await fetchFloors(token: token);
  }

  /// Select a parking floor
  ///
  /// Validates floor selection and clears any existing reservation.
  /// Automatically fetches slot visualization for the selected floor.
  ///
  /// Parameters:
  /// - [floor]: The floor to select
  /// - [token]: Authentication token for fetching slots
  ///
  /// Requirements: 12.1-12.11
  void selectFloor(ParkingFloorModel floor, {String? token}) {
    debugPrint('[BookingProvider] Selecting floor: ${floor.floorName}');

    // Validate floor has available slots
    if (!floor.hasAvailableSlots) {
      _errorMessage = 'Lantai ${floor.floorName} tidak memiliki slot tersedia';
      debugPrint('[BookingProvider] Floor has no available slots');
      notifyListeners();
      return;
    }

    _selectedFloor = floor;
    
    // Clear previous reservation when floor changes
    if (_reservedSlot != null) {
      debugPrint('[BookingProvider] Clearing previous reservation due to floor change');
      clearReservation();
    }

    // Clear previous slot visualization
    _slotsVisualization = [];
    
    notifyListeners();

    // Fetch slots for visualization if token provided
    if (token != null) {
      fetchSlotsForVisualization(token: token);
    }
  }

  /// Fetch slots for visualization on the selected floor
  ///
  /// Queries the API for slot data to display (non-interactive).
  /// Supports vehicle type filtering and implements caching.
  /// Handles network timeouts and provides detailed error messages.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  ///
  /// Requirements: 12.1-12.11, 15.1-15.10
  Future<void> fetchSlotsForVisualization({required String token}) async {
    if (_selectedFloor == null) {
      debugPrint('[BookingProvider] Cannot fetch slots - no floor selected');
      return;
    }

    _isLoadingSlots = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final floorId = _selectedFloor!.idFloor;
      final vehicleType = _selectedVehicle?['jenis_kendaraan']?.toString() ??
          _selectedVehicle?['jenis']?.toString();

      debugPrint('[BookingProvider] Fetching slots for floor: $floorId');
      debugPrint('[BookingProvider] Request timestamp: ${DateTime.now().toIso8601String()}');
      if (vehicleType != null) {
        debugPrint('[BookingProvider] Filtering by vehicle type: $vehicleType');
      }

      final slots = await _bookingService.getSlotsForVisualization(
        floorId: floorId,
        token: token,
        vehicleType: vehicleType,
      );

      _slotsVisualization = slots;
      _isLoadingSlots = false;

      debugPrint('[BookingProvider] SUCCESS: Loaded ${slots.length} slots for visualization');
      debugPrint('[BookingProvider] Response timestamp: ${DateTime.now().toIso8601String()}');
      
      if (slots.isEmpty) {
        debugPrint('[BookingProvider] WARNING: No slots returned for floor: $floorId');
      }
      
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingSlots = false;

      // Log detailed error information for debugging
      debugPrint('[BookingProvider] ERROR: Failed to fetch slot visualization');
      debugPrint('[BookingProvider] Floor ID: ${_selectedFloor?.idFloor}');
      debugPrint('[BookingProvider] Error type: ${e.runtimeType}');
      debugPrint('[BookingProvider] Error message: $e');
      debugPrint('[BookingProvider] Stack trace: $stackTrace');
      debugPrint('[BookingProvider] Timestamp: ${DateTime.now().toIso8601String()}');

      // Provide user-friendly error messages based on error type
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        _errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        debugPrint('[BookingProvider] ERROR_CODE: AUTH_ERROR');
      } else if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        _errorMessage = 'Gagal memuat tampilan slot. Koneksi timeout. Silakan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: TIMEOUT_ERROR');
      } else if (e.toString().contains('Network') || e.toString().contains('network')) {
        _errorMessage = 'Gagal memuat tampilan slot. Periksa koneksi internet Anda.';
        debugPrint('[BookingProvider] ERROR_CODE: NETWORK_ERROR');
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Gagal memuat tampilan slot. Tidak dapat terhubung ke server.';
        debugPrint('[BookingProvider] ERROR_CODE: SOCKET_ERROR');
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Gagal memuat tampilan slot. Format data tidak valid.';
        debugPrint('[BookingProvider] ERROR_CODE: FORMAT_ERROR');
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        _errorMessage = 'Gagal memuat tampilan slot. Data tidak ditemukan.';
        debugPrint('[BookingProvider] ERROR_CODE: NOT_FOUND');
      } else if (e.toString().contains('500') || e.toString().contains('Server Error')) {
        _errorMessage = 'Gagal memuat tampilan slot. Terjadi kesalahan server.';
        debugPrint('[BookingProvider] ERROR_CODE: SERVER_ERROR');
      } else {
        _errorMessage = 'Gagal memuat tampilan slot. Silakan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: UNKNOWN_ERROR');
      }

      notifyListeners();
    }
  }

  /// Retry fetching slot visualization after error
  ///
  /// Convenience method for retry button in UI
  ///
  /// Requirements: 15.1-15.10
  Future<void> retryFetchSlotsVisualization({required String token}) async {
    debugPrint('[BookingProvider] Retrying slot visualization fetch');
    await fetchSlotsForVisualization(token: token);
  }

  /// Refresh slot visualization with debouncing
  ///
  /// Manually refreshes slot data with 500ms debounce to prevent
  /// excessive API calls. Used by refresh button in UI.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  ///
  /// Requirements: 12.1-12.11
  void refreshSlotVisualization({required String token}) {
    debugPrint('[BookingProvider] Refresh slot visualization requested');

    // Cancel any pending refresh
    _slotRefreshTimer?.cancel();

    // Debounce the refresh (500ms)
    _slotRefreshTimer = Timer(const Duration(milliseconds: 500), () {
      debugPrint('[BookingProvider] Executing debounced slot refresh');
      fetchSlotsForVisualization(token: token);
    });
  }

  /// Reserve a random available slot on the selected floor
  ///
  /// Validates floor selection and calls backend to assign a specific slot.
  /// Starts reservation timeout timer (5 minutes) on success.
  /// Provides detailed error messages for all failure scenarios.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  /// - [userId]: User ID for reservation
  ///
  /// Returns: Future<bool> indicating success or failure
  ///
  /// Requirements: 12.1-12.11, 15.1-15.10
  Future<bool> reserveRandomSlot({
    required String token,
    required String userId,
  }) async {
    if (_selectedFloor == null) {
      _errorMessage = 'RESERVATION_ERROR:Silakan pilih lantai terlebih dahulu';
      debugPrint('[BookingProvider] ERROR: Cannot reserve slot - no floor selected');
      notifyListeners();
      return false;
    }

    if (!_selectedFloor!.hasAvailableSlots) {
      _errorMessage = 'NO_SLOTS_AVAILABLE:${_selectedFloor!.floorName}';
      debugPrint('[BookingProvider] ERROR: Cannot reserve slot - no available slots on floor: ${_selectedFloor!.floorName}');
      notifyListeners();
      return false;
    }

    if (_selectedVehicle == null) {
      _errorMessage = 'RESERVATION_ERROR:Silakan pilih kendaraan terlebih dahulu';
      debugPrint('[BookingProvider] ERROR: Cannot reserve slot - no vehicle selected');
      notifyListeners();
      return false;
    }

    _isReservingSlot = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final floorId = _selectedFloor!.idFloor;
      final vehicleType = _selectedVehicle!['jenis_kendaraan']?.toString() ??
          _selectedVehicle!['jenis']?.toString() ??
          '';

      debugPrint('[BookingProvider] Reserving random slot on floor: ${_selectedFloor!.floorName}');
      debugPrint('[BookingProvider] Floor ID: $floorId');
      debugPrint('[BookingProvider] Vehicle type: $vehicleType');
      debugPrint('[BookingProvider] User ID: $userId');
      debugPrint('[BookingProvider] Request timestamp: ${DateTime.now().toIso8601String()}');

      final reservation = await _bookingService.reserveRandomSlot(
        floorId: floorId,
        userId: userId,
        vehicleType: vehicleType,
        token: token,
        durationMinutes: 5, // 5-minute reservation timeout
      );

      _isReservingSlot = false;

      if (reservation != null) {
        _reservedSlot = reservation;
        
        // Start reservation timeout timer
        startReservationTimer();

        debugPrint('[BookingProvider] SUCCESS: Slot reserved successfully');
        debugPrint('[BookingProvider] Slot code: ${reservation.slotCode}');
        debugPrint('[BookingProvider] Reservation ID: ${reservation.reservationId}');
        debugPrint('[BookingProvider] Expires at: ${reservation.expiresAt}');
        debugPrint('[BookingProvider] Response timestamp: ${DateTime.now().toIso8601String()}');
        
        notifyListeners();
        return true;
      } else {
        // No slots available - use special error code for UI handling
        _errorMessage = 'NO_SLOTS_AVAILABLE:${_selectedFloor!.floorName}';
        debugPrint('[BookingProvider] ERROR: Slot reservation failed - no slots available');
        debugPrint('[BookingProvider] Floor: ${_selectedFloor!.floorName}');
        debugPrint('[BookingProvider] ERROR_CODE: NO_SLOTS_AVAILABLE');
        debugPrint('[BookingProvider] Response timestamp: ${DateTime.now().toIso8601String()}');
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _isReservingSlot = false;
      
      // Log detailed error information
      debugPrint('[BookingProvider] ERROR: Exception during slot reservation');
      debugPrint('[BookingProvider] Floor: ${_selectedFloor?.floorName}');
      debugPrint('[BookingProvider] Error type: ${e.runtimeType}');
      debugPrint('[BookingProvider] Error message: $e');
      debugPrint('[BookingProvider] Stack trace: $stackTrace');
      debugPrint('[BookingProvider] Timestamp: ${DateTime.now().toIso8601String()}');
      
      // Provide user-friendly error messages based on error type
      if (e.toString().contains('NO_SLOTS_AVAILABLE') || 
          e.toString().contains('no slots') ||
          e.toString().contains('tidak ada slot') ||
          e.toString().contains('404') ||
          e.toString().contains('409')) {
        _errorMessage = 'NO_SLOTS_AVAILABLE:${_selectedFloor!.floorName}';
        debugPrint('[BookingProvider] ERROR_CODE: NO_SLOTS_AVAILABLE');
      } else if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        _errorMessage = 'RESERVATION_ERROR:Sesi Anda telah berakhir. Silakan login kembali.';
        debugPrint('[BookingProvider] ERROR_CODE: AUTH_ERROR');
      } else if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        _errorMessage = 'RESERVATION_TIMEOUT:Permintaan timeout. Silakan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: TIMEOUT_ERROR');
      } else if (e.toString().contains('Network') || 
                 e.toString().contains('network') ||
                 e.toString().contains('SocketException')) {
        _errorMessage = 'RESERVATION_ERROR:Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: NETWORK_ERROR');
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'RESERVATION_ERROR:Format data tidak valid. Silakan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: FORMAT_ERROR');
      } else if (e.toString().contains('500') || e.toString().contains('Server Error')) {
        _errorMessage = 'RESERVATION_ERROR:Terjadi kesalahan server. Silakan coba beberapa saat lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: SERVER_ERROR');
      } else {
        _errorMessage = 'RESERVATION_ERROR:Gagal mereservasi slot. Silakan coba lagi.';
        debugPrint('[BookingProvider] ERROR_CODE: UNKNOWN_ERROR');
      }

      notifyListeners();
      return false;
    }
  }
  
  /// Retry slot reservation after error
  ///
  /// Convenience method for retry button in UI.
  /// Clears previous error and attempts reservation again.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API call
  /// - [userId]: User ID for reservation
  ///
  /// Returns: Future<bool> indicating success or failure
  ///
  /// Requirements: 15.1-15.10
  Future<bool> retryReserveSlot({
    required String token,
    required String userId,
  }) async {
    debugPrint('[BookingProvider] Retrying slot reservation');
    
    // Clear previous error
    _errorMessage = null;
    notifyListeners();
    
    // Attempt reservation again
    return await reserveRandomSlot(
      token: token,
      userId: userId,
    );
  }
  
  /// Get alternative floors with available slots
  ///
  /// Returns list of floors that have available slots, excluding the current floor.
  /// Sorted by availability (most available first).
  ///
  /// Requirements: 15.1-15.10
  List<ParkingFloorModel> getAlternativeFloors() {
    if (_selectedFloor == null) {
      return _floors.where((floor) => floor.hasAvailableSlots).toList()
        ..sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
    }
    
    return _floors
        .where((floor) => 
            floor.idFloor != _selectedFloor!.idFloor && 
            floor.hasAvailableSlots)
        .toList()
      ..sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
  }
  
  /// Get user-friendly error message from error code
  ///
  /// Parses error message codes and returns appropriate user-facing text.
  /// Supports special error codes for reservation failures and timeouts.
  ///
  /// Returns: Map with 'title', 'message', and optional 'floorName' keys
  ///
  /// Requirements: 15.1-15.10
  Map<String, String> getReservationErrorDetails() {
    if (_errorMessage == null) {
      return {
        'title': 'Error',
        'message': 'Terjadi kesalahan yang tidak diketahui',
      };
    }
    
    // Parse error message format: "ERROR_CODE:details"
    final parts = _errorMessage!.split(':');
    final errorCode = parts.isNotEmpty ? parts[0] : '';
    final details = parts.length > 1 ? parts.sublist(1).join(':') : '';
    
    switch (errorCode) {
      case 'NO_SLOTS_AVAILABLE':
        return {
          'title': 'Slot Tidak Tersedia',
          'message': 'Semua slot di $details sudah terisi. Silakan pilih lantai lain atau coba lagi nanti.',
          'floorName': details,
        };
        
      case 'RESERVATION_TIMEOUT':
        final floorName = details.isNotEmpty ? details : 'lantai ini';
        return {
          'title': 'Waktu Reservasi Habis',
          'message': 'Reservasi slot Anda telah berakhir. Silakan lakukan reservasi ulang di $floorName.',
          'floorName': details,
        };
        
      case 'RESERVATION_EXPIRED':
        return {
          'title': 'Reservasi Kadaluarsa',
          'message': 'Waktu reservasi telah habis. Silakan reservasi ulang untuk melanjutkan booking.',
        };
        
      case 'RESERVATION_ERROR':
        return {
          'title': 'Gagal Mereservasi Slot',
          'message': details.isNotEmpty ? details : 'Gagal mereservasi slot. Silakan coba lagi.',
        };
        
      case 'AUTH_ERROR':
        return {
          'title': 'Sesi Berakhir',
          'message': 'Sesi Anda telah berakhir. Silakan login kembali untuk melanjutkan.',
        };
        
      case 'TIMEOUT_ERROR':
        return {
          'title': 'Koneksi Timeout',
          'message': 'Permintaan timeout. Periksa koneksi internet Anda dan coba lagi.',
        };
        
      case 'NETWORK_ERROR':
        return {
          'title': 'Koneksi Bermasalah',
          'message': 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.',
        };
        
      case 'SERVER_ERROR':
        return {
          'title': 'Kesalahan Server',
          'message': 'Terjadi kesalahan server. Silakan coba beberapa saat lagi.',
        };
        
      default:
        return {
          'title': 'Terjadi Kesalahan',
          'message': _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
        };
    }
  }
  
  /// Check if current error is a reservation error
  ///
  /// Returns true if error is related to slot reservation
  ///
  /// Requirements: 15.1-15.10
  bool get hasReservationError {
    if (_errorMessage == null) return false;
    
    return _errorMessage!.startsWith('NO_SLOTS_AVAILABLE:') ||
           _errorMessage!.startsWith('RESERVATION_TIMEOUT:') ||
           _errorMessage!.startsWith('RESERVATION_EXPIRED:') ||
           _errorMessage!.startsWith('RESERVATION_ERROR:');
  }
  
  /// Check if current error is a timeout error
  ///
  /// Returns true if error is due to reservation timeout
  ///
  /// Requirements: 15.1-15.10
  bool get isReservationTimeout {
    if (_errorMessage == null) return false;
    return _errorMessage!.startsWith('RESERVATION_TIMEOUT:') ||
           _errorMessage!.startsWith('RESERVATION_EXPIRED:');
  }
  
  /// Check if current error is due to no slots available
  ///
  /// Returns true if error is because all slots are occupied
  ///
  /// Requirements: 15.1-15.10
  bool get isNoSlotsAvailable {
    if (_errorMessage == null) return false;
    return _errorMessage!.startsWith('NO_SLOTS_AVAILABLE:');
  }

  /// Clear slot reservation
  ///
  /// Clears the reserved slot and stops the reservation timer.
  /// Called when user changes floor or reservation expires.
  ///
  /// Requirements: 12.1-12.11
  void clearReservation() {
    debugPrint('[BookingProvider] Clearing slot reservation');

    _reservedSlot = null;
    
    // Stop reservation timer
    stopReservationTimer();

    notifyListeners();
  }

  /// Start automatic slot refresh timer
  ///
  /// Refreshes slot visualization every 15 seconds while floor is selected.
  /// Stops automatically when floor is deselected or page is disposed.
  ///
  /// Parameters:
  /// - [token]: Authentication token for API calls
  ///
  /// Requirements: 11.10, 14.1-14.10
  void startSlotRefreshTimer({required String token}) {
    // Stop any existing timer
    stopSlotRefreshTimer();

    if (_selectedFloor == null) {
      debugPrint('[BookingProvider] Cannot start slot refresh - no floor selected');
      return;
    }

    debugPrint('[BookingProvider] Starting slot refresh timer (15s interval)');

    // Set up periodic timer (15 seconds)
    _slotRefreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (timer) {
        // Only refresh if floor is still selected
        if (_selectedFloor != null) {
          debugPrint('[BookingProvider] Auto-refreshing slot visualization');
          fetchSlotsForVisualization(token: token);
        } else {
          debugPrint('[BookingProvider] Stopping slot refresh - floor deselected');
          stopSlotRefreshTimer();
        }
      },
    );
  }

  /// Stop automatic slot refresh timer
  ///
  /// Requirements: 11.10, 14.1-14.10
  void stopSlotRefreshTimer() {
    if (_slotRefreshTimer != null) {
      debugPrint('[BookingProvider] Stopping slot refresh timer');
      _slotRefreshTimer?.cancel();
      _slotRefreshTimer = null;
    }
  }

  /// Start reservation timeout timer
  ///
  /// Monitors reservation expiration and auto-clears when timeout reached.
  /// Timer duration is based on reservation's expiresAt timestamp.
  /// Provides clear error message when timeout occurs.
  ///
  /// Requirements: 11.10, 14.1-14.10, 15.1-15.10
  void startReservationTimer() {
    // Stop any existing timer
    stopReservationTimer();

    if (_reservedSlot == null) {
      debugPrint('[BookingProvider] Cannot start reservation timer - no reservation');
      return;
    }

    final timeRemaining = _reservedSlot!.timeRemaining;
    
    if (timeRemaining.isNegative) {
      debugPrint('[BookingProvider] ERROR: Reservation already expired');
      debugPrint('[BookingProvider] Expired at: ${_reservedSlot!.expiresAt}');
      debugPrint('[BookingProvider] Current time: ${DateTime.now()}');
      _errorMessage = 'RESERVATION_EXPIRED:Waktu reservasi telah habis. Silakan reservasi ulang.';
      clearReservation();
      return;
    }

    debugPrint('[BookingProvider] Starting reservation timer');
    debugPrint('[BookingProvider] Time remaining: ${timeRemaining.inMinutes}m ${timeRemaining.inSeconds % 60}s');
    debugPrint('[BookingProvider] Expires at: ${_reservedSlot!.expiresAt}');

    // Set up timer to clear reservation when it expires
    _reservationTimer = Timer(timeRemaining, () {
      debugPrint('[BookingProvider] TIMEOUT: Reservation timeout reached');
      debugPrint('[BookingProvider] Slot: ${_reservedSlot?.slotCode}');
      debugPrint('[BookingProvider] Floor: ${_reservedSlot?.floorName}');
      debugPrint('[BookingProvider] Expired at: ${_reservedSlot?.expiresAt}');
      debugPrint('[BookingProvider] Current time: ${DateTime.now()}');
      debugPrint('[BookingProvider] ERROR_CODE: RESERVATION_TIMEOUT');
      
      // Set error message with special code for UI handling
      _errorMessage = 'RESERVATION_TIMEOUT:${_reservedSlot?.floorName ?? ""}';
      
      // Clear the expired reservation
      clearReservation();
      
      notifyListeners();
    });
  }

  /// Stop reservation timeout timer
  ///
  /// Requirements: 11.10, 14.1-14.10
  void stopReservationTimer() {
    if (_reservationTimer != null) {
      debugPrint('[BookingProvider] Stopping reservation timer');
      _reservationTimer?.cancel();
      _reservationTimer = null;
    }
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

    // Clear slot reservation state
    _floors = [];
    _selectedFloor = null;
    _slotsVisualization = [];
    _reservedSlot = null;
    _isLoadingFloors = false;
    _isLoadingSlots = false;
    _isReservingSlot = false;

    // Stop all timers
    _stopAvailabilityTimer();
    stopSlotRefreshTimer();
    stopReservationTimer();

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
    
    // Stop all timers
    _stopAvailabilityTimer();
    _cancelDebounceTimers();
    stopSlotRefreshTimer();
    stopReservationTimer();
    
    // Cancel pending API calls
    _bookingService.cancelPendingRequests();
    
    // Clear large objects
    _selectedMall = null;
    _selectedVehicle = null;
    _costBreakdown = null;
    _createdBooking = null;
    _floors = [];
    _selectedFloor = null;
    _slotsVisualization = [];
    _reservedSlot = null;
    
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
