import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../data/models/active_parking_model.dart';
import '../../data/models/timer_state.dart';
import '../../data/services/parking_service.dart';

/// Provider for managing active parking state and real-time updates
/// Optimized with ValueNotifier for timer updates and app lifecycle handling
class ActiveParkingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ParkingService _parkingService;
  
  // State
  ActiveParkingModel? _activeParking;
  TimerState _timerState = TimerState.initial();
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  int _consecutiveErrors = 0;
  
  // Timers
  Timer? _updateTimer;
  Timer? _refreshTimer;
  
  // Lifecycle state
  bool _isAppInBackground = false;
  DateTime? _backgroundTime;
  
  // Getters
  ActiveParkingModel? get activeParking => _activeParking;
  TimerState get timerState => _timerState;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveParking => _activeParking != null;
  bool get isEmpty => _activeParking == null && !_isLoading;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get hasRecentSync => _lastSyncTime != null && 
      DateTime.now().difference(_lastSyncTime!).inSeconds < 60;

  ActiveParkingProvider({ParkingService? parkingService})
      : _parkingService = parkingService ?? ParkingService() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App returning to foreground
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        // App being terminated
        _stopTimers();
        break;
      case AppLifecycleState.hidden:
        // App hidden but still running
        break;
    }
  }

  void _handleAppPaused() {
    _isAppInBackground = true;
    _backgroundTime = DateTime.now();
    
    // Stop update timer to save battery
    _stopUpdateTimer();
    
    // Keep refresh timer running but at lower frequency
    // This ensures data stays relatively fresh
    debugPrint('[ActiveParkingProvider] App paused, reducing timer frequency');
  }

  void _handleAppResumed() {
    _isAppInBackground = false;
    
    if (_backgroundTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundTime!);
      debugPrint('[ActiveParkingProvider] App resumed after ${backgroundDuration.inSeconds}s');
      
      // If app was in background for more than 30 seconds, refresh data
      if (backgroundDuration.inSeconds > 30 && _activeParking != null) {
        debugPrint('[ActiveParkingProvider] Refreshing data after background period');
        // Trigger background refresh without showing loading state
        _refreshInBackground(''); // Token should be passed from context
      }
    }
    
    _backgroundTime = null;
    
    // Restart update timer
    if (_activeParking != null) {
      _startUpdateTimer();
    }
  }

  /// Fetch active parking data from API
  Future<void> fetchActiveParking({String? token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ActiveParkingProvider] Fetching active parking data...');
      
      final parking = await _parkingService.getActiveParkingWithRetry(
        token: token ?? '',
        maxRetries: 3,
      );

      _activeParking = parking;
      _lastSyncTime = DateTime.now();
      _consecutiveErrors = 0;
      
      if (parking != null) {
        debugPrint('[ActiveParkingProvider] Active parking found: ${parking.idTransaksi}');
        
        // Validate critical fields
        if (!_validateParkingData(parking)) {
          debugPrint('[ActiveParkingProvider] Warning: Some parking data fields are missing');
        }
        
        // Check for booking expiration
        if (parking.isPenaltyApplicable()) {
          debugPrint('[ActiveParkingProvider] Warning: Booking time exceeded, penalty applicable');
        }
        
        // Initialize timer state
        _updateTimerState();
        
        // Start timers
        _startUpdateTimer();
        _startRefreshTimer(token ?? '');
      } else {
        debugPrint('[ActiveParkingProvider] No active parking found');
        // No active parking, stop timers
        _stopTimers();
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _consecutiveErrors++;
      _isLoading = false;
      
      // Provide user-friendly error messages
      String userMessage = _getUserFriendlyError(e.toString());
      _errorMessage = userMessage;
      
      debugPrint('[ActiveParkingProvider] Error fetching active parking (attempt $_consecutiveErrors): $e');
      
      // Only clear active parking if we have multiple consecutive errors
      if (_consecutiveErrors >= 3) {
        _activeParking = null;
        _stopTimers();
        debugPrint('[ActiveParkingProvider] Cleared active parking after $_consecutiveErrors consecutive errors');
      }
      
      notifyListeners();
    }
  }

  /// Validate parking data for missing or null fields
  bool _validateParkingData(ActiveParkingModel parking) {
    bool isValid = true;
    
    if (parking.qrCode.isEmpty) {
      debugPrint('[ActiveParkingProvider] Warning: QR code is missing');
      isValid = false;
    }
    
    if (parking.namaMall.isEmpty) {
      debugPrint('[ActiveParkingProvider] Warning: Mall name is missing');
      isValid = false;
    }
    
    if (parking.kodeSlot.isEmpty) {
      debugPrint('[ActiveParkingProvider] Warning: Slot code is missing');
      isValid = false;
    }
    
    if (parking.platNomor.isEmpty) {
      debugPrint('[ActiveParkingProvider] Warning: Vehicle plate number is missing');
      isValid = false;
    }
    
    if (parking.biayaPerJam <= 0) {
      debugPrint('[ActiveParkingProvider] Warning: Invalid parking rate');
      isValid = false;
    }
    
    return isValid;
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

  /// Start 1-second interval timer for real-time updates
  /// Optimized to only run when app is in foreground
  void _startUpdateTimer() {
    _stopUpdateTimer();
    
    // Don't start timer if app is in background
    if (_isAppInBackground) {
      debugPrint('[ActiveParkingProvider] Skipping timer start - app in background');
      return;
    }
    
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeParking != null && !_isAppInBackground) {
        _updateTimerState();
        notifyListeners();
      } else if (_isAppInBackground) {
        // Pause timer updates when in background
        timer.cancel();
      }
    });
  }

  /// Stop the update timer
  void _stopUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Start 30-second periodic background refresh
  void _startRefreshTimer(String token) {
    _stopRefreshTimer();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_activeParking != null) {
        await _refreshInBackground(token);
      }
    });
  }

  /// Stop the refresh timer
  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Stop all timers
  void _stopTimers() {
    _stopUpdateTimer();
    _stopRefreshTimer();
  }

  /// Refresh data in background without showing loading state
  Future<void> _refreshInBackground(String token) async {
    try {
      debugPrint('[ActiveParkingProvider] Background refresh started');
      
      final parking = await _parkingService.getActiveParking(token: token);
      
      if (parking != null) {
        // Check if booking has expired during session
        final wasNotExpired = _activeParking?.isPenaltyApplicable() == false;
        final isNowExpired = parking.isPenaltyApplicable();
        
        if (wasNotExpired && isNowExpired) {
          debugPrint('[ActiveParkingProvider] Booking expired during session - penalty now applicable');
        }
        
        _activeParking = parking;
        _lastSyncTime = DateTime.now();
        _consecutiveErrors = 0;
        _updateTimerState();
        
        debugPrint('[ActiveParkingProvider] Background refresh successful');
        notifyListeners();
      } else {
        // Parking session ended
        debugPrint('[ActiveParkingProvider] Parking session ended - clearing data');
        _activeParking = null;
        _timerState = TimerState.initial();
        _stopTimers();
        notifyListeners();
      }
    } catch (e) {
      _consecutiveErrors++;
      // Silent fail for background refresh
      // Don't update error state to avoid disrupting UI
      debugPrint('[ActiveParkingProvider] Background refresh failed (attempt $_consecutiveErrors): $e');
      
      // If too many consecutive errors, stop trying
      if (_consecutiveErrors >= 5) {
        debugPrint('[ActiveParkingProvider] Too many consecutive errors, stopping background refresh');
        _stopRefreshTimer();
      }
    }
  }

  /// Update timer state with current calculations
  void _updateTimerState() {
    if (_activeParking == null) {
      _timerState = TimerState.initial();
      return;
    }

    try {
      final elapsed = _activeParking!.getElapsedDuration();
      final remaining = _activeParking!.getRemainingDuration();
      final isOvertime = _activeParking!.isPenaltyApplicable();
      final currentCost = _activeParking!.calculateCurrentCost();
      
      // Calculate penalty if applicable
      double? penaltyAmount;
      if (isOvertime && _activeParking!.penalty != null) {
        penaltyAmount = _activeParking!.penalty;
      } else if (isOvertime && _activeParking!.waktuSelesaiEstimas != null) {
        // Calculate penalty based on overtime duration
        // Assuming penalty is same rate as biayaPerJam for overtime hours
        final overtimeDuration = DateTime.now().difference(
          _activeParking!.waktuSelesaiEstimas!,
        );
        final overtimeHours = (overtimeDuration.inMinutes / 60.0).ceil();
        penaltyAmount = overtimeHours * _activeParking!.biayaPerJam;
      }

      // Calculate progress for circular animation
      final progress = TimerState.calculateProgress(
        elapsed: elapsed,
        remaining: remaining,
        endTime: _activeParking!.waktuSelesaiEstimas,
        startTime: _activeParking!.waktuMasuk,
      );

      _timerState = TimerState(
        elapsed: elapsed,
        remaining: remaining,
        progress: progress,
        isOvertime: isOvertime,
        currentCost: currentCost,
        penaltyAmount: penaltyAmount,
      );
    } catch (e) {
      debugPrint('[ActiveParkingProvider] Error updating timer state: $e');
      // Keep previous state on error
    }
  }

  /// Manually refresh active parking data
  Future<void> refresh({String? token}) async {
    debugPrint('[ActiveParkingProvider] Manual refresh triggered');
    await fetchActiveParking(token: token);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _consecutiveErrors = 0;
    notifyListeners();
  }

  /// Clear all data and stop timers
  void clear() {
    debugPrint('[ActiveParkingProvider] Clearing all data');
    _activeParking = null;
    _timerState = TimerState.initial();
    _isLoading = false;
    _errorMessage = null;
    _lastSyncTime = null;
    _consecutiveErrors = 0;
    _stopTimers();
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[ActiveParkingProvider] Disposing provider');
    WidgetsBinding.instance.removeObserver(this);
    _stopTimers();
    super.dispose();
  }

  /// Save timer state to prevent reset on rebuild
  Map<String, dynamic> saveState() {
    return {
      'activeParking': _activeParking?.toJson(),
      'timerState': {
        'elapsed': _timerState.elapsed.inSeconds,
        'remaining': _timerState.remaining?.inSeconds,
        'progress': _timerState.progress,
        'isOvertime': _timerState.isOvertime,
        'currentCost': _timerState.currentCost,
        'penaltyAmount': _timerState.penaltyAmount,
      },
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
    };
  }

  /// Restore timer state from saved data
  void restoreState(Map<String, dynamic> state) {
    try {
      if (state['activeParking'] != null) {
        _activeParking = ActiveParkingModel.fromJson(state['activeParking']);
      }
      
      if (state['timerState'] != null) {
        final timerData = state['timerState'];
        _timerState = TimerState(
          elapsed: Duration(seconds: timerData['elapsed'] ?? 0),
          remaining: timerData['remaining'] != null 
              ? Duration(seconds: timerData['remaining']) 
              : null,
          progress: timerData['progress'] ?? 0.0,
          isOvertime: timerData['isOvertime'] ?? false,
          currentCost: timerData['currentCost'] ?? 0.0,
          penaltyAmount: timerData['penaltyAmount'],
        );
      }
      
      if (state['lastSyncTime'] != null) {
        _lastSyncTime = DateTime.parse(state['lastSyncTime']);
      }
      
      // Restart timers if we have active parking
      if (_activeParking != null) {
        _startUpdateTimer();
        _startRefreshTimer(''); // Token should be passed from context
      }
      
      notifyListeners();
      debugPrint('[ActiveParkingProvider] State restored successfully');
    } catch (e) {
      debugPrint('[ActiveParkingProvider] Error restoring state: $e');
    }
  }
}
